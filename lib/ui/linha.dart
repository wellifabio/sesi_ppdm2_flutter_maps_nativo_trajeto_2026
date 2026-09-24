import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'widgets/menu.dart';

class Linha extends StatefulWidget {
  const Linha({super.key});

  @override
  State<Linha> createState() => _LinhaState();
}

class _LinhaState extends State<Linha> {
  LatLng _pontoInicial = LatLng(-22.7130000, -46.8180000); //SESI Amparo
  LatLng? _pontoClicado;
  Set<Polyline> _linhas = {};
  String mensagem = 'Destino: Clique em um ponto no mapa';

  @override
  void initState() {
    super.initState();
    obterCoordenadasGPS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map traçar linha")),
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
                      atualizarLinha();
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
                  PolylineLayer(polylines: _linhas.toList()),
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

  Future<void> obterCoordenadasGPS() async {
    bool servicoAtivo;
    LocationPermission permissao;
    servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      return Future.error('O serviço de localização está desativado.');
    }
    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permissão de localização negada.')),
          );
        }
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permissão negada permanentemente. Altere nas configurações.',
            ),
          ),
        );
      }
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(),
    );
    setState(() {
      _pontoInicial = LatLng(position.latitude, position.longitude);
    });
    atualizarLinha();
  }

  void atualizarLinha() {
    if (_pontoClicado == null) {
      _linhas = {};
      return;
    }

    final pontos = [_pontoInicial, _pontoClicado!];
    _linhas = {Polyline(points: pontos, color: Colors.blue, strokeWidth: 4.0)};
  }
}
