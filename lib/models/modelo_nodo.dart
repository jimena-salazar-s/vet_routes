import 'package:flutter/material.dart';

class ModeloNodo {
  double x;
  double y;
  double radio;
  Color color;
  String titulo; // Nombre del paciente o veterinaria
  String tipo;   // 'domicilio' o 'clinica'

  ModeloNodo(this.x, this.y, this.radio, this.color, this.titulo, this.tipo);
}
