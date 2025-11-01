import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final Duration checkInterval;
  final VoidCallback? onOffline;
  final VoidCallback? onOnline;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.checkInterval = const Duration(seconds: 30),
    this.onOffline,
    this.onOnline,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isOnline = true;
  bool _isCheckingConnectivity = false;
  Timer? _periodicCheck;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _setupPeriodicCheck();
  }

  @override
  void dispose() {
    _periodicCheck?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _setupPeriodicCheck() {
    _periodicCheck = Timer.periodic(widget.checkInterval, (timer) {
      _checkConnectivity();
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
      _connectivitySubscription = _connectivity.onConnectivityChanged
          .listen((results) => _updateConnectionStatus(results.first));
    } catch (e) {
      debugPrint('Error initializing connectivity: $e');
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  Future<void> _checkConnectivity() async {
    if (_isCheckingConnectivity) return;

    setState(() => _isCheckingConnectivity = true);

    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _updateConnectionStatus(ConnectivityResult.none);
    } finally {
      if (mounted) {
        setState(() => _isCheckingConnectivity = false);
      }
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    final isNowOnline = result != ConnectivityResult.none;

    if (mounted && wasOnline != isNowOnline) {
      setState(() {
        _isOnline = isNowOnline;
      });

      if (isNowOnline) {
        widget.onOnline?.call();
      } else {
        widget.onOffline?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: !_isOnline ? 44 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: !_isOnline ? 1.0 : 0.0,
            child: Container(
              width: double.infinity,
              color: AppColors.coolGray,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'re offline. Some features may be limited.',
                      style: AppTextStyles.textSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isCheckingConnectivity
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                    onPressed: _isCheckingConnectivity ? null : _checkConnectivity,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Check connection',
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}