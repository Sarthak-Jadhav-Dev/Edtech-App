import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kte/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignmentViewScreen extends StatefulWidget {
  final String classId;
  final String contentId;
  final Map<String, dynamic> assignmentData;

  const AssignmentViewScreen({
    super.key,
    required this.classId,
    required this.contentId,
    required this.assignmentData,
  });

  @override
  State<AssignmentViewScreen> createState() => _AssignmentViewScreenState();
}

class _AssignmentViewScreenState extends State<AssignmentViewScreen> {
  bool _isSubmitting = false;
  bool _isAlreadyDone = false;
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final submission = await FirestoreService().getAssignmentSubmission(uid, widget.contentId);
    if (submission != null) {
      setState(() => _isAlreadyDone = true);
    }
  }

  Future<void> _launchURL() async {
    final url = Uri.parse(widget.assignmentData['url']);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch the form link.")),
        );
      }
    }
  }

  Future<void> _markAsDone() async {
    setState(() => _isSubmitting = true);
    await FirestoreService().submitAssignment(
      studentId: uid,
      classId: widget.classId,
      contentId: widget.contentId,
    );
    setState(() {
      _isSubmitting = false;
      _isAlreadyDone = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment marked as complete! XP awarded.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Assignment", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(Icons.assignment, color: Colors.orange),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            widget.assignmentData['title'] ?? "Form Assignment",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Instructions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      widget.assignmentData['description'] ?? "Please complete the form by clicking the button below. Once finished, return here and mark as done.",
                      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _launchURL,
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: const Text("Open Form Link", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isAlreadyDone)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 10),
                            Text("This assignment is completed!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _markAsDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade900,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Mark as Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "Remember to actually finish the form before marking as done!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
