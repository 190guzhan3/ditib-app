import 'package:flutter_test/flutter_test.dart';
import 'package:moschee_app/cloud/geo.dart';
import 'package:moschee_app/cloud/deep_link_service.dart';
import 'package:moschee_app/cloud/groups/group_invite.dart';
import 'package:moschee_app/cloud/groups/group_roles.dart';

void main() {
  test('Rollen und Rechte', () {
    const owner = GroupPermissions(GroupRole.owner);
    const admin = GroupPermissions(GroupRole.admin);
    expect(admin.canManageMembers, isTrue);
    expect(admin.canManageRoles, isFalse);
    expect(GroupPermissions.none.isMember, isFalse);
    expect(
      owner.canChangeRole(
        targetIsSelf: false,
        from: GroupRole.member,
        to: GroupRole.admin,
      ),
      isTrue,
    );
    expect(
      owner.canChangeRole(
        targetIsSelf: true,
        from: GroupRole.owner,
        to: GroupRole.admin,
      ),
      isFalse,
    );
    expect(GroupRole.parse('admin'), GroupRole.admin);
    expect(GroupRole.parse('x'), isNull);
  });

  test('Einladungslinks', () {
    final token = GroupInviteLinks.generateToken();
    expect(GroupInviteLinks.tokenFrom(token), token);
    expect(
      GroupInviteLinks.tokenFrom(GroupInviteLinks.linkFor(token).toString()),
      token,
    );
    expect(GroupInviteLinks.tokenFrom('moscheeapp://invite/$token'), token);
    expect(
      GroupInviteLinks.tokenFrom('https://evil.example/invite/$token'),
      isNull,
    );
    expect(
      AppLink.parse(token),
      isNull,
      reason: 'nackter Token kommt nie vom System',
    );
    expect(AppLink.parse('moscheeapp://invite/$token')?.token, token);
    final invite = GroupInvite(
      token: token,
      groupId: 'g',
      groupName: 'G',
      createdBy: 'u',
      createdAt: DateTime(2026),
      expiresAt: DateTime(2026, 2),
      maxUses: 1,
      useCount: 1,
    );
    expect(invite.isActiveAt(DateTime(2026, 1, 15)), isFalse);
  });

  test('Geo: Umkreis und Abdeckung', () {
    const koeln = GeoPoint2(50.9375, 6.9603);
    const bonn = GeoPoint2(50.7374, 7.0982);
    const berlin = GeoPoint2(52.52, 13.405);
    expect(Geo.distanceKm(koeln, bonn), closeTo(24.5, 1.5));
    expect(withinRadius([berlin, bonn, koeln], (p) => p, koeln, 30), [
      koeln,
      bonn,
    ]);
    expect(
      Geo.decode(Geo.encode(koeln.lat, koeln.lng)).lat,
      closeTo(koeln.lat, 0.001),
    );
    final prefixes = Geo.coveringPrefixes(koeln, 30);
    expect(
      prefixes.any((p) => Geo.encode(bonn.lat, bonn.lng).startsWith(p)),
      isTrue,
    );
  });
}
