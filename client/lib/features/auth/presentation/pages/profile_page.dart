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
  @override
  void initState() {
    super.initState();
    // Gọi API lấy thông tin mới nhất ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthGetProfileRequested());
    });
  }

  // Hàm pull to refresh
  Future<void> _onRefresh() async {
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthGetProfileRequested());
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          // Nếu lỗi 401 thì logout, không thì hiện thông báo nhẹ
          if (state.message.contains('401')) {
            context.go('/auth');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        }
      },
      builder: (context, state) {
        User? user;
        if (state is AuthSuccess) {
          user = state.user;
        }

        // Fallback UI khi chưa có dữ liệu hoặc đang loading lần đầu
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
            title: Text("Hồ sơ cá nhân",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
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
            backgroundColor: AppTheme.surfaceColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),

                  _buildEditButton(context, user),
                  const SizedBox(height: 32),

                  _buildStatRow(),
                  const SizedBox(height: 24),

                  // Ngân sách
                  _buildInfoSection(
                    title: "Ngân sách chuyến đi",
                    child: _buildBudgetInfo(user.budget),
                  ),
                  const SizedBox(height: 24),

                  // Phong cách & Sở thích
                  _buildInfoSection(
                    title: "Sở thích & Phong cách",
                    child: _buildPreferences(user.preferences),
                  ),
                  const SizedBox(height: 24),

                  // Bio
                  if (user.bio != null && user.bio!.isNotEmpty)
                    _buildInfoSection(
                      title: "Giới thiệu",
                      child: Text(
                        user.bio!,
                        style:
                            GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey, height: 1.5),
                      ),
                    ),

                  const SizedBox(height: 32),
                  // Menu
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
    ImageProvider avatarImage;
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      avatarImage = NetworkImage(user.avatar!);
    } else {
      avatarImage = const AssetImage('assets/images/welcome.jpg');
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 2),
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppTheme.surfaceColor,
            backgroundImage: avatarImage,
            onBackgroundImageError: (_, __) {
              // Fallback nếu link ảnh lỗi
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.fullname.isNotEmpty ? user.fullname : "Trekker",
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey),
        ),
        if (user.ageGroup != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Nhóm tuổi: ${user.ageGroup}",
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, User user) {
    return SizedBox(
      width: 200,
      height: 40,
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EditProfilePage(user: user),
            ),
          );
          if (context.mounted) {
            context.read<AuthBloc>().add(AuthGetProfileRequested());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 16),
            SizedBox(width: 8),
            Text("Chỉnh sửa hồ sơ", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("0", "Điểm đến"),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildStatItem("0", "Chuyến đi"),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildStatItem("0", "Sự kiện"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style:
                GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildBudgetInfo(double? budget) {
    if (budget == null) {
      return Text("Chưa thiết lập ngân sách",
          style: GoogleFonts.inter(color: AppTheme.textGrey, fontStyle: FontStyle.italic));
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currencyFormat.format(budget),
          style: GoogleFonts.inter(
              fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 4),
        Text("Dự kiến chi tiêu mỗi chuyến đi",
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _buildPreferences(List<String>? preferences) {
    if (preferences == null || preferences.isEmpty) {
      return Text("Chưa chọn sở thích",
          style: GoogleFonts.inter(color: AppTheme.textGrey, fontStyle: FontStyle.italic));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: preferences.map((pref) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            // Capitalize first letter
            "${pref[0].toUpperCase()}${pref.substring(1)}",
            style: GoogleFonts.inter(
                fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textGrey),
        onTap: () {},
      ),
    );
  }
}
