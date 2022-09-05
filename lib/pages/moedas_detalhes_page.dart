import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aula_1/models/moeda.dart';
import 'package:intl/intl.dart';

class MoedasDetalhesPage extends StatefulWidget {
  Moeda moeda;

  MoedasDetalhesPage({Key? key, required this.moeda}) : super(key: key);

  @override
  State<MoedasDetalhesPage> createState() => _MoedasDetalhesPageState();
}

class _MoedasDetalhesPageState extends State<MoedasDetalhesPage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$'); // Formata o valor para reais
  final _form = GlobalKey<FormState>(); // Gera uma key (identificador) para o formulário
  final _valor = TextEditingController(); // Permite editar o texto valor e controlá-lo
  double quantidade = 0;

  /**
   * Método acionado ao clicar no botão comprar
   */
  comprar()
  {
    if(_form.currentState!.validate())
    {
      // Salvar a compra

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compra realizada com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moeda.nome),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    child: Image.asset(widget.moeda.icone),
                    ),
                  Container(width: 10), 
                  Text(
                    real.format(widget.moeda.preco),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            (quantidade) > 0 // Se a caixa de texto está com um valor acima de 0, a SizedBox é mostrada
            ? SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Container(
                margin: EdgeInsets.only(bottom: 24),
                alignment: Alignment.center,
                // padding: EdgeInsets.all(12),
                // decoration: BoxDecoration(color: Colors.teal.withOpacity(0.05)),
                child: Text(
                  '$quantidade ${widget.moeda.sigla}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.teal,
                  ),
                ),
              ),
            )
            : Container( // Se não, apenas um container vazio com margem é colocado
              margin: EdgeInsets.only(bottom: 24),
            ),

            Form( // Um widget de formulário
              key: _form, // Chave global gerado para o formulário em tempo de execução
              child: TextFormField( // Campo do formulário que estará sendo formatado e configurado
                controller: _valor,
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  suffix: Text(
                    'reais',
                    style: TextStyle(fontSize: 14),
                  )
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) { // Valida o texto digitado pelo usuário de acordo com as condições abaixo
                    if (value!.isEmpty)
                    {
                      return 'Informe o valor da compra';
                    }
                    else if (double.parse(value) < 50)
                    {
                      return 'Compra mínima é R\$ 50,00';
                    }
                    return null;
                  },
                onChanged: (value) { // Converte em tempo real o valor de reais para a moeda desejada, conformo o usuário for digitando
                  setState(() {
                    quantidade = (value.isEmpty)
                      ? 0
                      : double.parse(value) / widget.moeda.preco;
                  });
                },  
              ),
            ),
            Container( // Container para o botão de compra
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(top: 24),
              child: ElevatedButton(
                onPressed: () => comprar(),
                child: Row( // Utiliza-se um row para deixar o botão ocupando toda a tela (Exceto o valor de padding definido pelo body)
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Icon(Icons.check),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Comprar',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                )
              )
            )

          ],
        ),
       )
    );
  }
}