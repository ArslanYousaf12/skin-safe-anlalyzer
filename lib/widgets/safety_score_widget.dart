import 'package:flutter/material.dart';
import '../models/safety_report.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class SafetyScoreWidget extends StatelessWidget {
  final SafetyReport report;
  final bool isDetailed;

  const SafetyScoreWidget({
    super.key,
    required this.report,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final safetyColor = AppTheme.getSafetyColor(report.overallRating);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDetailed) ...[
          Text('Safety Rating', style: AppTheme.subheadingStyle),
          const SizedBox(height: AppConstants.smallPadding),
        ],

        Row(
          children: [
            // Safety score indicator
            _buildSafetyIndicator(safetyColor),

            const SizedBox(width: AppConstants.defaultPadding),

            // Rating and percentage info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        report.overallRating,
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: safetyColor,
                        ),
                      ),
                      const Spacer(),
                      if (isDetailed)
                        Text(
                          '${report.safetyPercentage.toStringAsFixed(1)}% safe',
                          style: AppTheme.captionStyle.copyWith(
                            color: safetyColor,
                          ),
                        ),
                    ],
                  ),
                  if (isDetailed) const SizedBox(height: 4),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: report.safetyPercentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(safetyColor),
                      minHeight: isDetailed ? 8 : 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Summary text
        if (isDetailed) ...[
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: safetyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
            ),
            child: Row(
              children: [
                Icon(_getSafetyIcon(), color: safetyColor),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    report.summaryText,
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSafetyIndicator(Color color) {
    return Container(
      width: isDetailed ? 50 : 40,
      height: isDetailed ? 50 : 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Icon(_getSafetyIcon(), color: color, size: isDetailed ? 24 : 20),
      ),
    );
  }

  IconData _getSafetyIcon() {
    switch (report.overallRating) {
      case 'Safe':
        return Icons.check_circle;
      case 'Caution':
        return Icons.warning;
      case 'Unsafe':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }
}
