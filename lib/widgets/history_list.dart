import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_history_provider.dart';
import '../providers/product_provider.dart';
import '../models/scanned_product.dart';
import '../utils/health_analyzer.dart';
import '../navigation_service.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScanHistoryProvider>(
      builder: (context, historyProvider, child) {
        final history = historyProvider.scanHistory;

        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No scan history',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Products you scan will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear History'),
                          content: const Text('Are you sure you want to clear all scan history?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                historyProvider.clearHistory();
                                Navigator.pop(context);
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final ScannedProduct scannedProduct = history[index];
                  final healthScore = HealthAnalyzer.calculateHealthScore(scannedProduct.product);
                  
                  return Dismissible(
                    key: Key(scannedProduct.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      historyProvider.removeFromHistory(scannedProduct.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${scannedProduct.product.name} removed from history'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              historyProvider.addToHistory(scannedProduct);
                            },
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: _buildHealthIndicator(healthScore),
                      title: Text(
                        scannedProduct.product.name ?? 'Unknown Product',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        scannedProduct.product.brands ?? scannedProduct.product.barcode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatDate(scannedProduct.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        final productProvider = Provider.of<ProductProvider>(context, listen: false);
                        productProvider.setProduct(scannedProduct.product);
                        
                         NavigationService().navigateToPageIndex(1);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHealthIndicator(double score) {
    Color color;
    IconData icon;

    if (score >= 80) {
      color = Colors.green;
      icon = Icons.thumb_up;
    } else if (score >= 50) {
      color = Colors.orange;
      icon = Icons.thumbs_up_down;
    } else {
      color = Colors.red;
      icon = Icons.thumb_down;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today ${_formatTime(date)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}