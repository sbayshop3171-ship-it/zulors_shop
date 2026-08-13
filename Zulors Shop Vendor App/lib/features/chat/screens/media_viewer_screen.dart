import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/features/chat/controllers/chat_controller.dart';
import 'package:zulors_shop_vendor/features/chat/domain/models/message_model.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:video_player/video_player.dart';

class MediaViewerScreen extends StatefulWidget {
  final int clickedIndex;
  final List<Attachment>? serverMedia;
  final List<XFile>? localMedia;
  const MediaViewerScreen({super.key, this.serverMedia, this.localMedia,required this.clickedIndex});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  VideoPlayerController? controller;
  ChewieController? chewController;
  late PageController pageController ;
  int currentIndex = 0;
  late bool _fromNetwork;
  final ReceivePort _port = ReceivePort();


  @override
  void initState() {

    _fromNetwork = widget.serverMedia?.isNotEmpty ?? false;
    currentIndex = widget.clickedIndex;

    pageController = PageController(initialPage: widget.clickedIndex);

    _loadVideo();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);


    super.initState();
  }

  void downloadCallback(String id, int status, int progress) async {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }


  Future _loadVideo() async {
    final ChatController chatController = Provider.of<ChatController>(context, listen: false);


    if(_fromNetwork && (widget.serverMedia?.isNotEmpty ?? false)){
      if(chatController.isVideoExtension(widget.serverMedia?[currentIndex].path ?? '')){
        controller =  VideoPlayerController.networkUrl(Uri.parse('${widget.serverMedia![currentIndex].path}'));


      }
    }else{
      if(chatController.isVideoExtension(widget.localMedia?[currentIndex].path ?? '')){
        controller = VideoPlayerController.file(File(widget.localMedia![currentIndex].path));

      }
    }

    if(controller != null){
      chewController = ChewieController(
        videoPlayerController: controller!,
        autoPlay: true,
        looping: true,
        allowFullScreen: false,
        placeholder: const Center(child: CircularProgressIndicator()),
      );

      chewController?.play();

      bool isNotExecute = true;

      chewController?.videoPlayerController.addListener(() {
        if((controller?.value.isInitialized ?? false) && isNotExecute){
          isNotExecute = false;
          setState(() {
            chewController = ChewieController(
              videoPlayerController: controller!,
              autoPlay: true,
              looping: true,
              allowFullScreen: false,
              aspectRatio: controller?.value.aspectRatio,
              placeholder: const Center(child: CircularProgressIndicator()),
            );


          });
        }
      });
    }


  }

  @override
  void dispose() {
    chewController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Provider.of<ChatController>(context, listen: false);
    final bool isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;

    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemBuilder: (context, index)=> Column(children: [

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row( children: [
                  Expanded(child: Text(
                    _extractFileName(
                      _fromNetwork ?
                      widget.serverMedia![currentIndex].path :
                      widget.localMedia![currentIndex].path,
                    ),
                    style: robotoRegular.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  InkWell(
                    onTap: ()=> Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.cancel_outlined, size: Dimensions.iconSizeMedium, color: Colors.white),
                    ),
                  )
                ]),
              ),
              // SizedBox(height: Get.height * 0.01),

              _fromNetwork ? chatController.isVideoExtension(widget.serverMedia![currentIndex].path ?? '') && chewController != null ? Flexible(
                child: Center(child: Chewie(controller: chewController!)),
              ) : Expanded(child: CustomImageWidget(
                fit: BoxFit.contain,
                image: widget.serverMedia![currentIndex].path!,
              )) : chatController.isVideoExtension(widget.localMedia![currentIndex].path) && chewController != null ? Flexible(
                child: Center(child: Chewie(controller: chewController!)),
              ) : Expanded(
                child: Image.file(File(widget.localMedia![currentIndex].path)),
              ),

               Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  InkWell(
                    onTap: ()=> _download(_fromNetwork ?
                    widget.serverMedia![currentIndex].path :
                    widget.localMedia![currentIndex].path,),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        child: Icon(Icons.file_download_outlined, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),

                ]),
              ),


            ]),
            itemCount: _fromNetwork ? widget.serverMedia?.length : widget.localMedia?.length,
            onPageChanged: (index) async{
              currentIndex = index;

              await _loadVideo();
              setState(() {});
            },
          ),

          if(_isButtonAvailable() )...[
            // Left Button
            Positioned.fill(child: Opacity(
              opacity:  currentIndex == (isLtr ? 0 : _getLastIndex()) ? 0.3 : 1,
              child: Align(alignment: Alignment.centerLeft, child: IconButton(
                highlightColor: Colors.transparent,
                onPressed: () => _leftButtonOnPress(isLtr),
                icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white, size: 36),
              )),
            )),

            // Right Button
            Positioned.fill(child: Opacity(
              opacity: currentIndex == (isLtr ? _getLastIndex() : 0) ? 0.3 : 1,
              child: Align(alignment: Alignment.centerRight, child: IconButton(
                highlightColor: Colors.transparent,
                onPressed: () => _rightButtonOnPress(isLtr),
                icon:  Icon(Icons.arrow_circle_right_outlined, color: Colors.white.withValues(alpha: 0.8), size: 40),
              )),
            )),
          ],
        ],
      ),
    ));


  }

  void _rightButtonOnPress(bool isLtr) {
    if(isLtr) {
      if (currentIndex < _getLastIndex()) {
        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }else {
      if (currentIndex > 0) {
        pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    }
  }

  void _leftButtonOnPress(bool isLtr) {
    if(!isLtr) {
      if (currentIndex < _getLastIndex()) {
        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }else {
      if (currentIndex > 0) {
        pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    }
  }



  bool _isButtonAvailable() => _fromNetwork ? (widget.serverMedia?.length ?? 0) > 1 : (widget.localMedia?.length ?? 0) > 1 ;

  int _getLastIndex() => ((_fromNetwork ? widget.serverMedia?.length : widget.localMedia?.length) ?? 0) - 1;

  Future<void> _download(String? url) async {
    if(url == null) return;
    final ChatController chatController = Provider.of<ChatController>(context, listen: false);

    final status = await Permission.notification.request();

    if(status.isGranted){
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()){
        directory = Platform.isAndroid
            ? await getExternalStorageDirectory() //FOR ANDROID
            : await getApplicationSupportDirectory();
      }

      chatController.downloadFile(url, directory!.path, "${directory.path}/$url", url);


    }else if(status.isDenied || status.isPermanentlyDenied){
      await openAppSettings();
    }
  }

  String _extractFileName(String? url) {
    return Uri.parse(url ?? '').pathSegments.last;
  }

}
