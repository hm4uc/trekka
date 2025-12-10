import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../onboarding/domain/entities/travel_constants.dart';
import '../../../onboarding/presentation/bloc/preferences_bloc.dart';
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
    // Gọi API lấy từ điển Constants (để map ID -> Label sở thích)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthGetProfileRequested());
    context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
    await Future.delayed(const Duration(seconds: 1));
  }

  void _handleItemTap(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tính năng '$title' đang phát triển!",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.surfaceColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        User? user = (authState is AuthSuccess) ? authState.user : null;
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
            backgroundColor: AppTheme.surfaceColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 1. THANH TIẾN ĐỘ HOÀN THÀNH (Gamification)
                  _buildCompletionProgressBar(85),
                  const SizedBox(height: 24),

                  // 2. HEADER CƠ BẢN (Avatar, Name, Email)
                  _buildHeader(user),
                  const SizedBox(height: 20),

                  // 3. BIO (Giới thiệu bản thân)
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 4. THÔNG TIN CÁ NHÂN (Chips: Tuổi | Giới tính | Nghề nghiệp)
                  _buildPersonalInfoChips(user),

                  const SizedBox(height: 24),

                  // 5. NÚT CHỈNH SỬA
                  _buildEditButton(context, user),
                  const SizedBox(height: 30),

                  // 6. THỐNG KÊ (Stats)
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("42", "Điểm đã đến")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("15", "Sự kiện tham gia")),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 7. TRAVEL DNA (Thông tin quan trọng nhất)
                  _buildTravelDnaCard(user),

                  const SizedBox(height: 30),

                  // 8. MENU
                  _buildMenuItem(Icons.calendar_today, "Lịch trình của tôi",
                      () => _handleItemTap("Lịch trình")),
                  _buildMenuItem(
                      Icons.favorite, "Địa điểm yêu thích", () => _handleItemTap("Yêu thích")),
                  _buildMenuItem(
                      Icons.location_on, "Địa điểm đã đi", () => _handleItemTap("Check-in")),
                  _buildMenuItem(
                      Icons.celebration, "Sự kiện đã tham gia", () => _handleItemTap("Sự kiện")),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Sub-widgets ---

  Widget _buildHeader(User user) {
    // Fallback avatar với UI Avatars (Tránh lỗi 400 và lỗi null)
    final avatarUrl = (user.avatar != null && user.avatar!.startsWith("http"))
        ? user.avatar!
        : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullname)}&background=F3D6C6&color=333&size=256";

    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: const Color(0xFFF3D6C6),
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          user.fullname,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textGrey),
        ),
      ],
    );
  }

  // Widget hiển thị Tuổi, Giới tính, Nghề nghiệp dạng Chips
  Widget _buildPersonalInfoChips(User user) {
    List<Widget> chips = [];

    // Tuổi
    if (user.age != null && user.age! > 0) {
      chips.add(_buildInfoChip(Icons.cake_outlined, "${user.age} tuổi"));
    }

    // Giới tính
    if (user.gender != null) {
      IconData genderIcon = Icons.person_outline;
      if (user.gender == 'male') genderIcon = Icons.male;
      if (user.gender == 'female') genderIcon = Icons.female;
      chips.add(_buildInfoChip(genderIcon, _formatGender(user.gender)));
    }

    // Nghề nghiệp
    if (user.job != null && user.job!.isNotEmpty) {
      // Viết hoa chữ cái đầu
      String jobLabel = "${user.job![0].toUpperCase()}${user.job!.substring(1)}";
      chips.add(_buildInfoChip(Icons.work_outline, jobLabel));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style:
                GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, User user) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
          );
          if (context.mounted) {
            context.read<AuthBloc>().add(AuthGetProfileRequested());
          }
        },
        icon: const Icon(Icons.edit, size: 16, color: Colors.black),
        label: const Text("Chỉnh sửa hồ sơ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
      ),
    );
  }

  // Card hiển thị Ngân sách & Sở thích (Gom chung cho gọn)
  Widget _buildTravelDnaCard(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.travel_explore, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text("Hồ sơ du lịch",
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),

          // Ngân sách
          _buildSectionTitle("Ngân sách dự kiến"),
          const SizedBox(height: 8),
          _buildBudgetDisplay(user.budget),

          const Padding(
              padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10)),

          // Sở thích
          _buildSectionTitle("Sở thích & Phong cách"),
          const SizedBox(height: 12),
          BlocBuilder<PreferencesBloc, PreferencesState>(
            builder: (context, prefState) {
              List<TravelStyle> styles =
                  (prefState is PreferencesLoaded) ? prefState.constants.styles : [];
              return _buildPreferencesWrap(user.preferences, styles);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDisplay(double? budget) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final budgetText = budget != null ? currencyFormat.format(budget) : "Chưa thiết lập";

    return Text(
      budgetText,
      style: GoogleFonts.inter(
          fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
    );
  }

  Widget _buildPreferencesWrap(List<String>? preferences, List<TravelStyle> styles) {
    if (preferences == null || preferences.isEmpty) {
      return const Text("Chưa chọn sở thích",
          style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: preferences.map((pid) {
        final label = styles
            .cast<TravelStyle>()
            .firstWhere((s) => s.id == pid,
                orElse: () => TravelStyle(id: pid, label: pid, icon: "", description: ""))
            .label;

        // Style chip màu xanh rêu đậm
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3E36),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            "#$label",
            style: GoogleFonts.inter(
                color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildCompletionProgressBar(int percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3E36).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Hoàn thành hồ sơ",
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text("$percent%",
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: Colors.black26,
                    color: AppTheme.primaryColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: Colors.white70),
          title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey));
  }

  String _formatGender(String? gender) {
    if (gender == 'male') return "Nam";
    if (gender == 'female') return "Nữ";
    if (gender == 'other') return "Khác";
    return "Chưa chọn";
  }
}
