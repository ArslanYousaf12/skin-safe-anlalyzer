import 'package:flutter/material.dart';
import '../models/safety_report.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/safety_score_widget.dart';
import 'analysis_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SafetyReport> _reports = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await FirebaseService().getProductAnalysisHistory();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _loadReports();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return _buildErrorView();
    }

    if (_reports.isEmpty) {
      return _buildEmptyView();
    }

    return _buildReportsList();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Error Loading History',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'There was a problem loading your analysis history.',
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _loadReports();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: Colors.grey),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Analysis History',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
            ),
            child: Text(
              'You haven\'t analyzed any products yet. Scan a product to get started.',
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan a Product'),
            onPressed: () {
              Navigator.of(context).pop(); // Return to home screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(SafetyReport report) {
    final product = report.product;
    final safetyColor = AppTheme.getSafetyColor(report.overallRating);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisResultScreen(report: report),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and date banner
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: AppTheme.subheadingStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.brand,
                          style: AppTheme.captionStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(product.analyzedDate),
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  // Safety rating display
                  Expanded(
                    child: SafetyScoreWidget(report: report, isDetailed: false),
                  ),

                  const SizedBox(width: AppConstants.defaultPadding),

                  // Ingredient counts
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildIngredientCountItem(
                        'Safe',
                        report.safeIngredientsCount,
                        AppTheme.safeColor,
                      ),
                      const SizedBox(height: 4),
                      _buildIngredientCountItem(
                        'Caution',
                        report.cautionIngredientsCount,
                        AppTheme.cautionColor,
                      ),
                      const SizedBox(height: 4),
                      _buildIngredientCountItem(
                        'Unsafe',
                        report.unsafeIngredientsCount,
                        AppTheme.unsafeColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // View details
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCountItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label: $count', style: AppTheme.captionStyle),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
