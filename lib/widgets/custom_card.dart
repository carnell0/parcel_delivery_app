// import 'package:flutter/material.dart';
// import 'package:animate_do/animate_do.dart';

// class CustomCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final VoidCallback? onTap;

//   const CustomCard({super.key, required this.title, required this.subtitle, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return FadeInUp(
//       duration: const Duration(milliseconds: 300),
//       child: Card(
//         elevation: 3,
//         color: const Color(0xFFF5F6F5),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
//         ),
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           title: Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//               color: Color(0xFF1C2526),
//             ),
//           ),
//           subtitle: Text(
//             subtitle,
//             style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
//           ),
//           trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFF28C38), size: 16),
//           onTap: onTap,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;

  const CustomCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF5F6F5),
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }
}