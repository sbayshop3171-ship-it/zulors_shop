import 'dart:math' as math;
import 'package:zulors_shop_vendor/features/product_details/enums/preview_type.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';


class ProductHelper {


  static String removeSpacesAndLowercase(String input) {
    return input.replaceAll(' ', '').toLowerCase();
  }

  static String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  static String replaceUnderscoreWithHyphen(String input) {
    return input.replaceAll('_', '-');
  }

  static List<String> processList(List<String> inputList) {
    return inputList.map((str) => str.toLowerCase().trim()).toList();
  }

  static String generateSKU() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random();
    String sku = '';

    for (int i = 0; i < 6; i++) {
      sku += chars[random.nextInt(chars.length)];
    }
    return sku;
  }


  static PreviewType getFileType(String url) {
    if(url.contains('.pdf')) {
      return PreviewType.pdf;
    } else if(url.contains('.jpg') || url.contains('.jpeg') || url.contains('.png')) {
      return  PreviewType.image;
    } else if(url.contains('.mp4') || url.contains('.mkv') || url.contains('.avi') || url.contains('.flv') || url.contains('.mov') || url.contains('.wmv') || url.contains('.webm')) {
      return PreviewType.video;
    } else if ( url.contains('.mp3') || url.contains('.wav') || url.contains('.aac') || url.contains('.wma') || url.contains('.amr')) {
      return PreviewType.audio;
    }else {
      return PreviewType.others;
    }
  }

  static String getFileExtension(String fileName) {
    if (fileName.contains('.')) {
      return '.${fileName.split('.').last}';
    }
    return '';
  }



  /// Converts HTML content to plain text while preserving headings, paragraphs and lists.
  static String htmlToPlainText(String htmlContent) {
    // Parse HTML string
    Document document = parse(htmlContent);

    StringBuffer buffer = StringBuffer();
    int olIndex = 1; // for ordered lists

    void parseNode(Node node) {
      if (node is Element) {
        switch (node.localName) {
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            buffer.writeln('\n${node.text.trim()}\n');
            break;
          case 'p':
            buffer.writeln('${node.text.trim()}\n');
            break;
          case 'li':
          // detect if parent is <ol>
            if (node.parent?.localName == 'ol') {
              buffer.writeln('$olIndex. ${node.text.trim()}');
              olIndex++;
            } else {
              buffer.writeln('• ${node.text.trim()}');
            }
            break;
          case 'ol':
            olIndex = 1; // reset counter
            node.nodes.forEach(parseNode);
            buffer.writeln();
            break;
          case 'ul':
            node.nodes.forEach(parseNode);
            buffer.writeln();
            break;
          case 'br':
            buffer.writeln();
            break;
          default:
            node.nodes.forEach(parseNode);
        }
      } else if (node is Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) buffer.write('$text ');
      }
    }

    // Parse body
    document.body?.nodes.forEach(parseNode);

    // Clean up multiple blank lines
    String plainText = buffer.toString()
        .replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n')
        .trim();

    return plainText;
  }



}