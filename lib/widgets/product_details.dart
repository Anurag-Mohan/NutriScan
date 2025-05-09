import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../utils/health_analyzer.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final product = productProvider.product;
        
        if (product == null) {
          return _buildEmptyState();
        }

        final healthScore = HealthAnalyzer.calculateHealthScore(product);
        final recommendations = HealthAnalyzer.getRecommendations(product);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductHeader(product),
              const SizedBox(height: 20),
              _buildHealthScoreCard(healthScore),
              const SizedBox(height: 16),
              _buildCard(
                'Nutrition Facts',
                _buildNutritionTable(product),
              ),
              if (product.ingredients?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildCard('Ingredients', Text(product.ingredients!)),
              ],
              if (recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCard(
                  'Health Recommendations',
                  Column(
                    children: recommendations.map((rec) => _buildRecommendation(rec)).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.food_bank_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No product scanned yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Scan a product barcode to see details',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(product),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name ?? 'Unknown Product',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (product.brands != null) ...[
                const SizedBox(height: 4),
                Text(
                  product.brands!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.qr_code, size: 16),
                  const SizedBox(width: 4),
                  Text(product.barcode),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(Product product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: product.imageUrl?.isNotEmpty ?? false
          ? Image.network(
              product.imageUrl!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }

  Widget _buildHealthScoreCard(double healthScore) {
    final (healthText, healthColor, healthIcon) = _getHealthAttributes(healthScore);

    return Card(
      elevation: 3,
      color: healthColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: healthColor.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(healthIcon, size: 50, color: healthColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    healthText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: healthColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Health Score: ${healthScore.toInt()}/100', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color, IconData) _getHealthAttributes(double healthScore) {
    if (healthScore >= 80) {
      return ('Healthy', Colors.green, Icons.thumb_up);
    } else if (healthScore >= 50) {
      return ('Moderately Healthy', Colors.orange, Icons.thumbs_up_down);
    } else {
      return ('Less Healthy', Colors.red, Icons.thumb_down);
    }
  }

  Widget _buildCard(String title, Widget content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionTable(Product product) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      border: TableBorder.all(color: Colors.grey.withOpacity(0.3), width: 1),
      children: [
        _buildTableRow('Nutrient', 'Amount', 'Daily %', isHeader: true),
        ..._buildNutrientRows(product),
      ],
    );
  }

  List<TableRow> _buildNutrientRows(Product product) {
    return [
      _buildTableRow('Energy', '${product.energy ?? "N/A"} kcal', 
                    _formatPercent(product.energyPercent)),
      _buildTableRow('Fat', '${product.fat ?? "N/A"} g', 
                    _formatPercent(product.fatPercent)),
      _buildTableRow('Saturated Fat', '${product.saturatedFat ?? "N/A"} g', 
                    _formatPercent(product.saturatedFatPercent)),
      _buildTableRow('Carbohydrates', '${product.carbohydrates ?? "N/A"} g', 
                    _formatPercent(product.carbohydratesPercent)),
      _buildTableRow('Sugars', '${product.sugars ?? "N/A"} g', 
                    _formatPercent(product.sugarsPercent)),
      _buildTableRow('Fiber', '${product.fiber ?? "N/A"} g', 
                    _formatPercent(product.fiberPercent)),
      _buildTableRow('Proteins', '${product.proteins ?? "N/A"} g', 
                    _formatPercent(product.proteinsPercent)),
      _buildTableRow('Salt', '${product.salt ?? "N/A"} g', 
                    _formatPercent(product.saltPercent)),
    ];
  }

  String _formatPercent(double? value) => value != null ? '${value.toInt()}%' : 'N/A';

  TableRow _buildTableRow(String col1, String col2, String col3, {bool isHeader = false}) {
    final style = isHeader ? const TextStyle(fontWeight: FontWeight.bold) : const TextStyle();
    
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? const Color.fromARGB(255, 36, 134, 49) : null),
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(col1, style: style)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(col2, style: style)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(col3, style: style)),
      ],
    );
  }

  Widget _buildRecommendation(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(recommendation)),
        ],
      ),
    );
  }
}