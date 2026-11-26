import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropService {
  ImageCropService._();

  static Future<String?> cropSquareImage({
    required BuildContext context,
    required String sourcePath,
    required String title,
    CropStyle cropStyle = CropStyle.rectangle,
    int maxSize = 900,
    int quality = 82,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: maxSize,
      maxHeight: maxSize,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: quality,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Colors.orangeAccent,
          dimmedLayerColor: Colors.black54,
          cropFrameColor: Colors.white70,
          cropGridColor: Colors.white24,
          lockAspectRatio: true,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.square,
          cropStyle: cropStyle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: title,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          rotateButtonsHidden: false,
          cropStyle: cropStyle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        if (kIsWeb) WebUiSettings(context: context),
      ],
    );

    return croppedFile?.path;
  }
}
