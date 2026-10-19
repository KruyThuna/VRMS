import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// SMART IMAGE RENDERER (HANDLES BASE64 DATA URIS, HTTPS URLS, ASSETS)
// ---------------------------------------------------------------------------

class SmartImage extends StatelessWidget {
  final String? imageSource;
  final BoxFit fit;
  final Widget? fallback;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SmartImage({
    super.key,
    required this.imageSource,
    this.fit = BoxFit.cover,
    this.fallback,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    final src = imageSource?.trim();

    if (src == null || src.isEmpty || src.toLowerCase() == 'null') {
      child = fallback ?? const SizedBox.shrink();
    } else if (src.startsWith('data:image')) {
      try {
        final commaIdx = src.indexOf(',');
        final base64Str = commaIdx != -1 ? src.substring(commaIdx + 1) : src;
        final bytes = base64Decode(base64Str);
        child = Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
        );
      } catch (_) {
        child = fallback ?? const SizedBox.shrink();
      }
    } else if (src.startsWith('http://') || src.startsWith('https://')) {
      child = Image.network(
        src,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
      );
    } else if (src.startsWith('assets/')) {
      child = Image.asset(
        src,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
      );
    } else {
      try {
        final bytes = base64Decode(src);
        child = Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
        );
      } catch (_) {
        child = fallback ?? const SizedBox.shrink();
      }
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}

// ---------------------------------------------------------------------------
// IMAGE UPLOAD & PREVIEW PICKER FIELD (WITH FILE PICKER + URL + PRESETS)
// ---------------------------------------------------------------------------

class ImageUploadPickerField extends StatefulWidget {
  final String? initialValue;
  final String label;
  final ValueChanged<String?> onChanged;
  final List<({String label, String url})>? presets;

  const ImageUploadPickerField({
    super.key,
    this.initialValue,
    this.label = 'Product / Banner Image',
    required this.onChanged,
    this.presets,
  });

  @override
  State<ImageUploadPickerField> createState() => _ImageUploadPickerFieldState();
}

class _ImageUploadPickerFieldState extends State<ImageUploadPickerField> {
  late TextEditingController _urlCtrl;
  String? _currentImage;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.initialValue;
    _urlCtrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant ImageUploadPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _currentImage) {
      _currentImage = widget.initialValue;
      _urlCtrl.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _picking = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        final ext = file.extension?.toLowerCase() ?? 'png';
        final mime = ext == 'jpg' || ext == 'jpeg'
            ? 'image/jpeg'
            : (ext == 'webp' ? 'image/webp' : 'image/png');
        final base64 = base64Encode(bytes);
        final dataUri = 'data:$mime;base64,$base64';
        setState(() {
          _currentImage = dataUri;
          _urlCtrl.text = dataUri;
        });
        widget.onChanged(dataUri);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _clearImage() {
    setState(() {
      _currentImage = null;
      _urlCtrl.clear();
    });
    widget.onChanged(null);
  }

  void _setImage(String url) {
    setState(() {
      _currentImage = url;
      _urlCtrl.text = url;
    });
    widget.onChanged(url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFF111827)),
              ),
              if (_currentImage != null && _currentImage!.isNotEmpty)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: _clearImage,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove Image',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_currentImage != null && _currentImage!.isNotEmpty) ...[
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SmartImage(
                      imageSource: _currentImage,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(11),
                      fallback: const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white54, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: Color(0xFF10B981), size: 12),
                          SizedBox(width: 4),
                          Text('Photo Loaded',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _picking ? null : _pickFile,
                  icon: _picking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: Text(
                      _picking
                          ? 'Loading Image...'
                          : 'Upload Image from Computer',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlCtrl,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Or paste image URL (https://... or data:image...)',
              hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              suffixIcon: IconButton(
                icon:
                    const Icon(Icons.check, size: 18, color: Color(0xFF059669)),
                tooltip: 'Apply URL',
                onPressed: () {
                  final text = _urlCtrl.text.trim();
                  if (text.isNotEmpty) _setImage(text);
                },
              ),
            ),
            onSubmitted: (v) {
              final text = v.trim();
              if (text.isNotEmpty) _setImage(text);
            },
          ),
          if (widget.presets != null && widget.presets!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in widget.presets!)
                  InkWell(
                    onTap: () => _setImage(p.url),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: Text(
                        '📸 ${p.label}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
