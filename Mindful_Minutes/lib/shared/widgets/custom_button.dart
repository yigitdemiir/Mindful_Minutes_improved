import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final Widget? iconWidget;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double elevation;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isOutlined = false,
    this.iconWidget,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.width,
    this.elevation = 0,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final defaultBorderRadius = BorderRadius.circular(16);
    final defaultPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            backgroundColor: backgroundColor ?? Colors.transparent,
            elevation: elevation,
            padding: padding ?? defaultPadding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? defaultBorderRadius,
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.primaryColor,
            elevation: elevation,
            padding: padding ?? defaultPadding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? defaultBorderRadius,
            ),
          );

    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconWidget != null) ...[
          iconWidget!,
          const SizedBox(width: 12),
        ],
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? Colors.white : Colors.white,
              ),
            ),
          )
        else
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isOutlined
                  ? Colors.white
                  : textColor ?? Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: buttonChild,
            ),
    );
  }
} 