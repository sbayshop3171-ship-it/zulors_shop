import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/message_body.dart';

abstract class ChatServiceInterface {
  Future<dynamic> getChatList(String type, int offset);
  Future<dynamic> searchChat(String type, String search);
  Future<dynamic> getMessageList(String type, int offset, int? id);
  Future<dynamic> sendMessage(MessageBody messageBody, String type, List<XFile?> files,  List<PlatformFile>? platformFile);
  Future<dynamic> seenMessage(int id, String type);
}