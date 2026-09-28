// lib/widgets/scratch_card.dart
// Interactive scratch-to-reveal card widget.
// Uses CustomPainter with canvas.saveLayer and BlendMode.clear to erase
// the top mask as the user drags their finger, revealing the hidden voucher.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../theme.dart';

class ScratchCardWidget extends StatefulWidget {
  final Reward reward;
  final VoidCallback onRevealed;

  const ScratchCardWidget({
    super.key,
    required this.reward,
    required this.onRevealed,
  });

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  final List<Offset> _points = [];
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _revealed = widget.reward.isScratched;
  }

  void _addPoint(Offset point) {
    if (_revealed) return;
    setState(() => _points.add(point));

    // Threshold check: after dragging across 30+ points, auto-reveal the voucher
    if (_points.length >= 30 && !_revealed) {
      HapticFeedback.mediumImpact();
      setState(() => _revealed = true);
      widget.onRevealed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius16),
          boxShadow: AppTheme.softShadows,
          border: Border.all(color: AppTheme.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            _RevealedRewardView(reward: widget.reward),
            if (!_revealed)
              GestureDetector(
                onPanDown: (d) => _addPoint(d.localPosition),
                onPanUpdate: (d) => _addPoint(d.localPosition),
                child: CustomPaint(
                  painter: _ScratchMaskPainter(points: _points),
                  child: const _ScratchOverlay(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScratchMaskPainter extends CustomPainter {
  final List<Offset> points;
  const _ScratchMaskPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // saveLayer isolates blend mode erasing to this widget's bounds
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 1. Draw opaque overlay mask
    final maskPaint = Paint()..color = const Color(0xFF282D3B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), maskPaint);

    // 2. Erase user scratch paths with BlendMode.clear
    final eraser = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], eraser);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchMaskPainter oldDelegate) => true;
}

class _ScratchOverlay extends StatelessWidget {
  const _ScratchOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars, color: AppTheme.primary, size: 36),
          SizedBox(height: AppTheme.space8),
          Text('SCRATCH HERE', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class _RevealedRewardView extends StatelessWidget {
  final Reward reward;
  const _RevealedRewardView({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Align(alignment: Alignment.topRight, child: Icon(Icons.check_circle, color: AppTheme.success, size: 18)),
          Column(
            children: [
              Text(reward.title, style: AppTheme.headingSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.space4),
              Text(reward.description, style: AppTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space8, vertical: AppTheme.space4),
            decoration: BoxDecoration(color: AppTheme.surfaceElevated, borderRadius: BorderRadius.circular(AppTheme.radius8), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5))),
            child: Text(reward.discountCode, style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }
}
