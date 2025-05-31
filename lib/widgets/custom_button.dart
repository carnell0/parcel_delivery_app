// import 'package:flutter/material.dart';
// import 'package:animate_do/animate_do.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;

//   const CustomButton({super.key, required this.text, required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return FadeInUp(
//       duration: const Duration(milliseconds: 300),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         child: SizedBox(
//           width: double.infinity,
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final Color? backgroundColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.backgroundColor = const Color(0xFFF28C38),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}