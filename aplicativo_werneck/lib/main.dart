import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'dart:convert';
import 'package:loading/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Pokedex'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map> data = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<Map> getUrlData(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      Map body = jsonDecode(response.body);
      String name = body["name"];
      String abilities = "";
      for (int i = 0; i < body["abilities"].length; i++) {
        String abilityName = body["abilities"][i]["ability"]["name"];
        if (i > 0) abilities += " | ";
        abilities += abilityName;
      }
      return {
        "titulo": name,
        "subtitulo": abilities,
        "isFav": false,
      };
    } else {
      return null;
    }
  }

  Future<void> getData() async {
    for (int i = 1; i <= 10; i++) {
      String url = 'https://pokeapi.co/api/v2/pokemon/' + i.toString();
      Map pokemon = await getUrlData(url);
      String imageUrl = 'http://pokeres.bastionbot.org/images/pokemon/' + i.toString() + '.png';
      if (pokemon != null) {
        pokemon["imageUrl"] = imageUrl;
        data.add(pokemon);
      }
    }
    setState(() {});
  }

  void onTapListItem(String titulo) {
    for (int i = 0; i < data.length; i++) {
      if (data[i]["titulo"] == titulo) {
        setState(() {
          data[i]["isFav"] = !data[i]["isFav"];
        });
      }
    }
  }

  Widget buildListItem(String titulo, String subtitulo, bool isFav, String imageUrl) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: ListTile(
        onTap: () {
          onTapListItem(titulo);
        },
        leading: Image.network(imageUrl),
        trailing: Icon(isFav ? Icons.star : Icons.star_border,
            size: 40, color: Colors.orangeAccent),
        title: Text(titulo,
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
      ),
    );
  }

  Widget buildList() {
    List<Widget> listItem = [];
    for (int i = 0; i < data.length; i++) {
      listItem.add(buildListItem(
          data[i]["titulo"], data[i]["subtitulo"], data[i]["isFav"], data[i]["imageUrl"]));
    }
    return Container(
      color: Colors.lightBlue.withOpacity(0.2),
      child: ListView(
        children: listItem,
      ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: Colors.lightBlueAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: data.length > 0 ? buildList(): buildLoading(),
    );
  }
}
