import 'package:flutter/material.dart';

/// A custom render widget replicating the "BIG ROADRUNNER LLC" logo
/// featuring metallic gold, fiery red gradient typography, speed curves,
/// and an optional light sweep shimmer overlay effect.
class BigRoadrunnerLogo extends StatelessWidget {
  final double width;
  final double height;
  final double lightSweepPosition; // 0.0 to 1.0 animation value
  final bool showLightSweep;

  const BigRoadrunnerLogo({
    super.key,
    this.width = 300,
    this.height = 160,
    this.lightSweepPosition = 0.0,
    this.showLightSweep = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _BigRoadrunnerLogoPainter(
          sweepPos: lightSweepPosition,
          drawSweep: showLightSweep,
        ),
      ),
    );
  }
}

class _BigRoadrunnerLogoPainter extends CustomPainter {
  final double sweepPos;
  final bool drawSweep;

  _BigRoadrunnerLogoPainter({
    required this.sweepPos,
    required this.drawSweep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Scale reference size (nominal 300x160)
    final double sx = w / 300.0;
    final double sy = h / 160.0;

    canvas.save();

    // 1. Draw top golden swoosh / highway arc
    final Path topArc = Path();
    topArc.moveTo(180 * sx, 35 * sy);
    topArc.cubicTo(260 * sx, 20 * sy, 290 * sx, 50 * sy, 240 * sx, 78 * sy);
    topArc.cubicTo(220 * sx, 90 * sy, 170 * sx, 78 * sy, 180 * sx, 68 * sy);
    topArc.cubicTo(230 * sx, 55 * sy, 245 * sx, 42 * sy, 180 * sx, 35 * sy);

    final Paint arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFE082),
          Color(0xFFFFB300),
          Color(0xFFFF8F00),
          Color(0xFFFFE082),
        ],
        stops: [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(topArc, arcPaint);

    // 2. Draw bottom golden highway curve
    final Path bottomArc = Path();
    bottomArc.moveTo(30 * sx, 115 * sy);
    bottomArc.cubicTo(60 * sx, 80 * sy, 150 * sx, 85 * sy, 250 * sx, 100 * sy);
    bottomArc.cubicTo(220 * sx, 130 * sy, 100 * sx, 145 * sy, 40 * sx, 115 * sy);

    final Paint bottomArcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF8F00),
          Color(0xFFFFD54F),
          Color(0xFFFF6F00),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(bottomArc, bottomArcPaint);

    // 3. Inner asphalt lane detail inside bottom curve
    final Path roadInner = Path();
    roadInner.moveTo(50 * sx, 113 * sy);
    roadInner.cubicTo(80 * sx, 95 * sy, 140 * sx, 95 * sy, 210 * sx, 108 * sy);
    roadInner.cubicTo(180 * sx, 122 * sy, 90 * sx, 128 * sy, 50 * sx, 113 * sy);

    final Paint roadPaint = Paint()
      ..color = const Color(0xFF1E1610)
      ..style = PaintingStyle.fill;
    canvas.drawPath(roadInner, roadPaint);

    // Golden road center stripe
    final Path stripe = Path();
    stripe.moveTo(65 * sx, 110 * sy);
    stripe.cubicTo(95 * sx, 100 * sy, 130 * sx, 102 * sy, 180 * sx, 111 * sy);

    final Paint stripePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * sx;
    canvas.drawPath(stripe, stripePaint);

