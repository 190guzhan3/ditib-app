// Beispiel-Functions. Nur anlegen, was der Client nicht sicher selbst
// erledigen kann (Aufräumen, Zähler, Berechtigungen, Benachrichtigungen).
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { getStorage } = require("firebase-admin/storage");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions/v1");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const {
  INVITE_TOKEN_PATTERN,
  evaluateInviteRedemption,
  evaluateRoleChange,
  inviteRole,
} = require("./group_access");

initializeApp();
const db = getFirestore();

// Beim Löschen eines Kontos alle Daten des Nutzers entfernen (DSGVO),
// auch die Push-Tokens unter users/{uid}/fcmTokens.
exports.cleanupDeletedUser = functions.auth.user().onDelete(async (user) => {
  await db.recursiveDelete(db.collection("users").doc(user.uid));
  await getStorage().bucket().deleteFiles({ prefix: `users/${user.uid}/` });
});

// Muster für eine aufrufbare Function mit Anmelde- und App-Check-Pflicht.
exports.ping = onCall({ enforceAppCheck: true }, (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Anmeldung erforderlich.");
  }
  return { ok: true, uid: request.auth.uid };
});

// ------------------------------------------------------------
// Push
// ------------------------------------------------------------

const UNREGISTERED_TOKEN_ERRORS = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

/**
 * Schickt eine Benachrichtigung an alle Geräte der Nutzer. `texts` ist
 * entweder {title, body} oder eine Funktion (locale) => {title, body}, damit
 * jedes Gerät seine Sprache bekommt. `screen` landet in
 * NotificationService.openScreenRequested. Ungültige Tokens werden
 * entfernt; Fehler beim Versand brechen die auslösende Aktion nie ab.
 */
async function notifyUsers(uids, texts, { screen = "home", excludeUid = null } = {}) {
  try {
    const targets = [...new Set(uids)].filter((uid) => uid && uid !== excludeUid);
    if (targets.length === 0) return;
    const snaps = await Promise.all(
      targets.map((uid) => db.collection("users").doc(uid).collection("fcmTokens").get()),
    );
    const tokenDocs = snaps.flatMap((snap) => snap.docs);
    if (tokenDocs.length === 0) return;
    if (process.env.FUNCTIONS_EMULATOR === "true") {
      // Der Emulator kann keine Push-Nachrichten senden.
      logger.info("Push (Emulator)", { targets, tokenCount: tokenDocs.length });
      return;
    }
    const messages = tokenDocs.map((doc) => ({
      token: doc.id,
      notification: typeof texts === "function" ? texts(doc.data().locale) : texts,
      data: { screen },
      apns: { payload: { aps: { sound: "default" } } },
    }));
    const result = await getMessaging().sendEach(messages);
    await Promise.all(result.responses.map(async (response, index) => {
      if (!response.success && UNREGISTERED_TOKEN_ERRORS.has(response.error?.code)) {
        await tokenDocs[index].ref.delete();
      }
    }));
  } catch (error) {
    logger.error("Benachrichtigung fehlgeschlagen", { error: String(error) });
  }
}

async function adminUids(groupId) {
  const members = await db.collection("groups").doc(groupId).collection("members")
    .where("role", "in", ["owner", "admin"]).get();
  return members.docs.map((doc) => doc.id);
}

// ------------------------------------------------------------
// Gruppen: Einladungen und Rollen
// ------------------------------------------------------------

// Einladung einlösen (oder mit dryRun nur prüfen). Läuft als Function,
// weil sie ein Mitgliedsdokument in einer fremden Gruppe anlegt.
exports.redeemGroupInvite = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Anmeldung erforderlich.");

  const token = typeof request.data?.token === "string" ? request.data.token.trim() : "";
  if (!INVITE_TOKEN_PATTERN.test(token)) return { status: "invalid" };
  const dryRun = request.data?.dryRun === true;

  const inviteRef = db.collection("groupInvites").doc(token);
  let joined = null;
  const result = await db.runTransaction(async (tx) => {
    joined = null;
    const inviteSnap = await tx.get(inviteRef);
    if (!inviteSnap.exists) return { status: "invalid" };
    const invite = inviteSnap.data() || {};
    const groupId = invite.groupId;
    if (typeof groupId !== "string" || groupId.length === 0) return { status: "invalid" };

    const groupRef = db.collection("groups").doc(groupId);
    const memberRef = groupRef.collection("members").doc(uid);
    const [groupSnap, memberSnap] = await Promise.all([tx.get(groupRef), tx.get(memberRef)]);
    const status = evaluateInviteRedemption({
      invite,
      group: groupSnap.exists ? groupSnap.data() : null,
      uid,
      isMember: memberSnap.exists,
      nowMillis: Date.now(),
    });

    if (dryRun) return { status: status === "join" ? "canJoin" : status, groupId };
    if (status !== "join") return { status, groupId };

    const authToken = request.auth.token || {};
    const email = typeof authToken.email === "string" ? authToken.email : null;
    const displayName = typeof authToken.name === "string" && authToken.name.trim() ?
      authToken.name.trim() :
      (email ? email.split("@")[0] : "");
    tx.set(memberRef, {
      uid,
      role: inviteRole(invite),
      displayName,
      joinedAt: FieldValue.serverTimestamp(),
      inviteToken: token,
    });
    tx.update(inviteRef, { useCount: FieldValue.increment(1) });
    joined = { name: displayName, groupName: groupSnap.data()?.name ?? "" };
    return { status: "joined", groupId };
  });

  if (joined && result.status === "joined") {
    await notifyUsers(
      await adminUids(result.groupId),
      (locale) => (locale === "de" ?
        { title: "Neues Mitglied", body: `${joined.name} ist ${joined.groupName} beigetreten.` } :
        { title: "New member", body: `${joined.name} joined ${joined.groupName}.` }),
      { screen: "group", excludeUid: uid },
    );
  }
  return result;
});

// Rolle eines Mitglieds ändern (nur Inhaber). Die Regeln verbieten dem
// Client, das Feld `role` zu schreiben.
exports.setGroupRole = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Anmeldung erforderlich.");
  const { groupId, uid: targetUid, role: toRole } = request.data || {};
  if (typeof groupId !== "string" || typeof targetUid !== "string") {
    throw new HttpsError("invalid-argument", "groupId und uid erforderlich.");
  }

  const members = db.collection("groups").doc(groupId).collection("members");
  await db.runTransaction(async (tx) => {
    const [callerSnap, targetSnap] = await Promise.all([
      tx.get(members.doc(uid)),
      tx.get(members.doc(targetUid)),
    ]);
    const verdict = evaluateRoleChange({
      callerUid: uid,
      callerRole: callerSnap.data()?.role,
      targetUid,
      fromRole: targetSnap.exists ? targetSnap.data()?.role : null,
      toRole,
    });
    if (verdict === "unchanged") return;
    if (verdict !== "ok") throw new HttpsError("permission-denied", verdict);
    tx.update(members.doc(targetUid), { role: toRole });
  });
  return { ok: true };
});
