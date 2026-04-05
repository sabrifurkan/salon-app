class AppointmentModel {
  final String? id;
  final String? userId;
  final String clientId;
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMin;
  final double price;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String room;   // 'oda1' veya 'oda2'
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined fields (from client & service tables)
  final String? clientName;
  final String? serviceName;

  AppointmentModel({
    this.id,
    this.userId,
    required this.clientId,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    this.durationMin = 30,
    this.price = 0,
    this.status = 'scheduled',
    this.room = 'oda1',
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.clientName,
    this.serviceName,
  });

  bool get isCancelled => status == 'cancelled';
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Handle joined data from Supabase
    final clientData = json['clients'];
    final serviceData = json['services'];

    String? clientFullName;
    if (clientData is Map<String, dynamic>) {
      final name = clientData['name'] ?? '';
      final surname = clientData['surname'] ?? '';
      clientFullName = '$name $surname'.trim();
    }

    String? svcName;
    if (serviceData is Map<String, dynamic>) {
      svcName = serviceData['name'] as String?;
    }

    return AppointmentModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      clientId: json['client_id'] as String? ?? '',
      serviceId: json['service_id'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'].toString()),
      endTime: DateTime.parse(json['end_time'].toString()),
      durationMin: (json['duration_min'] as num?)?.toInt() ?? 30,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'scheduled',
      room: json['room'] as String? ?? 'oda1',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      clientName: clientFullName,
      serviceName: svcName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'client_id': clientId,
      'service_id': serviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_min': durationMin,
      'price': price,
      'status': status,
      'room': room,
      'notes': notes,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? serviceId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMin,
    double? price,
    String? status,
    String? room,
    String? notes,
    String? clientName,
    String? serviceName,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      serviceId: serviceId ?? this.serviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMin: durationMin ?? this.durationMin,
      price: price ?? this.price,
      status: status ?? this.status,
      room: room ?? this.room,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      clientName: clientName ?? this.clientName,
      serviceName: serviceName ?? this.serviceName,
    );
  }
}
