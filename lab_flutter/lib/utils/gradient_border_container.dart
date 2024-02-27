import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final Color borderColor;
  final double lineHeight;

  GradientBorderPainter({
    required this.borderColor,
    this.lineHeight = 20.0, // Keep this thickness
  });

  @override
  void paint(Canvas canvas, Size size) {
    double nearTransparent = 0.21; // Very close to transparent but not full
    double middleOpacity= 1;

    // Paint for the top border with the gradient
    Paint borderPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, lineHeight),
        [borderColor.withOpacity(nearTransparent), borderColor.withOpacity(middleOpacity), borderColor.withOpacity(0)],
        [0.0, 0.5, 1.0],
      );

    // Draw the top border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, lineHeight),
      borderPaint,
    );

    // Paint for the bottom border with the gradient
    // Note: We use the same shader as the top border but reverse the direction
    borderPaint.shader = ui.Gradient.linear(
      Offset(0, size.height - lineHeight),
      Offset(0, size.height),
      [borderColor.withOpacity(0), borderColor.withOpacity(middleOpacity), borderColor.withOpacity(nearTransparent)],
      [0.0, 0.5, 1.0],
    );

    // Draw the bottom border
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - lineHeight, size.width, lineHeight),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//best one with trans-opaq-trans but there is space between
// class GradientBorderPainter extends CustomPainter {
//   final Color borderColor;
//   final double lineHeight;
//
//   GradientBorderPainter({
//     required this.borderColor,
//     this.lineHeight = 20.0, // Keep this thickness
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Paint for the top border with the gradient
//     Paint borderPaint = Paint()
//       ..shader = ui.Gradient.linear(
//         Offset(0, 0),
//         Offset(0, lineHeight),
//         [borderColor.withOpacity(0), borderColor, borderColor.withOpacity(0)],
//         [0.0, 0.5, 1.0],
//       );
//
//     // Draw the top border
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, lineHeight),
//       borderPaint,
//     );
//
//     // Paint for the bottom border with the gradient
//     // Note: We use the same shader as the top border but reverse the direction
//     borderPaint.shader = ui.Gradient.linear(
//       Offset(0, size.height - lineHeight),
//       Offset(0, size.height),
//       [borderColor.withOpacity(0), borderColor, borderColor.withOpacity(0)],
//       [0.0, 0.5, 1.0],
//     );
//
//     // Draw the bottom border
//     canvas.drawRect(
//       Rect.fromLTWH(0, size.height - lineHeight, size.width, lineHeight),
//       borderPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }


//best one lets try to combine top and bottom
// class GradientBorderPainter extends CustomPainter {
//   final Color borderColor;
//   final double lineHeight;
//
//   GradientBorderPainter({
//     required this.borderColor,
//     this.lineHeight = 20.0, // Adjust the thickness of the border if necessary
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Paint for the top border with the gradient
//     Paint borderPaint = Paint()
//       ..shader = ui.Gradient.linear(
//         Offset(0, 0),
//         Offset(0, lineHeight),
//         [borderColor, Colors.transparent],
//         [0.0, 1.0],
//       );
//
//     // Draw the top border
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, lineHeight),
//       borderPaint,
//     );
//
//     // Paint for the bottom border with the inverted gradient
//     borderPaint.shader = ui.Gradient.linear(
//       Offset(0, size.height - lineHeight),
//       Offset(0, size.height),
//       [Colors.transparent, borderColor],
//       [0.0, 1.0],
//     );
//
//     // Draw the bottom border
//     canvas.drawRect(
//       Rect.fromLTWH(0, size.height - lineHeight, size.width, lineHeight),
//       borderPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }


//closest one!!!! but bottom should be inverted top
// class GradientBorderPainter extends CustomPainter {
//   final Color borderColor;
//   final double lineHeight;
//
//   GradientBorderPainter({
//     required this.borderColor,
//     this.lineHeight = 20.0,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // The gradient should go from the edge to the center vertically
//     Paint borderPaint = Paint()
//       ..shader = ui.Gradient.linear(
//         Offset(0, 0),
//         Offset(0, lineHeight),
//         [borderColor, Colors.transparent],
//         [0.0, 1.0],
//       );
//
//     // Top border
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, lineHeight),
//       borderPaint,
//     );
//
//     // Bottom border - flip the gradient
//     borderPaint.shader = ui.Gradient.linear(
//       Offset(0, size.height - lineHeight),
//       Offset(0, size.height),
//       [borderColor, Colors.transparent],
//       [0.0, 1.0],
//     );
//     canvas.drawRect(
//       Rect.fromLTWH(0, size.height - lineHeight, size.width, lineHeight),
//       borderPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

//first one that shows bottom one as well, but is horizontal
// class GradientBorderPainter extends CustomPainter {
//   final Color borderColor;
//   final double lineHeight;
//
//   GradientBorderPainter({
//     required this.borderColor,
//     this.lineHeight = 20.0,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..shader = ui.Gradient.linear(
//         Offset(0, 0),
//         Offset(size.width, 0),
//         [Colors.transparent, borderColor, Colors.transparent],
//         [0.05, 0.5, 0.95], // Adjust the stops to control the fading effect
//       );
//
//     // Top border
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, lineHeight),
//       paint,
//     );
//
//     // Bottom border
//     canvas.drawRect(
//       Rect.fromLTWH(0, size.height - lineHeight, size.width, lineHeight),
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//

// class GradientBorderPainter extends CustomPainter {
//   final Color borderColor;
//   final double lineHeight;
//
//   GradientBorderPainter({
//     required this.borderColor,
//     required this.lineHeight,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           Colors.transparent,
//           borderColor,
//           Colors.transparent,
//         ],
//         stops: [0.1, 0.5, 0.9], // Adjust these stops if necessary
//       ).createShader(Rect.fromLTWH(0, 0, size.width, lineHeight));
//
//     // Draw the top border
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, lineHeight),
//       paint,
//     );
//
//     // Draw the bottom border
//     canvas.drawRect(
//       Rect.fromLTWH(0, size.height - lineHeight, size.width, lineHeight),
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class GradientBorderPainter extends CustomPainter {
//   final Color borderColor;
//   final double lineHeight;
//
//   GradientBorderPainter({
//     required this.borderColor,
//     this.lineHeight = 20.0,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint borderPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           Colors.transparent,
//           borderColor,
//           Colors.transparent,
//         ],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, lineHeight));
//
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, lineHeight),
//       borderPaint,
//     );
//
//     canvas.drawRect(
//       Rect.fromLTWH(0, size.height - lineHeight, size.width, lineHeight),
//       borderPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// import 'package:flutter/material.dart';
//
// class GradientBorderPainter extends CustomPainter {
//   final Color borderColor;
//   final double lineHeight;
//
//   GradientBorderPainter({
//     required this.borderColor,
//     required this.lineHeight,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Paint for the gradient stroke
//     Paint borderPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           borderColor.withOpacity(0), // Transparent at the start
//           borderColor, // Solid color in the middle
//           borderColor.withOpacity(0), // Transparent at the end
//         ],
//         stops: [
//           0.0, // Start
//           0.5, // Mid point
//           1.0, // End
//         ],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, lineHeight));
//
//     // Draw the top border
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, lineHeight),
//       borderPaint,
//     );
//
//     // Draw the bottom border
//     canvas.drawRect(
//       Rect.fromLTWH(0, size.height - lineHeight, size.width, lineHeight),
//       borderPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
