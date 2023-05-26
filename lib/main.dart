import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await checkFileExists()) {
    runApp(const MainApp());
  } else {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('File does not exist'),
        ),
      ),
    ));
  }
}

Future<bool> checkFileExists() async {
  const String fileName = 'assets/quirky_series.glb';
  try {
    await rootBundle.load(fileName);
    print('File exists');
    return true;
  } catch (e) {
    print('File does not exist ' + e.toString());
    return false;
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
      final node = ArCoreReferenceNode(
          name: 'test',
          //object3DFileName: 'assets/porsche.obj',
          //objectUrl: "https://github.com/JuMANocta/test_ARcore/raw/master/assets/quirky_series.glb",
          objectUrl: "https://github.com/JuMANocta/test_ARcore/raw/master/assets/quirky_series.glb",
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
}
