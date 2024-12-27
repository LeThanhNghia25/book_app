import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: ListView(
        padding: const EdgeInsets.all(12),
        // Hiệu ứng cuộn bật nảy
        physics: const BouncingScrollPhysics(),
        children: [
          Container(height: 35),
          userTile(),
          divider(),
          colorTiles(),
          divider(),
          bwTitles(),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin cơ bản của người dùng (hình ảnh, tên và nghề nghiệp)
  Widget userTile() {
    String url = "https://i.imgur.com/uvZ7IdP.png"; // Ảnh đại diện mẫu
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(url), // Tải ảnh từ URL
      ),
      title: Txt(
        text: "Name", // Tên người dùng (có thể thay bằng biến thực tế)
        fontWeight: FontWeight.bold,
      ),
      subtitle: Txt(text: "UX Designer"), // Nghề nghiệp hoặc chức danh
    );
  }

  // Widget tạo đường kẻ ngang để phân tách nội dung
  Widget divider() {
    return const Padding(
      padding: EdgeInsets.all(8.0), // Khoảng đệm cho Divider
      child: Divider(
        thickness: 1.5, // Độ dày của đường kẻ
      ),
    );
  }

  // Hiển thị các tùy chọn màu sắc (Person data, Settings, Payment...)
  Widget colorTiles() {
    return Column(
      children: [
        colorTile(Icons.person_outline, Colors.deepPurple, "Person data"),
        colorTile(Icons.settings_outlined, Colors.blue, "Settings"),
        colorTile(Icons.credit_card, Colors.pink, "Payment"),
        colorTile(Icons.favorite_border, Colors.orange, "Referral code"),
      ],
    );
  }

  // Hiển thị các tùy chọn đen trắng (FAQs, Handbook, Community)
  Widget bwTitles() {
    return Column(
      children: [
        bwTitle(Icons.info_outline, "FAQs"),
        bwTitle(Icons.border_color_outlined, "HandBook"),
        bwTitle(Icons.textsms_outlined, "Community"),
      ],
    );
  }

  // Tạo các tile màu đen trắng (dùng để tái sử dụng)
  Widget bwTitle(IconData icon, String text) {
    return colorTile(icon, Colors.black, text, blackAndWhite: true);
  }

  // Tạo ListTile có icon, text và mũi tên điều hướng
  Widget colorTile(IconData icon, Color color, String text,
      {bool blackAndWhite = false}) {
    return ListTile(
      leading: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          // Nếu blackAndWhite = true thì dùng màu xám nhạt, ngược lại thì dùng màu icon
          color:
          blackAndWhite ? const Color(0xfff3f4fe) : color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(18), // Bo góc cho container icon
        ),
        child: Icon(icon, color: color), // Hiển thị icon
      ),
      title: Txt(
        text: text,
        fontWeight: FontWeight.w500,
      ),
      trailing:
      const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
    );
  }

  // Tạo widget Text đơn giản với khả năng thiết lập độ đậm
  Widget Txt({required String text, FontWeight? fontWeight}) {
    return Text(
      text,
      style: TextStyle(
          fontWeight: fontWeight ??
              FontWeight
                  .normal), // Nếu không truyền fontWeight thì mặc định là normal
    );
  }
}