class ServiceModel {
  final String? id;
  final String? userId;
  final String name;
  final int defaultDurationMin;
  final double defaultPrice;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    this.id,
    this.userId,
    required this.name,
    this.defaultDurationMin = 30,
    this.defaultPrice = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      defaultDurationMin: (json['default_duration_min'] as num?)?.toInt() ?? 30,
      defaultPrice: (json['default_price'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'default_duration_min': defaultDurationMin,
      'default_price': defaultPrice,
      'is_active': isActive,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? defaultDurationMin,
    double? defaultPrice,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      defaultDurationMin: defaultDurationMin ?? this.defaultDurationMin,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
