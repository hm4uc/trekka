// lib/features/preferences/presentation/pages/preferences_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/travel_constants.dart';
import '../bloc/preferences_bloc.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  int _currentStep = 1;
  String? _selectedAgeGroup;
  final Set<String> _selectedStyles = {};
  double _currentBudget = 0;

  // Biến lưu config để dùng cho slider
  BudgetConfig? _budgetConfig;

  @override
  void initState() {
    super.initState();
    // Gọi event lấy dữ liệu ngay khi vào màn hình
    context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(value);
  }

  void _updateBudget(bool increase) {
    if (_budgetConfig == null) return;

    final step = _budgetConfig!.step;
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

  // Logic chuyển bước
  void _onContinue() {
    if (_currentStep == 1) {
      // Validate Step 1
      if (_selectedAgeGroup == null) {
        _showSnackBar("Vui lòng chọn nhóm tuổi của bạn!");
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      // Validate Step 2
      if (_selectedStyles.isEmpty) {
        _showSnackBar("Vui lòng chọn ít nhất 1 sở thích!");
        return;
      }
      setState(() => _currentStep = 3);
    } else {
      // Step 3 -> Hoàn tất
      context.go('/location-permission');
    }
  }

  void _onBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: _onBack)
            : null,
        title: Text("Bước $_currentStep/3",
            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textGrey)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/location-permission'),
            child: Text("Bỏ qua", style: GoogleFonts.inter(color: AppTheme.primaryColor)),
          )
        ],
      ),
      body: BlocConsumer<PreferencesBloc, PreferencesState>(
        listener: (context, state) {
          if (state is PreferencesError) {
            _showSnackBar(state.message);
          }
          if (state is PreferencesLoaded && _currentBudget == 0) {
            setState(() {
              _budgetConfig = state.constants.budgetConfig;
              _currentBudget = state.constants.budgetConfig.defaultValue;
            });
          }
        },
        builder: (context, state) {
          if (state is PreferencesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          if (state is PreferencesLoaded) {
            return Column(
              children: [
                // Progress Bar (Chia 3 phần)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(child: _buildProgressIndicator(active: _currentStep >= 1)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProgressIndicator(active: _currentStep >= 2)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProgressIndicator(active: _currentStep >= 3)),
                    ],
                  ),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepContent(state.constants),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -5))
                    ],
                  ),
                  child: PrimaryButton(
                    text: _currentStep == 3 ? "Hoàn tất" : "Tiếp tục",
                    onPressed: _onContinue,
                  ),
                ),
              ],
            );
          }
          return const Center(
              child: Text("Không tải được dữ liệu", style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  Widget _buildStepContent(TravelConstants constants) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Age(constants.ageGroup);
      case 2:
        return _buildStep2Interests(constants.styles);
      case 3:
        return _buildStep3Budget();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProgressIndicator({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryColor : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // --- STEP 1: CHỌN TUỔI (GRID ẢNH) ---
  Widget _buildStep1Age(List<String> ageGroups) {
    // Nếu chưa có dữ liệu API, hiển thị loading hoặc text báo
    if (ageGroups.isEmpty) {
      return const Center(
        child: Text("Đang tải danh sách độ tuổi...", style: TextStyle(color: Colors.white)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Tiêu đề
          Text(
            "Bạn thuộc nhóm tuổi nào?",
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Mô tả
          Text(
            "Giúp Trekka gợi ý các điểm đến phù hợp nhất với thế hệ của bạn.",
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 32),

          // LƯỚI 2x2
          GridView.builder(
            shrinkWrap: true,
            // Quan trọng: để nằm gọn trong SingleChildScrollView
            physics: const NeverScrollableScrollPhysics(),
            // Không cuộn riêng lẻ
            itemCount: ageGroups.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cột -> tạo thành lưới 2x2
              childAspectRatio: 1.0, // Tỷ lệ vuông 1:1 cho đẹp
              crossAxisSpacing: 16, // Khoảng cách ngang
              mainAxisSpacing: 16, // Khoảng cách dọc
            ),
            itemBuilder: (context, index) {
              final age = ageGroups[index];
              final isSelected = _selectedAgeGroup == age;

              // Lấy ảnh từ Helper (Đảm bảo bạn đã update ImageHelper như bài trước)
              final imagePath = ImageHelper.getAgeGroupImage(age);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAgeGroup = age;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // Hiệu ứng viền khi chọn
                    border: isSelected
                        ? Border.all(color: AppTheme.primaryColor, width: 3)
                        : Border.all(color: Colors.transparent, width: 0),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16), // Bo góc ảnh bên trong
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. ẢNH NỀN
                        Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                                color: AppTheme.surfaceColor); // Màu fallback nếu lỗi ảnh
                          },
                        ),

                        // 2. LỚP PHỦ TỐI (Để chữ dễ đọc)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.8),
                              ],
                              stops: const [0.5, 0.7, 1.0],
                            ),
                          ),
                        ),

                        // 3. TEXT ĐỘ TUỔI
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              age, // Ví dụ: "15-25"
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  const Shadow(
                                    blurRadius: 4,
                                    color: Colors.black,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 4. ICON CHECK (Chỉ hiện khi chọn)
                        if (isSelected)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: AppTheme.backgroundColor, // Màu check đen/tối trên nền xanh
                              ),
                            ),
                          ),

                        // 5. LỚP PHỦ MỜ KHI CHƯA CHỌN (Tùy chọn: làm chìm các ô khác)
                        if (_selectedAgeGroup != null && !isSelected)
                          Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// --- STEP 2: CHỌN SỞ THÍCH (GRID ẢNH) ---
  Widget _buildStep2Interests(List<TravelStyle> styles) {
    // Kiểm tra xem có item nào đang được chọn không (để làm tối các item còn lại)
    final bool hasSelection = _selectedStyles.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "Sở thích du lịch?",
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Chọn ít nhất một mục để cá nhân hóa gợi ý.",
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0, // Vuông vắn
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: styles.length,
            itemBuilder: (context, index) {
              final item = styles[index];
              final isSelected = _selectedStyles.contains(item.id);
              final imagePath = ImageHelper.getTravelStyleImage(item.id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedStyles.remove(item.id);
                    } else {
                      _selectedStyles.add(item.id);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // Viền xanh khi chọn
                    border: isSelected
                        ? Border.all(color: AppTheme.primaryColor, width: 3)
                        : Border.all(color: Colors.transparent, width: 0),
                    // Đổ bóng khi chọn
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. ẢNH NỀN
                        Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: AppTheme.surfaceColor),
                        ),

                        // 2. LỚP PHỦ (Overlay logic)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                // Nếu đang chọn item khác -> làm tối item này đi (0.6)
                                // Nếu không chọn gì -> làm tối nhẹ (0.3) để đọc chữ
                                hasSelection && !isSelected
                                    ? Colors.black.withOpacity(0.7)
                                    : Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.9), // Đáy luôn tối để hiện chữ
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),

                        // 3. TEXT LABEL
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: 16, // Tăng size chữ một chút cho dễ đọc
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.9), // Chữ hơi mờ nếu chưa chọn
                                shadows: [
                                  const Shadow(
                                    blurRadius: 4,
                                    color: Colors.black,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // 4. ICON CHECK (Góc trên phải)
                        if (isSelected)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: AppTheme.backgroundColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --- STEP 3: NGÂN SÁCH (Giữ nguyên logic cũ) ---
  Widget _buildStep3Budget() {
    if (_budgetConfig == null) return const SizedBox.shrink();
    final int divisions = ((_budgetConfig!.max - _budgetConfig!.min) / _budgetConfig!.step).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Ngân sách dự kiến?",
              style: GoogleFonts.inter(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 60),

          Center(
            child: Column(
              children: [
                Text("Ngân sách bạn chi trung bình cho mỗi chuyến đi.",
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey)),
                const SizedBox(height: 16),
                Text(_formatCurrency(_currentBudget),
                    style: GoogleFonts.inter(
                        fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 40),

          Row(
            children: [
              IconButton(
                  onPressed: () => _updateBudget(false),
                  icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.remove, color: Colors.white))),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: AppTheme.surfaceColor,
                    thumbColor: AppTheme.primaryColor,
                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _currentBudget,
                    min: _budgetConfig!.min,
                    max: _budgetConfig!.max,
                    divisions: divisions > 0 ? divisions : 1,
                    onChanged: (value) => setState(() => _currentBudget = value),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () => _updateBudget(true),
                  icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add, color: Colors.white))),
            ],
          ),
          // ... Labels Min/Max giữ nguyên
          const Spacer(),
        ],
      ),
    );
  }
}