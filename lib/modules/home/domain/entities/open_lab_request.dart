class OpenLabRequest {
  final int timestamp;
  final String signature;

  OpenLabRequest({required this.timestamp, required this.signature});

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'signature': signature,
  };
}
