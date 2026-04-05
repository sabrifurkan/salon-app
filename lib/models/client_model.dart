class ClientModel {
  final String? id;
  final String? userId;
  final String name;
  final String surname;
  final String? gender;
  final String? job;
  final List<String> treatmentAreas;
  final double pricePerArea;
  final DateTime? dob;
  final int? age;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Doğum tarihinden yaş hesaplar
  static int? calculateAge(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  ClientModel({
    this.id,
    this.userId,
    required this.name,
    required this.surname,
    this.gender,
    this.job,
    this.treatmentAreas = const [],
    this.pricePerArea = 0,
    this.dob,
    this.age,
    this.phone,
    this.address,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$name $surname';

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      gender: json['gender'] as String?,
      job: json['job'] as String?,
      treatmentAreas: (json['treatment_areas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pricePerArea: (json['price_per_area'] as num?)?.toDouble() ?? 0,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob'].toString()) : null,
      age: json['age'] as int?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
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
      'surname': surname,
      'gender': gender,
      'job': job,
      'treatment_areas': treatmentAreas,
      'price_per_area': pricePerArea,
      'dob': dob?.toIso8601String().split('T').first,
      'age': age ?? calculateAge(dob),
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }

  ClientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? surname,
    String? gender,
    String? job,
    List<String>? treatmentAreas,
    double? pricePerArea,
    DateTime? dob,
    int? age,
    String? phone,
    String? address,
    String? notes,
  }) {
    return ClientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      gender: gender ?? this.gender,
      job: job ?? this.job,
      treatmentAreas: treatmentAreas ?? this.treatmentAreas,
      pricePerArea: pricePerArea ?? this.pricePerArea,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
