import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/components/my_drawer.dart';
import 'package:myapp/themes/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const TranslatorPage(),
    ),
  );
}

// Translation Service Class
class TranslationService {
  // Option 1: LibreTranslate (Free, self-hosted)
  static final String _libreTranslateUrl = dotenv.env['LIBRE_TRANSLATE_URL'] ?? '';

  // Option 2: Google Translate via RapidAPI (Free tier available)
  static final String _rapidApiUrl = dotenv.env['TRANSLATOR_PAGE_RAPIDAPI_URL'] ?? '';
  static final String _rapidApiKey = dotenv.env['TRANSLATOR_PAGE_RAPIDAPI_KEY'] ?? ''; // Loaded from .env

  // Language code mapping for LibreTranslate
  static const Map<String, String> _libreLanguageCodes = {
    'en': 'en',
    'es': 'es',
    'fr': 'fr',
    'de': 'de',
    'it': 'it',
    'pt': 'pt',
    'ru': 'ru',
    'ja': 'ja',
    'ko': 'ko',
    'zh': 'zh',
    'ar': 'ar',
    'hi': 'hi',
    'nl': 'nl',
    'sv': 'sv',
    'tr': 'tr',
    'pl': 'pl',
    'ta': 'ta',
    'th': 'th',
    'vi': 'vi',
  };

  // Updated RapidAPI language codes based on the error message
  static const Map<String, String> _rapidApiLangCodes = {
    // Original languages
    'en': 'en',
    'es': 'es',
    'fr': 'fr',
    'de': 'de',
    'it': 'it',
    'pt': 'pt',
    'ru': 'ru',
    'ja': 'ja',
    'ko': 'ko',
    'zh': 'zh-cn',
    'ar': 'ar',
    'hi': 'hi',
    'nl': 'nl',
    'sv': 'sv',
    'tr': 'tr',
    'pl': 'pl',
    'ta': 'ta',
    'th': 'th',
    'vi': 'vi',
    
    // Indian Languages
    'bn': 'bn',         // Bengali
    'te': 'te',         // Telugu
    'mr': 'mr',         // Marathi
    'gu': 'gu',         // Gujarati
    'kn': 'kn',         // Kannada
    'ml': 'ml',         // Malayalam
    'pa': 'pa',         // Punjabi
    'or': 'or',         // Odia (Oriya)
    'as': 'as',         // Assamese
    'ur': 'ur',         // Urdu
    'ne': 'ne',         // Nepali
    'si': 'si',         // Sinhala
    'my': 'my',         // Myanmar (Burmese)
    'sd': 'sd',         // Sindhi
    'sa': 'sa',         // Sanskrit
    'mai': 'mai',       // Maithili
    'bho': 'bho',       // Bhojpuri
    'ks': 'ks',         // Kashmiri
    'gom': 'gom',       // Konkani
    'mni': 'mni',       // Manipuri (Meiteilon)
    'sat': 'sat',       // Santali
    'brx': 'brx',       // Bodo
    'doi': 'doi',       // Dogri
  };

