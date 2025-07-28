// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';

// class ImageTranslatePage extends StatefulWidget {
//   @override
//   _ImageTranslatePageState createState() => _ImageTranslatePageState();
// }

// class _ImageTranslatePageState extends State<ImageTranslatePage>
//     with TickerProviderStateMixin {
//   File? _image;
//   List<TextElement> _textElements = [];
//   List<TranslatedTextElement> _translatedElements = [];
//   String _selectedLanguage = 'es';
//   bool _isProcessing = false;
//   bool _isTranslating = false;
//   bool _showTranslation = false;
//   final ImagePicker _picker = ImagePicker();
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _scaleController;

//   // RapidAPI Google Translate credentials - Replace with your actual key
//   final String _rapidApiKey = 'YOUR_RAPIDAPI_KEY_HERE';
//   final String _rapidApiHost = 'google-translate1.p.rapidapi.com';

//   final Map<String, String> _languages = {
//     'es': 'Spanish',
//     'fr': 'French',
//     'de': 'German',
//     'it': 'Italian',
//     'pt': 'Portuguese',
//     'ru': 'Russian',
//     'ja': 'Japanese',
//     'ko': 'Korean',
//     'zh': 'Chinese (Simplified)',
//     'ar': 'Arabic',
//     'hi': 'Hindi',
//     'tr': 'Turkish',
//     'nl': 'Dutch',
//     'sv': 'Swedish',
//     'da': 'Danish',
//     'no': 'Norwegian',
//     'fi': 'Finnish',
//     'pl': 'Polish',
//     'th': 'Thai',
//     'vi': 'Vietnamese',
//     'cs': 'Czech',
//     'hu': 'Hungarian',
//     'ro': 'Romanian',
//     'sk': 'Slovak',
//     'bg': 'Bulgarian',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _scaleController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _requestPermissions();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _scaleController.dispose();
//     super.dispose();
//   }

//   Future<void> _requestPermissions() async {
//     await Permission.camera.request();
//     await Permission.storage.request();
//   }

//   ThemeData get lightMode => ThemeData(
//     colorScheme: ColorScheme.light(
//       background: const Color(0xFFF8FAFC),
//       primary: const Color(0xFF3B82F6),
//       secondary: const Color(0xFFEFF6FF),
//       tertiary: const Color(0xFFFFFFFF),
//       inversePrimary: const Color(0xFF1E40AF),
//     ),
//   );

//   ThemeData get darkMode => ThemeData(
//     colorScheme: ColorScheme.dark(
//       background: const Color(0xFF0F172A),
//       primary: const Color(0xFF60A5FA),
//       secondary: const Color(0xFF1E293B),
//       tertiary: const Color(0xFF334155),
//       inversePrimary: const Color(0xFF93C5FD),
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final colorScheme = isDark ? darkMode.colorScheme : lightMode.colorScheme;

//     return Scaffold(
//       backgroundColor: colorScheme.background,
//       appBar: _buildAppBar(colorScheme),
//       body: _buildBody(colorScheme),
//       floatingActionButton: _buildFloatingActionButton(colorScheme),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: colorScheme.background,
//       foregroundColor: colorScheme.primary,
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.translate,
//               color: colorScheme.primary,
//               size: 24,
//             ),
//           ),
//           SizedBox(width: 12),
//           Text(
//             'Image Translator',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 22,
//               color: colorScheme.primary,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           onPressed: _showLanguageSelector,
//           icon: Container(
//             padding: EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: colorScheme.secondary,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               Icons.language,
//               color: colorScheme.primary,
//             ),
//           ),
//         ),
//         SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildBody(ColorScheme colorScheme) {
//     if (_image == null) {
//       return _buildWelcomeScreen(colorScheme);
//     }

