import 'package:flutter/material.dart';

class QuickReplyChips extends StatelessWidget {
  final Function(String) onSelected;

  const QuickReplyChips({super.key, required this.onSelected});

  final List<String> _options = const [
    "Tell me a fun math fact!",
    "Give me a short quiz!",
    "Tell me a story ðŸ“–",
    "How do stars glow? â­",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _options.length,
        itemBuilder: (context, index) {
          final option = _options[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
            child: ActionChip(
              label: Text(
                option,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () => onSelected(option),
            ),
          );
        },
      ),
    );
  }
}
