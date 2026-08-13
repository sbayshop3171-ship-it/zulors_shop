import 'package:image_picker/image_picker.dart';

abstract class AiServiceInterface {

  Future<dynamic> generateTitle({required String title, required String langCode});

  Future<dynamic> generateDescription({required String title, required String langCode});

  Future<dynamic> generateGeneralData({required String title,  required String description, required String langCode});

  Future<dynamic> generateTitleSuggestions({required String keywords});

  Future<dynamic> generateFromImage({required XFile image});

  Future<dynamic> generatePricing({required String title, required String langCode});

  Future<dynamic> generateVariationData({required String title,  required String description});

  Future<dynamic> generateMetaSeoData({required String title,  required String description});

  Future<dynamic> generateLimitCheck();

}