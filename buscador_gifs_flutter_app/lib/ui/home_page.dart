import 'dart:convert';

import 'package:buscador_gifs_flutter_app/ui/gif_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String _search = null;//é a variavel que vai fazer a busca dentro do api "$_search"
  int _offSet=0;//é a variavel que vai definir o offset dentro da api"$_offSet"
  
  Future<Map> _getGifs() async{
    http.Response response;
    
    if(_search == null)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=IYZFiE8uyDVNhOPEhXPzsBoxdMrnSCT3&limit=20&rating=G ");//vai aguardar a resposta do site os melhores gifs
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=IYZFiE8uyDVNhOPEhXPzsBoxdMrnSCT3&q=$_search&limit=19&offset=$_offSet&rating=G&lang=en");//os gifs escolhidos

    return json.decode(response.body);
  }


  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {

     // print(map);

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://www.quixada.ufc.br/wp-content/uploads/2017/10/logo.png"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){    //vai receber as informações que vão ser escritas pelo teclado!
                _search = text; //guarda o texto em _search
                setState(() { // atualiza a tela
                  _search = text;
                  _offSet = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){//enquanto os dados estão sendo carregados, vai haver um ícone de carregamento
                if((snapshot.connectionState == ConnectionState.waiting)|| (snapshot.connectionState==ConnectionState.none)){


                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation <Color>(Colors.white),

                        strokeWidth: 5.0,
                      ),

                    );


                }else if(snapshot.hasError)
                  return Container();
                else
                  return _createGifTable(context,snapshot, _search, _offSet);
              }
            ),
          ),
        ],
      ),
    );
  }
}

int _getCount(List data, String a){
  if (a == null){
    return data.length;
  }else{
   return data.length + 1;
  }
}

Widget _createGifTable(BuildContext, AsyncSnapshot snapshot, String a, int b){
  return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0
      ),
      itemCount:_getCount(snapshot.data["data"],a),  // é o número de componentes " de quadradinhos" que vão ser exibidos
      itemBuilder: (context,index){
        if(a == null || index<snapshot.data["data"].length) {
          return GestureDetector( // permite clicar na imagem e mostrar ela em outra página
            child:FadeInImage.memoryNetwork(placeholder: kTransparentImage, //vai carregar uma tela tranparente enquanto busca as informações para exibir os gifs
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>GifPage(snapshot.data["data"][index]))
              );
            },
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
        }else {
          return Container(
            child: GestureDetector(
              child: Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Icon(Icons.add, color: Colors.white, size: 70.0,),
              Text("Carregar mais...",
                  style: TextStyle(color: Colors.white,fontSize: 22.0),)
              ],
            ),
              onTap: (){
        setState(){
        b += 1;
        };

        },
  ));
      };
      }
  );

}