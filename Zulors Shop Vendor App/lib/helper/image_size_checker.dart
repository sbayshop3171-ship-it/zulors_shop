import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageSize{

   static Future <double> getImageSizeFromXFile(XFile xFile)  async {
    int sizeInKB =  await xFile.length();
    double sizeInMB = sizeInKB / (1024 * 1024);
    return sizeInMB;
  }

   static Future <double> getMultipleImageSizeFromXFile(List<XFile>  xFiles)  async {

     double imageSize = 0.0;
     for (var element in xFiles) {
       imageSize = ( await element.length() / (1024 * 1024)) + imageSize;
     }
     return imageSize;
   }

   // static Future <double> getMultipleImageSizeFromMultipart(List<MultipartBody>  multiParts)  async {
   //
   //   double imageSize = 0.0;
   //   for (var element in multiParts) {
   //     imageSize = ( await element.file.length() / (1024 * 1024)) + imageSize;
   //   }
   //   return imageSize;
   // }

   static String getFileSizeFromPlatformFileToString(PlatformFile platformFile)  {

     int sizeOfTheFileInBytes =  platformFile.size;
     String fileSize = "";

     if((sizeOfTheFileInBytes / (1024 * 1024)) > 1){
       fileSize = "${(sizeOfTheFileInBytes / (1024 * 1024)).toStringAsFixed(1)} MB";
     }else{
       fileSize = "${(sizeOfTheFileInBytes / 1024 ).toStringAsFixed(1)} KB";
     }
     return fileSize;
   }

   static double getFileSizeFromPlatformFileToDouble(PlatformFile platformFile)  {
     return (platformFile.size / (1024 * 1024));
   }


   static double getFileSizeFromXFileSync(XFile xFile) {
     final file = File(xFile.path);
     final sizeInBytes = file.lengthSync();
     return sizeInBytes / (1024 * 1024);
   }

   static double getMultipleFileSizeFromPlatformFiles(List<PlatformFile> platformFiles)  {

     double fileSize = 0.0;
     for (var element in platformFiles) {
       fileSize  = (element.size / (1024 * 1024)) + fileSize;
     }
     return fileSize;
   }



   static double getFileSizeFromFile(File file) {
     try {
       if (file.existsSync()) {
         final int sizeInBytes = file.lengthSync();
         return sizeInBytes / (1024 * 1024); // Convert bytes → MB
       }
     } catch (e) {
       debugPrint('Error reading file size: $e');
     }
     return 0.0;
   }

}