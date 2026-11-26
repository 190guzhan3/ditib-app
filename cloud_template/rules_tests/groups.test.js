// Firestore-Regeln für Gruppen, Mitglieder, Einladungen und Push-Tokens.
// Ausführen: npm install && npm test (startet den Firestore-Emulator).
import { after, before, beforeEach, test } from "node:test";
import { readFileSync } from "node:fs";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  Timestamp,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  deleteDoc,
  writeBatch,
} from "firebase/firestore";

let env;
const TOKEN = "AbCdEfGhIjKlMnOpQrStUvWxYz012345";

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-app-template",
    firestore: { rules: readFileSync(new URL("../firestore.rules", import.meta.url), "utf8") },
  });
});
after(() => env.cleanup());

// Gruppe g1: owner o, admin a, member m. Fremder: x.
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "groups/g1"), { name: "Gruppe", ownerId: "o" });
    for (const [uid, role] of [["o", "owner"], ["a", "admin"], ["m", "member"]]) {
      await setDoc(doc(db, `groups/g1/members/${uid}`), { uid, role });
    }
  });
});

const db = (uid) => env.authenticatedContext(uid).firestore();

function invite(uid, extra = {}) {
  return {
    token: TOKEN,
    groupId: "g1",
    groupName: "Gruppe",
    createdBy: uid,
    createdAt: serverTimestamp(),
    expiresAt: Timestamp.fromMillis(Date.now() + 7 * 864e5),
    role: "member",
    maxUses: null,
    useCount: 0,
    revoked: false,
    ...extra,
  };
}

test("Gruppe lesen nur als Mitglied", async () => {
  await assertSucceeds(getDoc(doc(db("m"), "groups/g1")));
  await assertFails(getDoc(doc(db("x"), "groups/g1")));
});

test("Gruppe anlegen nur zusammen mit eigenem Inhaber-Eintrag", async () => {
  const x = db("x");
  const batch = writeBatch(x);
  batch.set(doc(x, "groups/g2"), { name: "Neu", ownerId: "x" });
  batch.set(doc(x, "groups/g2/members/x"), { uid: "x", role: "owner" });
  await assertSucceeds(batch.commit());
  await assertFails(setDoc(doc(db("x"), "groups/g3"), { name: "Ohne", ownerId: "x" }));
  // Sich in eine bestehende Gruppe als Inhaber eintragen geht nicht.
  await assertFails(setDoc(doc(db("x"), "groups/g1/members/x"), { uid: "x", role: "owner" }));
});

test("Rollen ändert der Client nie selbst", async () => {
  await assertFails(updateDoc(doc(db("o"), "groups/g1/members/m"), { role: "admin" }));
  await assertFails(updateDoc(doc(db("m"), "groups/g1/members/m"), { role: "owner" }));
});

test("Austreten und Entfernen", async () => {
  await assertFails(deleteDoc(doc(db("m"), "groups/g1/members/a")));
  await assertSucceeds(deleteDoc(doc(db("a"), "groups/g1/members/m")));
  await assertFails(deleteDoc(doc(db("o"), "groups/g1/members/o")));
});

test("Gruppe bearbeiten als Admin, löschen nur als Inhaber", async () => {
  await assertSucceeds(updateDoc(doc(db("a"), "groups/g1"), { name: "Neu" }));
  await assertFails(updateDoc(doc(db("m"), "groups/g1"), { name: "Neu" }));
  await assertFails(updateDoc(doc(db("a"), "groups/g1"), { ownerId: "a" }));
  await assertFails(deleteDoc(doc(db("a"), "groups/g1")));
  await assertSucceeds(deleteDoc(doc(db("o"), "groups/g1")));
});

test("Einladungen: Admins für Mitglieder, nur Inhaber für Admins", async () => {
  await assertFails(setDoc(doc(db("m"), `groupInvites/${TOKEN}`), invite("m")));
  await assertFails(setDoc(doc(db("a"), `groupInvites/${TOKEN}`), invite("a", { role: "admin" })));
  await assertFails(setDoc(doc(db("a"), `groupInvites/${TOKEN}`), invite("a", { useCount: 5 })));
  await assertFails(setDoc(doc(db("a"), `groupInvites/${TOKEN}`), invite("a", { role: "owner" })));
  await assertSucceeds(setDoc(doc(db("o"), `groupInvites/${TOKEN}`), invite("o", { role: "admin", maxUses: 1 })));
});

test("Einladungen: lesen mit Token, nur widerrufen, nie hochzählen", async () => {
  await assertSucceeds(setDoc(doc(db("a"), `groupInvites/${TOKEN}`), invite("a")));
  await assertSucceeds(getDoc(doc(db("x"), `groupInvites/${TOKEN}`)));
  await assertFails(updateDoc(doc(db("x"), `groupInvites/${TOKEN}`), { useCount: 1 }));
  await assertFails(updateDoc(doc(db("a"), `groupInvites/${TOKEN}`), { useCount: 1 }));
  await assertSucceeds(updateDoc(doc(db("a"), `groupInvites/${TOKEN}`), { revoked: true }));
});

test("Push-Tokens nur für sich selbst", async () => {
  const data = { token: "t1", platform: "ios", locale: "de", utcOffsetMinutes: 60, updatedAt: serverTimestamp() };
  await assertSucceeds(setDoc(doc(db("m"), "users/m/fcmTokens/t1"), data));
  await assertFails(setDoc(doc(db("x"), "users/m/fcmTokens/t1"), data));
  await assertFails(getDoc(doc(db("x"), "users/m/fcmTokens/t1")));
});
