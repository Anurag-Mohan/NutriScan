import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShoppingChecklistItem {
  final String id;
  String name;
  String category;
  bool isCompleted;
  DateTime addedAt;
  String? healthScore;
  bool isUrgent;

  ShoppingChecklistItem({
    required this.id,
    required this.name,
    this.category = 'General',
    this.isCompleted = false,
    required this.addedAt,
    this.healthScore,
    this.isUrgent = false,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isCompleted': isCompleted,
      'addedAt': addedAt.toIso8601String(),
      'healthScore': healthScore,
      'isUrgent': isUrgent,
    };
  }

  factory ShoppingChecklistItem.fromJson(Map<String, dynamic> json) {
    return ShoppingChecklistItem(
      id: json['id'],
      name: json['name'],
      category: json['category'] ?? 'General',
      isCompleted: json['isCompleted'] ?? false,
      addedAt: DateTime.parse(json['addedAt']),
      healthScore: json['healthScore'],
      isUrgent: json['isUrgent'] ?? false,
    );
  }
}

class SmartShoppingChecklist extends StatefulWidget {
  const SmartShoppingChecklist({super.key});

  @override
  State<SmartShoppingChecklist> createState() => _SmartShoppingChecklistState();
}

class _SmartShoppingChecklistState extends State<SmartShoppingChecklist>
    with TickerProviderStateMixin {
  List<ShoppingChecklistItem> _items = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedCategory = 'General';
  bool _showCompleted = false;
  late AnimationController _fabController;
  late AnimationController _addItemController;
  late Animation<double> _fabAnimation;
  late Animation<double> _addItemAnimation;
  bool _isLoading = true;

  static const String _storageKey = 'shopping_checklist_items';
  static const String _showCompletedKey = 'show_completed_items';

  final List<String> _categories = [
    'General',
    'Fruits & Vegetables',
    'Dairy & Eggs',
    'Meat & Fish',
    'Snacks',
    'Beverages',
    'Health Foods'
  ];

  final List<String> _quickSuggestions = [
    'Bananas 🍌',
    'Greek Yogurt 🥛',
    'Chicken Breast 🍗',
    'Spinach 🥬',
    'Almonds 🥜',
    'Avocado 🥑',
    'Salmon 🐟',
    'Sweet Potato 🍠'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addItemController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _addItemAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _addItemController, curve: Curves.bounceOut),
    );
    _fabController.forward();
  }
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_storageKey);
      if (itemsJson != null) {
        final List<dynamic> itemsList = json.decode(itemsJson);
        setState(() {
          _items = itemsList
              .map((item) => ShoppingChecklistItem.fromJson(item))
              .toList();
        });
      }

      setState(() {
        _showCompleted = prefs.getBool(_showCompletedKey) ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final itemsJson = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, itemsJson);
      
      await prefs.setBool(_showCompletedKey, _showCompleted);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _addItemController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem(String name, {String? category, bool isUrgent = false}) async {
    if (name.trim().isEmpty) return;

    final item = ShoppingChecklistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      category: category ?? _selectedCategory,
      addedAt: DateTime.now(),
      healthScore: _generateHealthScore(name),
      isUrgent: isUrgent,
    );

    setState(() {
      _items.insert(0, item);
    });

    _addItemController.reset();
    _addItemController.forward();
    await _saveData();
    HapticFeedback.lightImpact();

    _textController.clear();
    _focusNode.unfocus();
  }

  void _removeItem(String id) async {
    setState(() {
      _items.removeWhere((item) => item.id == id);
    });
    await _saveData();
    
    HapticFeedback.mediumImpact();
  }

  void _toggleItem(String id) async {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index].isCompleted = !_items[index].isCompleted;
      }
    });
    await _saveData();
    
    HapticFeedback.selectionClick();
  }

  void _toggleShowCompleted() async {
    setState(() {
      _showCompleted = !_showCompleted;
    });
    await _saveData();
  }


  void _clearCompletedItems() async {
    setState(() {
      _items.removeWhere((item) => item.isCompleted);
    });
    
    await _saveData();
    HapticFeedback.mediumImpact();
  }

  String? _generateHealthScore(String itemName) {
    final healthyItems = ['banana', 'apple', 'spinach', 'salmon', 'yogurt', 'almond', 'avocado', 'broccoli', 'quinoa', 'oats'];
    final unhealthyItems = ['chips', 'soda', 'candy', 'cookie', 'cake', 'donut', 'fries'];
    
    final lowerName = itemName.toLowerCase();
    if (healthyItems.any((item) => lowerName.contains(item))) {
      return 'Healthy';
    } else if (unhealthyItems.any((item) => lowerName.contains(item))) {
      return 'Moderate';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        ),
      );
    }

    final activeItems = _items.where((item) => !item.isCompleted).toList();
    final completedItems = _items.where((item) => item.isCompleted).toList();
    final totalItems = _items.length;
    final completedCount = completedItems.length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shopping List',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _toggleShowCompleted,
                            icon: Icon(
                              _showCompleted ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                            ),
                          ),
                          if (completedItems.isNotEmpty)
                            IconButton(
                              onPressed: _clearCompletedItems,
                              icon: const Icon(
                                Icons.clear_all,
                                color: Colors.white,
                              ),
                              tooltip: 'Clear completed items',
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (totalItems > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: totalItems > 0 ? completedCount / totalItems : 0,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completedCount/$totalItems',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completedCount == totalItems && totalItems > 0
                          ? '🎉 Shopping complete! Healthy choices!'
                          : '${totalItems - completedCount} items remaining',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),


          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add healthy item to your list...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2C2C2C),
                          prefixIcon: const Icon(Icons.add_shopping_cart, color: Color(0xFF4CAF50)),
                          suffixIcon: IconButton(
                            onPressed: () => _addItem(_textController.text),
                            icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
                          ),
                        ),
                        onSubmitted: _addItem,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickSuggestions.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(
                            suggestion,
                            style: const TextStyle(color: Color(0xFF4CAF50)),
                          ),
                          onPressed: () => _addItem(suggestion, isUrgent: true),
                          backgroundColor: const Color(0xFF2C2C2C),
                          side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),


          Expanded(
            child: activeItems.isEmpty && completedItems.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [

                      ...activeItems.map((item) => _buildItemTile(item)),
                      

                      if (_showCompleted && completedItems.isNotEmpty) ...[
                        if (activeItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Colors.grey[700]),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Completed (${completedItems.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        ...completedItems.map((item) => _buildItemTile(item)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _focusNode.requestFocus(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Item', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Your shopping list is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add healthy items to get started!',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _focusNode.requestFocus(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add First Item', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ShoppingChecklistItem item) {
    return AnimatedBuilder(
      animation: _addItemAnimation,
      builder: (context, child) {
        return ScaleTransition(
          scale: item == _items.first ? _addItemAnimation : 
                 const AlwaysStoppedAnimation(1.0),
          child: Dismissible(
            key: Key(item.id),
            background: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 28,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _removeItem(item.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: item.isUrgent
                    ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                    : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: GestureDetector(
                  onTap: () => _toggleItem(item.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.isCompleted ? const Color(0xFF4CAF50) : Colors.grey[600]!,
                        width: 2,
                      ),
                      color: item.isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
                    ),
                    child: item.isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: item.isCompleted ? Colors.grey[500] : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.healthScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.healthScore == 'Healthy' 
                              ? const Color(0xFF4CAF50).withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item.healthScore == 'Healthy' 
                                ? const Color(0xFF4CAF50)
                                : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.healthScore == 'Healthy' 
                                  ? Icons.eco 
                                  : Icons.warning_amber,
                              size: 12,
                              color: item.healthScore == 'Healthy' 
                                  ? const Color(0xFF4CAF50)
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.healthScore!,
                              style: TextStyle(
                                color: item.healthScore == 'Healthy' 
                                    ? const Color(0xFF4CAF50)
                                    : Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (item.isUrgent) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                onTap: () => _toggleItem(item.id),
              ),
            ),
          ),
        );
      },
    );
  }
}