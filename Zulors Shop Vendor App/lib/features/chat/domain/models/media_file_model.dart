import 'package:image_picker/image_picker.dart';

class MediaFileModel{
  XFile? file;
  String? thumbnailPath;
  bool? isVideo;
  MediaFileModel({required this.file, required this.thumbnailPath, required this.isVideo});
}