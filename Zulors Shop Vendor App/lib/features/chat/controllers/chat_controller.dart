import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/media_file_model.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/message_body.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/chat_model.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/message_model.dart';
import 'package:zulors_shop_vendor/features/chat/domain/services/chat_service_interface.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/helper/image_size_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';

enum SenderType {
  customer,
  seller,
  admin,
  deliveryMan,
  unknown
}

class ChatController extends ChangeNotifier {
  final ChatServiceInterface chatServiceInterface;
  ChatController({required this.chatServiceInterface});


  List<Chat>? _chatList;
  List<Chat>? get chatList => _chatList;
  bool _isSendButtonActive = false;
  bool get isSendButtonActive => _isSendButtonActive;
  int _userTypeIndex = 0;
  int get userTypeIndex =>  _userTypeIndex;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  ChatModel? _chatModel;
  ChatModel? get chatModel => _chatModel;

  MessageModel? messageModel;

  bool _pickedFIleCrossMaxLimit = false;
  bool get pickedFIleCrossMaxLimit => _pickedFIleCrossMaxLimit;

  bool _pickedFIleCrossMaxLength = false;
  bool get pickedFIleCrossMaxLength => _pickedFIleCrossMaxLength;

  bool _singleFIleCrossMaxLimit = false;
  bool get singleFIleCrossMaxLimit => _singleFIleCrossMaxLimit;

  List<PlatformFile>? _pickedFiles;
  List<PlatformFile>? get pickedFiles => _pickedFiles;

  String _onImageOrFileTimeShowID = '';
  String get onImageOrFileTimeShowID => _onImageOrFileTimeShowID;

  bool _isClickedOnImageOrFile = false;
  bool get isClickedOnImageOrFile => _isClickedOnImageOrFile;

  bool _isClickedOnMessage = false;
  bool get isClickedOnMessage => _isClickedOnMessage;

  String _onMessageTimeShowID = '';
  String get onMessageTimeShowID => _onMessageTimeShowID;

  bool _openEmojiPicker = false;
  bool get openEmojiPicker => _openEmojiPicker;



