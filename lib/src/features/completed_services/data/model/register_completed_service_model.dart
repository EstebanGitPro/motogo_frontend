/// Model for the request body of POST /completed-services.
///
/// Contains the data needed to register a completed service
/// for a motorcycle at a specific branch.
class RegisterCompletedServiceModel {
  final String branchId;
  final String motorcycleId;
  final List<String> serviceIds;
  final double? quotedPrice;
  final double? finalPrice;
  final String? representativeNotes;

  const RegisterCompletedServiceModel({
    required this.branchId,
    required this.motorcycleId,
    required this.serviceIds,
    this.quotedPrice,
    this.finalPrice,
    this.representativeNotes,
  });

  /// Converts the model to a JSON map for the API request body.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'branch_id': branchId,
      'motorcycle_id': motorcycleId,
      'service_ids': serviceIds,
    };
    if (quotedPrice != null) {
      json['quoted_price'] = quotedPrice;
    }
    if (finalPrice != null) {
      json['final_price'] = finalPrice;
    }
    if (representativeNotes != null && representativeNotes!.trim().isNotEmpty) {
      json['representative_notes'] = representativeNotes!.trim();
    }
    return json;
  }
}
