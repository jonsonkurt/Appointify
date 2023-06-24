import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin_add_org_chart.dart';
import 'admin_view_members_page.dart';

class OrgChartPage extends StatefulWidget {
  const OrgChartPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrgChartPage createState() => _OrgChartPage();
}

class _OrgChartPage extends State<OrgChartPage> {
  Map<String, List<Map<String, Object>>> schoolOrg = {"nodes": [], "edges": []};
  TransformationController transformationController =
      TransformationController();

  // List imagesURL = [];

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
      child: WillPopScope(
        onWillPop: () async {
          return false; // Disable back button
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFF274C77),
              title: const Text(
                "Org Chart",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: "GothamRnd",
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert), // Set the icon
                    onSelected: (value) {
                      // Handle menu item selection here
                      if (value == 'option1') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminViewMembers(),
                          ),
                        );
                      } else if (value == 'option2') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddOrgChartPage(),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'option1',
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: Colors.black,
                              ), // Icon for Option 1
                              SizedBox(width: 8), // Add some spacing
                              Text(
                                'View members',
                                style: TextStyle(
                                  fontFamily: 'GothamRnd',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'option2',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Colors.black,
                              ), // Icon for Option 2
                              SizedBox(width: 8), // Add some spacing
                              Text(
                                'Add a member',
                                style: TextStyle(
                                  fontFamily: 'GothamRnd',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    })
              ],
            ),
            body: StreamBuilder(
              stream: ref.orderByChild("rank").onValue,
              builder: (context, AsyncSnapshot snapshot) {
                dynamic values;

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
                        String pos1 = values[id.toString()]["position1"];
                        String pos2 = values[id.toString()]["position2"];
                        String pos3 = values[id.toString()]["position3"];
                        String faculty = values[id.toString()]["faculty"];
                        String imageURL = values[id.toString()]["imageURL"];
                        int intRank = int.parse(rank);
                        var newNode = {
                          "id": id,
                          "label": name,
                          "rank": intRank,
                          "position1": pos1,
                          "position2": pos2,
                          "position3": pos3,
                          "faculty": faculty,
                          "imageURL": imageURL,
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

                            if (entry1["position1"] == "Program Coordinator, BS Archi" ||
                                entry1["position2"] ==
                                    "Program Coordinator, BS Archi" ||
                                entry1["position3"] ==
                                    "Program Coordinator, BS Archi") {
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
                          Expanded(
                            child: InteractiveViewer(
                                constrained: false,
                                transformationController:
                                    TransformationController(
                                        transformationController.value =
                                            Matrix4.identity()
                                              ..translate(-760.0, 0, -100)
                                              ..scale(0.5)),
                                boundaryMargin: const EdgeInsets.all(500),
                                minScale: 0.1,
                                maxScale: 5.6,
                                child: GraphView(
                                  graph: graph,
                                  algorithm: BuchheimWalkerAlgorithm(
                                      builder, TreeEdgeRenderer(builder)),
                                  paint: Paint()
                                    ..color = Colors.black
                                    ..strokeWidth = 2
                                    ..style = PaintingStyle.stroke,
                                  builder: (Node node) {
                                    // I can decide what widget should be shown here based on the id
                                    var a = node.key!.value as int?;
                                    List<Map<String, dynamic>> nodes =
                                        schoolOrg['nodes']!;

                                    var nodeValue = nodes.firstWhere(
                                        (element) => element["id"] == a);
                                    int index = a! - 1;

                                    // print(imagesURL[index]);
                                    return rectangleWidget(
                                      nodeValue["label"] as String?,
                                      nodeValue["position1"] as String?,
                                      nodeValue["position2"] as String?,
                                      nodeValue["position3"] as String?,
                                      nodeValue["faculty"] as String?,
                                      nodeValue["imageURL"] as String?,
                                      nodeValue["id"].toString(),
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
      ),
    );
  }

  Widget rectangleWidget(
    String? a,
    String? position1,
    String? position2,
    String? position3,
    String? faculty,
    String? image,
    String? id,
  ) {
    return Column(
      children: [
        Container(
          height: 130,
          width: 130,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              )),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: image == ""
                  ? const Card(
                      elevation: 5.0,
                      shape: CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: Icon(
                        Icons.person,
                        size: 35,
                      ),
                    )
                  : Card(
                      elevation: 5.0,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: Image(
                        fit: BoxFit.cover,
                        image: NetworkImage(image!),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const CircularProgressIndicator();
                        },
                        errorBuilder: (context, object, stack) {
                          return const Icon(
                            Icons.error_outline,
                            color: Color.fromARGB(255, 35, 35, 35),
                          );
                        },
                      ),
                    )),
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 18,
              right: MediaQuery.of(context).size.width / 18,
              top: MediaQuery.of(context).size.width / 30),
          child: Column(
            children: [
              Container(
                width: 350,
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Color(0xFF6096BA),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      a!,
                      style: const TextStyle(
                          fontFamily: 'GothamRnd',
                          fontSize: 15,
                          color: Colors.white,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (position1 != "-")
                        Text(
                          position1!,
                          style: const TextStyle(
                              fontFamily: 'GothamRnd',
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      if (position2 != "-")
                        Text(
                          position2!,
                          style: const TextStyle(
                              fontFamily: 'GothamRnd',
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      if (position3 != "-")
                        Text(
                          position3!,
                          style: const TextStyle(
                              fontFamily: 'GothamRnd',
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      if (faculty != "-")
                        Text(
                          faculty!,
                          style: const TextStyle(
                              fontFamily: 'GothamRnd',
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                        ),
                      // Text(
                      //   '$position1\n$position2\n$position3\n$faculty',
                      //   style: const TextStyle(
                      //       fontFamily: 'GothamRnd',
                      //       fontSize: 15,
                      //       color: Colors.black,
                      //       decoration: TextDecoration.none),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Column(
        //   children: [
        //     Container(
        //         padding: const EdgeInsets.all(16),
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(4),
        //           boxShadow: [
        //             BoxShadow(color: Colors.blue[100]!, spreadRadius: 2),
        //           ],
        //         ),
        //         child: SizedBox(
        //           child: Column(
        //             children: [
        //               Container(
        //                 color: const Color(0xFF274C77),
        //               ),
        //               Text(
        //                   '${a}\n${position1}\n${position2}\n$position3\n$faculty'),
        //             ],
        //           ),
        //         )),
        //   ],
        // ),
      ],
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();
    // var edges = schoolOrg["edges"]!;

    // for (var element in edges) {
    //   var fromNodeId = element["from"];
    //   var toNodeId = element["to"];

    //   graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    // }

    // builder
    //   ..siblingSeparation = (100)
    //   ..levelSeparation = (150)
    //   ..subtreeSeparation = (150)
    //   ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);
  }
}