  Future<void> getMessageList(int? id, int offset, {bool reload = true}) async {
    if(reload){
      messageModel = null;
    }

    ApiResponse apiResponse = await chatServiceInterface.getMessageList(_userTypeIndex == 0 ? 'customer' : 'delivery-man', offset, id);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(offset == 1) {
        messageModel = null;
        messageModel = MessageModel.fromJson(apiResponse.response!.data);
      } else {
        messageModel!.totalSize =  MessageModel.fromJson(apiResponse.response!.data).totalSize;
        messageModel!.offset =  MessageModel.fromJson(apiResponse.response!.data).offset;
        messageModel!.message!.addAll(MessageModel.fromJson(apiResponse.response!.data).message!) ;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    notifyListeners();
  }


  Future<void> getChatList(BuildContext context, int offset, {bool reload = false}) async {
    if(reload){
      _chatModel = null;
    }
    _isLoading = true;
    ApiResponse apiResponse = await chatServiceInterface.getChatList(_userTypeIndex == 0 ? 'customer' : 'delivery-man', offset);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(offset == 1) {
        _chatModel = null;
        _chatModel = ChatModel.fromJson(apiResponse.response!.data);
      }else {
        _chatModel!.totalSize = ChatModel.fromJson(apiResponse.response!.data).totalSize;
        _chatModel!.offset = ChatModel.fromJson(apiResponse.response!.data).offset;
        _chatModel!.chat!.addAll(ChatModel.fromJson(apiResponse.response!.data).chat!);
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchedChatList(BuildContext context, String search) async {
    ApiResponse apiResponse = await chatServiceInterface.searchChat(_userTypeIndex == 0 ? 'customer' : 'delivery-man', search);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _chatModel = ChatModel(totalSize: 10, limit: '10', offset: '1', chat: []);
      apiResponse.response!.data.forEach((chat) {_chatModel!.chat!.add(Chat.fromJson(chat));});
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  Future<http.StreamedResponse> sendMessage(MessageBody messageBody,) async {
    if(kDebugMode){
      print("===api call===id = ${messageBody.userId}");
    }
    _isLoading = true;
    notifyListeners();

    http.StreamedResponse response = await chatServiceInterface.sendMessage(messageBody, _userTypeIndex == 0 ? 'customer' : 'delivery-man' , getXFileFromMediaFileModel(pickedMediaFileModelList ?? []) ?? [], pickedFiles ?? []);
    if (response.statusCode == 200) {
      getMessageList(messageBody.userId, 1, reload: false);
      _emptyAllPickedData();
    }

    getChatList(Get.context!, 1, reload: false);
    _isLoading = false;
    notifyListeners();
    return response;
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    notifyListeners();
  }

  void setUserTypeIndex(BuildContext context, int index, {bool isUpdate = true}) {
    _userTypeIndex = index;
    _chatModel = null;
    getChatList(context, 1);
    if(isUpdate) {
      notifyListeners();
    }
  }

  List<PlatformFile> _pickedMediaFiles =[];
  List<PlatformFile>? get pickedMediaFiles => _pickedMediaFiles;
  List<MediaFileModel>? pickedMediaFileModelList = [];
  bool hasPicked = false;
  bool pickedImageCrossMaxLength = false;


  void pickMultipleMedia(bool isRemove,{int? index, bool openCamera = false,}) async {
    pickedImageCrossMaxLength = false;
    _pickedFIleCrossMaxLimit = false;
    _singleFIleCrossMaxLimit = false;

    hasPicked = true;
    notifyListeners();


    if(isRemove) {
      if(index != null){
        pickedMediaFileModelList?.removeAt(index);
      }
    } else if(openCamera){
      final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 400);

      if(pickedImage != null) {
        double value =  await ImageSize.getImageSizeFromXFile(pickedImage);
        ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

        if(value > (configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
          showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
        } else {
          pickedMediaFileModelList?.add(MediaFileModel(file: pickedImage, thumbnailPath: pickedImage.path, isVideo: false));
        }
      }

    } else {

      FilePickerResult? filePickerResult =  await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          ...AppConstants.imageExtensions,
          ...AppConstants.videoExtensions,
        ],
        compressionQuality: 100,
      );

      _pickedMediaFiles = filePickerResult?.files ?? [];


      for (PlatformFile file in _pickedMediaFiles) {
        if (isVideoExtension(file.path ?? '')) {
          final thumbnailPath = await generateThumbnail(file.path ?? '');
          if (thumbnailPath != null) {

            pickedMediaFileModelList?.add(MediaFileModel(file: file.xFile, thumbnailPath: thumbnailPath, isVideo: true));
          }
        } else {
          double value =  await ImageSize.getImageSizeFromXFile(file.xFile);
          ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

          if(value > (configModel?.systemImageFileUploadMaxSize  ?? AppConstants.fileImageMaxLimit)) {
            showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize  ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
          } else {
            pickedMediaFileModelList?.add(MediaFileModel(file: file.xFile, thumbnailPath: file.path, isVideo: false));
          }
        }
      }
    }

    pickedMediaFileModelList?.forEach((element) {
      if(ImageSize.getFileSizeFromXFileSync(element.file!) > (Provider.of<SplashController>(Get.context!, listen: false).configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.maxSizeOfASingleFile)) {
        _singleFIleCrossMaxLimit = true;
      }
    });

    pickedImageCrossMaxLength = _isMediaCrossMaxLen();
    _pickedFIleCrossMaxLimit = await _isCrossMediaMaxLimit();

    toggleMediaSendingButtonActive();

    hasPicked = false;
    notifyListeners();
  }

  bool _isMediaCrossMaxLen() => pickedMediaFileModelList!.length > AppConstants.maxLimitOfTotalFileSent;

  Future<bool> _isCrossMediaMaxLimit() async =>
      _pickedMediaFiles.length == AppConstants.maxLimitOfTotalFileSent
        && await ImageSize.getMultipleImageSizeFromXFile(getXFileFromMediaFileModel(pickedMediaFileModelList ?? []) ?? [])
        > (Provider.of<SplashController>(Get.context!, listen: false).configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.maxLimitOfFileSentINConversation);




  Future<void> pickOtherFile(bool isRemove, {int? index}) async {
    _pickedFIleCrossMaxLength = false;
    _pickedFIleCrossMaxLimit = false;

    if(isRemove){
      if(_pickedFiles != null){
        _pickedFiles!.removeAt(index!);
      }else if(_pickedFiles!.isEmpty){
        _pickedFIleCrossMaxLength = false;
      }
    }else{

      List<PlatformFile>? platformFile = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.documentExtensions,
        allowMultiple: true,
        withReadStream: true,
      ))?.files ;

      _pickedFiles = [];


      platformFile?.forEach((element) {
        if(ImageSize.getFileSizeFromPlatformFileToDouble(element) > (Provider.of<SplashController>(Get.context!, listen: false).configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.maxSizeOfASingleFile)  ) {
          _singleFIleCrossMaxLimit = true;
        } else{
          _pickedFiles!.add(element);
        }
      });
    }


    _pickedFIleCrossMaxLength = _isFileCrossMaxLen();
    _pickedFIleCrossMaxLimit = _isFileMediaMaxLimit();


    toggleMediaSendingButtonActive();

    notifyListeners();
  }

