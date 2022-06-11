import 'package:crud_table_sqlite/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crud SQLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: "Catatan",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController judulController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  get index => null;

  @override
  void initState() {
    refreshCatatan();
    super.initState();
  }

  //ambil data from database
  List<Map<String, dynamic>> catatan = [];

  void refreshCatatan() async {
    final data = await SQLHelper.getCatatan();
    setState(() {
      catatan = data;
    });
  }

  void _DeleteFormDialog(Map data) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning!"),
            content: Text("Apakah kamu yakin?"),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    deleteCatatan(data["id"]);
                    Navigator.pop(context);
                  },
                  child: Text("Delete"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print(catatan);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: catatan.length,
          itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(5),
                child: ListTile(
                  title: Text(catatan[index]["judul"]),
                  subtitle: Text(catatan[index]["deskripsi"]),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () => modalForm(catatan[index]["id"]),
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.orangeAccent,
                            )),
                        IconButton(
                            onPressed: () => _DeleteFormDialog(catatan[index]),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ))
                      ],
                    ),
                  ),
                ),
              )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modalForm(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }

//  fungsi tambah
  Future<void> tambahCatatan() async {
    await SQLHelper.tambahCatatan(
        judulController.text, deskripsiController.text);
    refreshCatatan();
  }

//  fungsi ubah data
  Future<void> ubahCatatan(int id) async {
    await SQLHelper.ubahCatatan(
        id, judulController.text, deskripsiController.text);
    refreshCatatan();
  }

//  delete data
  Future<void> deleteCatatan(int id) async {
    await SQLHelper.deleteCatatan(
        id, judulController.text, deskripsiController.text);
    refreshCatatan();
  }

//  form tambah
  void modalForm(int? id) async {
    if (id != null) {
      final dataCatatan = catatan.firstWhere((element) => element["id"] == id);
      judulController.text = dataCatatan["judul"];
      deskripsiController.text = dataCatatan["deskripsi"];
    }

    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              height: 700,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: judulController,
                      decoration: const InputDecoration(hintText: "Judul"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: deskripsiController,
                      decoration: const InputDecoration(hintText: "Deskripsi"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (id == null) {
                            await tambahCatatan();
                            judulController.text = "";
                            deskripsiController.text = "";
                            Navigator.pop(context);
                          } else {
                            await ubahCatatan(id);
                            judulController.text = "";
                            deskripsiController.text = "";
                            Navigator.pop(context);
                          }
                        },
                        child: Text(id == null ? "Tambah" : "Ubah"))
                  ],
                ),
              ),
            ));
  }
}
