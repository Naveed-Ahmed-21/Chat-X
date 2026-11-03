import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectedMedia {

  final XFile file;

  final TextEditingController captionController =
  TextEditingController();

  SelectedMedia({
    required this.file,
  });

  void dispose() {
    captionController.dispose();
  }

}