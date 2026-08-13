
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/message_body.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class ChatRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> getChatList(String type, int offset);
  Future<ApiResponse> searchChat(String type, String search);
  Future<ApiResponse> getMessageList(String type, int offset, int? id);
  Future<http.StreamedResponse> sendMessage(MessageBody messageBody, String type, List<XFile?> files, List<PlatformFile>? platformFile);
  Future<ApiResponse> seenMessage(int id, String type);
}