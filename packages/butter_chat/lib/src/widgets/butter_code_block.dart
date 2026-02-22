import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../butter_chat_style.dart';

/// A code block with syntax label and copy button.
class ButterCodeBlock extends StatefulWidget {
  const ButterCodeBlock({
    super.key,
    required this.code,
    this.language,
    this.style,
  });

  final String code;
  final String? language;
  final ButterCodeBlockStyle? style;

  @override
  State<ButterCodeBlock> createState() => _ButterCodeBlockState();
}

class _ButterCodeBlockState extends State<ButterCodeBlock> {
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = widget.style;

    final bgColor =
        style?.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final radius = style?.borderRadius ?? BorderRadius.circular(8);
    final textStyle = style?.textStyle ??
        theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: colorScheme.onSurfaceVariant,
        );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language label and copy button.
          Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 0),
            child: Row(
              children: [
                if (widget.language != null && widget.language!.isNotEmpty)
                  Text(
                    widget.language!,
                    style: style?.languageLabelStyle ??
                        theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _copied ? Icons.check : Icons.copy,
                    size: 16,
                    color: style?.copyButtonColor ??
                        colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _copyToClipboard,
                  tooltip: _copied ? 'Copied!' : 'Copy code',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // Code content.
          Padding(
            padding: style?.padding ??
                const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SelectableText(
              widget.code,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
