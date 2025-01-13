import 'package:book_app/screens/register_sreen.dart';
import 'package:flutter/material.dart';
import '../base_screen.dart';
import 'package:book_app/controllers/login_controller.dart'; // Import LoginController

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();
  final FocusNode _emailFocusNode = FocusNode();  // Thêm FocusNode
  final FocusNode _passwordFocusNode = FocusNode();  // Thêm FocusNode
  void _handleLogin(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập email và mật khẩu!")),
      );
      return;
    }

    if (!_isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email không hợp lệ!")),
      );
      return;
    }

    bool isSuccess = await _loginController.login(email, password);

    if (isSuccess) {
      // Sau khi đăng nhập thành công, chuyển đến BaseScreen (màn hình chính có footer và header)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BaseScreen()), // Chuyển đến BaseScreen
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thất bại! Vui lòng kiểm tra lại thông tin.")),
      );
    }
  }

  bool _isEmailValid(String email) {
    final emailRegex =
    RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }
  @override
  void dispose() {
    // Hãy nhớ dispose khi không sử dụng nữa
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đăng Nhập',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,  // Thêm focusNode
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Mật khẩu',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _handleLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('ĐĂNG NHẬP'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có tài khoản? ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Chuyển đến màn hình đăng ký
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()), // Đảm bảo RegisterScreen đã được tạo
                    );
                  },
                  child: Text(
                    'Đăng ký ngay',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
