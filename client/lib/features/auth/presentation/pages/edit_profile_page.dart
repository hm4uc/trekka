import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';

class EditProfilePage extends StatefulWidget {
  final User user; // Nhận user hiện tại để hiển thị

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _avatarController;

  // Giá trị dropdown
  String _selectedGender = 'male';
  String _selectedAgeGroup = '15-25';

  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _ageGroups = ['15-25', '26-35', '36-50', '50+'];

  @override
  void initState() {
    super.initState();
    // Fill data cũ vào form
    _nameController = TextEditingController(text: widget.user.fullname);
    _bioController = TextEditingController(text: widget.user.bio ?? "");
    _avatarController = TextEditingController(text: widget.user.avatar ?? "https://example.com/avatar.jpg");

    if (widget.user.gender != null && _genders.contains(widget.user.gender)) {
      _selectedGender = widget.user.gender!;
    }
    if (widget.user.ageGroup != null && _ageGroups.contains(widget.user.ageGroup)) {
      _selectedAgeGroup = widget.user.ageGroup!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    context.read<AuthBloc>().add(AuthUpdateProfileSubmitted(
      fullname: _nameController.text.trim(),
      gender: _selectedGender,
      ageGroup: _selectedAgeGroup,
      bio: _bioController.text.trim(),
      avatar: _avatarController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green),
          );
          context.pop(); // Quay về trang Profile
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text("Chỉnh sửa Hồ sơ", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Edit Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_avatarController.text),
                      backgroundColor: AppTheme.surfaceColor,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text("Thay đổi ảnh đại diện",
                    style: GoogleFonts.inter(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 30),

              // Fullname
              _buildLabel("Tên hiển thị"),
              AuthTextField(controller: _nameController, hintText: "Nhập tên của bạn"),
              const SizedBox(height: 20),

              // Row: Age & Gender
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Độ tuổi"),
                        _buildDropdown(_ageGroups, _selectedAgeGroup, (val) {
                          setState(() => _selectedAgeGroup = val!);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Giới tính"),
                        _buildDropdown(_genders, _selectedGender, (val) {
                          setState(() => _selectedGender = val!);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Avatar URL (Tạm thời nhập text)
              _buildLabel("Link Ảnh đại diện (URL)"),
              AuthTextField(controller: _avatarController, hintText: "https://..."),
              const SizedBox(height: 20),

              // Bio
              _buildLabel("Giới thiệu bản thân"),
              AuthTextField(
                controller: _bioController,
                hintText: "Viết gì đó về bạn...",
              ),
              const SizedBox(height: 40),

              // Save Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return PrimaryButton(
                    text: "Lưu thay đổi",
                    isLoading: state is AuthLoading,
                    onPressed: _onSubmit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey)),
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.surfaceColor,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textGrey),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}