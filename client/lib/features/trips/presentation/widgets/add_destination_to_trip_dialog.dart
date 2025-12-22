import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../injection_container.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../destinations/presentation/bloc/destination_event.dart';
import '../../../destinations/presentation/bloc/destination_state.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';

class AddDestinationToTripDialog extends StatefulWidget {
  final String tripId;
  final TripBloc tripBloc;

  const AddDestinationToTripDialog({
    super.key,
    required this.tripId,
    required this.tripBloc,
  });

  @override
  State<AddDestinationToTripDialog> createState() => _AddDestinationToTripDialogState();
}

class _AddDestinationToTripDialogState extends State<AddDestinationToTripDialog> {
  String? selectedDestinationId;
  String? selectedDestinationName;
  int visitOrder = 1;
  int estimatedTime = 60;
  DateTime? visitDate;
  TimeOfDay? startTime;
  final notesController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
  }

  @override
  void dispose() {
    notesController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DestinationBloc>()
        ..add(const GetDestinationsEvent(
          page: 1,
          limit: 100, // Get more destinations for selection
          sortBy: 'name', // Sort alphabetically for easier selection
        )),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Text(
                    'Thêm điểm đến',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search and select destination
                    Text(
                      'Chọn điểm đến',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDestinationSelector(),

                    const SizedBox(height: 20),

                    // Visit order
                    Text(
                      'Thứ tự ghé thăm',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'VD: 1',
                        hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        visitOrder = int.tryParse(value) ?? 1;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Estimated time
                    Text(
                      'Thời gian ước tính (phút)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: estimatedTime.toDouble(),
                      min: 15,
                      max: 480,
                      divisions: 31,
                      label: '$estimatedTime phút',
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          estimatedTime = value.toInt();
                        });
                      },
                    ),
                    Text(
                      '$estimatedTime phút (${(estimatedTime / 60).toStringAsFixed(1)} giờ)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Visit date
                    Text(
                      'Ngày ghé thăm',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: visitDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            visitDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              visitDate != null
                                  ? DateFormat('dd/MM/yyyy').format(visitDate!)
                                  : 'Chọn ngày',
                              style: GoogleFonts.inter(
                                color: visitDate != null ? Colors.white : AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Start time
                    Text(
                      'Giờ bắt đầu',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            startTime = time;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              startTime != null
                                  ? startTime!.format(context)
                                  : 'Chọn giờ',
                              style: GoogleFonts.inter(
                                color: startTime != null ? Colors.white : AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Notes
                    Text(
                      'Ghi chú',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'VD: Ghé thăm vào buổi sáng',
                        hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Add button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addDestination,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Thêm điểm đến',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationSelector() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is DestinationLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }

        if (state is DestinationLoaded) {
          return GestureDetector(
            onTap: () => _showDestinationPicker(context, state.destinations),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedDestinationId != null ? AppTheme.primaryColor : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    color: selectedDestinationId != null ? AppTheme.primaryColor : AppTheme.textGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDestinationName ?? 'Chọn điểm đến',
                      style: GoogleFonts.inter(
                        color: selectedDestinationId != null ? Colors.white : AppTheme.textGrey,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppTheme.textGrey),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  void _showDestinationPicker(BuildContext context, List destinations) {
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Filter destinations based on search
          final filteredDestinations = destinations.where((dest) {
            if (searchQuery.isEmpty) return true;
            return dest.name.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Chọn điểm đến',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${filteredDestinations.length} điểm',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Search field
                      TextField(
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm điểm đến...',
                          hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: filteredDestinations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 60, color: AppTheme.textGrey),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy điểm đến',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDestinations.length,
                          itemBuilder: (context, index) {
                            final dest = filteredDestinations[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.place,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                dest.name,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: dest.address.isNotEmpty
                                  ? Text(
                                      dest.address,
                                      style: GoogleFonts.inter(
                                        color: AppTheme.textGrey,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  selectedDestinationId = dest.id;
                                  selectedDestinationName = dest.name;
                                });
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
      ),
    );
  }

  void _addDestination() {
    if (selectedDestinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn điểm đến'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final destinationData = {
      'destId': selectedDestinationId!,
      'visitOrder': visitOrder,
      'estimatedTime': estimatedTime,
      if (visitDate != null) 'visitDate': DateFormat('yyyy-MM-dd').format(visitDate!),
      if (startTime != null) 'startTime': '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00',
      if (notesController.text.isNotEmpty) 'notes': notesController.text,
    };

    // Store navigator context before popping
    final navigatorContext = Navigator.of(context).context;

    // Pop dialog first
    Navigator.pop(context);

    // Add destination to trip using the passed TripBloc
    widget.tripBloc.add(AddDestinationToTripEvent(widget.tripId, destinationData));

    // Show success message using navigator context
    ScaffoldMessenger.of(navigatorContext).showSnackBar(
      const SnackBar(
        content: Text('Đang thêm điểm đến...'),
        backgroundColor: AppTheme.primaryColor,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
