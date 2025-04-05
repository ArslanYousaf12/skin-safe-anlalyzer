import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class IngredientListWidget extends StatelessWidget {
  final List<Ingredient> ingredients;
  final bool showDetails;
  final Function(Ingredient)? onIngredientTap;

  const IngredientListWidget({
    super.key,
    required this.ingredients,
    this.showDetails = false,
    this.onIngredientTap,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Text(
            'No ingredients information available',
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return _buildIngredientItem(context, ingredient);
      },
    );
  }

  Widget _buildIngredientItem(BuildContext context, Ingredient ingredient) {
    final color = _getSafetyColor(ingredient.riskLevel);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap:
            onIngredientTap != null ? () => onIngredientTap!(ingredient) : null,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Safety indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSafetyIcon(ingredient.riskLevel),
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ingredient.riskLevel,
                          style: AppTheme.captionStyle.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Ingredient name
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Tap indicator icon
                  if (onIngredientTap != null)
                    Icon(
                      showDetails
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20,
                    ),
                ],
              ),

              // Details section
              if (showDetails) ...[
                const SizedBox(height: AppConstants.smallPadding),
                const Divider(),
                const SizedBox(height: AppConstants.smallPadding),

                // Description
                if (ingredient.description.isNotEmpty) ...[
                  Text(ingredient.description, style: AppTheme.captionStyle),
                  const SizedBox(height: AppConstants.smallPadding),
                ],

                // Concerns (if any)
                if (ingredient.concerns.isNotEmpty) ...[
                  Text(
                    'Concerns:',
                    style: AppTheme.captionStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...ingredient.concerns.map(
                    (concern) => _buildBulletPoint(concern),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                ],

                // Alternatives (if any)
                if (ingredient.alternatives.isNotEmpty) ...[
                  Text(
                    'Safer Alternatives:',
                    style: AppTheme.captionStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ingredient.alternatives
                            .map(
                              (alt) => Chip(
                                label: Text(
                                  alt,
                                  style: AppTheme.captionStyle.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                                backgroundColor: Colors.grey[100],
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: AppTheme.captionStyle),
          Expanded(child: Text(text, style: AppTheme.captionStyle)),
        ],
      ),
    );
  }

  Color _getSafetyColor(String riskLevel) {
    return AppTheme.getSafetyColor(riskLevel);
  }

  IconData _getSafetyIcon(String riskLevel) {
    switch (riskLevel) {
      case 'Safe':
        return Icons.check_circle_outline;
      case 'Caution':
        return Icons.warning_amber;
      case 'Unsafe':
        return Icons.dangerous_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
