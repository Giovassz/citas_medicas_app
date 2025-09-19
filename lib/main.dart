import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase (Android con google-services.json)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citas Médicas + Firebase',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference citasRef = FirebaseFirestore.instance.collection(
    'citas_prueba',
  );

  Future<void> _guardarCitaDePrueba() async {
    try {
      await citasRef.add({
        'paciente': 'Erick Estrella',
        'sintoma': 'Dolor de cabeza',
        'fecha': '2025-09-20', // Usamos el formato de la consigna
        'creadoEn': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cita de prueba guardada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al guardar: $e')));
      }
    }
  }

  String _renderItem(Map<String, dynamic> data) {
    final p = data['paciente'] ?? '—';
    final s = data['sintoma'] ?? '—';
    final f = data['fecha'] ?? '—';
    return 'Paciente $p tiene cita por $s el ${_formateaFecha(f)}';
  }

  String _formateaFecha(String iso) {
    // Espera 'YYYY-MM-DD' y muestra 'DD/MM/YYYY'
    final parts = iso.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return iso;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citas Médicas + Firebase')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Firebase OK ✅',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _guardarCitaDePrueba,
                    icon: const Icon(Icons.add),
                    label: const Text('Guardar cita de prueba'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lectura (opcional):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: citasRef
                  .orderBy('creadoEn', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No hay citas aún.'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: Text(_renderItem(data)),
                      subtitle: Text('ID: ${docs[index].id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
