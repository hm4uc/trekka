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
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _avatarController;
  late TextEditingController _budgetController;

  String _selectedGender = 'male';
  String _selectedAgeGroup = '15-25';

  // Danh sách sở thích mẫu (Có thể lấy từ constants của bạn)
  final List<String> _allPreferences = [
    "nature",
    "culture_history",
    "food_drink",
    "chill_relax",
    "adventure",
    "shopping_entertainment",
    "luxury",
    "local_life"
  ];
  final Set<String> _selectedPreferences = {};

  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _ageGroups = ['15-25', '26-35', '36-50', '50+'];

  @override
  void initState() {
    super.initState();
    // Fill data
    _nameController = TextEditingController(text: widget.user.fullname);
    _bioController = TextEditingController(text: widget.user.bio ?? "");
    _avatarController =
        TextEditingController(text: widget.user.avatar ?? "https://example.com/avatar.jpg");

    // Budget: ép kiểu về int cho đẹp nếu tròn
    String budgetStr = "";
    if (widget.user.budget != null) {
      budgetStr = widget.user.budget!.toInt().toString();
    }
    _budgetController = TextEditingController(text: budgetStr);

    if (widget.user.gender != null && _genders.contains(widget.user.gender)) {
      _selectedGender = widget.user.gender!;
    }
    if (widget.user.ageGroup != null && _ageGroups.contains(widget.user.ageGroup)) {
      _selectedAgeGroup = widget.user.ageGroup!;
    }

    // Preferences
    if (widget.user.preferences != null) {
      _selectedPreferences.addAll(widget.user.preferences!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _avatarController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    // ⚠️ QUAN TRỌNG: API Update hiện tại của bạn chưa hỗ trợ update preferences/budget
    // Nếu API backend đã hỗ trợ thì thêm vào params.
    // Dựa vào code AuthUpdateProfileSubmitted hiện tại, chỉ có: fullname, gender, ageGroup, bio, avatar.
    // Tôi sẽ gửi những gì có thể gửi.

    context.read<AuthBloc>().add(AuthUpdateProfileSubmitted(
          fullname: _nameController.text.trim(),
          gender: _selectedGender,
          ageGroup: _selectedAgeGroup,
          bio: _bioController.text.trim(),
          avatar: _avatarController.text.trim(),
          // budget: double.tryParse(_budgetController.text), // Chờ update Backend/Event
          // preferences: _selectedPreferences.toList(),      // Chờ update Backend/Event
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã lưu thay đổi!"), backgroundColor: Colors.green),
          );
          context.pop();
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
              // 1. Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_avatarController.text),
                      backgroundColor: AppTheme.surfaceColor,
                      onBackgroundImageError: (_, __) {},
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: AppTheme.primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 16, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Link Avatar (Tạm thời)
              _buildLabel("URL Ảnh đại diện"),
              AuthTextField(controller: _avatarController, hintText: "https://..."),
              const SizedBox(height: 20),

              // 3. Tên & Bio
              _buildLabel("Tên hiển thị"),
              AuthTextField(controller: _nameController, hintText: "Tên của bạn"),
              const SizedBox(height: 20),

              _buildLabel("Giới thiệu (Bio)"),
              AuthTextField(
                  controller: _bioController, hintText: "Mô tả ngắn về bạn..."),
              const SizedBox(height: 20),

              // 4. Dropdowns Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Độ tuổi"),
                        _buildDropdown(_ageGroups, _selectedAgeGroup,
                            (val) => setState(() => _selectedAgeGroup = val!)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Giới tính"),
                        _buildDropdown(_genders, _selectedGender,
                            (val) => setState(() => _selectedGender = val!)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Budget (UI Only - chờ API update)
              _buildLabel("Ngân sách (VNĐ)"),
              AuthTextField(
                  controller: _budgetController,
                  hintText: "VD: 5000000",
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              // 6. Preferences (UI Only - chờ API update)
              _buildLabel("Sở thích"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allPreferences.map((pref) {
                  final isSelected = _selectedPreferences.contains(pref);
                  return FilterChip(
                    label: Text(pref),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedPreferences.add(pref);
                        } else {
                          _selectedPreferences.remove(pref);
                        }
                      });
                    },
                    backgroundColor: AppTheme.surfaceColor,
                    selectedColor: AppTheme.primaryColor,
                    labelStyle:
                        TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? Colors.transparent : Colors.white24)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

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
              child: Text(_formatLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _formatLabel(String s) {
    if (s == 'male') return 'Nam';
    if (s == 'female') return 'Nữ';
    if (s == 'other') return 'Khác';
    return s;
  }
}
