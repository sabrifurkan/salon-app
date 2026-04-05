class CampaignModel {
  final String? id;
  final String? userId;
  final String message;
  final int recipientCount;
  final List<String> recipientIds;
  final DateTime? sentAt;
  final String status; // 'draft', 'sent', 'failed'
  final DateTime? createdAt;

  CampaignModel({
    this.id,
    this.userId,
    required this.message,
    this.recipientCount = 0,
    this.recipientIds = const [],
    this.sentAt,
    this.status = 'sent',
    this.createdAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      message: json['message'] as String? ?? '',
      recipientCount: (json['recipient_count'] as num?)?.toInt() ?? 0,
      recipientIds: (json['recipient_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString())
          : null,
      status: json['status'] as String? ?? 'sent',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'message': message,
      'recipient_count': recipientCount,
      'recipient_ids': recipientIds,
      'status': status,
    };
  }
}
