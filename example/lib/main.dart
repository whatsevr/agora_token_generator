/// Agora Token Generator Flutter Example
///
/// A modern and professional Flutter web application for generating Agora tokens.
///
/// Features:
/// - Generate multiple types of Agora tokens (RTC, RTM, Multi-Service)
/// - Modern Material 3 UI with animations and transitions
/// - Real-time form validation and error handling
/// - Copy-to-clipboard functionality with visual feedback
/// - Statistics tracking for token generation
/// - Quick actions for common operations
/// - Password visibility toggle for sensitive fields
/// - Loading states and shimmer effects
/// - Responsive design optimized for web and desktop
///
/// Author: Agora.io
/// Version: 2.0.0
/// Last Updated: June 2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_token_generator/agora_token_generator.dart';

void main() {
  runApp(const AgoraTokenGeneratorApp());
}

class AgoraTokenGeneratorApp extends StatelessWidget {
  const AgoraTokenGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Token Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0084FF),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0084FF), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
      home: const TokenGeneratorPage(),
    );
  }
}

class TokenGeneratorPage extends StatefulWidget {
  const TokenGeneratorPage({super.key});

  @override
  State<TokenGeneratorPage> createState() => _TokenGeneratorPageState();
}

class _TokenGeneratorPageState extends State<TokenGeneratorPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _appIdController =
      TextEditingController(text: '970CA35de60c44645bbae8a215061b33');
  final _appCertificateController =
      TextEditingController(text: '5CFd2fd1755d40ecb72977518be15d3b');
  final _channelController = TextEditingController(text: 'testChannel');
  final _uidController = TextEditingController(text: '12345');
  final _accountController = TextEditingController(text: 'testUser');
  final _expireSecondsController = TextEditingController(text: '3600');

  // Generated tokens
  String _rtcTokenWithUid = '';
  String _rtcTokenWithAccount = '';
  String _rtcTokenWithZeroUid = '';
  String _rtmToken = '';
  String _multiServiceToken = '';

  // Token type selection
  int _selectedTokenType = 0;
  bool _isGenerating = false;
  bool _obscureAppCertificate = true;
  String _errorMessage = '';
  int _tokensGenerated = 0;
  DateTime? _lastGenerationTime;
  final List<String> _tokenTypes = [
    'RTC Token (UID)',
    'RTC Token (Account)',
    'RTC Token (UID=0)',
    'RTM Token',
    'Multi-Service Token'
  ];

  @override
  void dispose() {
    _appIdController.dispose();
    _appCertificateController.dispose();
    _channelController.dispose();
    _uidController.dispose();
    _accountController.dispose();
    _expireSecondsController.dispose();
    super.dispose();
  }

  Future<void> _generateTokens() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = '';
    });

    try {
      final appId = _appIdController.text;
      final appCertificate = _appCertificateController.text;
      final channel = _channelController.text;
      final uid = int.tryParse(_uidController.text) ?? 0;
      final account = _accountController.text;
      final expireSeconds = int.tryParse(_expireSecondsController.text) ?? 3600;

      // Simulate network delay for better UX demonstration
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate RTC Token with UID
      _rtcTokenWithUid = RtcTokenBuilder.buildTokenWithUid(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channel,
        uid: uid,
        tokenExpireSeconds: expireSeconds,
      );

      // Generate RTC Token with Account
      _rtcTokenWithAccount = RtcTokenBuilder.buildTokenWithAccount(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channel,
        account: account,
        tokenExpireSeconds: expireSeconds,
      );

      // Generate RTC Token with UID=0
      _rtcTokenWithZeroUid = RtcTokenBuilder.buildTokenWithUid(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channel,
        uid: 0,
        tokenExpireSeconds: expireSeconds,
      );

      // Generate RTM Token
      _rtmToken = RtmTokenBuilder.buildToken(
        appId: appId,
        appCertificate: appCertificate,
        userId: account,
        tokenExpireSeconds: expireSeconds,
      );

      // Generate Multi-Service Token
      var token = AccessToken(appId, appCertificate, expireSeconds);

      // Add RTC service
      var rtcService = ServiceRTC(channel, uid.toString());
      rtcService.addPrivilege(Privileges.JOIN_CHANNEL, expireSeconds);
      rtcService.addPrivilege(Privileges.PUBLISH_AUDIO_STREAM, expireSeconds);
      token.addService(rtcService);

      // Add RTM service
      var rtmService = ServiceRTM(account);
      rtmService.addPrivilege(Privileges.LOGIN, expireSeconds);
      token.addService(rtmService);

      _multiServiceToken = token.build();

      // Update statistics
      _tokensGenerated++;
      _lastGenerationTime = DateTime.now();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Tokens generated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate tokens: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  String _getCurrentToken() {
    switch (_selectedTokenType) {
      case 0:
        return _rtcTokenWithUid;
      case 1:
        return _rtcTokenWithAccount;
      case 2:
        return _rtcTokenWithZeroUid;
      case 3:
        return _rtmToken;
      case 4:
        return _multiServiceToken;
      default:
        return '';
    }
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Token copied to clipboard!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget _buildShimmerEffect() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(4, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index < 3 ? 8.0 : 0),
            child: Container(
              height: 16,
              width: double.infinity * (0.9 - (index * 0.1)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: const Alignment(-1.0, 0.0),
                  end: const Alignment(1.0, 0.0),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    bool showPasswordToggle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        obscureText: showPasswordToggle ? _obscureAppCertificate : obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          suffixIcon: showPasswordToggle
              ? IconButton(
                  icon: Icon(
                    _obscureAppCertificate
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureAppCertificate = !_obscureAppCertificate;
                    });
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'UID' && int.tryParse(value) == null) {
            return 'UID must be a valid number';
          }
          if (label == 'Expire Time (seconds)' && int.tryParse(value) == null) {
            return 'Expire time must be a valid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0084FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.token,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Agora Token Generator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0084FF).withOpacity(0.1),
                      const Color(0xFF0084FF).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Agora Tokens',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0084FF),
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create secure tokens for Agora RTC and RTM services with customizable parameters.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Web Platform Notice (only show on web)
              if (kIsWeb) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.web, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Web Version',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Running in web mode with optimized compression for browser compatibility.',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Statistics Card
              if (_tokensGenerated > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Tokens Generated',
                            _tokensGenerated.toString(),
                            Icons.token,
                            Colors.blue,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Last Generated',
                            _lastGenerationTime != null
                                ? _formatTimeAgo(_lastGenerationTime!)
                                : 'Never',
                            Icons.access_time,
                            Colors.green,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Token Types',
                            '${_tokenTypes.length}',
                            Icons.category,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Configuration Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.settings,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Configuration',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInputField(
                        label: 'App ID',
                        controller: _appIdController,
                        hint: 'Enter your Agora App ID',
                        prefixIcon: Icons.apps,
                      ),
                      _buildInputField(
                        label: 'App Certificate',
                        controller: _appCertificateController,
                        hint: 'Enter your Agora App Certificate',
                        prefixIcon: Icons.security,
                        showPasswordToggle: true,
                      ),
                      _buildInputField(
                        label: 'Channel Name',
                        controller: _channelController,
                        hint: 'Enter channel name',
                        prefixIcon: Icons.group,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              label: 'UID',
                              controller: _uidController,
                              hint: 'Enter UID (number)',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.person,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              label: 'User Account',
                              controller: _accountController,
                              hint: 'Enter user account',
                              prefixIcon: Icons.account_circle,
                            ),
                          ),
                        ],
                      ),
                      _buildInputField(
                        label: 'Expire Time (seconds)',
                        controller: _expireSecondsController,
                        hint: 'Token expiration time in seconds',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.access_time,
                      ),
                      const SizedBox(height: 16),

                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              'Clear All',
                              Icons.clear_all,
                              Colors.orange,
                              _clearAllFields,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              'Demo Data',
                              Icons.data_usage,
                              Colors.purple,
                              _loadDemoData,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              'Reset',
                              Icons.refresh,
                              Colors.blue,
                              _resetToDefaults,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message Display
              if (_errorMessage.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = '';
                          });
                        },
                        icon: Icon(Icons.close,
                            color: Colors.red.shade600, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Generate Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: _isGenerating
                      ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF0084FF), Color(0xFF0066CC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateTokens,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.generating_tokens,
                          color: Colors.white),
                  label: Text(
                    _isGenerating ? 'Generating...' : 'Generate Tokens',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Generated Tokens Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.token,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Generated Tokens',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<int>(
                        value: _selectedTokenType,
                        decoration: const InputDecoration(
                          labelText: 'Token Type',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _tokenTypes.asMap().entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTokenType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Generated Token:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    key: ValueKey(_isGenerating),
                                    decoration: BoxDecoration(
                                      color: _isGenerating
                                          ? Colors.grey.shade400
                                          : const Color(0xFF0084FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      onPressed: _isGenerating
                                          ? null
                                          : () => _copyToClipboard(
                                              _getCurrentToken()),
                                      icon: const Icon(Icons.copy,
                                          color: Colors.white, size: 18),
                                      tooltip: 'Copy to clipboard',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: _isGenerating
                                  ? _buildShimmerEffect()
                                  : AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Text(
                                        _getCurrentToken().isEmpty
                                            ? 'Click "Generate Tokens" to see results...'
                                            : _getCurrentToken(),
                                        key: ValueKey(_getCurrentToken()),
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 13,
                                          color: _getCurrentToken().isEmpty
                                              ? Colors.grey.shade500
                                              : Colors.grey.shade800,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Token Information',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._buildTokenInfoItems(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Keep your App Certificate secure. Never expose it in client applications.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _getCurrentToken().isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _copyToClipboard(_getCurrentToken()),
              icon: const Icon(Icons.copy),
              label: const Text('Copy Token'),
              backgroundColor: const Color(0xFF0084FF),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  List<Widget> _buildTokenInfoItems() {
    final items = [
      {
        'title': 'RTC Token (UID)',
        'description': 'For joining video/audio channels with numeric user ID',
        'icon': Icons.videocam,
        'color': Colors.red,
      },
      {
        'title': 'RTC Token (Account)',
        'description':
            'For joining video/audio channels with string user account',
        'icon': Icons.person_outline,
        'color': Colors.orange,
      },
      {
        'title': 'RTC Token (UID=0)',
        'description': 'For joining channels without specific user ID',
        'icon': Icons.groups,
        'color': Colors.green,
      },
      {
        'title': 'RTM Token',
        'description': 'For real-time messaging service',
        'icon': Icons.chat_bubble_outline,
        'color': Colors.blue,
      },
      {
        'title': 'Multi-Service Token',
        'description': 'Combined token for both RTC and RTM services',
        'icon': Icons.integration_instructions,
        'color': Colors.purple,
      },
    ];

    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    item['description'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildQuickActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.3)),
        backgroundColor: color.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _clearAllFields() {
    setState(() {
      _appIdController.clear();
      _appCertificateController.clear();
      _channelController.clear();
      _uidController.clear();
      _accountController.clear();
      _expireSecondsController.clear();
      _rtcTokenWithUid = '';
      _rtcTokenWithAccount = '';
      _rtcTokenWithZeroUid = '';
      _rtmToken = '';
      _multiServiceToken = '';
      _errorMessage = '';
    });
  }

  void _loadDemoData() {
    setState(() {
      _appIdController.text = '970CA35de60c44645bbae8a215061b33';
      _appCertificateController.text = '5CFd2fd1755d40ecb72977518be15d3b';
      _channelController.text = 'demoChannel';
      _uidController.text = '12345';
      _accountController.text = 'demoUser';
      _expireSecondsController.text = '7200';
      _errorMessage = '';
    });
  }

  void _resetToDefaults() {
    setState(() {
      _appIdController.text = '970CA35de60c44645bbae8a215061b33';
      _appCertificateController.text = '5CFd2fd1755d40ecb72977518be15d3b';
      _channelController.text = 'testChannel';
      _uidController.text = '12345';
      _accountController.text = 'testUser';
      _expireSecondsController.text = '3600';
      _rtcTokenWithUid = '';
      _rtcTokenWithAccount = '';
      _rtcTokenWithZeroUid = '';
      _rtmToken = '';
      _multiServiceToken = '';
      _errorMessage = '';
      _selectedTokenType = 0;
    });
  }
}