    // 4. Draw "BIG" Text in metallic gold font styling
    final TextPainter bigPainter = TextPainter(
      text: TextSpan(
        text: 'BIG',
        style: TextStyle(
          fontSize: 48 * sy,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 2.0,
          foreground: Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF9C4), // Bright gold top
                Color(0xFFFFD54F), // Gold
                Color(0xFFFF8F00), // Deep bronze bottom
              ],
            ).createShader(Rect.fromLTWH(80 * sx, 10 * sy, 120 * sx, 50 * sy)),
          shadows: const [
            Shadow(color: Colors.black, offset: Offset(2, 3), blurRadius: 4),
            Shadow(color: Color(0xAAFFB300), blurRadius: 10),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    bigPainter.layout();
    bigPainter.paint(canvas, Offset(88 * sx, 8 * sy));

    // 5. Draw "ROADRUNNER" Text in metallic red styling
    final TextPainter roadrunnerPainter = TextPainter(
      text: TextSpan(
        text: 'ROADRUNNER',
        style: TextStyle(
          fontSize: 31 * sy,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
          foreground: Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF8A80), // Highlight top
                Color(0xFFD50000), // Vibrant Red
                Color(0xFF880E4F), // Dark Crimson bottom
              ],
            ).createShader(Rect.fromLTWH(10 * sx, 55 * sy, 220 * sx, 40 * sy)),
          shadows: const [
            Shadow(color: Colors.black, offset: Offset(2, 3), blurRadius: 5),
            Shadow(color: Color(0xDDFF1744), blurRadius: 8),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    roadrunnerPainter.layout();
    roadrunnerPainter.paint(canvas, Offset(12 * sx, 50 * sy));

    // Gold outline stroke for ROADRUNNER
    final TextPainter roadrunnerOutline = TextPainter(
      text: TextSpan(
        text: 'ROADRUNNER',
        style: TextStyle(
          fontSize: 31 * sy,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2 * sx
            ..color = const Color(0xFFFFD54F),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    roadrunnerOutline.layout();
    roadrunnerOutline.paint(canvas, Offset(12 * sx, 50 * sy));

    // 6. Draw "LLC" Badge Circle & Text
    final Offset llcCenter = Offset(250 * sx, 82 * sy);
    final double llcRadius = 18 * sy;

    // Circle background & golden border
    final Paint llcBg = Paint()..color = const Color(0xFF101010);
    canvas.drawCircle(llcCenter, llcRadius, llcBg);

    final Paint llcBorder = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFECB3), Color(0xFFFF8F00)],
      ).createShader(Rect.fromCircle(center: llcCenter, radius: llcRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * sx;
    canvas.drawCircle(llcCenter, llcRadius, llcBorder);

    final TextPainter llcText = TextPainter(
      text: TextSpan(
        text: 'LLC',
        style: TextStyle(
          fontSize: 12 * sy,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: const Color(0xFFFFC107),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    llcText.layout();
    llcText.paint(
      canvas,
      Offset(llcCenter.dx - (llcText.width / 2), llcCenter.dy - (llcText.height / 2)),
    );

    // 7. Light Sweeps Overlay (if enabled)
    if (drawSweep) {
      _paintLightSweeps(canvas, size, sweepPos);
    }

    canvas.restore();
  }

  void _paintLightSweeps(Canvas canvas, Size size, double progress) {
    final double w = size.width;
    final double h = size.height;

    // Light Sweep 1: Top-Left to Bottom-Right beam
    final double sweep1X = -w + (progress * w * 3.0);
    final Path beam1 = Path();
    beam1.moveTo(sweep1X, -20);
    beam1.lineTo(sweep1X + 50, -20);
    beam1.lineTo(sweep1X - 20, h + 20);
    beam1.lineTo(sweep1X - 70, h + 20);
    beam1.close();

    final Paint sweepPaint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.8),
          const Color(0xFFFFECB3).withOpacity(0.9),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.4, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(sweep1X - 70, 0, 120, h))
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beam1, sweepPaint1);

    // Light Sweep 2: Opposite Direction (Bottom-Right to Top-Left beam)
    final double sweep2X = (w * 2.0) - (progress * w * 3.0);
    final Path beam2 = Path();
    beam2.moveTo(sweep2X, h + 20);
    beam2.lineTo(sweep2X + 50, h + 20);
    beam2.lineTo(sweep2X + 110, -20);
    beam2.lineTo(sweep2X + 60, -20);
    beam2.close();

    final Paint sweepPaint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.amber.withOpacity(0.0),
          const Color(0xFFFFD54F).withOpacity(0.85),
          Colors.white.withOpacity(0.95),
          Colors.amber.withOpacity(0.0),
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(sweep2X, 0, 110, h))
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beam2, sweepPaint2);
  }

  @override
  bool shouldRepaint(covariant _BigRoadrunnerLogoPainter oldDelegate) {
    return oldDelegate.sweepPos != sweepPos || oldDelegate.drawSweep != drawSweep;
  }
}
