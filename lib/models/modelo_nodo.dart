import 'package:flutter/material.dart';

class ModeloNodo {
  double x;
  double y;
  double radio;
  Color color;
  String titulo;
  String tipo;   // 'Veterinaria', 'Domicilio', 'Urgencia', 'Inicio'
  int? orden;    // Número de secuencia en la ruta
  bool esInicio; // Bandera para identificar el punto de partida

  ModeloNodo(
    this.x,
    this.y,
    this.radio,
    this.color,
    this.titulo,
    this.tipo, {
    this.orden,
    this.esInicio = false,
  });
}
