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
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Text('Agrega una imagen en assets/images/mapa.png'),
                    ),
                  ),
                ),
              ),

              // 1.1 CAPA DE TRANSPARENCIA (Velo sutil para atenuar el mapa)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.2), // Puedes ajustar la opacidad (0.1 a 0.3)
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
                    _manejarToqueEnCanvas(x, y);
                  } else if (modo == 3) {
                    setState(() {
                      posGlobal = ubicaNodo(x, y);
                    });
                  } else if (modo == 4) { // Modo Conectar Aristas
                    ModeloNodo? nodoTocado;
                    for (var nodo in vNodo) {
                      double distancia = sqrt(pow(nodo.x - x, 2) + pow(nodo.y - y, 2));
                      if (distancia <= nodo.radio) {
                        nodoTocado = nodo;
                        break;
                      }
                    }

                    if (nodoTocado != null) {
                      if (nodoOrigen == null) {
                        nodoOrigen = nodoTocado;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nodo origen seleccionado. Toca el nodo destino.')),
                        );
                      } else {
                        _conectarNodos(nodoOrigen!, nodoTocado);
                        nodoOrigen = null; 
                      }
                    }
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
            // Botón Agregar
            IconButton(
              onPressed: () => setState(() { modo = 1; nodoOrigen = null; }),
              icon: Icon(Icons.add_location, color: modo == 1 ? Colors.teal : Colors.grey, size: 30),
              tooltip: 'Agregar Nodo',
            ),
            // Botón Borrar
            IconButton(
              onPressed: () => setState(() { modo = 2; nodoOrigen = null; }),
              icon: Icon(Icons.delete, color: modo == 2 ? Colors.teal : Colors.grey, size: 30),
              tooltip: 'Borrar Nodo',
            ),
            // Botón Mover
            IconButton(
              onPressed: () => setState(() { modo = 3; nodoOrigen = null; }),
              icon: Icon(Icons.open_with, color: modo == 3 ? Colors.teal : Colors.grey, size: 30),
              tooltip: 'Mover Nodo',
            ),
            // Botón Conectar Aristas
            IconButton(
              onPressed: () => setState(() { modo = 4; }),
              icon: Icon(Icons.timeline, color: modo == 4 ? Colors.teal : Colors.grey, size: 30),
              tooltip: 'Conectar Nodos',
            ),
            // Botón Calcular Ruta Óptima (Priorizando Urgencias)
            IconButton(
              onPressed: () {
                setState(() {
                  modo = -1;
                  nodoOrigen = null;
                });
                _calcularRutaOptima();
              },
              icon: const Icon(Icons.alt_route, color: Colors.amber, size: 30),
              tooltip: 'Calcular Ruta Óptima',
            ),
          ],
        ),
      ),
    );
  }

  // Ventana emergente con la opción de Punto de Inicio
  void _mostrarDialogoTipoNodo(double x, double y) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tipo de Punto Veterinario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.amber),
                title: const Text('Punto de Inicio 🏁'),
                onTap: () {
                  _agregarNodoAlCanvas(x, y, 'Inicio', Colors.amber, 'I', esInicio: true);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
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

  void _manejarToqueEnCanvas(double x, double y) {
    setState(() {
      if (modo == 2) { // Modo Borrar
        ModeloNodo? nodoAEliminar;
        for (var nodo in vNodo) {
          double distancia = sqrt(pow(nodo.x - x, 2) + pow(nodo.y - y, 2));
          if (distancia <= nodo.radio) {
            nodoAEliminar = nodo;
            break;
          }
        }

        if (nodoAEliminar != null) {
          vArista.removeWhere((a) => a.origen == nodoAEliminar || a.destino == nodoAEliminar);
          vNodo.remove(nodoAEliminar);
          return;
        }

        vArista.removeWhere((arista) => _tocaArista(x, y, arista));
      }
    });
  }

  void _agregarNodoAlCanvas(double x, double y, String tipo, Color color, String prefijo, {bool esInicio = false}) {
    setState(() {
      if (esInicio) {
        for (var nodo in vNodo) {
          nodo.esInicio = false;
          if (nodo.tipo == 'Inicio') {
            nodo.tipo = 'Veterinaria';
            nodo.color = Colors.blue;
            nodo.titulo = 'V${vNodo.indexOf(nodo) + 1}';
          }
        }
      }

      double radio = 15;
      String titulo = esInicio ? 'Inicio' : '$prefijo${vNodo.length + 1}';
      vNodo.add(ModeloNodo(x, y, radio, color, titulo, tipo, esInicio: esInicio));
    });
  }

  void _conectarNodos(ModeloNodo origen, ModeloNodo destino) {
    if (origen == destino) return;

    if (!_puedeConectarNodo(origen) || !_puedeConectarNodo(destino)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este nodo ya tiene el máximo de conexiones permitidas (2).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool yaExiste = vArista.any((a) => 
      (a.origen == origen && a.destino == destino) || 
      (a.origen == destino && a.destino == origen)
    );

    if (!yaExiste) {
      setState(() {
        vArista.add(ModeloArista(origen, destino));
      });
    }
  }

  void _calcularRutaOptima() {
    if (vNodo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay nodos en el mapa para calcular ruta.')),
      );
      return;
    }

    bool tieneInicio = vNodo.any((n) => n.esInicio);
    if (!tieneInicio) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Falta Punto de Inicio ⚠️'),
          content: const Text('Por favor, define un punto de inicio antes de calcular la ruta.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    ModeloNodo inicio = vNodo.firstWhere((n) => n.esInicio);
    List<ModeloNodo> pendientes = vNodo.where((n) => !n.esInicio).toList();

    setState(() {
      vArista.clear();
      List<ModeloNodo> ruta = [inicio];
      ModeloNodo actual = inicio;

      while (pendientes.isNotEmpty) {
        pendientes.sort((a, b) {
          if (a.tipo == 'Urgencia' && b.tipo != 'Urgencia') return -1;
          if (a.tipo != 'Urgencia' && b.tipo == 'Urgencia') return 1;
          
          double distA = sqrt(pow(a.x - actual.x, 2) + pow(a.y - actual.y, 2));
          double distB = sqrt(pow(b.x - actual.x, 2) + pow(b.y - actual.y, 2));
          return distA.compareTo(distB);
        });

        ModeloNodo siguiente = pendientes.removeAt(0);
        vArista.add(ModeloArista(actual, siguiente));
        ruta.add(siguiente);
        actual = siguiente;
      }

      for (int i = 0; i < ruta.length; i++) {
        ruta[i].orden = i + 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Ruta optimizada desde el punto de inicio!'),
        backgroundColor: Colors.teal.shade700,
      ),
    );
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

  bool _tocaArista(double tapX, double tapY, ModeloArista arista) {
    double x1 = arista.origen.x;
    double y1 = arista.origen.y;
    double x2 = arista.destino.x;
    double y2 = arista.destino.y;

    double A = tapX - x1;
    double B = tapY - y1;
    double C = x2 - x1;
    double D = y2 - y1 == 0 && x2 - x1 == 0 ? 1 : y2 - y1; 

    if (C == 0 && D == 0) return sqrt(pow(tapX - x1, 2) + pow(tapY - y1, 2)) < 15;

    double dot = A * C + B * D;
    double lenSq = C * C + D * D;
    double param = -1;
    if (lenSq != 0) param = dot / lenSq;

    double xx, yy;
    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    double distancia = sqrt(pow(tapX - xx, 2) + pow(tapY - yy, 2));
    return distancia < 15.0;
  }

  bool _puedeConectarNodo(ModeloNodo nodo) {
    int conexionesActuales = vArista.where((a) => a.origen == nodo || a.destino == nodo).length;
    return conexionesActuales < 2;
  }
}
