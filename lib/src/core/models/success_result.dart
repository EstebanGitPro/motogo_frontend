/// A wrapper class that contains both the data and the success message
/// returned from a backend operation.
///
/// This is used when the backend returns both:
/// - A data entity (in `data` field)
/// - A success message (in `message` field)
///
/// This allows the UI to display the backend's success message instead of
/// using local constant strings.
class SuccessResult<T> {
  final T data;
  final String message;

  const SuccessResult({required this.data, required this.message});
}
