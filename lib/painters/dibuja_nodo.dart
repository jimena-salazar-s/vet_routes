import 'package:flutter/material.dart';
import 'package:vet_routes/models/modelo_nodo.dart';
import 'package:vet_routes/models/modelo_arista.dart';

class DibujaNodo extends CustomPainter {
  List<ModeloNodo> vNodo;
  List<ModeloArista> vArista;
  ModeloNodo? nodoOrigen;

  DibujaNodo(this.vNodo, this.vArista, this.nodoOrigen);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Pincel para las líneas de la ruta
    Paint paintLinea = Paint()
      ..color = Colors.blueGrey.shade700
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (var arista in vArista) {
      canvas.drawLine(
        Offset(arista.origen.x, arista.origen.y),
        Offset(arista.destino.x, arista.destino.y),
        paintLinea,
      );
    }

    // 2. Pincel para los nodos (círculos)
    Paint paintNodo = Paint()..style = PaintingStyle.fill;

    for (var ele in vNodo) {
      // Feedback visual: si es el nodo origen seleccionado, lo oscurecemos
      if (ele == nodoOrigen) {
        paintNodo.color = Colors.amber.shade800;
      } else {
        paintNodo.color = ele.color;
      }

      canvas.drawCircle(Offset(ele.x, ele.y), ele.radio, paintNodo);

      // Dibujar texto o etiqueta dentro del nodo (opcional para identificarlo)
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: ele.titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(ele.x - (textPainter.width / 2), ele.y - (textPainter.height / 2)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
