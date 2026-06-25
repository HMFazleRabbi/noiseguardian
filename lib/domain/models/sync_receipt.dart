/// DoE portal receipt returned on HTTP 201 (design doc §9.6).
class SyncReceipt {
  const SyncReceipt({
    required this.receiptId,
    required this.serverSignatureEcdsa,
  });

  final String receiptId;
  final String serverSignatureEcdsa;

  factory SyncReceipt.fromJson(Map<String, dynamic> json) {
    return SyncReceipt(
      receiptId: json['receipt_id'] as String,
      serverSignatureEcdsa: (json['server_signature'] ??
              json['server_signature_ecdsa']) as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'receipt_id': receiptId,
        'server_signature': serverSignatureEcdsa,
      };
}
