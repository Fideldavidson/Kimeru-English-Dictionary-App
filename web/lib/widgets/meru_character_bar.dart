import 'package:flutter/material.dart';

class MeruCharacterBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onCharacterPressed;

  const MeruCharacterBar({
    super.key,
    required this.controller,
    this.onCharacterPressed,
  });

  static const List<String> characters = [
    'ĩ', 'ũ', 'ā', 'ē', 'ī', 'ō', 'ū', 'Ĩ', 'Ũ', 'Ā', 'Ē', 'Ī', 'Ō', 'Ū'
  ];

  void _insertCharacter(String char) {
    final text = controller.text;
    final selection = controller.selection;
    
    // Default to end if no selection
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final newText = text.replaceRange(start, end, char);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + char.length),
    );
    
    onCharacterPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final char = characters[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _insertCharacter(char),
                child: Container(
                  width: 44,
                  alignment: Alignment.center,
                  child: Text(
                    char,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
