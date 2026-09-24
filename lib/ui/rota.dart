import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'widgets/menu.dart';

class Rota extends StatefulWidget {
  const Rota({super.key});

  @override
  State<Rota> createState() => _RotaState();
}

class _RotaState extends State<Rota> {
  final _pontoInicial = LatLng(-22.7130000, -46.8180000); //SESI Amparo
  LatLng? _pontoClicado;
  Set<Polyline> _Rotas = {};
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
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _pontoInicial, // SESI Amparo
                  initialZoom: 17.0,
                  onTap: (tapPosition, latLng) {
                    setState(() {
                      _pontoClicado = latLng;
                      mensagem =
                          'Destino: @${latLng.latitude}, ${latLng.longitude}';
                      buscarRota(_pontoInicial, latLng);
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.flutter_obter_posicao_map',
                  ),
                  PolylineLayer(polylines: _Rotas.toList()),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pontoInicial,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                      if (_pontoClicado != null)
                        Marker(
                          point: _pontoClicado!,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> buscarRota(LatLng origem, LatLng destino) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origem.longitude},${origem.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      final pontos = coords.map((c) {
        return LatLng(c[1].toDouble(), c[0].toDouble());
      }).toList();

      setState(() {
        _Rotas = {
          Polyline(points: pontos, color: Colors.blue, strokeWidth: 5.0),
        };
      });
    }
  }
}
