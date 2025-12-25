import 'package:flutter/material.dart';

/// Wrapper widget that triggers a callback when the tab becomes visible
/// Useful for refreshing data when user switches between navigation tabs
class TabRefreshWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTabVisible;

  const TabRefreshWrapper({
    super.key,
    required this.child,
    this.onTabVisible,
  });

  @override
  State<TabRefreshWrapper> createState() => _TabRefreshWrapperState();
}

class _TabRefreshWrapperState extends State<TabRefreshWrapper>
    with AutomaticKeepAliveClientMixin {
  bool _hasBeenBuilt = false;

  @override
  bool get wantKeepAlive => true; // Keep the page alive when switching tabs

  @override
  void didUpdateWidget(TabRefreshWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger refresh callback when widget is updated (tab becomes visible)
    if (_hasBeenBuilt) {
      widget.onTabVisible?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (!_hasBeenBuilt) {
      _hasBeenBuilt = true;
    }

    return widget.child;
  }
}

