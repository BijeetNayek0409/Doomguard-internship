import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../shared/services/app_icon_service.dart';
import '../../../shared/services/app_name_service.dart';

/// Displays a real app icon fetched from the device.
/// Falls back to an emoji + colored background if the icon is unavailable.
class AppIconWidget extends StatefulWidget {
  final String packageName;
  final double size;

  const AppIconWidget({
    super.key,
    required this.packageName,
    this.size = 44,
  });

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  Uint8List? _icon;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AppIconWidget old) {
    super.didUpdateWidget(old);
    if (old.packageName != widget.packageName) {
      _icon = null;
      _loaded = false;
      _load();
    }
  }

  Future<void> _load() async {
    final bytes = await AppIconService.instance.getIcon(widget.packageName);
    if (mounted) {
      setState(() {
        _icon = bytes;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = AppNameService.getAppMeta(widget.packageName);
    final appColor = Color(meta.colorHex);
    final radius = widget.size * 0.27;

    if (!_loaded) {
      // Skeleton placeholder while loading
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: appColor.withAlpha(0x22),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    if (_icon != null) {
      // Real icon from device
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(
          _icon!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }

    // Fallback: emoji on colored background
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: appColor.withAlpha(0x22),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          meta.emoji,
          style: TextStyle(fontSize: widget.size * 0.48),
        ),
      ),
    );
  }
}
