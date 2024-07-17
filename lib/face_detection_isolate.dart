// // file: face_detection_isolate.dart
// import 'dart:isolate';
// import 'package:camera/camera.dart';
// import 'package:face_recognition_with_images/ML/Recognition.dart';
// import 'package:face_recognition_with_images/ML/Recognizer.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image/image.dart' as img;

// class FaceDetectionIsolate {
//   static Future<List<Recognition>> processImage(CameraImage cameraImage) async {
//     final ReceivePort receivePort = ReceivePort();
//     await Isolate.spawn(isolateFunction, receivePort.sendPort);
    
//     final SendPort sendPort = await receivePort.first;
//     final results = await sendReceive(sendPort, cameraImage);
    
//     return results;
//   }

//   static Future<dynamic> sendReceive(SendPort sendPort, dynamic message) async {
//     final ReceivePort receivePort = ReceivePort();
//     sendPort.send([message, receivePort.sendPort]);
//     return receivePort.first;
//   }

//   static void isolateFunction(SendPort sendPort) async {
//     final ReceivePort receivePort = ReceivePort();
//     sendPort.send(receivePort.sendPort);

//     final detector = FaceDetector(
//       options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast)
//     );
//     final recognizer = Recognizer();

//     await for (final message in receivePort) {
//       final CameraImage cameraImage = message[0];
//       final SendPort replyTo = message[1];

//       final InputImage inputImage = inputImageFromCameraImage(cameraImage);
//       final List<Face> faces = await detector.processImage(inputImage);
      
//       final img.Image image = convertCameraImageToImage(cameraImage);
//       final List<Recognition> recognitions = [];

//       for (Face face in faces) {
//         final croppedFace = cropFace(image, face.boundingBox);
//         final recognition = recognizer.recognize(croppedFace, face.boundingBox);
//         recognitions.add(recognition);
//       }

//       replyTo.send(recognitions);
//     }
//   }

//   static InputImage inputImageFromCameraImage(CameraImage cameraImage) {
//     // Implement conversion from CameraImage to InputImage
//     // This depends on your specific implementation
//       final camera =
//         camDirec == CameraLensDirection.front ? cameras[1] : cameras[0];
//     final sensorOrientation = camera.sensorOrientation;

//     InputImageRotation? rotation;
//     if (Platform.isIOS) {
//       rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//     } else if (Platform.isAndroid) {
//       var rotationCompensation =
//           _orientations[controller!.value.deviceOrientation];
//       if (rotationCompensation == null) {
//         print("rotationCompensation null");
//         return null;
//       }
//       if (camera.lensDirection == CameraLensDirection.front) {
//         // front-facing
//         rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
//       } else {
//         // back-facing
//         rotationCompensation =
//             (sensorOrientation - rotationCompensation + 360) % 360;
//       }
//       rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
//     }

//     if (rotation == null) {
//       print("rotation null");
//       return null;
//     }

//     final format = InputImageFormatValue.fromRawValue(frame!.format.raw);
//     if (format == null ||
//         (Platform.isAndroid && format != InputImageFormat.yuv_420_888) ||
//         (Platform.isIOS && format != InputImageFormat.bgra8888)) {
//       print("Invalid format: $format");
//       return null;
//     }

//     if (frame!.planes.length != 3) return null;
//     final bytes = concatenatePlanes(frame!.planes);

//     return InputImage.fromBytes(
//       bytes: bytes,
//       metadata: InputImageMetadata(
//         size: Size(frame!.width.toDouble(), frame!.height.toDouble()),
//         rotation: rotation,
//         format: format,
//         bytesPerRow: frame!.planes[0].bytesPerRow,
//       ),
//     );
//   }

//   static img.Image convertCameraImageToImage(CameraImage cameraImage) {
//     // Implement conversion from CameraImage to img.Image
//     // This should be similar to your existing convertYUV420ToImage function
//   }

//   static img.Image cropFace(img.Image image, Rect boundingBox) {
//     // Implement face cropping
//     // This should be similar to your existing face cropping logic
//   }
// }