import 'package:flutter/material.dart';

/// A widget that fades in + slides up with a stagger delay based on index.
///
/// Wrap any list item with this to get entrance animations:
/// ```dart
/// StaggeredAnimation(
///   index: index,
///   child: MyCard(),
/// )
/// ```
class StaggeredAnimation extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration duration;

  const StaggeredAnimation({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<StaggeredAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Stagger: each item waits (index * 60ms) then animates
    final staggerDelay = widget.baseDelay * widget.index;

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(staggerDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value * 30, // 30px max slide
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
