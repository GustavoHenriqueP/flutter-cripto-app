import 'package:flutter/material.dart';
import 'package:flutter_aula_1/configs/app_setting.dart';
import 'package:flutter_aula_1/models/moeda.dart';
import 'package:flutter_aula_1/pages/moedas_detalhes_page.dart';
import 'package:flutter_aula_1/repositories/favoritas_repository.dart';
import 'package:flutter_aula_1/repositories/moeda_repository.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoedasPage extends StatefulWidget { ////StatefulWidget - Um Widget mutável

  const MoedasPage({Key? key}) : super(key: key);

  @override
  State<MoedasPage> createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  final tabela = MoedaRepository.tabela; //Pega a tabela de moedas e coloca nesta variável lista
  late NumberFormat real; //Com o package "intl", conseguimos formatar os números para diferntes unidades de medida, como moeda por exemplo
  late Map<String, String> loc;
  List<Moeda> selecionadas = []; //Lista de moedas selecionadas
  late FavoritasRepository favoritas;

  void readNumberFormat()
  {
    loc = context.watch<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  changeLanguageButton()
  {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final name = loc['name'] == 'R\$' ? '\$' : 'R\$';
    
    return PopupMenuButton(
      icon: Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.swap_vert),
            title: Text('Usar $locale'),
            onTap: () {
              context.read<AppSettings>().setLocale(locale, name);
              Navigator.pop(context);
            },
          ),
        ),
      ]
    );
  }

  AppBar appBarDinamica()
  {
    if(selecionadas.isEmpty) //Se lista de selecionadas estiver vazia, fica na AppBar padrão
    {
      return AppBar( //Barra do App
        title: const Text('Cripto Moedas'), //Título App
        actions: [
          changeLanguageButton(),
        ],
      );
    }
    else //Se lista de selecionadas não estiver vazia, fica na AppBar de selecionadas
    {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), 
          onPressed: () {
            setState(() {
              selecionadas = [];
            });
          }
        ),
        title: Text('${selecionadas.length} selecionadas'),
        backgroundColor: Colors.blueGrey[50],
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
           fontSize: 20,
           fontWeight: FontWeight.bold,
        )
      );
    }
  }

  /**
   * Método que fará a rota para a page "MoedasDetalhesPage"
   */
  void mostrarDetalhes(Moeda moeda)
  {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MoedasDetalhesPage(moeda: moeda,)
      ),
    );
  }

  void limparSelecionadas()
  {
    setState(() {
      selecionadas = [];
    });
  }

  @override
  Widget build(BuildContext context) { //Método build cria o widget em si
    // favoritas = Provider.of<FavoritasRepository>(context);
    favoritas = context.watch<FavoritasRepository>();
    readNumberFormat();

    return Scaffold( //Scaffold serve para formatar nossa tela em um MaterialApp
      appBar: appBarDinamica(),
      body: ListView.separated( //Corpo do App - Neste caso, uma ListView
        itemBuilder: (BuildContext context, int moeda) {
          return ListTile( //Método para alinhar e formatar componentes em uma linha da lista
            shape: RoundedRectangleBorder( //Ajusta os componentes da lista para um formato circular
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
            leading: (selecionadas.contains(tabela[moeda])) //Define um íncone da lista (lado esquerdo)
              ? CircleAvatar(
                  child: Icon(Icons.check), //Define um ícone de "Check"
                )
              : SizedBox( 
              width: 40,
              child: Image.asset(tabela[moeda].icone), //Caminho para o ícone das moedas
              ), 
            title: Row(
              children: [
                Text(
                  tabela[moeda].nome, 
                  style: TextStyle( //Título do componente
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if(favoritas.lista.contains(tabela[moeda]))
                  Icon(Icons.circle, color: Colors.amber, size: 8),
              ],
            ), 
            trailing: Text(real.format(tabela[moeda].preco)), //Texto presente no lado direito
            selected: selecionadas.contains(tabela[moeda]),
            selectedTileColor: Colors.indigo[50],
            onTap: () { //Clicando em uma moeda quando na lista de seleção, ela é selecionada. Porém se ela já está selecionada, ela é removida
              setState(() { //Altera o estado do widget, permitindo um rebuild
              if (selecionadas.isEmpty)
              {
                mostrarDetalhes(tabela[moeda]);
              }
              else if (selecionadas.isNotEmpty && !selecionadas.contains(tabela[moeda]))
              {
                selecionadas.add(tabela[moeda]);
              }
              else if (selecionadas.contains(tabela[moeda]))
                {
                  selecionadas.remove(tabela[moeda]);
                }
              });
            },
            onLongPress: () { //Pressionando em uma moeda, ativa a lista de seleção e adiciona a moeda pressionada na mesma
              setState(() {
                if (selecionadas.isEmpty)
                {
                  selecionadas.add(tabela[moeda]);
                }
              });
            },

          );
        }, 
        padding: const EdgeInsets.all(16), //Espaçamento em todas as laterais de um componente da lista
        separatorBuilder: (_, __) => Divider(),  //Separa os componentes da lista com linhas
        itemCount: tabela.length, //Tamanho da lista que será renderizada (Informação necessária para o Flutter)
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, //Define a posição do FAB no centro
        floatingActionButton: selecionadas.isNotEmpty //Verifica se está na tela de selecionadas
          ? FloatingActionButton.extended(
            onPressed: () {
              favoritas.saveAll(selecionadas);
              limparSelecionadas();
            },
            icon: Icon(Icons.star),
            label: Text(
              'FAVORITAR',
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
         : null,
    );
  }
}