  bool _isFileCrossMaxLen() => _pickedFiles!.length > AppConstants.maxLimitOfTotalFileSent;

  bool _isFileMediaMaxLimit()  => _pickedFiles?.length == AppConstants.maxLimitOfTotalFileSent && pickedFiles != null &&
      ImageSize.getMultipleFileSizeFromPlatformFiles(pickedFiles!) > AppConstants.maxLimitOfFileSentINConversation;


  double? getExtractSizeInMB(String sizeString) {
    final regex = RegExp(r'^(\d+(\.\d+)?)\s*([kKmMgG])[bB]?$');
    final match = regex.firstMatch(sizeString.trim());

    if (match != null) {
      double value = double.parse(match.group(1)!);
      String unit = match.group(3)!.toUpperCase();

      if (unit == 'G') {
        return value * 1024; // Convert GB to MB
      } else if (unit == 'M') {
        return value; // Already in MB
      } else {
        return null;
      }
    } else {
      return null;
    }
  }



  String getChatTime (String todayChatTimeInUtc , String? nextChatTimeInUtc) {
    String chatTime = '';
    DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(todayChatTimeInUtc);

    DateTime nextConversationDateTime;
    DateTime currentDate = DateTime.now();

    if(nextChatTimeInUtc == null){
      String chatTime = DateConverter.isoStringToLocalDateAndTime(todayChatTimeInUtc);
      return chatTime;
    }else{
      nextConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(nextChatTimeInUtc);
      if(todayConversationDateTime.difference(nextConversationDateTime) < const Duration(minutes: 30) &&
          todayConversationDateTime.weekday == nextConversationDateTime.weekday){
        chatTime = '';
      }else if(currentDate.weekday != todayConversationDateTime.weekday
          && DateConverter.countDays(todayConversationDateTime) < 6){

        if( (currentDate.weekday -1 == 0 ? 7 : currentDate.weekday -1) == todayConversationDateTime.weekday){
          chatTime = DateConverter.convert24HourTimeTo12HourTimeWithDay(todayConversationDateTime, false);
        }else{
          chatTime = DateConverter.convertStringTimeToDate(todayConversationDateTime).toString();
        }
      }else if(currentDate.weekday == todayConversationDateTime.weekday
          && DateConverter.countDays(todayConversationDateTime) < 6){
        chatTime = DateConverter.convert24HourTimeTo12HourTimeWithDay(todayConversationDateTime, true);
      }else{
        chatTime = DateConverter.isoStringToLocalDateAndTime(todayChatTimeInUtc);
      }
    }

    return chatTime;
  }



  bool isSameUserWithPreviousMessage(Message? previousConversation, Message currentConversation){
    if(getSenderType(previousConversation) == getSenderType(currentConversation) && previousConversation?.message != null && currentConversation.message !=null){
      return true;
    }
    return false;
  }
  bool isSameUserWithNextMessage( Message currentConversation, Message? nextConversation){
    if(getSenderType(currentConversation) == getSenderType(nextConversation) && nextConversation?.message != null && currentConversation.message !=null){
      return true;
    }
    return false;
  }

  SenderType getSenderType(Message? senderData) {
    if (senderData?.sentByCustomer == true) {
      return SenderType.customer;
    } else if (senderData?.sentBySeller == true) {
      return SenderType.seller;
    } else if (senderData?.sentByDeliveryMan == true) {
      return SenderType.deliveryMan;
    } else {
      return SenderType.unknown;
    }
  }


  String getChatTimeWithPrevious (Message currentChat, Message? previousChat) {
    DateTime todayConversationDateTime = DateConverter
        .isoUtcStringToLocalTimeOnly(currentChat.createdAt ?? "");

    DateTime previousConversationDateTime;

    if (previousChat?.createdAt == null) {
      return 'Not-Same';
    } else {
      previousConversationDateTime =
          DateConverter.isoUtcStringToLocalTimeOnly(previousChat!.createdAt!);
      if (kDebugMode) {
        print("The Difference is ${previousConversationDateTime.difference(todayConversationDateTime) < const Duration(minutes: 30)}");
      }
      if (previousConversationDateTime.difference(todayConversationDateTime) <
          const Duration(minutes: 30) &&
          todayConversationDateTime.weekday ==
              previousConversationDateTime.weekday && isSameUserWithPreviousMessage(currentChat, previousChat)) {
        return '';
      } else {
        return 'Not-Same';
      }
    }
  }

