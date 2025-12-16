import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_themes.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/event_card.dart';
import '../pages/events_list_page.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sự kiện sắp diễn ra',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventsListPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Xem tất cả',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Events List
        BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is UpcomingEventsLoading) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            }

            if (state is UpcomingEventsLoaded) {
              if (state.events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Không có sự kiện sắp diễn ra',
                      style: GoogleFonts.inter(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.events.length,
                  itemBuilder: (context, index) {
                    final event = state.events[index];
                    return SizedBox(
                      width: 320,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < state.events.length - 1 ? 16 : 0,
                        ),
                        child: EventCard(
                          event: event,
                          onTap: () {
                            context.push(
                              '/event-detail/${event.id}',
                              extra: event,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            if (state is EventError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        state.message,
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          context.read<EventBloc>().add(
                                const GetUpcomingEventsEvent(limit: 5),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text(
                          'Thử lại',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Initial state - trigger fetch
            context.read<EventBloc>().add(const GetUpcomingEventsEvent(limit: 5));
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

