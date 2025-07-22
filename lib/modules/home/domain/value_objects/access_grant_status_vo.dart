enum AccessGrantStatusVO {
  pending,
  granted,
  rejected;

  static AccessGrantStatusVO fromJson(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'pending':
          return AccessGrantStatusVO.pending;
        case 'granted':
          return AccessGrantStatusVO.granted;
        case 'rejected':
          return AccessGrantStatusVO.rejected;
        default:
          throw Exception('Unknown status: $value');
      }
    } else if (value is int) {
      return AccessGrantStatusVO.values[value];
    }
    throw Exception('Invalid status type: $value');
  }

  String toJson() => name;
}