  // Method 1: LibreTranslate (Completely Free)
  static Future<String> translateWithLibreTranslate(
    String text, 
    String fromLang, 
    String toLang
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_libreTranslateUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'q': text,
          'source': _libreLanguageCodes[fromLang] ?? 'en',
          'target': _libreLanguageCodes[toLang] ?? 'es',
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 15)); // Increased timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translatedText'] ?? text;
      } else {
        print('LibreTranslate HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      print('LibreTranslate Error: $e');
      return 'Translation error: Please check your internet connection or try another API';
    }
  }

  // Method 2: Google Translate via RapidAPI - FIXED VERSION
  static Future<String> translateWithRapidApi(
    String text,
    String fromLang,
    String toLang,
  ) async {
    try {
      print('translateWithRapidApi called with fromLang="$fromLang", toLang="$toLang", text="$text"');

      final fromLangLower = fromLang.toLowerCase();
      final toLangLower = toLang.toLowerCase();

      final from = _rapidApiLangCodes[fromLangLower] ?? 'auto';
      final to = _rapidApiLangCodes[toLangLower] ?? 'en';

      print('Using mapped from="$from", to="$to"');

      if (text.trim().isEmpty) {
        return 'Please enter text to translate';
      }

      // Fixed: Using JSON body instead of form data
      final requestBody = {
        'from': from,
        'to': to,
        'text': text,
      };

      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(_rapidApiUrl),
        headers: {
          'Content-Type': 'application/json', // Changed from form-urlencoded
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': 'google-translate113.p.rapidapi.com',
        },
        body: json.encode(requestBody), // Using JSON body
      ).timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check different possible response structures
        if (data['trans'] != null) {
          return data['trans'];
        } else if (data['data'] != null && data['data']['translations'] != null) {
          return data['data']['translations'][0]['translatedText'];
        } else if (data['translatedText'] != null) {
          return data['translatedText'];
        } else {
          print('Unexpected response structure: $data');
          return text;
        }
      } else {
        print('Translation failed: ${response.body}');
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      print('RapidAPI Error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        return 'Network error: Please check your internet connection';
      } else if (e.toString().contains('401')) {
        return 'Authentication error: Please check your RapidAPI key';
      } else if (e.toString().contains('403')) {
        return 'Access denied: Please check your RapidAPI subscription';
      } else {
        return 'Translation error: ${e.toString()}';
      }
    }
  }

  // Method 3: MyMemory Translation API (Free, no API key needed) - IMPROVED
  static Future<String> translateWithMyMemory(
    String text, 
    String fromLang, 
    String toLang
  ) async {
    try {
      // MyMemory uses full language codes like en|es
      final langPair = '$fromLang|$toLang';
      final encodedText = Uri.encodeComponent(text);
      final String url = 'https://api.mymemory.translated.net/get?q=$encodedText&langpair=$langPair';
      
      print('MyMemory URL: $url');
      
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      print('MyMemory Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['responseStatus'] == 200 || data['responseStatus'] == '200') {
          final translatedText = data['responseData']['translatedText'];
          if (translatedText != null && translatedText.isNotEmpty) {
            return translatedText;
          }
        }
        // If main translation fails, try alternative structure
        if (data['matches'] != null && data['matches'].isNotEmpty) {
          return data['matches'][0]['translation'] ?? text;
        }
        throw Exception('Translation API returned no results');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('MyMemory Error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        return 'Network error: Please check your internet connection';
      } else {
        return 'Translation error: ${e.toString()}';
      }
    }
  }
}

class TranslatorPage extends StatelessWidget {
  const TranslatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'AI Translator Pro',
          theme: themeProvider.themeData,
          home: const TranslatorChatScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class TranslatorChatScreen extends StatefulWidget {
  const TranslatorChatScreen({super.key});

  @override
  State<TranslatorChatScreen> createState() => _TranslatorChatScreenState();
}

class _TranslatorChatScreenState extends State<TranslatorChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final FocusNode _inputFocusNode = FocusNode();
  
  String _fromLanguage = 'en';
  String _toLanguage = 'es';
  bool _isTranslating = false;
  bool _isInputFocused = false;
  
  // Translation API selection
  String _selectedApi = 'rapidapi'; // 'mymemory', 'libretranslate', 'rapidapi'
  
