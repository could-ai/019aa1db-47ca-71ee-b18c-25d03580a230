import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قارئ الأسعار',
      debugShowCheckedModeBanner: false,
      // إعدادات اللغة العربية
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Segoe UI', // خط افتراضي جيد للعربية
      ),
      home: const PriceCheckScreen(),
    );
  }
}

// نموذج بسيط للمنتج
class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});
}

class PriceCheckScreen extends StatefulWidget {
  const PriceCheckScreen({super.key});

  @override
  State<PriceCheckScreen> createState() => _PriceCheckScreenState();
}

class _PriceCheckScreenState extends State<PriceCheckScreen> {
  // قاعدة بيانات وهمية للمنتجات (في التطبيق الحقيقي تكون في Supabase)
  final Map<String, Product> _products = {
    '123456789': Product(name: 'علبة بيبسي 330 مل', price: 2.50),
    '987654321': Product(name: 'شيبس ليز عائلي', price: 5.00),
    '111222333': Product(name: 'ماء معدني 1.5 لتر', price: 1.00),
    '444555666': Product(name: 'شوكولاتة جالاكسي', price: 3.50),
  };

  String? _scannedBarcode;
  Product? _foundProduct;
  bool _isScanning = false;
  final TextEditingController _manualController = TextEditingController();

  // دالة للبحث عن المنتج
  void _lookupProduct(String barcode) {
    setState(() {
      _scannedBarcode = barcode;
      _foundProduct = _products[barcode];
      _manualController.text = barcode;
    });

    if (_foundProduct != null) {
      _showProductDialog();
    } else {
      _showNotFoundDialog(barcode);
    }
  }

  // عرض تفاصيل المنتج
  void _showProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم العثور على المنتج', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(
              _foundProduct!.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${NumberFormat.currency(symbol: 'د.ل', decimalDigits: 2).format(_foundProduct!.price)}',
              style: const TextStyle(fontSize: 28, color: Colors.teal, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('الباركود: $_scannedBarcode', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  // عرض رسالة عدم العثور على المنتج
  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المنتج غير موجود'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 60),
            const SizedBox(height: 16),
            const Text('هذا الصنف غير مسجل في قاعدة البيانات.'),
            const SizedBox(height: 8),
            Text('الباركود: $barcode', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddProductDialog(barcode);
            },
            child: const Text('إضافة الصنف'),
          ),
        ],
      ),
    );
  }

  // إضافة منتج جديد (محلياً للتجربة)
  void _showAddProductDialog(String barcode) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة صنف جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الصنف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'السعر',
                border: OutlineInputBorder(),
                suffixText: 'د.ل',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                setState(() {
                  _products[barcode] = Product(
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إضافة الصنف بنجاح!')),
                );
                _lookupProduct(barcode); // عرض المنتج المضاف
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قارئ الأسعار'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // أيقونة توضيحية
              Icon(
                Icons.qr_code_scanner,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 30),
              const Text(
                'قم بمسح الباركود لمعرفة السعر',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              
              // زر المسح بالكاميرا
              SizedBox(
                height: 60,
                child: FilledButton.icon(
                  onPressed: () async {
                    // الانتقال لصفحة الكاميرا
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
                    );
                    if (result != null) {
                      _lookupProduct(result);
                    }
                  },
                  icon: const Icon(Icons.camera_alt, size: 28),
                  label: const Text('مسح الباركود بالكاميرا', style: TextStyle(fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              
              // إدخال يدوي (مفيد في حالة عدم عمل الكاميرا أو للتجربة)
              const Text('أو أدخل الرقم يدوياً:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'مثال: 123456789',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: () {
                      if (_manualController.text.isNotEmpty) {
                        _lookupProduct(_manualController.text);
                      }
                    },
                    icon: const Icon(Icons.search),
                    iconSize: 28,
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              // عرض قائمة المنتجات المتوفرة للتجربة
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('أرقام باركود للتجربة:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _products.keys.map((code) => ActionChip(
                          label: Text(code),
                          onPressed: () {
                            _manualController.text = code;
                            _lookupProduct(code);
                          },
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// صفحة الكاميرا المنفصلة
class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('وجه الكاميرا للباركود')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: false,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              // عند اكتشاف باركود، نغلق الصفحة ونعيد القيمة
              Navigator.pop(context, barcode.rawValue);
              break; // نأخذ أول باركود فقط
            }
          }
        },
      ),
    );
  }
}
