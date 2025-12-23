import 'package:easy_localization/easy_localization.dart' hide NumberFormat;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/trip.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedStatus = null; // All
            break;
          case 1:
            _selectedStatus = 'draft';
            break;
          case 2:
            _selectedStatus = 'planned';
            break;
          case 3:
            _selectedStatus = 'ongoing';
            break;
          case 4:
            _selectedStatus = 'completed';
            break;
        }
      });
      context.read<TripBloc>().add(GetTripsEvent(status: _selectedStatus));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TripBloc>()..add(const GetTripsEvent()),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          title: Text(
            'Lịch trình của tôi',
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
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textGrey,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Nháp'),
              Tab(text: 'Đã lên kế hoạch'),
              Tab(text: 'Đang diễn ra'),
              Tab(text: 'Hoàn thành'),
            ],
          ),
        ),
        body: BlocBuilder<TripBloc, TripState>(
          builder: (context, state) {
            if (state is TripLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }

            if (state is TripError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: GoogleFonts.inter(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TripBloc>().add(GetTripsEvent(status: _selectedStatus));
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state is TripListLoaded) {
              if (state.trips.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TripBloc>().add(RefreshTripsEvent(status: _selectedStatus));
                },
                color: AppTheme.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.trips.length,
                  itemBuilder: (context, index) {
                    return _buildTripCard(context, state.trips[index]);
                  },
                ),
              );
            }

            return _buildEmptyState();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to create trip page
            context.push('/create-trip');
          },
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add),
          label: Text(
            'Tạo lịch trình',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Chưa có lịch trình nào',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tạo lịch trình đầu tiên của bạn\nđể bắt đầu hành trình khám phá',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    String startDate;
    String endDate;
    try {
      startDate = DateFormat('dd/MM/yyyy', 'vi_VN').format(trip.tripStartDate);
      endDate = DateFormat('dd/MM/yyyy', 'vi_VN').format(trip.tripEndDate);
    } catch (e) {
      final start = trip.tripStartDate;
      final end = trip.tripEndDate;
      startDate = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
      endDate = '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
    }
    final duration = trip.tripEndDate.difference(trip.tripStartDate).inDays + 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to trip detail page
          context.push('/trips/${trip.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (trip.coverImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  trip.coverImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                ),
              )
            else
              _buildPlaceholderImage(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Row(
                    children: [
                      _buildStatusBadge(trip.tripStatus),
                      const Spacer(),
                      if (trip.aiGenerated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, size: 12, color: Colors.purple),
                              const SizedBox(width: 4),
                              Text(
                                'AI',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    trip.tripTitle,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (trip.tripDescription != null && trip.tripDescription!.isNotEmpty)
                    Text(
                      trip.tripDescription!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 16),

                  // Trip Info
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.calendar_today, '$duration ngày'),
                      _buildInfoChip(Icons.people, '${trip.participantCount} người'),
                      _buildInfoChip(_getTransportIcon(trip.tripTransport), _getTransportLabel(trip.tripTransport)),
                      if (trip.tripDestinations != null && trip.tripDestinations!.isNotEmpty)
                        _buildInfoChip(Icons.place, '${trip.tripDestinations!.length} điểm đến'),
                      if (trip.tripEvents != null && trip.tripEvents!.isNotEmpty)
                        _buildInfoChip(Icons.event, '${trip.tripEvents!.length} sự kiện'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date Range
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 16, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        '$startDate - $endDate',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),

                  // Budget
                  if (trip.tripBudget > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 16, color: AppTheme.textGrey),
                        const SizedBox(width: 4),
                        Text(
                          '${'budget'.tr()}: ${intl.NumberFormat.currency(locale: 'vi', symbol: '₫').format(trip.tripBudget)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.3),
            AppTheme.primaryColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.map, size: 80, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'draft':
        color = Colors.grey;
        label = 'Nháp';
        icon = Icons.edit;
        break;
      case 'planned':
        color = Colors.blue;
        label = 'Đã lên kế hoạch';
        icon = Icons.event_available;
        break;
      case 'ongoing':
        color = Colors.orange;
        label = 'Đang diễn ra';
        icon = Icons.flight_takeoff;
        break;
      case 'completed':
        color = Colors.green;
        label = 'Hoàn thành';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Đã hủy';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransportIcon(String transport) {
    switch (transport) {
      case 'walking':
        return Icons.directions_walk;
      case 'bicycle':
        return Icons.directions_bike;
      case 'motorbike':
        return Icons.two_wheeler;
      case 'car':
        return Icons.directions_car;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'plane':
        return Icons.flight;
      default:
        return Icons.directions;
    }
  }

  String _getTransportLabel(String transport) {
    switch (transport) {
      case 'walking':
        return 'Đi bộ';
      case 'bicycle':
        return 'Xe đạp';
      case 'motorbike':
        return 'Xe máy';
      case 'car':
        return 'Ô tô';
      case 'bus':
        return 'Xe buýt';
      case 'train':
        return 'Tàu hỏa';
      case 'plane':
        return 'Máy bay';
      default:
        return transport;
    }
  }
}

