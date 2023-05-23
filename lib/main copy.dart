import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
//import 'package:vector_math/vector_math_64.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

Future<bool> isAssetExists(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (e) {
    print('Asset not found: $path');
    return false;
  }
}
Future<File> copyAssetToFile(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final file = File('${documentsDirectory.path}/${assetPath.split('/').last}');
  await file.writeAsBytes(byteData.buffer.asUint8List());
  return file;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('ARCORE IS AVAILABLE?');
  print(await ArCoreController.checkArCoreAvailability());
  print('\nAR SERVICES INSTALLED?');
  print(await ArCoreController.checkIsArCoreInstalled());

  String object3DPath = 'assets/models/sans_nom.glb';
  bool fileExists = await isAssetExists(object3DPath);

  if (fileExists) {
    print('The 3D object file exists: $object3DPath');
    runApp(const MainApp());
  } else {
    print('The 3D object file does not exist: $object3DPath');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: ARCoreView()),
    );
  }
}

class ARCoreView extends StatefulWidget {
  const ARCoreView({super.key});

  @override
  _ARCoreViewState createState() => _ARCoreViewState();
}

class _ARCoreViewState extends State<ARCoreView> {
  late ArCoreController arCoreController;

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ArCoreView(
      onArCoreViewCreated: _onARCoreViewCreated,
      enableTapRecognizer: true,
      enableUpdateListener: true,
    );
  }

  void _onARCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onNodeTap = (node) => _handleNodeTap(node);
    arCoreController.onPlaneTap = _onPlaneTap;
  }

  void _handleNodeTap(String node) {
    print('Node tapped: $node');
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    print('Plane tapped: ${hit.pose.translation}');

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<bool>(
          future: _addObject(hit),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!) {
              return AlertDialog(
                content: const Text('Error adding object'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            } else {
              return AlertDialog(
                content: const Text('Object added successfully'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Future<bool> _addObject(ArCoreHitTestResult hit) async {
    const String obj3dFileName = 'assets/models/sans_nom.glb';
    if (!await isAssetExists(obj3dFileName)) {
      print('File not found: $obj3dFileName');
      return false;
    }
    //File localFile = await copyAssetToFile(obj3dFileName);
    try {
      final node = ArCoreReferenceNode(
        name: 'Porche',
        objectUrl: "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF/Duck.gltf",
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
        // scale: Vector3(0.01, 0.01, 0.01),
      );

      print('Adding object: ${node.name} from file: ${node.object3DFileName}');

      await arCoreController.addArCoreNodeWithAnchor(node);
      print('Object added successfully');
      return true;
    } catch (e, stackTrace) {
      print('Error adding object: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> _checkFileExists(String filePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filePath');
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }
}
//version fonctionelle
// import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:vector_math/vector_math_64.dart' as vector;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   print('ARCORE IS AVAILABLE?');
//   print(await ArCoreController.checkArCoreAvailability());
//   print('\nAR SERVICES INSTALLED?');
//   print(await ArCoreController.checkIsArCoreInstalled());

//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(body: ARCoreView()),
//     );
//   }
// }

// class ARCoreView extends StatefulWidget {
//   const ARCoreView({super.key});

//   @override
//   _ARCoreViewState createState() => _ARCoreViewState();
// }

// class _ARCoreViewState extends State<ARCoreView> {
//   late ArCoreController arCoreController;

//   @override
//   void dispose() {
//     arCoreController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ArCoreView(
//       onArCoreViewCreated: _onARCoreViewCreated,
//       enableTapRecognizer: true,
//     );
//   }

//   void _onARCoreViewCreated(ArCoreController controller) {
//     arCoreController = controller;
//     arCoreController.onNodeTap = (node) => _handleNodeTap(node);
//     arCoreController.onPlaneTap = _onPlaneTap;
//   }

//   void _handleNodeTap(String node) {
//     print('Node tapped: $node');
//   }

//   void _onPlaneTap(List<ArCoreHitTestResult> hits) {
//     final hit = hits.first;
//     print('Plane tapped: ${hit.pose.translation}');
//     _addObject(hit);
//   }

//   Future<bool> _addObject(ArCoreHitTestResult plane) async {
//     try {
//       const url = "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb";
//       const fileName = "Duck.glb";
//       final localPath = await downloadAndSaveModel(url, fileName);

//       final node = ArCoreReferenceNode(
//         name: fileName,
//         object3DFileName: localPath,
//         //objectUrl:"https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
//         position: plane.pose.translation,
//         rotation: plane.pose.rotation,
//         //scale: vector.Vector3(0.01, 0.01, 0.01),
//       );

//       print('Adding object: ${node.name} from file: ${node.object3DFileName}');

//       await arCoreController.addArCoreNode(node);
//       print('Object added successfully');
//       return true;
//     } catch (e, stackTrace) {
//       print('Error adding object: $e');
//       print('Stack trace: $stackTrace');
//       return false;
//     }
//   }

//   Future<String> downloadAndSaveModel(String url, String fileName) async {
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/$fileName';
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);
//       return filePath;
//     } else {
//       throw Exception('Failed to download model');
//     }
//   }
// }
