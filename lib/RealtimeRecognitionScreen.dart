import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_recognition_with_images/ML/Recognition.dart';
import 'package:face_recognition_with_images/ML/Recognizer.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

late List<CameraDescription> cameras;

class RealtimeRecognitionScreen extends StatefulWidget {
  RealtimeRecognitionScreen({Key? key}) : super(key: key);
  @override
  _RealtimeRecognitionScreenState createState() =>
      _RealtimeRecognitionScreenState();
}

class _RealtimeRecognitionScreenState extends State<RealtimeRecognitionScreen> {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;
  late List<Recognition> recognitions = [];

  //TODO declare face detector
  late FaceDetector detector;
  late Recognizer recognizer;
  //TODO declare face recognizer

  @override
  void initState() {
    super.initState();

    //TODO initialize face detector
    detector = FaceDetector(
        options:
            FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
    recognizer = Recognizer();

    //TODO initialize face recognizer

    //TODO initialize camera footage
    _initializeCamera();
    _scanResults = [];
  }

  //TODO code to initialize the camera feed
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(description, ResolutionPreset.low);
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) {
        if (!isBusy) {
          isBusy = true;
          Future.delayed(Duration(milliseconds: 100), () {
            print("Face detection started");
            frame = image;
            doFaceDetectionOnFrame();
          });
        }
      });
      setState(() {}); // Trigger a rebuild after camera initialization
    });
  }

  //TODO close all resources
  @override
  void dispose() {
    controller?.dispose();
    detector.close();
    super.dispose();
  }

  //TODO face detection on a frame
  dynamic _scanResults;
  CameraImage? frame;
  doFaceDetectionOnFrame() async {
    try {
      InputImage? inputImage = getInputImage();
      if (inputImage != null) {
        List<Face> faces = await detector.processImage(inputImage);
        setState(() {
          _scanResults = faces;
        });
        for (Face face in faces) {
          print("Face detected at: ${face.boundingBox}");
        }
        // performFaceRecognition(faces);
      } else
        print("null nha");
    } catch (e) {
      print("Error in face detection: $e");
    } finally {
      setState(() {
        isBusy = false;
      });
    }
  }

  img.Image? image;
  bool register = false;
  // TODO perform Face Recognition

  // performFaceRecognition(List<Face> faces) async {
  //   recognitions.clear();

  //   //TODO convert CameraImage to Image and rotate it so that our frame will be in a portrait
  //   image = convertYUV420ToImage(frame!);
  //   image = img.copyRotate(image!,
  //       angle: camDirec == CameraLensDirection.front ? 270 : 90);

  //   for (Face face in faces) {
  //     Rect faceRect = face.boundingBox;
  //     //TODO crop face
  //     img.Image croppedFace = img.copyCrop(image!,
  //         x: faceRect.left.toInt(),
  //         y: faceRect.top.toInt(),
  //         width: faceRect.width.toInt(),
  //         height: faceRect.height.toInt());
      
  //     Recognition recognition = recognizer.recognize(croppedFace, faceRect);
  //     recognitions.add(recognition);
  //     //TODO pass cropped face to face recognition model

  //     //TODO show face registration dialogue
  //   }
  //   print("recognitions-face-list: ${recognitions[0].name}");
  // }

  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width: width, height: height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data!.setPixelR(w, h, yuv2rgb(y, u, v)); //= yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  //
  //
  InputImage? getInputImage() {
    final camera =
        camDirec == CameraLensDirection.front ? cameras[1] : cameras[0];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[controller!.value.deviceOrientation];
      if (rotationCompensation == null) {
        print("rotationCompensation null");
        return null;
      }
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) {
      print("rotation null");
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(frame!.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.yuv_420_888) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      print("Invalid format: $format");
      return null;
    }

    if (frame!.planes.length != 3) return null;
    final bytes = concatenatePlanes(frame!.planes);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(frame!.width.toDouble(), frame!.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: frame!.planes[0].bytesPerRow,
      ),
    );
  }

  Uint8List concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  // TODO Show rectangles around detected faces
  Widget buildResult() {
    if (_scanResults == null ||
        _scanResults.isEmpty ||
        controller == null ||
        !controller.value.isInitialized) {
      print("scan: $_scanResults");
      print("controller: $controller");
      print(
          "controller.value.isInitialized: ${controller.value.isInitialized}");
      return const Center(
          child: Text('Camera is not initialized or no faces detected.'));
    }
    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter =
        FaceDetectorPainter(imageSize, _scanResults, camDirec);
    return CustomPaint(
      painter: painter,
    );
  }

  //TODO toggle camera direction
  void _toggleCameraDirection() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = cameras[1];
    } else {
      camDirec = CameraLensDirection.back;
      description = cameras[0];
    }
    await controller.stopImageStream();
    setState(() {
      controller;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if (controller != null) {
      //TODO View for displaying the live camera footage
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  )
                : Container(),
          ),
        ),
      );

      //TODO View for displaying rectangles around detected aces
      stackChildren.add(
        Positioned(
            top: 0.0,
            left: 0.0,
            width: size.width,
            height: size.height,
            child: buildResult()),
      );
    }

    //TODO View for displaying the bar to switch camera direction or for registering faces
    stackChildren.add(Positioned(
      top: size.height - 140,
      left: 0,
      width: size.width,
      height: 80,
      child: Card(
        margin: const EdgeInsets.only(left: 20, right: 20),
        color: Colors.blue,
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.cached,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      color: Colors.black,
                      onPressed: () {
                        _toggleCameraDirection();
                      },
                    ),
                    Container(
                      width: 30,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.face_retouching_natural,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      color: Colors.black,
                      onPressed: () {},
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            margin: const EdgeInsets.only(top: 0),
            color: Colors.black,
            child: Stack(
              children: stackChildren,
            )),
      ),
    );
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.facesList, this.camDire2);

  final Size absoluteImageSize;
  final List<Face> facesList;
  CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    if (facesList.isEmpty) return;
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.green;

    for (Face face in facesList) {
      canvas.drawRect(
        Rect.fromLTRB(
          camDire2 == CameraLensDirection.front
              ? (absoluteImageSize.width - face.boundingBox.right) * scaleX
              : face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY,
          camDire2 == CameraLensDirection.front
              ? (absoluteImageSize.width - face.boundingBox.left) * scaleX
              : face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY,
        ),
        paint,
      );

    //   TextSpan span = TextSpan(
    //       style: const TextStyle(color: Colors.white, fontSize: 20),
    //       text: "${face.name}  ${face.distance.toStringAsFixed(2)}");
    //   TextPainter tp = TextPainter(
    //       text: span,
    //       textAlign: TextAlign.left,
    //       textDirection: TextDirection.ltr);
    //   tp.layout();
    //   tp.paint(canvas, Offset(face.location.left*scaleX, face.location.top*scaleY));
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
