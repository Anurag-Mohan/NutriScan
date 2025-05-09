import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/scanner_view.dart';
import '../widgets/product_details.dart';
import '../widgets/history_list.dart';
import '../providers/product_provider.dart';
import '../navigation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    NavigationService().homePageController = _pageController;
    NavigationService().updateSelectedIndex = _updateSelectedIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    NavigationService().homePageController = null;
    NavigationService().updateSelectedIndex = null;
    super.dispose();
  }

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _updateSelectedIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Scanner'),
        actions: [
          if (_selectedIndex != 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_selectedIndex == 1) {
                  context.read<ProductProvider>().clearProduct();
                }
              },
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _updateSelectedIndex(index);
        },
        children: const [
          ScannerView(),
          ProductDetails(),
          HistoryList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}