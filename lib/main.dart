import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=846fee7c";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          //estabelece um pre tema diferene
          inputDecorationTheme: InputDecorationTheme(
              prefixStyle: TextStyle(color: Colors.amber),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))))));
}

Future<Map> getData() async {
  //auxilio obter dados que demoram
  http.Response response =
      await http.get(request); //demora um pouco pra chegar entao eleespera
  print(json.decode(response.body));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realControler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroControler = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarControler.text = (real / dolar).toStringAsFixed(2);
    euroControler.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realControler.text = (dolar * this.dolar).toStringAsFixed(2);
    euroControler.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realControler.text = (euro * this.euro).toStringAsFixed(2);
    dolarControler.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _limpaTudo() {
    //limpa os valores nos campos da tela
    realControler.text = "";
    dolarControler.text = "";
    euroControler.text = "";
  }

  @override
  Widget build(BuildContext context) {
    //construtor com os widgets
    return Scaffold(
      //constroi o basico da pagina com gavetas
      backgroundColor: Colors.black, //cor de fundo
      appBar: AppBar(
        //e nela temos uma barra superior
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: FutureBuilder(
        //o que esta dentro da pagina sera reconstruido no futuro
        future:
            getData(), //analisando o que sera feito em funçao do tempo de get do site
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:

            case ConnectionState.waiting: //enquanto estiver esperando get
              return Center(
                child: CircularProgressIndicator(
                    backgroundColor: Colors.amber), //loading
              );

            default: //quando termina
              if (snapshot.hasError) {
                //caso der erro retorna mensagem
                return Center(
                    child: Text(
                  "Erro ao Carregar Dados",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                //
                //
                return SingleChildScrollView(
                  //permite rolar a tela caso fique cheia
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, //alinha no centro horizontalmente
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      Divider(),
                      //
                      buildTextField("Reais", "R\$", realControler,
                          _realChanged, _limpaTudo),
                      Divider(),
                      //
                      buildTextField("Dolares", "US\$", dolarControler,
                          _dolarChanged, _limpaTudo),
                      Divider(),
                      //
                      buildTextField("Euros", "€", euroControler, _euroChanged,
                          _limpaTudo),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c,
    Function f, Function Limpa) {
  //cria a minha entrada de texto
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
        fontSize: 25.0,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f,
    onTap:
        Limpa, //se tocar no campo de inserir texto, chama a função passada (limpa, ou _limpaTudo)
    keyboardType: TextInputType.number,
  );
}
