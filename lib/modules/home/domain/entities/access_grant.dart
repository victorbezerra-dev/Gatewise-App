import '../value_objects/access_grant_status_vo.dart';

class AccessGrant {
  final int id;
  final String authorizedUserId;
  final String? grantedByUserId;
  final int labId;
  final DateTime? grantedAt;
  final DateTime? revokedAt;
  final String reason;
  final AccessGrantStatusVO status;

  AccessGrant({
    required this.id,
    required this.authorizedUserId,
    this.grantedByUserId,
    required this.labId,
    this.grantedAt,
    this.revokedAt,
    required this.reason,
    required this.status,
  });

  factory AccessGrant.fromJson(Map<String, dynamic> json) => AccessGrant(
    id: json['id'] as int,
    authorizedUserId: json['authorizedUserId'] as String,
    grantedByUserId: json['grantedByUserId'] as String?,
    labId: json['labId'] as int,
    grantedAt: json['grantedAt'] != null
        ? DateTime.parse(json['grantedAt'])
        : null,
    revokedAt: json['revokedAt'] != null
        ? DateTime.parse(json['revokedAt'])
        : null,
    reason: json['reason'] ?? '',
    status: AccessGrantStatusVO.fromJson(json['status']),
  );
}
