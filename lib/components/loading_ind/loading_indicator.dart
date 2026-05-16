import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key, this.size = 40});
  final double size;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return LoadingAnimationWidget.fourRotatingDots(
      color: color.primary,
      size: widget.size,
    );
  }
}
