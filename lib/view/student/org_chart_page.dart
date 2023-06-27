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
  TransformationController transformationController =
      TransformationController();
  bool isOrgChartComplete = false;
  List<String> neededPosition = [];

  Future<List<String>> checkPositions() async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('organizationChart');

    DatabaseEvent event = await databaseReference.once();

    List<String> positions = [
      'University President',
      'Vice President for Academic Affairs',
      'Dean',
      'Department Chairperson',
      'BSCE Program Coordinator',
      'Department Secretary',
      'Job Placement Officer',
      'OJT Coordinator',
      'Department Extension Coordinator',
      'Budget Officer/Property Custodian',
      'Department BSCE Research Coordinator',
      'GAD Coordinator',
      'In-Charge Knowledge Management Unit',
      'Program Coordinator, BS Archi',
      'Research Coordinator, BS Archi'
    ];

    Set<String> takenPositions = <String>{};

    if (event.snapshot.value != null) {
      Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      values?.forEach((key, value) {
        Map<String, dynamic> childData = Map<String, dynamic>.from(value);
        if (childData['position1'] != null) {
          takenPositions.add(childData['position1']);
        }
        if (childData['position2'] != null) {
          takenPositions.add(childData['position2']);
        }
        if (childData['position3'] != null) {
          takenPositions.add(childData['position3']);
        }
      });
    }

    List<String> availablePositions = positions
        .where((position) => !takenPositions.contains(position))
        .toList();

    if (availablePositions.isEmpty) {
      // print('None');
      isOrgChartComplete = true;
      return [];
    } else {
      // print(availablePositions);
      neededPosition = availablePositions;
      return availablePositions;
    }
  }

  // // List imagesURL = [];

  // // nodes
  List<Map<String, Object>> nodes = [];

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

                  if (isOrgChartComplete) {
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
                                                ..translate(
                                                    -MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        0.28,
                                                    0,
                                                    -100)
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
                                      // int index = a! - 1;

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
                }
                return const Center(
                  child: Text(
                      "Waiting for admin to complete the organizational chart"),
                );
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    checkPositions();
    super.initState();
  }
}
