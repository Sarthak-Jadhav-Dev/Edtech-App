import 'package:flutter/material.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String title;
  const AssignmentDetailScreen({super.key, required this.title});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Assignment Detail", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "Sans"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                  const SizedBox(width: 5),
                  const Text("Due: Oct 25, 2023", style: TextStyle(fontFamily: "Sans", color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Instructions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Sans"),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please complete the worksheet attached below. You need to identify the vowel sounds and color the pictures accordingly. Take a clear photo of your work and upload it here.",
                style: TextStyle(fontFamily: "Sans", color: Colors.black87),
              ),
              const SizedBox(height: 20),
              const Text(
                "Attachments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Sans"),
              ),
              const SizedBox(height: 10),
              _buildAttachmentItem("Phonics_Worksheet_01.pdf"),
              const SizedBox(height: 40),
              const Text(
                "Your Submission",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Sans"),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () {
                  // Handle file upload
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.shade200, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.purple.shade300),
                      const SizedBox(height: 10),
                      const Text("Upload Image or File", style: TextStyle(fontFamily: "Sans", color: Colors.purple)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.deepPurpleAccent.shade100,
                  side: BorderSide(color: Colors.deepPurpleAccent.shade700),
                  shape: const StadiumBorder(),
                ),
                child: const Text("Submit Assignment", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Sans")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(String fileName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        color: Colors.purple.shade50,
        child: ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
          title: Text(fileName, style: const TextStyle(fontFamily: "Sans")),
          trailing: const Icon(Icons.download, color: Colors.purple),
          onTap: () {},
        ),
      ),
    );
  }
}