  void downloadFile(String url, String dir, String openFileUrl, String fileName) async {

    var snackBar = const SnackBar(content: Text('Downloading....'),backgroundColor: Colors.black54, duration: Duration(seconds: 1),);
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);

    final task  = await FlutterDownloader.enqueue(
      url: url,
      savedDir: dir,
      fileName: fileName,
      showNotification: true,
      saveInPublicStorage: true,
      openFileFromNotification: true,
    );

    if(task !=null){
      await OpenFile.open(openFileUrl);
    }
  }


  void toggleOnClickMessage ({required String onMessageTimeShowID}) {
    _onImageOrFileTimeShowID = '';
    _isClickedOnImageOrFile = false;
    if(_isClickedOnMessage && _onMessageTimeShowID != onMessageTimeShowID){
      _onMessageTimeShowID = onMessageTimeShowID;
    }else if(_isClickedOnMessage && _onMessageTimeShowID == onMessageTimeShowID){
      _isClickedOnMessage = false;
      _onMessageTimeShowID = '';
    }else{
      _isClickedOnMessage = true;
      _onMessageTimeShowID = onMessageTimeShowID;
    }
    notifyListeners();
  }


  String? getOnPressChatTime(Message currentConversation){
    if(currentConversation.id.toString() == _onMessageTimeShowID || currentConversation.id.toString() == _onImageOrFileTimeShowID){
      DateTime currentDate = DateTime.now();
      DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(
          currentConversation.createdAt ?? ""
      );

      if(currentDate.weekday != todayConversationDateTime.weekday
          && DateConverter.countDays(todayConversationDateTime) <= 7){
        return DateConverter.convertStringTimeToDateChatting(todayConversationDateTime);
      }else if(currentDate.weekday == todayConversationDateTime.weekday
          && DateConverter.countDays(todayConversationDateTime) <= 7){
        return  DateConverter.convert24HourTimeTo12HourTime(todayConversationDateTime);
      }else{
        return DateConverter.isoStringToLocalDateAndTime(currentConversation.createdAt!);
      }
    }else{
      return null;
    }
  }

  void setEmojiPickerValue(bool value, {bool notify = true}){
    _openEmojiPicker = value;
    if(notify){
      notifyListeners();
    }
  }

  bool isVideoExtension(String path) {
    final fileExtension = path.split('.').last.toLowerCase();

    return AppConstants.videoExtensions.contains(fileExtension);
  }

  Future<String?> generateThumbnail(String filePath) async {
    final directory = await getTemporaryDirectory();

    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: filePath, // Replace with your video URL
      thumbnailPath: directory.path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 100,
      maxWidth: 200,
      quality: 1,
    );

    return thumbnailPath.path;
  }

  List<XFile>? getXFileFromMediaFileModel(List<MediaFileModel> mediaFileModel) {
    return mediaFileModel
        .map((model) => model.file)
        .whereType<XFile>() // Filters out any null values
        .toList();
  }

  void _emptyAllPickedData() {
    _pickedMediaFiles = [];
    pickedMediaFileModelList = [];
    _pickedFiles = [];
    _pickedFiles = [];
  }


  void toggleMediaSendingButtonActive(){
    bool isNotEmptyCheck = (pickedMediaFileModelList?.isNotEmpty ?? false) || (_pickedFiles?.isNotEmpty ?? false);
    bool mediaCheck =  !pickedImageCrossMaxLength && !_pickedFIleCrossMaxLength;
    _isSendButtonActive = (isNotEmptyCheck && mediaCheck);
  }


  void updateMessageSeen(int index, {bool isUpdate = true}){
    _chatModel!.chat![index].seenBySeller = true;
    _chatModel!.chat![index].unseenMessageCount = 0;
    if(isUpdate){
      notifyListeners();
    }
  }


  Future<ApiResponse> seenMessage(BuildContext context, int? customerId, int? deliveryId) async {
    ApiResponse apiResponse = await chatServiceInterface.seenMessage(_userTypeIndex == 0 ? customerId!: deliveryId!, _userTypeIndex == 0 ? 'customer' : 'delivery-man');
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {} else {
      ApiChecker.checkApi(apiResponse);
    }

    notifyListeners();
    return apiResponse;
  }

}
