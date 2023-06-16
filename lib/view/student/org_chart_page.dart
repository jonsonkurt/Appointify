import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';


class OrgChartPage extends StatefulWidget {
  const OrgChartPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrgChartPage createState() => _OrgChartPage();
}

class _OrgChartPage extends State<OrgChartPage> {
  var json = {
    'nodes': [
      {'id': 1, 'label': 'President'},
      {'id': 2, 'label': 'Vice President'},
      {'id': 3, 'label': 'Secretary'},
      {'id': 4, 'label': 'Auditor'},
      {'id': 5, 'label': 'Treasurer'},
      {'id': 6, 'label': 'dot'},
      {'id': 7, 'label': 'square'},
      {'id': 8, 'label': 'triangle'},
    ],
    'edges': [
      {'from': 1, 'to': 2},
      {'from': 2, 'to': 3},
      {'from': 2, 'to': 4},
      {'from': 2, 'to': 5},
      {'from': 5, 'to': 6},
      {'from': 5, 'to': 7},
      {'from': 6, 'to': 8}
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Org Chart"),
          backgroundColor: Colors.orange,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Wrap(
              children: [
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.siblingSeparation.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Sibling Separation'),
                    onChanged: (text) {
                      builder.siblingSeparation = int.tryParse(text) ?? 100;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.levelSeparation.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Level Separation'),
                    onChanged: (text) {
                      builder.levelSeparation = int.tryParse(text) ?? 100;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.subtreeSeparation.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Subtree separation'),
                    onChanged: (text) {
                      builder.subtreeSeparation = int.tryParse(text) ?? 100;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.orientation.toString(),
                    decoration: const InputDecoration(labelText: 'Orientation'),
                    onChanged: (text) {
                      builder.orientation = int.tryParse(text) ?? 100;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.01,
                  maxScale: 5.6,
                  child: GraphView(
                    graph: graph,
                    algorithm: BuchheimWalkerAlgorithm(
                        builder, TreeEdgeRenderer(builder)),
                    paint: Paint()
                      ..color = Colors.black
                      ..strokeWidth = 1
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      // I can decide what widget should be shown here based on the id
                      var a = node.key!.value as int?;
                      var nodes = json['nodes']!;
                      var nodeValue =
                          nodes.firstWhere((element) => element['id'] == a);
                      return rectangleWidget(nodeValue['label'] as String?);
                    },
                  )),
            ),
          ],
        ));
  }

  Widget rectangleWidget(String? a) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.blue[100]!, spreadRadius: 1),
            ],
          ),
          child: Text('${a}')),
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    var edges = json['edges']!;
    edges.forEach((element) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    });

    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}
