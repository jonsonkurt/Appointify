import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:firebase_database/firebase_database.dart';

class OrgChartPage extends StatefulWidget {
  const OrgChartPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrgChartPage createState() => _OrgChartPage();
}

class _OrgChartPage extends State<OrgChartPage> {
  Map<String, List<Map<String, Object>>> schoolOrg = {"nodes": [], "edges": []};
  // // nodes
  List<Map<String, Object>> nodes = [];
  // var json = {
  //   'nodes': [
  //     {
  //       "id": 11,
  //       "label": "Ar. Brian",
  //       "rank": 6,
  //     },
  //     {
  //       "id": 12,
  //       "label": "Engr. Alvin",
  //       "rank": 5,
  //     },
  //     {
  //       "id": 13,
  //       "label": "Engr. Marcelino",
  //       "rank": 5,
  //     },
  //     {
  //       "id": 14,
  //       "label": "Engr. Ralph",
  //       "rank": 5,
  //     },
  //     {
  //       "id": 15,
  //       "label": "Prof. William",
  //       "rank": 5,
  //     },
  //     {
  //       "id": 1,
  //       "label": "Robles",
  //       "rank": 1,
  //     },
  //     {
  //       "id": 2,
  //       "label": "Dr. Ma. Agnes",
  //       "rank": 2,
  //     },
  //     {
  //       "id": 3,
  //       "label": "Dr. Willie",
  //       "rank": 3,
  //     },
  //     {
  //       "id": 4,
  //       "label": "Engr. Roslyn",
  //       "rank": 4,
  //     },
  //     {
  //       "id": 5,
  //       "label": "Engr. Larry",
  //       "rank": 5,
  //     },
  //     {
  //       "id": 6,
  //       "label": "Engr. Cene",
  //       "rank": 5,
  //     },
  //     {
  //       "id": 7,
  //       "label": "Engr. Renato",
  //       "rank": 5,
  //     },
  //     {
  //       "id": 8,
  //       "label": "Ar. Kenn",
  //       "rank": 5,
  //     },
  //     {
  //       "id": 9,
  //       "label": "Ar. Christian",
  //       "rank": 6,
  //     },
  //     {
  //       "id": 10,
  //       "label": "Ar. Dan",
  //       "rank": 6,
  //     },
  //   ],
  //   'edges': [
  //     {"from": 1, "to": 2},
  //     {"from": 2, "to": 3},
  //     {"from": 3, "to": 4},
  //     {"from": 4, "to": 12},
  //     {"from": 4, "to": 13},
  //     {"from": 4, "to": 14},
  //     {"from": 4, "to": 15},
  //     {"from": 4, "to": 5},
  //     {"from": 4, "to": 6},
  //     {"from": 4, "to": 7},
  //     {"from": 4, "to": 8},
  //     {"from": 8, "to": 11},
  //     {"from": 8, "to": 9},
  //     {"from": 8, "to": 10}
  //   ]
  // };

