import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../destinations/presentation/bloc/destination_event.dart';
import 'favorites_page.dart';

/// Wrapper widget for FavoritesPage to handle BLoC provider and initial data fetching
class FavoritesPageWrapper extends StatefulWidget {
  final int initialTab;

  const FavoritesPageWrapper({super.key, this.initialTab = 0});

  @override
  State<FavoritesPageWrapper> createState() => _FavoritesPageWrapperState();
}

class _FavoritesPageWrapperState extends State<FavoritesPageWrapper> {
  @override
  void initState() {
    super.initState();
    // Trigger initial fetch when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.initialTab == 0) {
          context.read<DestinationBloc>().add(const GetLikedItemsEvent(limit: 20));
        } else {
          context.read<DestinationBloc>().add(const GetCheckedInItemsEvent(limit: 20));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FavoritesPage(initialTab: widget.initialTab);
  }
}

