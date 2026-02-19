/// Request model for submitting a service item rating.
///
/// Sent as JSON body to:
/// `POST /completed-services/{id}/items/{itemId}/rating`
class RateServiceRequest {
  /// Rating value (1–5).
  final int rating;

  /// Optional user comment.
  final String? comment;

  const RateServiceRequest({required this.rating, this.comment});

  Map<String, dynamic> toJson() => {
    'rating': rating,
    if (comment != null && comment!.isNotEmpty) 'comment': comment,
  };
}
