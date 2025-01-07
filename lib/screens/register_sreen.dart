// import 'package:flutter/material.dart';
// import 'login_screen.dart';
//
// class RegisterScreen extends StatelessWidget {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//   TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(  // Bọc Column trong SingleChildScrollView
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: 50),
//               Text(
//                 'Book App',
//                 style: TextStyle(
//                   fontSize: 40,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'Tạo tài khoản miễn phí',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 30),
//               TextField(
//                 controller: _emailController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: 'Email',
//                   hintStyle: TextStyle(color: Colors.white54),
//                   filled: true,
//                   fillColor: Colors.grey[800],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.white),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: 15),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: 'Mật khẩu',
//                   hintStyle: TextStyle(color: Colors.white54),
//                   filled: true,
//                   fillColor: Colors.grey[800],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.white),
//               ),
//               SizedBox(height: 15),
//               TextField(
//                 controller: _confirmPasswordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: 'Nhập lại mật khẩu',
//                   hintStyle: TextStyle(color: Colors.white54),
//                   filled: true,
//                   fillColor: Colors.grey[800],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.white),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   String email = _emailController.text.trim();
//                   String password = _passwordController.text.trim();
//                   String confirmPassword = _confirmPasswordController.text.trim();
//
//                   // Kiểm tra mật khẩu và mật khẩu nhập lại
//                   if (password != confirmPassword) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                           content:
//                           Text("Mật khẩu và nhập lại mật khẩu không khớp!")),
//                     );
//                     return;
//                   }
//
//                   // Điều hướng sang trang đăng nhập và truyền dữ liệu
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => LoginScreen(
//                         email: email,
//                         password: password,
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   minimumSize: Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text('TIẾP TỤC'),
//               ),
//               SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () {
//                   // Nếu đã có tài khoản, quay lại màn đăng nhập
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => LoginScreen(
//                       email: _emailController.text.trim(),
//                       password: _passwordController.text.trim(),)),
//                   );
//                 },
//                 child: Text(
//                   'Đã có tài khoản?',
//                   style: TextStyle(
//                     color: Colors.green,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }