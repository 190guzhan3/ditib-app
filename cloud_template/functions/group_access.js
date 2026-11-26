// Reine Hilfsfunktionen fuer Gruppen, Rollen und Einladungen.
// Bewusst ohne Firebase-Abhaengigkeiten, damit sie direkt testbar sind
// (node --test).

const INVITE_TOKEN_PATTERN = /^[A-Za-z0-9]{22,64}$/;
const ROLES = ["owner", "admin", "member"];

function toMillis(value) {
  if (!value) return null;
  if (typeof value.toMillis === "function") return value.toMillis();
  if (value instanceof Date) return value.getTime();
  if (typeof value === "string") {
    const parsed = Date.parse(value);
    return Number.isNaN(parsed) ? null : parsed;
  }
  return null;
}

function isAdminRole(role) {
  return role === "owner" || role === "admin";
}

/**
 * Entscheidet, ob ein Nutzer eine Einladung einloesen darf.
 * "join" bedeutet: Mitglied anlegen. Sonst ein Status fuer die App.
 */
function evaluateInviteRedemption({invite, group, uid, isMember, nowMillis}) {
  if (!invite || !group) return "invalid";
  if (isMember) return "alreadyMember";
  if (invite.revoked === true) return "expired";
  const expiresAt = toMillis(invite.expiresAt);
  if (expiresAt === null || expiresAt <= nowMillis) return "expired";
  const maxUses = Number.isInteger(invite.maxUses) ? invite.maxUses : null;
  const useCount = Number.isInteger(invite.useCount) ? invite.useCount : 0;
  if (maxUses !== null && useCount >= maxUses) return "expired";
  const blocked = Array.isArray(group.blockedUserIds) ? group.blockedUserIds : [];
  if (blocked.includes(uid)) return "blocked";
  return "join";
}

/** Rolle aus einer Einladung; "owner" ist per Einladung nie moeglich. */
function inviteRole(invite) {
  return invite?.role === "admin" ? "admin" : "member";
}

/**
 * Darf callerRole die Rolle von target (aktuell fromRole) auf toRole setzen?
 * Nur der Inhaber ernennt oder entfernt Admins; die Inhaberschaft selbst
 * wechselt hier nicht. Spiegelt GroupPermissions.canChangeRole im Client.
 */
function evaluateRoleChange({callerUid, callerRole, targetUid, fromRole, toRole}) {
  if (!ROLES.includes(toRole) || toRole === "owner") return "invalidRole";
  if (callerRole !== "owner") return "notOwner";
  if (callerUid === targetUid) return "self";
  if (!fromRole) return "notMember";
  if (fromRole === "owner") return "targetIsOwner";
  if (fromRole === toRole) return "unchanged";
  return "ok";
}

module.exports = {
  INVITE_TOKEN_PATTERN,
  ROLES,
  evaluateInviteRedemption,
  evaluateRoleChange,
  inviteRole,
  isAdminRole,
  toMillis,
};
