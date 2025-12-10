import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../onboarding/domain/entities/travel_constants.dart';
import '../../../onboarding/presentation/bloc/preferences_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _ageController;

  String _selectedGender = 'other';
  String? _selectedJob; // Giữ null nếu chưa chọn
  double _currentBudget = 0;
  bool _isBudgetSkipped = false;
  final Set<String> _selectedPreferences = {};

  List<String> _jobs = [];
  List<TravelStyle> _travelStyles = [];
  BudgetConfig? _budgetConfig;

  @override
  void initState() {
    super.initState();
    context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
    _initUserData();
  }

  void _initUserData() {
    _nameController = TextEditingController(text: widget.user.fullname);
    _bioController = TextEditingController(text: widget.user.bio ?? "");
    _ageController = TextEditingController(text: widget.user.age?.toString() ?? "");
    _selectedGender = widget.user.gender ?? 'other';
    _selectedJob = widget.user.job;

    if (widget.user.preferences != null) _selectedPreferences.addAll(widget.user.preferences!);

    if (widget.user.budget != null && widget.user.budget! > 0) {
      _currentBudget = widget.user.budget!;
      _isBudgetSkipped = false;
    } else {
      _currentBudget = 1000000;
      _isBudgetSkipped = true;
    }
  }

  void _onSubmit() {
    String avatarUrl = widget.user.avatar ?? "";
    if (avatarUrl.isEmpty || !avatarUrl.startsWith("http")) {
      avatarUrl =
          "https://ui-avatars.com/api/?name=${Uri.encodeComponent(_nameController.text)}&background=F3D6C6&color=333&size=256";
    }

    context.read<AuthBloc>().add(AuthUpdateProfileSubmitted(
        fullname: _nameController.text.trim(),
        gender: _selectedGender,
        age: int.tryParse(_ageController.text),
        job: _selectedJob ?? "",
        bio: _bioController.text.trim(),
        avatar: avatarUrl,
        budget: _isBudgetSkipped ? null : _currentBudget,
        preferences: _selectedPreferences.toList()));
  }

  // Logic tăng giảm budget
  void _updateBudget(bool increase) {
    if (_budgetConfig == null || _isBudgetSkipped) return;

    final step = _budgetConfig!.step; // API trả về 100000
    final min = _budgetConfig!.min;
    final max = _budgetConfig!.max;

    setState(() {
      if (increase) {
        if (_currentBudget + step <= max) _currentBudget += step;
      } else {
        if (_currentBudget - step >= min) _currentBudget -= step;
      }
    });
  }

  // Hàm hiện BottomSheet chọn Job
  void _showJobPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text("Chọn nghề nghiệp",
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    final job = _jobs[index];
                    final label = "${job[0].toUpperCase()}${job.substring(1)}";
                    final isSelected = _selectedJob == job;
                    return ListTile(
                      title: Text(label,
                          style:
                              TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.white)),
                      trailing:
                          isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                      onTap: () {
                        setState(() => _selectedJob = job);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đã lưu thay đổi!"), backgroundColor: Colors.green));
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text("Chỉnh sửa Hồ sơ", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocConsumer<PreferencesBloc, PreferencesState>(
          listener: (context, state) {
            if (state is PreferencesLoaded) {
              setState(() {
                _travelStyles = state.constants.styles;
                _budgetConfig = state.constants.budgetConfig;
                _jobs = state.constants.jobs;
                if (widget.user.budget == null) _currentBudget = _budgetConfig!.defaultValue;
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarEdit(),
                  const SizedBox(height: 30),

                  _buildLabel("Tên hiển thị"),
                  _buildCustomTextField(_nameController, "Tên của bạn"),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildLabel("Tuổi"),
                        _buildCustomTextField(_ageController, "Nhập tuổi", isNumber: true),
                      ])),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildLabel("Giới tính"),
                        _buildDropdown(['male', 'female', 'other'], _selectedGender,
                            (v) => setState(() => _selectedGender = v!),
                            isGender: true),
                      ])),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // JOB PICKER MỚI (Thân thiện hơn)
                  _buildLabel("Nghề nghiệp"),
                  GestureDetector(
                    onTap: _showJobPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedJob != null
                                ? "${_selectedJob![0].toUpperCase()}${_selectedJob!.substring(1)}"
                                : "Chọn nghề nghiệp",
                            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white54),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("Giới thiệu (Bio)"),
                  _buildCustomTextField(_bioController, "Viết gì đó về bạn...", maxLines: 3),
                  const SizedBox(height: 30),

                  // BUDGET VỚI NÚT +/-
                  if (_budgetConfig != null) _buildBudgetControl(),

                  const SizedBox(height: 20),
                  _buildLabel("Sở thích của bạn"),
                  _buildPreferencesChips(),
                  const SizedBox(height: 40),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) => PrimaryButton(
                        text: "Lưu thay đổi",
                        isLoading: authState is AuthLoading,
                        onPressed: _onSubmit),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Components ---

  Widget _buildBudgetControl() {
    return Column(
      children: [
        _buildLabel("Ngân sách dự kiến mỗi chuyến đi"),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _isBudgetSkipped
                ? "Chưa xác định"
                : NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(_currentBudget),
            style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _isBudgetSkipped ? AppTheme.textGrey : AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 10),
        IgnorePointer(
          ignoring: _isBudgetSkipped,
          child: Opacity(
            opacity: _isBudgetSkipped ? 0.4 : 1.0,
            child: Row(
              children: [
                // Nút (-) đã sửa lỗi tràn viền
                _buildBudgetBtn(Icons.remove, () => _updateBudget(false)),

                // Slider
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveTrackColor: AppTheme.surfaceColor,
                      thumbColor: AppTheme.primaryColor,
                      overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _currentBudget,
                      min: _budgetConfig!.min,
                      max: _budgetConfig!.max,
                      divisions: ((_budgetConfig!.max - _budgetConfig!.min) / _budgetConfig!.step)
                          .round(),
                      onChanged: (v) => setState(() => _currentBudget = v),
                    ),
                  ),
                ),

                // Nút (+) đã sửa lỗi tràn viền
                _buildBudgetBtn(Icons.add, () => _updateBudget(true)),
              ],
            ),
          ),
        ),

        // Toggle Budget (Giữ nguyên)
        GestureDetector(
          onTap: () => setState(() => _isBudgetSkipped = !_isBudgetSkipped),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isBudgetSkipped ? Icons.check_circle : Icons.circle_outlined,
                    color: _isBudgetSkipped ? AppTheme.primaryColor : AppTheme.textGrey,
                    size: 20),
                const SizedBox(width: 8),
                Text("Chưa xác định ngân sách",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _isBudgetSkipped ? Colors.white : AppTheme.textGrey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetBtn(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8), // Bo tròn hiệu ứng splash
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarEdit() {
    final avatarUrl = (widget.user.avatar != null && widget.user.avatar!.startsWith("http"))
        ? widget.user.avatar!
        : "https://ui-avatars.com/api/?background=F3D6C6&color=333&size=256";

    return Center(
      child: Column(
        children: [
          CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: AppTheme.surfaceColor),
          const SizedBox(height: 12),
          const Text("Thay đổi ảnh đại diện",
              style: TextStyle(
                  color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, String hint,
      {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          isDense: false,
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? value, Function(String?) onChanged,
      {bool isGender = false, String? hint}) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint ?? "Chọn", style: const TextStyle(color: Colors.white38)),
          isExpanded: true,
          dropdownColor: const Color(0xFF2A2A3E),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                      isGender
                          ? (e == 'male'
                              ? 'Nam'
                              : e == 'female'
                                  ? 'Nữ'
                                  : 'Khác')
                          : "${e[0].toUpperCase()}${e.substring(1)}",
                      style: const TextStyle(color: Colors.white))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPreferencesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _travelStyles.map((s) {
        final isSelected = _selectedPreferences.contains(s.id);
        return FilterChip(
          label: Text(s.label),
          selected: isSelected,
          onSelected: (v) => setState(
              () => v ? _selectedPreferences.add(s.id) : _selectedPreferences.remove(s.id)),
          backgroundColor: const Color(0xFF1E3E36),
          selectedColor: const Color(0xFF2E7D68),
          labelStyle: const TextStyle(color: Colors.white),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), side: BorderSide.none),
          deleteIcon: isSelected ? const Icon(Icons.close, size: 14, color: Colors.white) : null,
          onDeleted: isSelected ? () => setState(() => _selectedPreferences.remove(s.id)) : null,
        );
      }).toList(),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)));
}
