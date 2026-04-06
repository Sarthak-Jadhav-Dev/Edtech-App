import 'package:flutter/material.dart';
import 'package:kte/services/firestore_service.dart';

class AddContentScreen extends StatefulWidget {
  final String classId;

  const AddContentScreen({super.key, required this.classId});

  @override
  State<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedType = 'video';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addContent() async {
    if (_titleController.text.trim().isEmpty || _urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    bool success = await FirestoreService().addContent(
      classId: widget.classId,
      title: _titleController.text.trim(),
      type: _selectedType,
      url: _urlController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content added!')));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add content.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(title: const Text("Add Content", style: TextStyle(fontFamily: "Poppins")), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "URL (YouTube / Google Forms)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'video', child: Text("YouTube Video")),
                DropdownMenuItem(value: 'assignment', child: Text("Google Forms Assignment")),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    onPressed: _addContent,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.purple.shade900,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text("Save Content", style: TextStyle(color: Colors.white, fontFamily: "Sans", fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}
