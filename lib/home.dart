import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vet_routes/models/modelo_nodo.dart';
import 'package:vet_routes/models/modelo_arista.dart';
import 'package:vet_routes/painters/dibuja_nodo.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int modo = -1; 
  int posGlobal = -1;

  List<ModeloNodo> vNodo = [];
  List<ModeloArista> vArista = [];
  ModeloNodo? nodoOrigen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas Veterinarias 🐾'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              // 1. MAPA DE FONDO
              Positioned.fill(
                child: Image.asset(
                  'assets/images/mapa.png',
                  fit: BoxFit.cover,
                  // Si aún no tienes la imagen puesta, puedes comentar estas líneas o poner un color de respaldo:
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Text('Agrega una imagen en assets/images/mapa.png'),
                    ),
                  ),
                ),
              ),

              // 2. LIENZO DE NODOS Y ARISTAS
              CustomPaint(
                size: Size.infinite,
                painter: DibujaNodo(vNodo, vArista, nodoOrigen),
              ),

              // 3. DETECTOR DE GESTOS
              GestureDetector(
                onPanDown: (desp) {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  Offset localPosition = renderBox.globalToLocal(desp.globalPosition);

                  double x = localPosition.dx;
                  double y = localPosition.dy;

                  if (modo == 1) {
                    // MODO 1: Agregar nodo (Abrimos un diálogo para elegir el tipo)
                    _mostrarDialogoTipoNodo(x, y);
                  } else if (modo == 2) {
                    setState(() {
                      int pos = ubicaNodo(x, y);
                      if (pos >= 0) {
                        vArista.removeWhere((arista) =>
                            arista.origen == vNodo[pos] ||
                            arista.destino == vNodo[pos]);
                        vNodo.removeAt(pos);
                      }
                    });
                  } else if (modo == 3) {
                    setState(() {
                      posGlobal = ubicaNodo(x, y);
                    });
                  } else if (modo == 4) {
                    setState(() {
                      int pos = ubicaNodo(x, y);
                      if (pos >= 0) {
                        if (nodoOrigen == null) {
                          nodoOrigen = vNodo[pos];
                        } else {
                          if (nodoOrigen != vNodo[pos]) {
                            vArista.add(ModeloArista(nodoOrigen!, vNodo[pos]));
                          }
                          nodoOrigen = null;
                        }
                      } else {
                        nodoOrigen = null;
                      }
                    });
                  }
                },
                onPanUpdate: (desp) {
                  setState(() {
                    if (posGlobal >= 0 && modo == 3) {
                      RenderBox renderBox = context.findRenderObject() as RenderBox;
                      Offset localPosition = renderBox.globalToLocal(desp.globalPosition);

                      vNodo[posGlobal].x = localPosition.dx;
                      vNodo[posGlobal].y = localPosition.dy;
                    }
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    posGlobal = -1;
                  });
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => setState(() { modo = 1; nodoOrigen = null; }),
              icon: Icon(Icons.add_location, color: modo == 1 ? Colors.teal : Colors.grey, size: 30),
            ),
            IconButton(
              onPressed: () => setState(() { modo = 2; nodoOrigen = null; }),
              icon: Icon(Icons.delete, color: modo == 2 ? Colors.teal : Colors.grey, size: 30),
            ),
            IconButton(
              onPressed: () => setState(() { modo = 3; nodoOrigen = null; }),
              icon: Icon(Icons.open_with, color: modo == 3 ? Colors.teal : Colors.grey, size: 30),
            ),
            IconButton(
              onPressed: () => setState(() { modo = 4; }),
              icon: Icon(Icons.timeline, color: modo == 4 ? Colors.teal : Colors.grey, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  // Ventana emergente para clasificar el nodo según el requerimiento del veterinario
  void _mostrarDialogoTipoNodo(double x, double y) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tipo de Visita Veterinaria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.blue),
                title: const Text('Centro Veterinario'),
                onTap: () {
                  _agregarNodoAlCanvas(x, y, 'Veterinaria', Colors.blue, 'V');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.teal),
                title: const Text('Domicilio (Cita)'),
                onTap: () {
                  _agregarNodoAlCanvas(x, y, 'Domicilio', Colors.teal, 'D');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Urgencia'),
                onTap: () {
                  _agregarNodoAlCanvas(x, y, 'Urgencia', Colors.red, 'U');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _agregarNodoAlCanvas(double x, double y, String tipo, Color color, String prefijo) {
    setState(() {
      double radio = 15;
      String titulo = '$prefijo${vNodo.length + 1}';
      vNodo.add(ModeloNodo(x, y, radio, color, titulo, tipo));
    });
  }

  int ubicaNodo(double xB, double yB) {
    for (int i = 0; i < vNodo.length; i++) {
      double dist = sqrt(pow(vNodo[i].x - xB, 2) + pow(vNodo[i].y - yB, 2));
      if (dist <= vNodo[i].radio) {
        return i;
      }
    }
    return -1;
  }
}
