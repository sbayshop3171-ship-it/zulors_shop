import 'package:zulors_shop_vendor/features/ai/domain/repositories/ai_repository_interface.dart';
import 'package:zulors_shop_vendor/features/ai/domain/services/ai_service_interface.dart';
import 'package:image_picker/image_picker.dart';


class AiService implements AiServiceInterface {
  final AiRepositoryInterface aiRepositoryInterface;
  AiService({required this.aiRepositoryInterface});


  @override
  Future<dynamic> generateTitle({required String title, required String langCode}) async {
    return await aiRepositoryInterface.generateTitle(title: title, langCode: langCode);
  }


  @override
  Future<dynamic> generateDescription({required String title, required String langCode}) async {
    return await aiRepositoryInterface.generateDescription(title: title, langCode: langCode);
  }

  // Future<ApiResponse?> required String title,  required String description, required String langCode({required String title,  required String description, required String langCode})=

  @override
  Future<dynamic> generateGeneralData({required String title,  required String description, required String langCode}) async {
    return await aiRepositoryInterface.generateGeneralData(title: title, langCode: langCode, description: description);
  }

  @override
  Future<dynamic> generateTitleSuggestions({required String keywords}) async {
    return await aiRepositoryInterface.generateTitleSuggestions(keywords: keywords);
  }

  @override
  Future<dynamic> generateFromImage({required XFile image}) async {
    return await aiRepositoryInterface.generateFromImage(image: image);
  }


  @override
  Future<dynamic> generatePricing({required String title, required String langCode}) async {
    return await aiRepositoryInterface.generatePricing(title: title, langCode: langCode);
  }

  @override
  Future<dynamic> generateVariationData({required String title, required String description}) async {
    return await aiRepositoryInterface.generateVariationData(title: title, description: description);
  }


  @override
  Future<dynamic> generateMetaSeoData({required String title, required String description}) async {
    return await aiRepositoryInterface.generateMetaSeoData(title: title, description: description);
  }


  @override
  Future<dynamic> generateLimitCheck() async {
    return await aiRepositoryInterface.generateLimitCheck();
  }


}