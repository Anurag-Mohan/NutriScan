<div align="center">

# 🍎 NutriScan - Smart Food Scanner & Health Analyzer

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![OpenFoodFacts](https://img.shields.io/badge/OpenFoodFacts-FF6B35?style=for-the-badge&logo=data&logoColor=white)](https://world.openfoodfacts.org)

**NutriScan** is a powerful Flutter mobile application that revolutionizes the way you make food choices. Simply scan any food product's barcode to instantly access comprehensive nutritional information, health scores, and personalized recommendations. Make informed decisions about what you eat and maintain a smart shopping checklist for healthier living.

</div>

---

## ✨ Features

### 🔍 **Barcode Scanner**
- **Lightning-fast scanning** with real-time camera integration
- **Instant product recognition** using OpenFoodFacts database
- **Multi-format support** for various barcode types

### 📊 **Comprehensive Health Analysis**
- **Smart Health Scoring** algorithm (0-100 scale)
- **Detailed nutritional breakdown** with visual charts
- **Ingredient analysis** with allergen detection
- **Nutritional traffic light system** (Red/Amber/Green)

### 📝 **Smart Shopping Checklist**
- **Organized shopping lists** with categories
- **Health-conscious recommendations** while shopping
- **Persisteing even after restarting device** with device storage

### 🎨 **Beautiful User Interface**
- **Modern Material Design** with smooth animations
- **Intuitive navigation** with bottom tab bar
- **Responsive design** for all screen sizes

## 📱 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="screenshots/scanner_screen.png" width="250" alt="Scanner Screen"/>
        <br/>
        <sub><b>🔍 Scanner Screen</b></sub>
      </td>
      <td align="center">
        <img src="screenshots/product_details.png" width="250" alt="Product Details"/>
        <br/>
        <sub><b>📊 Product Details</b></sub>
      </td>
      <td align="center">
        <img src="screenshots/shopping_list.png" width="250" alt="Shopping List"/>
        <br/>
        <sub><b>📝 Shopping List</b></sub>
      </td>
    </tr>
  </table>
  
  <br/>
  
  *✨ Featuring smooth animations, intuitive UI, and comprehensive product information display ✨*
</div></div>

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (>=3.0.0)
- **Dart SDK** (>=3.0.0)
- **Android Studio** or **VS Code** with Flutter plugins
- **Physical device** or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Anurag-Mohan/NutriScan.git
   cd NutriScan
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                    # Application entry point
├── models/                      # Data models and entities
├── screens/                     # UI screen
├── widgets/                     # Reusable UI components
├── utils/                       # Helper functions and constants
├── provider/                    # Api and business logic
└── navigation_service.dart      # Internal app navigation based on page index
```

## 🔧 Key Technologies

### **Core Framework**
- **Flutter 3.x** - Cross-platform mobile development
- **Dart** - Programming language optimized for UI

### **Barcode Scanning**
- **flutter_barcode_scanner** - Camera-based barcode detection
- **qr_code_scanner** - Alternative QR/barcode scanning solution

### **API Integration**
- **OpenFoodFacts API** - Comprehensive food product database
- **http** - RESTful API communication
- **dio** - Advanced HTTP client with interceptors

### **Local Storage**
- **shared_preferences** - Simple key-value storage

## 🎯 Core Features Implementation

### Health Scoring Algorithm

The app uses a sophisticated scoring system that evaluates:
- **Nutritional completeness** (protein, vitamins, minerals)
- **Harmful additives** detection and impact assessment
- **Sugar and sodium content** relative to recommended daily values

## 🔄 Future Enhancements

- [ ] **AI-powered meal planning** based on scanned products
- [ ] **Recipe suggestions** using available ingredients
- [ ] **Price comparison** across different retailers
- [ ] **Sustainability scoring** for eco-conscious shopping
- [ ] **Voice commands** for hands-free scanning
- [ ] **Apple Watch/Wear OS** companion apps
- [ ] **Augmented Reality** product information overlay

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### **Contribution Guidelines**
- Follow Flutter/Dart style guidelines
- Add tests for new features
- Update documentation as needed
- Ensure compatibility across platforms

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenFoodFacts** - For providing comprehensive food product data
- **Flutter Team** - For the amazing cross-platform framework
- **Material Design** - For design inspiration and guidelines
- **Contributors** - Thank you to all who have contributed to this project

## 📞 Contact & Support

<div>

- **Developer**: [Anurag Mohan](https://github.com/Anurag-Mohan)
- **Repository**: [NutriScan on GitHub](https://github.com/Anurag-Mohan/NutriScan)
- **Issues**: [Report bugs or request features](https://github.com/Anurag-Mohan/NutriScan/issues)

</div>

---

<div align="center">
  <h3>🌟 If you find NutriScan helpful, please give it a star! 🌟</h3>
  <p>Made with ❤️ and Flutter</p>
</div>
