import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.compact = false, this.size = 120});
  final bool compact;
  final double size;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF28A8E0);
    const cyan = Color(0xFF62C8EE);
    final mark = SizedBox(
      width: size,
      height: size * .72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.directions_run_rounded, size: size * .68, color: cyan),
          Positioned(left: size * .02, top: size * .27, child: Container(width: size * .31, height: size * .31, decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(size * .08)), child: Icon(Icons.add_rounded, color: Colors.white, size: size * .27))),
        ],
      ),
    );
    if (compact) return mark;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      mark,
      Text('+Fisio', style: TextStyle(fontSize: size * .38, height: .9, fontWeight: FontWeight.w900, color: blue)),
      SizedBox(height: size * .07),
      Text('Seu consultório no seu bolso', style: TextStyle(fontSize: size * .105, fontWeight: FontWeight.w700, color: const Color(0xFF2579A8))),
    ]);
  }
}
