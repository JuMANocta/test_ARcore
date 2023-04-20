import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

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
    try {
      final node = ArCoreReferenceNode(
        name: 'Porche',
        object3DFileName: 'free_animals_-_quirky_series.glb',
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
        scale: Vector3(0.01, 0.01, 0.01),
      );

      print('Adding object: ${node.name} from file: ${node.object3DFileName}');

      await arCoreController.addArCoreNodeWithAnchor(node);
      print('Object added successfully');
      return true;
    } catch (e) {
      print('Error adding object: $e');
      return false;
    }
  }
}
