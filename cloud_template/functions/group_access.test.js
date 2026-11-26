// Ausfuehren: node --test (im Ordner functions/)
const test = require("node:test");
const assert = require("node:assert/strict");
const {
  evaluateInviteRedemption,
  evaluateRoleChange,
  inviteRole,
} = require("./group_access");

const now = Date.parse("2026-01-01T12:00:00Z");
const valid = {expiresAt: "2026-01-02T00:00:00Z", useCount: 0};

test("Einladung: gueltig, abgelaufen, verbraucht, widerrufen, gesperrt", () => {
  const base = {group: {}, uid: "u1", isMember: false, nowMillis: now};
  assert.equal(evaluateInviteRedemption({...base, invite: valid}), "join");
  assert.equal(evaluateInviteRedemption({...base, invite: null}), "invalid");
  assert.equal(
      evaluateInviteRedemption({...base, invite: {...valid, expiresAt: "2025-12-31T00:00:00Z"}}),
      "expired",
  );
  assert.equal(
      evaluateInviteRedemption({...base, invite: {...valid, maxUses: 1, useCount: 1}}),
      "expired",
  );
  assert.equal(evaluateInviteRedemption({...base, invite: {...valid, revoked: true}}), "expired");
  assert.equal(
      evaluateInviteRedemption({...base, invite: valid, group: {blockedUserIds: ["u1"]}}),
      "blocked",
  );
  assert.equal(evaluateInviteRedemption({...base, invite: valid, isMember: true}), "alreadyMember");
});

test("Einladung vergibt nie die Inhaberrolle", () => {
  assert.equal(inviteRole({role: "admin"}), "admin");
  assert.equal(inviteRole({role: "owner"}), "member");
  assert.equal(inviteRole({}), "member");
});

test("Rollenwechsel nur durch den Inhaber, nie fuer sich selbst oder zum Inhaber", () => {
  const base = {callerUid: "o", callerRole: "owner", targetUid: "m", fromRole: "member"};
  assert.equal(evaluateRoleChange({...base, toRole: "admin"}), "ok");
  assert.equal(evaluateRoleChange({...base, callerRole: "admin", toRole: "admin"}), "notOwner");
  assert.equal(evaluateRoleChange({...base, targetUid: "o", toRole: "admin"}), "self");
  assert.equal(evaluateRoleChange({...base, toRole: "owner"}), "invalidRole");
  assert.equal(evaluateRoleChange({...base, fromRole: "owner", toRole: "member"}), "targetIsOwner");
  assert.equal(evaluateRoleChange({...base, fromRole: null, toRole: "admin"}), "notMember");
  assert.equal(evaluateRoleChange({...base, toRole: "member"}), "unchanged");
});