  @override
  Widget build(BuildContext context) {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('organizationChart');

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Org Chart"),
            backgroundColor: Colors.orange,
          ),
          body: StreamBuilder(
            stream: ref.orderByChild("rank").onValue,
            builder: (context, AsyncSnapshot snapshot) {
              dynamic values;
              // String latestRank = "";
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                DataSnapshot dataSnapshot = snapshot.data!.snapshot;
                if (dataSnapshot.value != null) {
                  values = dataSnapshot.value;

                  for (int index = 0; index < values.length; index++) {
                    if (values.keys.elementAt(index) != "null") {
                      int id = int.parse(values.keys.elementAt(index));
                      String name = values[id.toString()]["name"];
                      String rank = values[id.toString()]["rank"];
                      int intRank = int.parse(rank);
                      var newNode = {
                        "id": id,
                        "label": name,
                        "rank": intRank,
                      };
                      schoolOrg["nodes"]!.add(newNode);
                      nodes.add(newNode);
                    }
                  }
                }

                // print("Nodes sa taas: $nodes");
                // var jsonNodes = schoolOrg["nodes"];
                Map<String, dynamic> entry;

                Map<int, List<Map<String, Object>>> groupedData = {};
                for (entry in nodes) {
                  int rank = entry["rank"];

                  if (!groupedData.containsKey(rank)) {
                    groupedData[rank] = [];
                  }
                  groupedData[rank]!.add(entry.cast<String, Object>());
                }

                // Print the ranks and corresponding IDs and labels
                for (int rank = 1; rank <= 5; rank++) {
                  if (groupedData.containsKey(rank) &&
                      groupedData.containsKey(rank + 1)) {
                    List<Map<String, dynamic>> rankData1 = groupedData[rank]!;
                    List<Map<String, dynamic>> rankData2 =
                        groupedData[rank + 1]!;

                    // List<String> entries = [];

                    for (var entry1 in rankData1) {
                      for (var entry2 in rankData2) {
                        if (rank == 5) {
                          var newEdges = {
                            "from": entry1["id"],
                            "to": entry2["id"]
                          };
                          if (entry1["label"] == "Ar. Kenn") {
                            schoolOrg["edges"]!
                                .add(newEdges.cast<String, Object>());
                          }
                        } else {
                          var newEdges = {
                            "from": entry1["id"],
                            "to": entry2["id"]
                          };
                          schoolOrg["edges"]!
                              .add(newEdges.cast<String, Object>());
                        }
                      }
                    }
                  }
                }
                var edges = schoolOrg["edges"]!;
                print("titi: $edges");

                for (var element in edges) {
                  var fromNodeId = element["from"];
                  var toNodeId = element["to"];

                  graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
                }

                builder
                  ..siblingSeparation = (100)
                  ..levelSeparation = (150)
                  ..subtreeSeparation = (150)
                  ..orientation =
                      (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
                // schoolOrg = {"nodes": nodes, "edges": edges};

                // print(json.runtimeType);
                // print(json);
                // print(schoolOrg.runtimeType);
                // print(schoolOrg);
                // var edges = schoolOrg["edges"]!
                //     .map((element) => element as Map<String, Object>)
                //     .toList();

                // for (var element in edges) {
                //   var fromNodeId = element["from"];
                //   var toNodeId = element["to"];
                //   print("1::: ${fromNodeId}");
                //   print("2::: ${toNodeId}");
                // }

                // return Card();
                return SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Wrap(
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue:
                                    builder.siblingSeparation.toString(),
                                decoration: const InputDecoration(
                                    labelText: 'Sibling Separation'),
                                onChanged: (text) {
                                  builder.siblingSeparation =
                                      int.tryParse(text) ?? 100;
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue:
                                    builder.levelSeparation.toString(),
                                decoration: const InputDecoration(
                                    labelText: 'Level Separation'),
                                onChanged: (text) {
                                  builder.levelSeparation =
                                      int.tryParse(text) ?? 100;
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue:
                                    builder.subtreeSeparation.toString(),
                                decoration: const InputDecoration(
                                    labelText: 'Subtree separation'),
                                onChanged: (text) {
                                  builder.subtreeSeparation =
                                      int.tryParse(text) ?? 100;
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: builder.orientation.toString(),
                                decoration: const InputDecoration(
                                    labelText: 'Orientation'),
                                onChanged: (text) {
                                  builder.orientation =
                                      int.tryParse(text) ?? 100;
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: InteractiveViewer(
                              constrained: false,
                              boundaryMargin: const EdgeInsets.all(50),
                              minScale: 0.1,
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
                                  List<Map<String, Object>> nodes =
                                      schoolOrg['nodes']!;

                                  var nodeValue = nodes.firstWhere(
                                      (element) => element["id"] == a);

                                  return rectangleWidget(
                                    nodeValue["label"] as String?,
                                  );
                                },
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Text("hello");
            },
          )),
    );
  }

  Widget rectangleWidget(
    String? a,
  ) {
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
    super.initState();
    // var edges = schoolOrg["edges"]!;
    // print("titi: $edges");

    // for (var element in edges) {
    //   var fromNodeId = element["from"];
    //   var toNodeId = element["to"];

    //   graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    // }

    // builder
    //   ..siblingSeparation = (100)
    //   ..levelSeparation = (150)
    //   ..subtreeSeparation = (150)
    //   ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}
