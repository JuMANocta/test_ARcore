import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
//import 'package:vector_math/vector_math_64.dart' as vector;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('ARCORE IS AVAILABLE?');
  print(await ArCoreController.checkArCoreAvailability());
  print('\nAR SERVICES INSTALLED?');
  print(await ArCoreController.checkIsArCoreInstalled());

  runApp(const MainApp());
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
    _addObject(hit);
  }

  Future<bool> _addObject(ArCoreHitTestResult plane) async {
    try {
      // const url = "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb";
      // const fileName = "Duck.glb";
      // final localPath = await downloadAndSaveModel(url, fileName);

      final node = ArCoreReferenceNode(
          name: 'test', //fileName,
          //object3DFileName: 'free_animals_-_quirky_series.glb',//localPath,
          objectUrl:
              "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
          position: plane.pose.translation,
          rotation: plane.pose.rotation);

      print('Adding object: ${node.name} from file: ${node.object3DFileName}');

      await arCoreController.addArCoreNode(node);
      print('Object added successfully');
      return true;
    } catch (e, stackTrace) {
      print('Error adding object: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Future<String> downloadAndSaveModel(String url, String fileName) async {
  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath = '${directory.path}/$fileName';
  //     final file = File(filePath);
  //     await file.writeAsBytes(response.bodyBytes);
  //     return filePath;
  //   } else {
  //     throw Exception('Failed to download model');
  //   }
  // }
}