  late AnimationController _swapController;
  late AnimationController _sendController;
  late AnimationController _typingController;

  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'flag': '🇺🇸', 'code': 'EN'},
    'ta': {'name': 'Tamil', 'flag': '🇮🇳', 'code': 'TA'},
    'hi': {'name': 'Hindi', 'flag': '🇮🇳', 'code': 'HI'},
    'ar': {'name': 'Arabic', 'flag': '🇸🇦', 'code': 'AR'},
    'as': {'name': 'Assamese', 'flag': '🇮🇳', 'code': 'AS'},
    'bn': {'name': 'Bengali', 'flag': '🇮🇳', 'code': 'BN'},
    'bho': {'name': 'Bhojpuri', 'flag': '🇮🇳', 'code': 'BHO'},
    'brx': {'name': 'Bodo', 'flag': '🇮🇳', 'code': 'BRX'},
    'zh': {'name': 'Chinese', 'flag': '🇨🇳', 'code': 'ZH'},
    'doi': {'name': 'Dogri', 'flag': '🇮🇳', 'code': 'DOI'},
    'nl': {'name': 'Dutch', 'flag': '🇳🇱', 'code': 'NL'},
    'fr': {'name': 'French', 'flag': '🇫🇷', 'code': 'FR'},
    'de': {'name': 'German', 'flag': '🇩🇪', 'code': 'DE'},
    'gu': {'name': 'Gujarati', 'flag': '🇮🇳', 'code': 'GU'},
    'it': {'name': 'Italian', 'flag': '🇮🇹', 'code': 'IT'},
    'ja': {'name': 'Japanese', 'flag': '🇯🇵', 'code': 'JA'},
    'kn': {'name': 'Kannada', 'flag': '🇮🇳', 'code': 'KN'},
    'ks': {'name': 'Kashmiri', 'flag': '🇮🇳', 'code': 'KS'},
    'gom': {'name': 'Konkani', 'flag': '🇮🇳', 'code': 'GOM'},
    'ko': {'name': 'Korean', 'flag': '🇰🇷', 'code': 'KR'},
    'mai': {'name': 'Maithili', 'flag': '🇮🇳', 'code': 'MAI'},
    'ml': {'name': 'Malayalam', 'flag': '🇮🇳', 'code': 'ML'},
    'mni': {'name': 'Manipuri', 'flag': '🇮🇳', 'code': 'MNI'},
    'mr': {'name': 'Marathi', 'flag': '🇮🇳', 'code': 'MR'},
    'my': {'name': 'Myanmar', 'flag': '🇲🇲', 'code': 'MY'},
    'ne': {'name': 'Nepali', 'flag': '🇳🇵', 'code': 'NE'},
    'or': {'name': 'Odia', 'flag': '🇮🇳', 'code': 'OR'},
    'pl': {'name': 'Polish', 'flag': '🇵🇱', 'code': 'PL'},
    'pt': {'name': 'Portuguese', 'flag': '🇵🇹', 'code': 'PT'},
    'pa': {'name': 'Punjabi', 'flag': '🇮🇳', 'code': 'PA'},
    'ru': {'name': 'Russian', 'flag': '🇷🇺', 'code': 'RU'},
    'sa': {'name': 'Sanskrit', 'flag': '🇮🇳', 'code': 'SA'},
    'sat': {'name': 'Santali', 'flag': '🇮🇳', 'code': 'SAT'},
    'sd': {'name': 'Sindhi', 'flag': '🇮🇳', 'code': 'SD'},
    'si': {'name': 'Sinhala', 'flag': '🇱🇰', 'code': 'SI'},
    'es': {'name': 'Spanish', 'flag': '🇪🇸', 'code': 'ES'},
    'sv': {'name': 'Swedish', 'flag': '🇸🇪', 'code': 'SV'},
    'te': {'name': 'Telugu', 'flag': '🇮🇳', 'code': 'TE'},
    'th': {'name': 'Thai', 'flag': '🇹🇭', 'code': 'TH'},
    'tr': {'name': 'Turkish', 'flag': '🇹🇷', 'code': 'TR'},
    'ur': {'name': 'Urdu', 'flag': '🇵🇰', 'code': 'UR'},
    'vi': {'name': 'Vietnamese', 'flag': '🇻🇳', 'code': 'VI'},
  };

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _sendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    });

    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _swapController.dispose();
    _sendController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    _swapController.forward().then((_) {
      setState(() {
        final temp = _fromLanguage;
        _fromLanguage = _toLanguage;
        _toLanguage = temp;
      });
      _swapController.reset();
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTranslating) return;

    _sendController.forward().then((_) => _sendController.reverse());
    HapticFeedback.lightImpact();

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTranslating = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Real AI Translation with better error handling
    String translatedText;
    try {
      switch (_selectedApi) {
        case 'libretranslate':
          translatedText = await TranslationService.translateWithLibreTranslate(
            text, _fromLanguage, _toLanguage);
          break;
        case 'mymemory':
          translatedText = await TranslationService.translateWithMyMemory(
            text, _fromLanguage, _toLanguage);
          break;
        default: // rapidai
          translatedText = await TranslationService.translateWithRapidApi(
            text, _fromLanguage, _toLanguage);
      }
    } catch (e) {
      print('Translation error in _sendMessage: $e');
      translatedText = 'Translation failed: ${e.toString()}';
    }

    final aiMessage = ChatMessage(
      text: translatedText,
      isUser: false,
      timestamp: DateTime.now(),
      sourceLanguage: _languages[_fromLanguage]!['name']!,
      targetLanguage: _languages[_toLanguage]!['name']!,
      confidence: 0.95,
    );

    setState(() {
      _messages.add(aiMessage);
      _isTranslating = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          "AI Translator",
          style: TextStyle(color: theme.colorScheme.inversePrimary),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.inversePrimary,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.colorScheme.inversePrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _buildLanguageIndicator(),
          _buildApiSelector(),
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.colorScheme.inversePrimary,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildLanguageSelector(),
            Expanded(child: _buildChatArea()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiSelector() {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: Icon(Icons.api, color: theme.colorScheme.inversePrimary),
      onSelected: (String value) {
        setState(() {
          _selectedApi = value;
        });
        String message = 'Switched to ${value.toUpperCase()} API';
        // if (value == 'rapidapi') {
        //   message += '\n⚠️ Make sure to add your RapidAPI key!';
        // }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'mymemory',
          child: Row(
            children: [
              Icon(Icons.memory, color: _selectedApi == 'mymemory' ? Colors.green : null),
              const SizedBox(width: 8),
              const Text('MyMemory (Free)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'libretranslate',
          child: Row(
            children: [
              Icon(Icons.translate, color: _selectedApi == 'libretranslate' ? Colors.green : null),
              const SizedBox(width: 8),
              const Text('LibreTranslate'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'rapidapi',
          child: Row(
            children: [
              Icon(Icons.speed, color: _selectedApi == 'rapidapi' ? Colors.green : null),
              const SizedBox(width: 8),
              const Text('Google (RapidAPI)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageIndicator() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_languages[_fromLanguage]!['flag']!, style: const TextStyle(fontSize: 12)),
          Icon(Icons.arrow_forward, size: 12, color: theme.colorScheme.primary),
          Text(_languages[_toLanguage]!['flag']!, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Translation Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.inversePrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedApi.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLanguageDropdown('From', _fromLanguage, (value) {
                  setState(() => _fromLanguage = value!);
                }),
              ),
              const SizedBox(width: 8),
              _buildSwapButton(),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLanguageDropdown('To', _toLanguage, (value) {
                  setState(() => _toLanguage = value!);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(String label, String value, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    final language = _languages[value]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.expand_more, color: theme.colorScheme.primary, size: 18),
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.inversePrimary,
              ),
              dropdownColor: theme.colorScheme.tertiary,
              selectedItemBuilder: (context) {
                return _languages.entries.map((entry) {
                  return Row(
                    children: [
                      Text(entry.value['flag']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value['name']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: _languages.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Text(entry.value['flag']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 12),
                      Text(
                        entry.value['name']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapButton() {
    final theme = Theme.of(context);
    return Transform.translate(
      offset: const Offset(0, 11),
      child: AnimatedBuilder(
        animation: _swapController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _swapController.value * 3.14159,
            child: GestureDetector(
              onTap: _swapLanguages,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.swap_horiz,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatArea() {
    return _messages.isEmpty ? _buildEmptyState() : _buildMessageList();
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to Translate',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.inversePrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a message below to get AI-powered translation',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isTranslating ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTranslating) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildTypingIndicator() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingController,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final animValue = (_typingController.value - delay) % 1.0;
                        return Container(
                          margin: EdgeInsets.only(right: index < 2 ? 3 : 0),
                          child: Transform.translate(
                            offset: Offset(0, -3 * (animValue < 0.5 ? animValue * 2 : (1 - animValue) * 2)),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Translating...',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: message.isUser 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: message.isUser 
                          ? theme.colorScheme.inversePrimary
                          : theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12).copyWith(
                        bottomLeft: message.isUser
                            ? const Radius.circular(12)
                            : const Radius.circular(3),
                        bottomRight: message.isUser
                            ? const Radius.circular(3)
                            : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: message.isUser 
                            ? theme.colorScheme.background
                            : theme.colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!message.isUser) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_languages[_fromLanguage]!['flag']!, style: const TextStyle(fontSize: 8)),
                              Text(' → ', style: TextStyle(fontSize: 8, color: theme.colorScheme.primary)),
                              Text(_languages[_toLanguage]!['flag']!, style: const TextStyle(fontSize: 8)),
                              const SizedBox(width: 4),
                              Text(
                                '${(message.confidence! * 100).toInt()}%',
                                style: TextStyle(fontSize: 8, color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    final theme = Theme.of(context);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isUser ? theme.colorScheme.inversePrimary : theme.colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser ? theme.colorScheme.background : theme.colorScheme.primary,
        size: 14,
      ),
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _inputFocusNode,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.inversePrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Type your message for AI translation...',
                hintStyle: TextStyle(color: theme.colorScheme.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _sendController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - (_sendController.value * 0.1),
                child: GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _messageController.text.trim().isNotEmpty
                          ? theme.colorScheme.inversePrimary
                          : theme.colorScheme.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _isTranslating
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.background,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: _messageController.text.trim().isNotEmpty
                                  ? theme.colorScheme.background
                                  : theme.colorScheme.primary,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? sourceLanguage;
  final String? targetLanguage;
  final double? confidence;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sourceLanguage,
    this.targetLanguage,
    this.confidence,
  });
}