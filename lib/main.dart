import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';

void main() async {
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
      final node = ArCoreReferenceNode(
          name: 'quirky_series',
          object3DFileName: 'assets/quirky_series.glb',
          //objectUrl: "https://github.com/JuMANocta/test_ARcore/raw/master/assets/free_animals_-_quirky_series.glb",
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
