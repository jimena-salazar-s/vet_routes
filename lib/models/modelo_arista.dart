import 'dart:math';
import 'package:vet_routes/models/modelo_nodo.dart';

class ModeloArista {
  ModeloNodo origen;
  ModeloNodo destino;
  late double peso; // Distancia o costo de la ruta

  ModeloArista(this.origen, this.destino) {
    peso = sqrt(pow(destino.x - origen.x, 2) + pow(destino.y - origen.y, 2));
  }
}
