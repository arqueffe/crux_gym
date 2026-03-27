import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class AuthHtmlInput extends StatefulWidget {
  const AuthHtmlInput({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autocomplete,
    this.fieldName,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? autocomplete;
  final String? fieldName;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  @override
  State<AuthHtmlInput> createState() => _AuthHtmlInputState();
}

class _AuthHtmlInputState extends State<AuthHtmlInput> {
  static int _viewIdSeed = 0;

  late final String _viewType;
  late final web.HTMLDivElement _container;
  late final web.HTMLInputElement _input;

  @override
  void initState() {
    super.initState();
    _viewType = 'auth-html-input-${_viewIdSeed++}';
    _input = web.HTMLInputElement();
    _container = web.HTMLDivElement();
    _buildDom();
    widget.controller.addListener(_syncFromController);
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int _) => _container,
    );
  }

  @override
  void didUpdateWidget(covariant AuthHtmlInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromController);
      widget.controller.addListener(_syncFromController);
    }
    _applyInputState();
    _syncFromController();
  }

  void _buildDom() {
    _container.style
      ..width = '100%'
      ..height = '100%'
      ..display = 'flex'
      ..alignItems = 'center';

    _input.style
      ..width = '100%'
      ..height = '100%'
      ..border = 'none'
      ..outline = 'none'
      ..background = 'transparent'
      ..fontSize = '16px';

    _input.onInput.listen((_) {
      final value = _input.value;
      if (widget.controller.text != value) {
        widget.controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
      widget.onChanged?.call(value);
    });

    _input.onKeyDown.listen((event) {
      if (event.key == 'Enter') {
        widget.onSubmitted?.call();
      }
    });

    _container.append(_input);
    _applyInputState();
    _syncFromController();
  }

  void _applyInputState() {
    _input.disabled = !widget.enabled;
    _input.placeholder = widget.hintText ?? '';
    _input.autocomplete = widget.autocomplete ?? 'off';
    _input.name = widget.fieldName ?? '';
    _input.spellcheck = false;
    _input.type = widget.obscureText
        ? 'password'
        : _mapType(widget.keyboardType ?? TextInputType.text);
  }

  String _mapType(TextInputType type) {
    if (type == TextInputType.emailAddress) {
      return 'email';
    }
    if (type == TextInputType.number) {
      return 'number';
    }
    return 'text';
  }

  void _syncFromController() {
    final text = widget.controller.text;
    if (_input.value != text) {
      _input.value = text;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    _container.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = widget.errorText == null
        ? theme.colorScheme.outline
        : theme.colorScheme.error;
    final background = widget.enabled
        ? theme.colorScheme.surface
        : theme.disabledColor.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.labelText,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Icon(widget.prefixIcon),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: HtmlElementView(
                  viewType: _viewType,
                ),
              ),
              if (widget.suffix != null) ...[
                const SizedBox(width: 8),
                widget.suffix!,
              ],
            ],
          ),
        ),
        if (widget.helperText != null || widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: widget.errorText == null
                    ? theme.hintColor
                    : theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
