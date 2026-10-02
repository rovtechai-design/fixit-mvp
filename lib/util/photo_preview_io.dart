import 'dart:io';

import 'package:flutter/widgets.dart';

Widget buildPhotoPreview(String path) => ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(File(path), height: 160, width: double.infinity, fit: BoxFit.cover),
    );
