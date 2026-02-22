import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import 'butter_code_block.dart';

/// Renders markdown content optimized for AI-generated text.
///
/// Wraps [GptMarkdown] and injects [ButterCodeBlock] for code blocks
/// with a copy button overlay.
class ButterMarkdownContent extends StatelessWidget {
  const ButterMarkdownContent({
    super.key,
    required this.content,
    this.style,
    this.codeBlockBuilder,
  });

  /// The markdown text to render.
  final String content;

  /// Optional text style override.
  final TextStyle? style;

  /// Optional custom code block builder.
  final Widget Function(BuildContext context, String code, String? language)?
      codeBlockBuilder;

  @override
  Widget build(BuildContext context) {
    return GptMarkdown(
      content,
      style: style,
      codeBuilder: (context, name, code, closed) {
        if (codeBlockBuilder != null) {
          return codeBlockBuilder!(context, code, name);
        }
        return ButterCodeBlock(code: code, language: name);
      },
    );
  }
}
