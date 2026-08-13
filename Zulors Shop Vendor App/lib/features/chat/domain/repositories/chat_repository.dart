import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/message_body.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ChatRepository implements ChatRepositoryInterface{
  final DioClient? dioClient;
  ChatRepository({required this.dioClient});

  @override
  Future<ApiResponse> getChatList(String type, int offset) async {
    try {
      final response = await dioClient!.get('${AppConstants.cartUri}$type?limit=30&offset=$offset');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> searchChat(String type, String search) async {
    try {
      final response = await dioClient!.get('${AppConstants.chatSearchUri}$type?search=$search');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getMessageList(String type, int offset, int? id) async {
    try {
      final response = await dioClient!.get('${AppConstants.messageUri}$type/$id?limit=30&offset=$offset');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<http.StreamedResponse> sendMessage(MessageBody messageBody, String type, List<XFile?> files, List<PlatformFile>? platformFile) async {
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}${AppConstants.sendMessageUri}$type'));



    request.headers.addAll(<String,String>{'Authorization': 'Bearer ${Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}'});
    for(int i=0; i<files.length;i++){
      Uint8List list = await files[i]!.readAsBytes();
      var part = http.MultipartFile('media[]', files[i]!.readAsBytes().asStream(), list.length, filename: basename(files[i]!.path));
      request.files.add(part);
    }

    if(platformFile != null ) {
      if(platformFile.isNotEmpty){
        for(PlatformFile pfile in platformFile) {
          request.files.add(http.MultipartFile('file[]', pfile.readStream!, pfile.size, filename: basename(pfile.name)));
        }
      }
    }

    Map<String, String> fields = {};
    request.fields.addAll(<String, String>{'id': messageBody.userId.toString(), 'message': messageBody.message ?? ''});
    request.fields.addAll(fields);
    http.StreamedResponse response = await request.send();

    return response;
  }


  @override
  Future<ApiResponse> seenMessage(int id, String type) async {
    try {
      final response = await dioClient!.post('${AppConstants.seenMessageUri}$type',
          data: {'id':id});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }
}