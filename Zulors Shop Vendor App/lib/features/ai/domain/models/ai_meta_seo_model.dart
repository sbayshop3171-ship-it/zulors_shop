class AiMetaSEOModel {
  bool? success;
  String? message;
  Data? data;

  AiMetaSEOModel({this.success, this.message, this.data});

  AiMetaSEOModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? metaTitle;
  String? metaDescription;
  String? metaIndex;
  int? metaNoFollow;
  int? metaNoImageIndex;
  int? metaNoArchive;
  int? metaNoSnippet;
  int? metaMaxSnippet;
  int? metaMaxSnippetValue;
  int? metaMaxVideoPreview;
  int? metaMaxVideoPreviewValue;
  int? metaMaxImagePreview;
  String? metaMaxImagePreviewValue;

  Data(
      {this.metaTitle,
        this.metaDescription,
        this.metaIndex,
        this.metaNoFollow,
        this.metaNoImageIndex,
        this.metaNoArchive,
        this.metaNoSnippet,
        this.metaMaxSnippet,
        this.metaMaxSnippetValue,
        this.metaMaxVideoPreview,
        this.metaMaxVideoPreviewValue,
        this.metaMaxImagePreview,
        this.metaMaxImagePreviewValue});

  Data.fromJson(Map<String, dynamic> json) {
    metaTitle = json['meta_title'];
    metaDescription = json['meta_description'];
    metaIndex = json['meta_index'];
    metaNoFollow = json['meta_no_follow'];
    metaNoImageIndex = json['meta_no_image_index'];
    metaNoArchive = json['meta_no_archive'];
    metaNoSnippet = json['meta_no_snippet'];
    metaMaxSnippet = json['meta_max_snippet'];
    metaMaxSnippetValue = json['meta_max_snippet_value'];
    metaMaxVideoPreview = json['meta_max_video_preview'];
    metaMaxVideoPreviewValue = json['meta_max_video_preview_value'];
    metaMaxImagePreview = json['meta_max_image_preview'];
    metaMaxImagePreviewValue = json['meta_max_image_preview_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['meta_title'] = metaTitle;
    data['meta_description'] = metaDescription;
    data['meta_index'] = metaIndex;
    data['meta_no_follow'] = metaNoFollow;
    data['meta_no_image_index'] = metaNoImageIndex;
    data['meta_no_archive'] = metaNoArchive;
    data['meta_no_snippet'] = metaNoSnippet;
    data['meta_max_snippet'] = metaMaxSnippet;
    data['meta_max_snippet_value'] = metaMaxSnippetValue;
    data['meta_max_video_preview'] = metaMaxVideoPreview;
    data['meta_max_video_preview_value'] = metaMaxVideoPreviewValue;
    data['meta_max_image_preview'] = metaMaxImagePreview;
    data['meta_max_image_preview_value'] = metaMaxImagePreviewValue;
    return data;
  }
}
