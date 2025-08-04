import 'package:flutter/cupertino.dart';

class PictureDescriptionDetail {
  final String name;
  final TextEditingController controller;
  final bool isRequired;

  PictureDescriptionDetail({
    required this.name,
    this.isRequired = true // Default to true
  }) : controller = TextEditingController();
}