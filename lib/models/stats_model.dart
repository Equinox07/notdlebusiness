class StatsDto {
  final int totalCount;
  final Map<String, int>? variatedCounts;

  StatsDto({required this.totalCount, this.variatedCounts});

  factory StatsDto.fromJson(Map<String, dynamic> json) {
    return StatsDto(
      totalCount: json['totalCount'] as int,
      variatedCounts: (json['variatedCounts'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      if (variatedCounts != null) 'variatedCounts': variatedCounts,
    };
  }
}

class CompanyStatsResponse {
  final StatsDto? clients;
  final StatsDto? orders;
  final StatsDto? payments;
  final StatsDto? measurements;
  final StatsDto? projects;
  final StatsDto? fabrics;
  final StatsDto? invoices;

  CompanyStatsResponse({
    this.clients,
    this.orders,
    this.payments,
    this.measurements,
    this.projects,
    this.fabrics,
    this.invoices,
  });

  factory CompanyStatsResponse.fromJson(Map<String, dynamic> json) {
    return CompanyStatsResponse(
      clients:
          json['clients'] != null
              ? StatsDto.fromJson(json['clients'] as Map<String, dynamic>)
              : null,
      orders:
          json['orders'] != null
              ? StatsDto.fromJson(json['orders'] as Map<String, dynamic>)
              : null,
      payments:
          json['payments'] != null
              ? StatsDto.fromJson(json['payments'] as Map<String, dynamic>)
              : null,
      measurements:
          json['measurements'] != null
              ? StatsDto.fromJson(json['measurements'] as Map<String, dynamic>)
              : null,
      projects:
          json['projects'] != null
              ? StatsDto.fromJson(json['projects'] as Map<String, dynamic>)
              : null,
      fabrics:
          json['fabrics'] != null
              ? StatsDto.fromJson(json['fabrics'] as Map<String, dynamic>)
              : null,
      invoices:
          json['invoices'] != null
              ? StatsDto.fromJson(json['invoices'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (clients != null) 'clients': clients!.toJson(),
      if (orders != null) 'orders': orders!.toJson(),
      if (payments != null) 'payments': payments!.toJson(),
      if (measurements != null) 'measurements': measurements!.toJson(),
      if (projects != null) 'projects': projects!.toJson(),
      if (fabrics != null) 'fabrics': fabrics!.toJson(),
      if (invoices != null) 'invoices': invoices!.toJson(),
    };
  }
}
