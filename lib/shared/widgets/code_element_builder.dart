import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9); // remove 'language-' prefix
    }

    // Determine if it's inline code or a code block
    bool isInline = !element.textContent.contains('\n');

    if (isInline && language.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          element.textContent,
          style: const TextStyle(
            color: Color(0xFF89D4CF),
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Unified dark grey background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Language and Copy button
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.isNotEmpty ? language.toUpperCase() : 'CODE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Builder(
                  builder: (context) => InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: element.textContent));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied to clipboard'), duration: Duration(seconds: 1)),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.copy_outlined, size: 20, color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code Block
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                ),
                child: HighlightView(
                  element.textContent,
                  language: language.isEmpty ? 'plaintext' : language,
                  theme: atomOneDarkTheme,
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
