class ErrorStruct {
  final String code;
  final String? technicalDetails;

  const ErrorStruct({
    required this.code,
    this.technicalDetails,
  });
}