import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'widgets/menu.dart';

class Rota extends StatefulWidget {
  const Rota({super.key});

  @override
  State<Rota> createState() => _RotaState();
}

class _RotaState extends State<Rota> {
  final LatLng _pontoInicial = LatLng(-22.7130000, -46.8180000); //SESI Amparo
  String mensagem = 'Destino: Clique em um ponto no mapa';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map traçar Rota")),
      drawer: Menu.ops(context),
      body: Center(
        child: Column(
          children: [
            Text(
              'Origem: @${_pontoInicial.latitude}, ${_pontoInicial.longitude}',
            ),
            Text(mensagem),
          ],
        ),
      ),
    );
  }
}
