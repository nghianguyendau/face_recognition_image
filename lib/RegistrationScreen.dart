import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:face_recognition_with_images/ML/Recognition.dart';
import 'package:face_recognition_with_images/ML/Recognizer.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _HomePageState();
}

class _HomePageState extends State<RegistrationScreen> {
  //TODO declare variables
  late ImagePicker imagePicker;
  File? _image;
  List<Face> faces = [];
  var image;

  //TODO declare detector
  late FaceDetector faceDetector;

  bool _isLoading = false;

  //TODO declare face recognizer
  // Recognizer recognizer = Recognizer();
  late Recognizer recognizer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    recognizer = Recognizer();

    //TODO initialize face detector

    final options =
        FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
    faceDetector = FaceDetector(options: options);

    //TODO initialize face recognizer
  }

  //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doFaceDetection();
      });
    }
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doFaceDetection();
      });
    }
  }

  void checkAndShowRegistrationDialog(Uint8List croppedFace, Recognition recognition) {
    var embeddings = recognition.embeddings;  // Giả sử embeddings là một phần của đối tượng recognition
    Pair closestMatch = recognizer.findNearestCosine(embeddings);

    // Giả sử ngưỡng là 0.7
    if (closestMatch.distance > 0.7) {
      // Khuôn mặt đã được đăng ký
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Notification"),
            content: const Text("This face is already registered."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Hiển thị hộp thoại đăng ký khuôn mặt
      showFaceRegistrationDialogue(croppedFace, recognition);
    }
  }


  //TODO face detection code here

  doFaceDetection() async {
    setState(() {
      _isLoading = true;
    });
    try {
      //TODO remove rotation of camera images
      InputImage inputImage = InputImage.fromFile(_image!);
      final bytes = await _image!.readAsBytes();
      image = await decodeImageFromList(bytes);
      //TODO passing input to face detector and getting detected faces
      faces = await faceDetector.processImage(inputImage);
      for (Face face in faces) {
        final Rect boundingBox = face.boundingBox;
        print("Rect = " + boundingBox.toString());

        num left = boundingBox.left < 0 ? 0 : boundingBox.left;
        num top = boundingBox.top < 0 ? 0 : boundingBox.top;
        num right = boundingBox.right > image.width
            ? image.width - 1
            : boundingBox.right;
        num bottom = boundingBox.bottom > image.height
            ? image.height - 1
            : boundingBox.bottom;
        num width = right - left;
        num height = bottom - top;

        // final bytes = _image!.readAsBytesSync();
        img.Image? faceImg = img.decodeImage(bytes!);
        img.Image croppedFace = img.copyCrop(faceImg!,
            x: left.toInt(),
            y: top.toInt(),
            width: width.toInt(),
            height: height.toInt());
        if (croppedFace == null)
          return;
        else {
          //TODO perform face recognition

          Recognition recognition =
              recognizer.recognize(croppedFace, boundingBox);
          // print("00000 ${recognition.toString()}");
          checkAndShowRegistrationDialog(
              Uint8List.fromList(img.encodeBmp(croppedFace)), recognition);
        }
      }
      drawRectangleAroundFaces();
    } catch (e) {
      print("Error:" + e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    //TODO call the method to perform face recognition on detected faces
  }

  //TODO remove rotation of camera images
  removeRotation(File inputImage) async {
    final img.Image? capturedImage =
        img.decodeImage(await File(inputImage!.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }

  //TODO perform Face Recognition

  //TODO Face Registration Dialogue
  TextEditingController textEditingController = TextEditingController();
  showFaceRegistrationDialogue(Uint8List cropedFace, Recognition recognition) {
    print('111111111');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Face Registration", textAlign: TextAlign.center),
        alignment: Alignment.center,
        content: SizedBox(
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.memory(
                cropedFace,
                width: 200,
                height: 200,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter Name")),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    recognizer.registerFaceInDB(
                        textEditingController.text, recognition.embeddings);
                    textEditingController.text = "";
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Face Registered"),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(200, 40)),
                  child: const Text("Register"))
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  //TODO draw rectangles
  drawRectangleAroundFaces() async {
    // image = await _image?.readAsBytes();
    // image = await decodeImageFromList(image);
    print("${image.width}   ${image.height}");
    setState(() {
      image;
      faces;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          double availableHeight = constraints.maxHeight;
          double availableWidth = constraints.maxWidth;
          return Stack(
            children: [
              Column(
                children: [
                  // Phần ảnh chiếm 2/3 không gian có sẵn
                  Container(
                    height: availableHeight * 2 / 3,
                    width: availableWidth,
                    child: _image != null && image != null
                        ? FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: image.width.toDouble(),
                              height: image.height.toDouble(),
                              child: CustomPaint(
                                painter: FacePainter(
                                    facesList: faces, imageFile: image),
                              ),
                            ),
                          )
                        : Center(
                            child: Image.asset(
                              "assets/images/logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                  // Phần nút chiếm phần còn lại của không gian
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImageButton(
                              Icons.image, _imgFromGallery, availableWidth),
                          _buildImageButton(
                              Icons.camera, _imgFromCamera, availableWidth),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Đang xử lý...",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildImageButton(
      IconData icon, Function() onTap, double screenWidth) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: screenWidth / 5,
          height: screenWidth / 5,
          child: Icon(icon, color: Colors.blue, size: screenWidth / 10),
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face> facesList;
  dynamic imageFile;
  FacePainter({required this.facesList, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    Paint p = Paint();
    p.color = Colors.green;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 5;

    for (Face face in facesList) {
      canvas.drawRect(face.boundingBox, p);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
