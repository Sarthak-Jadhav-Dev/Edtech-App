import 'package:flutter/material.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AddContentScreen extends StatefulWidget {
  final String classId;
  final String? contentId;
  final Map<String, dynamic>? initialData;

  const AddContentScreen({super.key, required this.classId, this.contentId, this.initialData});

  @override
  State<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedType = 'video';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _descController.text = widget.initialData!['description'] ?? '';
      _urlController.text = widget.initialData!['url'] ?? '';
      _selectedType = widget.initialData!['type'] ?? 'video';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addContent() async {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();

    if (title.isEmpty) {
      _showSnack('Title is required');
      return;
    }

    if (url.isEmpty) {
      _showSnack('URL is required');
      return;
    }

    String? videoId;
    if (_selectedType == 'video') {
      videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId == null) {
        _showSnack('Invalid YouTube URL. Please paste a valid link.');
        return;
      }
    }

    setState(() => _isLoading = true);

    bool success;
    if (widget.contentId != null) {
      success = await FirestoreService().updateContent(
        classId: widget.classId,
        contentId: widget.contentId!,
        title: title,
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        type: _selectedType,
        url: url,
        videoId: videoId,
      );
    } else {
      success = await FirestoreService().addContent(
        classId: widget.classId,
        title: title,
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        type: _selectedType,
        url: url,
        videoId: videoId,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSnack(widget.contentId != null ? 'Content updated successfully!' : 'Content added successfully!');
      Navigator.pop(context);
    } else if (mounted) {
      _showSnack('Failed to process content.');
    }
  }

  void _showSnack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text(widget.contentId != null ? "Edit Content" : "Add Learning Material", style: const TextStyle(fontFamily: "Poppins", color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
           child: Column(
             children: [
               Container(
                 decoration: BoxDecoration(
                   color: Theme.of(context).cardColor,
                   borderRadius: BorderRadius.circular(25),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.grey.withValues(alpha: 0.2),
                       blurRadius: 10,
                       offset: const Offset(0, 5),
                     )
                   ],
                 ),
                 padding: const EdgeInsets.all(25.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     DropdownButtonFormField<String>(
                       initialValue: _selectedType,
                       items: const [
                         DropdownMenuItem(value: 'video', child: Text("YouTube Video")),
                         DropdownMenuItem(value: 'assignment', child: Text("Google Forms Assignment")),
                       ],
                       onChanged: (val) {
                         if (val != null) setState(() => _selectedType = val);
                       },
                       decoration: InputDecoration(
                         labelText: "Content Type",
                         prefixIcon: Icon(Icons.category, color: Colors.purple.shade400),
                         filled: true,
                         fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                       ),
                     ),
                     const SizedBox(height: 20),
                     TextField(
                       controller: _titleController,
                       decoration: InputDecoration(
                         labelText: "Title",
                         prefixIcon: Icon(Icons.title, color: Colors.purple.shade400),
                         filled: true,
                         fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                       ),
                     ),
                     const SizedBox(height: 20),
                     TextField(
                       controller: _descController,
                       maxLines: 2,
                       decoration: InputDecoration(
                         labelText: "Description",
                         prefixIcon: Icon(Icons.description, color: Colors.purple.shade400),
                         filled: true,
                         fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                       ),
                     ),
                     const SizedBox(height: 20),
                     
                     TextField(
                       controller: _urlController,
                       decoration: InputDecoration(
                         labelText: _selectedType == 'video' ? "YouTube Video Link (Unlisted/Public)" : "Assignment URL Link",
                         prefixIcon: Icon(Icons.link, color: Colors.purple.shade400),
                         filled: true,
                         fillColor: Colors.purple.shade50.withValues(alpha: 0.5),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                       ),
                     ),
                     
                     const SizedBox(height: 40),
                     _isLoading
                         ? const Center(child: CircularProgressIndicator())
                         : ElevatedButton(
                             onPressed: _addContent,
                             style: ElevatedButton.styleFrom(
                               minimumSize: const Size(double.infinity, 55),
                               backgroundColor: Colors.purple.shade900,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                               elevation: 5,
                             ),
                             child: Text(widget.contentId != null ? "Save Changes" : "Publish Content", style: const TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 18)),
                           ),
                   ],
                 ),
               ),
             ],
           ),
        ),
      ),
    );
  }
}
