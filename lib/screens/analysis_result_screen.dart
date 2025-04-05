import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/safety_report.dart';
import '../models/ingredient.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/safety_score_widget.dart';
import '../widgets/ingredient_list_widget.dart';

class AnalysisResultScreen extends StatefulWidget {
  final SafetyReport report;

  const AnalysisResultScreen({super.key, required this.report});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _ingredientDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
            tooltip: 'Share Results',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Summary'), Tab(text: 'Ingredients')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSummaryTab(), _buildIngredientsTab()],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductCard(),
          const SizedBox(height: AppConstants.defaultPadding),
          SafetyScoreWidget(report: widget.report, isDetailed: true),
          const SizedBox(height: AppConstants.largePadding),
          _buildConcerningIngredientsSection(),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    final product = widget.report.product;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: AppTheme.headingStyle),
            const SizedBox(height: 4),
            Text(product.brand, style: AppTheme.bodyStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.category,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  product.category.toUpperCase(),
                  style: AppTheme.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(product.analyzedDate),
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConcerningIngredientsSection() {
    final concerningIngredients = widget.report.product.concerningIngredients;

    if (concerningIngredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Concerning Ingredients (${concerningIngredients.length})',
          style: AppTheme.subheadingStyle,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        IngredientListWidget(
          ingredients: concerningIngredients,
          showDetails: true,
        ),
      ],
    );
  }

  Widget _buildIngredientsTab() {
    final ingredients = widget.report.product.ingredients;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Ingredients (${ingredients.length})',
                style: AppTheme.subheadingStyle,
              ),
              Switch(
                value: _ingredientDetailsExpanded,
                onChanged: (value) {
                  setState(() {
                    _ingredientDetailsExpanded = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text('Show Details', style: AppTheme.captionStyle)],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          IngredientListWidget(
            ingredients: ingredients,
            showDetails: _ingredientDetailsExpanded,
            onIngredientTap: _showIngredientDetails,
          ),
        ],
      ),
    );
  }

  void _showIngredientDetails(Ingredient ingredient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final color = AppTheme.getSafetyColor(ingredient.riskLevel);

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.smallPadding,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ingredient.riskLevel,
                            style: AppTheme.captionStyle.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.content_copy),
                          onPressed: () => _copyToClipboard(ingredient.name),
                          tooltip: 'Copy name',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(ingredient.name, style: AppTheme.headingStyle),
                    const SizedBox(height: AppConstants.defaultPadding),
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(ingredient.description),
                    if (ingredient.concerns.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.defaultPadding),
                      const Text(
                        'Concerns',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      ...ingredient.concerns.map(
                        (concern) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(concern)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (ingredient.alternatives.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.defaultPadding),
                      const Text(
                        'Safer Alternatives',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ingredient.alternatives
                                .map(
                                  (alt) => Chip(
                                    label: Text(alt),
                                    backgroundColor: AppTheme.primaryColor
                                        .withOpacity(0.1),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void _shareResults() {
    final product = widget.report.product;

    final safeCount = widget.report.safeIngredientsCount;
    final cautionCount = widget.report.cautionIngredientsCount;
    final unsafeCount = widget.report.unsafeIngredientsCount;

    final shareText = '''
SkinSafe Analysis Results:

Product: ${product.name}
Brand: ${product.brand}
Safety Rating: ${widget.report.overallRating}

Ingredient Breakdown:
✅ Safe: $safeCount
⚠️ Caution: $cautionCount
❌ Unsafe: $unsafeCount

${widget.report.summaryText}

Analyzed with SkinSafe Analyzer
''';

    Share.share(shareText);
  }
}
