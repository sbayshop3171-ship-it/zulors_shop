import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/message_body.dart';
import 'package:zulors_shop_vendor/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:zulors_shop_vendor/features/chat/domain/services/chat_service_interface.dart';

class ChatService implements ChatServiceInterface{
  ChatRepositoryInterface chatRepoInterface;
  ChatService({required this.chatRepoInterface});

  @override
  Future getChatList(String type, int offset) async{
    return await chatRepoInterface.getChatList(type, offset);
  }

  @override
  Future getMessageList(String type, int offset, int? id) async{
    return await chatRepoInterface.getMessageList(type, offset, id);
  }

  @override
  Future searchChat(String type, String search) {
    return chatRepoInterface.searchChat(type, search);
  }

  @override
  Future sendMessage(MessageBody messageBody, String type, List<XFile?> files, List<PlatformFile>? platformFile) {
    return chatRepoInterface.sendMessage(messageBody, type, files, platformFile);
  }

  @override
  Future seenMessage(int id, String type) async{
    return chatRepoInterface.seenMessage(id, type);
  }
}