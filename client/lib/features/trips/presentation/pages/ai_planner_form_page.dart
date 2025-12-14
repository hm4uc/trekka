import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_themes.dart';

class AIPlannerFormPage extends StatefulWidget {
  const AIPlannerFormPage({super.key});

  @override
  State<AIPlannerFormPage> createState() => _AIPlannerFormPageState();
}

class _AIPlannerFormPageState extends State<AIPlannerFormPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tripNameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedDuration = '1_day'; // 1_day, half_day, 2_days, 3_days
  List<String> _selectedStyles = [];
  double _budget = 500000;
  String _transport = 'walking'; // walking, motorbike, car
  int _groupSize = 1;

  final List<Map<String, dynamic>> _travelStyles = [
    {'id': 'nature', 'label': 'Thiên nhiên', 'icon': Icons.nature, 'color': Colors.green},
    {'id': 'food_drink', 'label': 'Ẩm thực', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'id': 'culture_history', 'label': 'Văn hóa', 'icon': Icons.museum, 'color': Colors.purple},
    {'id': 'adventure', 'label': 'Phiêu lưu', 'icon': Icons.hiking, 'color': Colors.red},
    {'id': 'chill_relax', 'label': 'Thư giãn', 'icon': Icons.spa, 'color': Colors.blue},
    {'id': 'shopping_entertainment', 'label': 'Giải trí', 'icon': Icons.shopping_bag, 'color': Colors.pink},
  ];

  final List<Map<String, String>> _durations = [
    {'id': 'half_day', 'label': 'Nửa ngày', 'description': '4-5 tiếng'},
    {'id': '1_day', 'label': '1 ngày', 'description': '8-10 tiếng'},
    {'id': '2_days', 'label': '2 ngày', 'description': 'Có nghỉ đêm'},
    {'id': '3_days', 'label': '3 ngày', 'description': 'Khám phá sâu'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationController.dispose();
    _tripNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.black,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _generateTrip() {
    if (_formKey.currentState!.validate()) {
      if (_selectedStyles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất một phong cách du lịch'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // TODO: Call AI Trip Generation API
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildGeneratingDialog(),
      );

      // Simulate API call
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Return to trips page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Lịch trình đã được tạo thành công!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'AI Trip Planner',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildTripNameField(),
                    const SizedBox(height: 20),
                    _buildLocationField(),
                    const SizedBox(height: 20),
                    _buildDateSelection(),
                    const SizedBox(height: 20),
                    _buildDurationSelection(),
                    const SizedBox(height: 20),
                    _buildTravelStyleSelection(),
                    const SizedBox(height: 20),
                    _buildBudgetSlider(),
                    const SizedBox(height: 20),
                    _buildTransportSelection(),
                    const SizedBox(height: 20),
                    _buildGroupSizeSelector(),
                    const SizedBox(height: 32),
                    _buildGenerateButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.2),
            Colors.purple.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo lịch trình thông minh',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI sẽ giúp bạn lên kế hoạch chi tiết',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripNameField() {
    return _buildSection(
      title: 'Tên chuyến đi',
      child: TextFormField(
        controller: _tripNameController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'VD: Khám phá Hà Nội cuối tuần',
          hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
          filled: true,
          fillColor: AppTheme.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.edit, color: AppTheme.primaryColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập tên chuyến đi';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationField() {
    return _buildSection(
      title: 'Điểm đến',
      child: TextFormField(
        controller: _locationController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nhập địa điểm (VD: Hà Nội, Đà Nẵng...)',
          hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
          filled: true,
          fillColor: AppTheme.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.location_on, color: AppTheme.primaryColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập điểm đến';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateSelection() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return _buildSection(
      title: 'Thời gian',
      child: Row(
        children: [
          Expanded(
            child: _buildDateButton(
              label: 'Ngày đi',
              date: _startDate,
              onTap: () => _selectDate(context, true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateButton(
              label: 'Ngày về',
              date: _endDate,
              onTap: () => _selectDate(context, false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? dateFormat.format(date) : 'Chọn ngày',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: date != null ? Colors.white : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelection() {
    return _buildSection(
      title: 'Thời lượng',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: _durations.length,
        itemBuilder: (context, index) {
          final duration = _durations[index];
          final isSelected = _selectedDuration == duration['id'];

          return InkWell(
            onTap: () => setState(() => _selectedDuration = duration['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    duration['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    duration['description']!,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTravelStyleSelection() {
    return _buildSection(
      title: 'Phong cách du lịch',
      subtitle: 'Chọn ít nhất 1 phong cách',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _travelStyles.map((style) {
          final isSelected = _selectedStyles.contains(style['id']);

          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedStyles.remove(style['id']);
                } else {
                  _selectedStyles.add(style['id'] as String);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (style['color'] as Color).withOpacity(0.2)
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? (style['color'] as Color) : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    style['icon'] as IconData,
                    size: 18,
                    color: isSelected ? (style['color'] as Color) : AppTheme.textGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    style['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetSlider() {
    return _buildSection(
      title: 'Ngân sách mỗi người',
      subtitle: NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
          .format(_budget),
      child: Column(
        children: [
          Slider(
            value: _budget,
            min: 100000,
            max: 5000000,
            divisions: 49,
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.surfaceColor,
            onChanged: (value) => setState(() => _budget = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '100K',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textGrey,
                ),
              ),
              Text(
                '5M',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportSelection() {
    final transports = [
      {'id': 'walking', 'label': 'Đi bộ', 'icon': Icons.directions_walk},
      {'id': 'motorbike', 'label': 'Xe máy', 'icon': Icons.two_wheeler},
      {'id': 'car', 'label': 'Ô tô', 'icon': Icons.directions_car},
      {'id': 'public', 'label': 'Xe buýt', 'icon': Icons.directions_bus},
    ];

    return _buildSection(
      title: 'Phương tiện di chuyển',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: transports.length,
        itemBuilder: (context, index) {
          final transport = transports[index];
          final isSelected = _transport == transport['id'];

          return InkWell(
            onTap: () => setState(() => _transport = transport['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    transport['icon'] as IconData,
                    size: 20,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    transport['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupSizeSelector() {
    return _buildSection(
      title: 'Số người tham gia',
      child: Row(
        children: [
          IconButton(
            onPressed: _groupSize > 1
                ? () => setState(() => _groupSize--)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: _groupSize > 1 ? AppTheme.primaryColor : AppTheme.textGrey,
            iconSize: 32,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                '$_groupSize ${_groupSize == 1 ? "người" : "người"}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _groupSize < 20
                ? () => setState(() => _groupSize++)
                : null,
            icon: const Icon(Icons.add_circle_outline),
            color: _groupSize < 20 ? AppTheme.primaryColor : AppTheme.textGrey,
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _generateTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 24),
            const SizedBox(width: 12),
            Text(
              'Tạo lịch trình với AI',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildGeneratingDialog() {
    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 20),
            Text(
              'AI đang tạo lịch trình...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang phân tích sở thích và tối ưu hóa tuyến đường',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