//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildImageCard(colorScheme),
//           SizedBox(height: 20),
//           _buildControlsCard(colorScheme),
//           if (_textElements.isNotEmpty) ...[
//             SizedBox(height: 20),
//             _buildResultsCard(colorScheme),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildWelcomeScreen(ColorScheme colorScheme) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: colorScheme.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.photo_camera_outlined,
//                 size: 80,
//                 color: colorScheme.primary,
//               ),
//             ),
//             SizedBox(height: 32),
//             Text(
//               'Translate Text in Images',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.primary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Capture or select an image to extract and translate text into your preferred language',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: colorScheme.primary.withOpacity(0.7),
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 48),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildActionButton(
//                     'Camera',
//                     Icons.camera_alt_outlined,
//                     () => _pickImage(ImageSource.camera),
//                     colorScheme,
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: _buildActionButton(
//                     'Gallery',
//                     Icons.photo_library_outlined,
//                     () => _pickImage(ImageSource.gallery),
//                     colorScheme,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton(
//     String label,
//     IconData icon,
//     VoidCallback onTap,
//     ColorScheme colorScheme,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [colorScheme.primary, colorScheme.inversePrimary],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: colorScheme.primary.withOpacity(0.3),
//             blurRadius: 12,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//             child: Column(
//               children: [
//                 Icon(
//                   icon,
//                   size: 32,
//                   color: Colors.white,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageCard(ColorScheme colorScheme) {
//     return FadeTransition(
//       opacity: _fadeController,
//       child: Container(
//         decoration: BoxDecoration(
//           color: colorScheme.tertiary,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: colorScheme.primary.withOpacity(0.1),
//               blurRadius: 20,
//               offset: Offset(0, 8),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Stack(
//             children: [
//               CustomPaint(
//                 painter: ImageWithTextPainter(
//                   image: _image!,
//                   textElements: _showTranslation ? _translatedElements : _textElements,
//                   showTranslation: _showTranslation,
//                 ),
//                 child: Container(
//                   width: double.infinity,
//                   height: 300,
//                   child: Image.file(
//                     _image!,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               if (_isProcessing)
//                 Container(
//                   width: double.infinity,
//                   height: 300,
//                   color: Colors.black.withOpacity(0.5),
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'Extracting text...',
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildControlsCard(ColorScheme colorScheme) {
//     return SlideTransition(
//       position: Tween<Offset>(
//         begin: Offset(0, 0.5),
//         end: Offset.zero,
//       ).animate(_slideController),
//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: colorScheme.tertiary,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: colorScheme.primary.withOpacity(0.1),
//               blurRadius: 20,
//               offset: Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.settings_outlined,
//                   color: colorScheme.primary,
//                   size: 24,
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Translation Settings',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             GestureDetector(
//               onTap: _showLanguageSelector,
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: colorScheme.secondary,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: colorScheme.primary.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.language,
//                       color: colorScheme.primary,
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Translate to: ${_languages[_selectedLanguage]}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: colorScheme.primary,
//                         ),
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_drop_down,
//                       color: colorScheme.primary,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _textElements.isEmpty ? null : _translateText,
//                     icon: _isTranslating
//                         ? SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : Icon(Icons.translate),
//                     label: Text(_isTranslating ? 'Translating...' : 'Translate'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colorScheme.primary,
//                       foregroundColor: Colors.white,
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   child: Icon(Icons.camera_alt),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colorScheme.secondary,
//                     foregroundColor: colorScheme.primary,
//                     padding: EdgeInsets.all(16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   child: Icon(Icons.photo_library),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colorScheme.secondary,
//                     foregroundColor: colorScheme.primary,
//                     padding: EdgeInsets.all(16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResultsCard(ColorScheme colorScheme) {
//     return ScaleTransition(
//       scale: _scaleController,
//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: colorScheme.tertiary,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: colorScheme.primary.withOpacity(0.1),
//               blurRadius: 20,
//               offset: Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.text_fields,
//                   color: colorScheme.primary,
//                   size: 24,
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Extracted Text',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 Spacer(),
//                 if (_translatedElements.isNotEmpty)
//                   Switch(
//                     value: _showTranslation,
//                     onChanged: (value) {
//                       setState(() {
//                         _showTranslation = value;
//                       });
//                     },
//                     activeColor: colorScheme.primary,
//                   ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Container(
//               constraints: BoxConstraints(maxHeight: 200),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: _buildTextList(colorScheme),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildTextList(ColorScheme colorScheme) {
//     final elements = _showTranslation ? _translatedElements : _textElements;
//     return elements.asMap().entries.map((entry) {
//       int index = entry.key;
//       var element = entry.value;
//       String text = _showTranslation 
//           ? (element as TranslatedTextElement).translatedText
//           : (element as TextElement).text;

//       return Container(
//         margin: EdgeInsets.only(bottom: 8),
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: colorScheme.secondary,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: colorScheme.primary,
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: text));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Text copied to clipboard'),
//                     backgroundColor: colorScheme.primary,
//                   ),
//                 );
//               },
//               icon: Icon(
//                 Icons.copy,
//                 size: 18,
//                 color: colorScheme.primary,
//               ),
//             ),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _buildFloatingActionButton(ColorScheme colorScheme) {
//     return FloatingActionButton.extended(
//       onPressed: () {
//         setState(() {
//           _image = null;
//           _textElements.clear();
//           _translatedElements.clear();
//           _showTranslation = false;
//         });
//         _fadeController.reset();
//         _slideController.reset();
//         _scaleController.reset();
//       },
//       icon: Icon(Icons.refresh),
//       label: Text('New Image'),
//       backgroundColor: colorScheme.primary,
//       foregroundColor: Colors.white,
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//           _textElements.clear();
//           _translatedElements.clear();
//           _showTranslation = false;
//         });
//         _fadeController.forward();
//         await _extractText();
//       }
//     } catch (e) {
//       _showErrorSnackbar('Error picking image: $e');
//     }
//   }

//   Future<void> _extractText() async {
//     if (_image == null) return;

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final inputImage = InputImage.fromFile(_image!);
//       final textRecognizer = GoogleMlKit.vision.textRecognizer();
//       final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

//       List<TextElement> elements = [];
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           if (line.text.trim().isNotEmpty) {
//             elements.add(TextElement(
//               text: line.text,
//               boundingBox: line.boundingBox,
//             ));
//           }
//         }
//       }

//       setState(() {
//         _textElements = elements;
//         _isProcessing = false;
//       });

//       await textRecognizer.close();
//       _slideController.forward();

//       if (elements.isNotEmpty) {
//         _scaleController.forward();
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//       });
//       _showErrorSnackbar('Error extracting text: $e');
//     }
//   }

//   Future<void> _translateText() async {
//     if (_textElements.isEmpty) return;

//     setState(() {
//       _isTranslating = true;
//     });

//     try {
//       List<TranslatedTextElement> translated = [];

//       for (TextElement element in _textElements) {
//         String translatedText = await _translateSingleText(element.text);
//         translated.add(TranslatedTextElement(
//           originalText: element.text,
//           translatedText: translatedText,
//           boundingBox: element.boundingBox,
//         ));
//       }

//       setState(() {
//         _translatedElements = translated;
//         _isTranslating = false;
//         _showTranslation = true;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Translation completed successfully!'),
//           backgroundColor: Theme.of(context).colorScheme.primary,
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _isTranslating = false;
//       });
//       _showErrorSnackbar('Translation failed. Please check your API key and try again.');
//     }
//   }

//   Future<String> _translateSingleText(String text) async {
//     if (_rapidApiKey == 'YOUR_RAPIDAPI_KEY_HERE') {
//       // Return mock translation for demo purposes
//       return '[TRANSLATED] $text';
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('https://google-translate1.p.rapidapi.com/language/translate/v2'),
//         headers: {
//           'Content-Type': 'application/x-www-form-urlencoded',
//           'X-RapidAPI-Key': _rapidApiKey,
//           'X-RapidAPI-Host': _rapidApiHost,
//         },
//         body: {
//           'q': text,
//           'target': _selectedLanguage,
//           'source': 'auto',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['data']['translations'][0]['translatedText'];
//       } else {
//         throw Exception('Translation API error: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Translation failed: $e');
//     }
//   }

//   void _showLanguageSelector() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         final colorScheme = Theme.of(context).colorScheme;
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.7,
//           decoration: BoxDecoration(
//             color: colorScheme.tertiary,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     Text(
//                       'Select Language',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.primary,
//                       ),
//                     ),
//                     Spacer(),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: Icon(Icons.close),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _languages.length,
//                   itemBuilder: (context, index) {
//                     String code = _languages.keys.elementAt(index);
//                     String name = _languages[code]!;
//                     bool isSelected = code == _selectedLanguage;

//                     return ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: isSelected 
//                               ? colorScheme.primary 
//                               : colorScheme.secondary,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Icon(
//                           Icons.language,
//                           color: isSelected 
//                               ? Colors.white 
//                               : colorScheme.primary,
//                         ),
//                       ),
//                       title: Text(
//                         name,
//                         style: TextStyle(
//                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                           color: colorScheme.primary,
//                         ),
//                       ),
//                       trailing: isSelected 
//                           ? Icon(Icons.check, color: colorScheme.primary) 
//                           : null,
//                       onTap: () {
//                         setState(() {
//                           _selectedLanguage = code;
//                         });
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }

// class TextElement {
//   final String text;
//   final Rect boundingBox;

//   TextElement({required this.text, required this.boundingBox});
// }

// class TranslatedTextElement extends TextElement {
//   final String originalText;
//   final String translatedText;

//   TranslatedTextElement({
//     required this.originalText,
//     required this.translatedText,
//     required Rect boundingBox,
//   }) : super(text: translatedText, boundingBox: boundingBox);
// }

// class ImageWithTextPainter extends CustomPainter {
//   final File image;
//   final List<dynamic> textElements;
//   final bool showTranslation;

//   ImageWithTextPainter({
//     required this.image,
//     required this.textElements,
//     required this.showTranslation,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (textElements.isEmpty) return;

//     final paint = Paint()
//       ..color = Colors.blue.withOpacity(0.3)
//       ..style = PaintingStyle.fill;

//     final borderPaint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;

//     for (var element in textElements) {
//       final boundingBox = element.boundingBox;
      
//       // Scale the bounding box to fit the widget size
//       final scaledRect = Rect.fromLTWH(
//         boundingBox.left * (size.width / 1000), // Adjust scaling as needed
//         boundingBox.top * (size.height / 1000),
//         boundingBox.width * (size.width / 1000),
//         boundingBox.height * (size.height / 1000),
//       );

//       // Draw background rectangle
//       canvas.drawRect(scaledRect, paint);
//       canvas.drawRect(scaledRect, borderPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }