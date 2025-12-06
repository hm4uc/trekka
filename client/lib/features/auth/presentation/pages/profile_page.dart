import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_themes.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // @override
  // void initState() {
  //   super.initState();
  //   // Gọi API khi vào màn
  //   // Dùng addPostFrameCallback để đảm bảo widget đã build xong
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<AuthBloc>().add(AuthGetProfileRequested());
  //   });
  // }

  // Hàm pull to refresh
  Future<void> _onRefresh() async {
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthGetProfileRequested());
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Lấy thông tin User từ AuthState
        // Nếu chưa có user (ví dụ đang loading), hiển thị placeholder hoặc loading
        User? user;
        if (state is AuthSuccess) {
          user = state.user;
        }

        if (user == null) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("Hồ sơ", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.backgroundColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 1. Header (Avatar + Name)
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),

                  // 2. Edit Button
                  _buildEditButton(context, user),
                  const SizedBox(height: 24),

                  // 3. Stats Cards (Dummy Data vì API chưa có)
                  Row(
                    children: [
                      // Todo: new api
                      Expanded(child: _buildStatCard("0", "Điểm đến")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard("0", "Sự kiện")),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Completion Rate
                  _buildCompletionCard(),
                  const SizedBox(height: 32),

                  // 5. Ngân sách
                  _buildSectionTitle("Ngân sách"),
                  _buildBudgetInfo(user.budget),
                  const SizedBox(height: 24),

                  // 6. Sở thích (Preferences)
                  _buildSectionTitle("Sở thích & Phong cách"),
                  _buildTags(user.preferences ?? []),
                  const SizedBox(height: 32),

                  // 7. Menu List
                  _buildMenuItem(Icons.calendar_today_rounded, "Lịch trình của tôi"),
                  _buildMenuItem(Icons.favorite_rounded, "Địa điểm yêu thích"),
                  _buildMenuItem(Icons.history_rounded, "Lịch sử chuyến đi"),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS CON ---
  Widget _buildProfileHeader(User user) {
    // Xử lý avatar: Nếu user.avatar null hoặc lỗi thì dùng ảnh mặc định
    final imageProvider = (user.avatar != null && user.avatar!.isNotEmpty)
        ? NetworkImage(user.avatar!) as ImageProvider
        : const AssetImage('assets/images/welcome.jpg');

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceColor,
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageProvider,
                backgroundColor: AppTheme.surfaceColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.fullname.isNotEmpty ? user.fullname : "Trekker",
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, User user) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () async {
          // 1. Chờ người dùng quay lại từ màn hình Edit
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EditProfilePage(user: user),
            ),
          );

          // 2. 👇 QUAN TRỌNG: Kiểm tra xem màn hình Profile này còn tồn tại không
          if (!context.mounted) return;

          // 3. Nếu còn tồn tại, mới được dùng context để gọi Bloc
          context.read<AuthBloc>().add(AuthGetProfileRequested());
        },
        icon: const Icon(Icons.edit, size: 16, color: AppTheme.backgroundColor),
        label: Text("Chỉnh sửa hồ sơ",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.backgroundColor)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration:
          BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text("50%",
              style: GoogleFonts.inter(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Hoàn thành hồ sơ",
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildBudgetInfo(double? budget) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final budgetText = budget != null ? currencyFormat.format(budget) : "Chưa thiết lập";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(
            budgetText,
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text("Ngân sách dự kiến mỗi chuyến đi",
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildTags(List<String> tags) {
    if (tags.isEmpty) {
      return Text("Chưa có sở thích nào",
          style: GoogleFonts.inter(color: AppTheme.textGrey, fontStyle: FontStyle.italic));
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: tags.map((tag) {
          // Format tag cho đẹp (Ví dụ: nature -> #Nature)
          final displayTag = "#${tag[0].toUpperCase()}${tag.substring(1)}";

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              displayTag,
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryColor),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration:
          BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textGrey),
        onTap: () {},
      ),
    );
  }
}
