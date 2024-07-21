import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Police App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, 
      appBar: AppBar(
        title: Text('Police App', style: TextStyle( fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.blue[800], 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Título
            Text(
              'Police App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            // Botones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IncidentRegistrationScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.app_registration, color: Colors.white),
                      label: Text('Registro', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700], // Fondo del botón
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.info, color: Colors.white),
                      label: Text('Acerca de', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700], // Fondo del botón
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IncidentsListScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.list, color: Colors.white),
                      label: Text('Lista', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700], 
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncidentRegistrationScreen extends StatefulWidget {
  @override
  _IncidentRegistrationScreenState createState() => _IncidentRegistrationScreenState();
}

class _IncidentRegistrationScreenState extends State<IncidentRegistrationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _image;
  String? _audioPath;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _recordAudio() async {
    
    await Permission.microphone.request();
    if (await Permission.microphone.isGranted) {

    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveIncident() async {
    final prefs = await SharedPreferences.getInstance();
    final incidents = prefs.getStringList('incidents') ?? [];

    final newIncident = {
      'title': _titleController.text,
      'date': _selectedDate.toIso8601String(),
      'description': _descriptionController.text,
      'imagePath': _image?.path,
      'audioPath': _audioPath,
    };

    incidents.add(jsonEncode(newIncident));
    await prefs.setStringList('incidents', incidents);

    // Mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Incidente guardado exitosamente!')),
    );


    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _image = null;
      _audioPath = null;
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Incidentes', style: TextStyle( fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Fecha: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  if (_image != null)
                    Image.file(_image!, width: 100, height: 100, fit: BoxFit.cover)
                  else
                    Text('Sin imagen.'),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Selecciona una Imagen'),
                    ),
                  ),
                ],
              ),
             /* SizedBox(height: 10),
              ElevatedButton(
                onPressed: _recordAudio,
                child: Text('Grabar Audio'),
              ),*/
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveIncident,
                  child: Text('Guardar Incidente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil del Oficial', style: TextStyle( fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/Perfil.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Oficial Freddy Villar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Matrícula: 2021-1870',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'En cada acto de servicio, recordemos que nuestra verdadera misión es proteger la dignidad humana. La justicia no solo se administra, se vive cada día en cada decisión que tomamos. Mantengamos siempre la integridad como nuestra guía y el respeto como nuestra meta.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncidentsListScreen extends StatefulWidget {
  @override
  _IncidentsListScreenState createState() => _IncidentsListScreenState();
}

class _IncidentsListScreenState extends State<IncidentsListScreen> {
  List<Map<String, dynamic>> _incidents = [];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    final prefs = await SharedPreferences.getInstance();
    final incidentsJson = prefs.getStringList('incidents') ?? [];
    setState(() {
      _incidents = incidentsJson.map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _confirmDeleteIncident(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Seguro que quieres eliminar este incidente?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteIncident(index);
    }
  }

  Future<void> _deleteIncident(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final incidentsJson = prefs.getStringList('incidents') ?? [];
    incidentsJson.removeAt(index);
    await prefs.setStringList('incidents', incidentsJson);

    setState(() {
      _incidents.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Incidentes', style: TextStyle( fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView.builder(
        itemCount: _incidents.length,
        itemBuilder: (context, index) {
          final incident = _incidents[index];
          return ListTile(
            title: Text(incident['title']),
            subtitle: Text('Fecha: ${incident['date'].split('T')[0]}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IncidentDetailScreen(
                    incident: incident,
                    onDelete: () => _confirmDeleteIncident(index),
                  ),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmDeleteIncident(index),
            ),
          );
        },
      ),
    );
  }
}


class IncidentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> incident;
  final VoidCallback onDelete;

  IncidentDetailScreen({required this.incident, required this.onDelete});

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Seguro que quieres eliminar este incidente?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      onDelete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Incidente', style: TextStyle( fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Título: ${incident['title']}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Fecha: ${incident['date'].split('T')[0]}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Descripción: ${incident['description']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            if (incident['imagePath'] != null)
              Image.file(File(incident['imagePath']), width: 100, height: 100, fit: BoxFit.cover),
            SizedBox(height: 10),
            if (incident['audioPath'] != null)
              Text('Audio grabado: ${incident['audioPath']}'),
          ],
        ),
      ),
    );
  }
}

