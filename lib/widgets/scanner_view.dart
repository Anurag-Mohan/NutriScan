import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../navigation_service.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    try {
      final success = await productProvider.fetchProductByBarcode(code);

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product found! Showing details...'),
              backgroundColor: Colors.green,
            ),
          );
          
          Future.delayed(const Duration(seconds: 1), () {
            NavigationService().navigateToPageIndex(1);
          });
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found. Try another barcode.'),
              backgroundColor: Colors.red,
            ),
          );

          setState(() {
            _isScanning = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isScanning = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      _isLoading ? 'Searching product...' : 'Scan a product barcode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Position the barcode within the frame',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () => _controller.toggleTorch(),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                      onPressed: () => _controller.switchCamera(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}