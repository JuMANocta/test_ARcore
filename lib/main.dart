import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';

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
    _addObject(hit);
  }

  Future<void> _addObject(ArCoreHitTestResult hit) async {
    try {
      final node = ArCoreReferenceNode(
        name: 'Porche',
        object3DFileName: 'assets/models/free_animals_-_quirky_series.glb',
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
      );

      print('Adding object: ${node.name} from file: ${node.object3DFileName}');

      arCoreController.addArCoreNodeWithAnchor(node);
      print('Object added successfully');
    } catch (e) {
      print('Error adding object: $e');
    }
  }
}
