class ResponseDataList {
  bool status;
  String message;
  List? data;
  int? count;
  ResponseDataList({required this.status, required this.message, this.data, this.count});
}