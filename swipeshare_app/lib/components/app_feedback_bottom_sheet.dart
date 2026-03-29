import 'package:flutter/material.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class AppFeedbackBottomSheet extends StatefulWidget {
  const AppFeedbackBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppFeedbackBottomSheet(),
    );
  }

  @override
  State<AppFeedbackBottomSheet> createState() => _AppFeedbackBottomSheetState();
}

class _AppFeedbackBottomSheetState extends State<AppFeedbackBottomSheet> {
  final _controller = TextEditingController();
  final _userService = UserService.instance;
  bool _isLoading = false;

  ColorScheme get _colors => Theme.of(context).colorScheme;
  TextTheme get _textTheme => Theme.of(context).textTheme;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await _userService.sendFeedback(text);
      await _markSeen();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(SnackbarMessages.genericError(e.toString())),
        ),
      );
      return;
    }

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(SnackbarMessages.feedbackSubmitted)),
    );
  }

  Future<void> _skip() async {
    await _markSeen();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _markSeen() async {
    final user = await _userService.getCurrentUser();
    await _userService.updateUserData(
      user.id,
      {'hasSeenAppFeedback': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: _colors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _colors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Share Feedback',
                  style: _textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: _colors.outlineVariant),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We\'d love to hear what you think about the app!',
                          style: _textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(color: _colors.outline, width: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            textCapitalization: TextCapitalization.sentences,
                            style: _textTheme.bodySmall,
                            decoration: InputDecoration(
                              hintText: 'Enter your feedback...',
                              hintStyle: _textTheme.bodySmall?.copyWith(
                                color: _colors.surfaceTint,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(16, 16, 9, 4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _isLoading ? null : _submit,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: _colors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _colors.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'Submit',
                                    style: _textTheme.labelLarge?.copyWith(
                                      color: _colors.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _isLoading ? null : _skip,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: _colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Skip',
                              style: _textTheme.labelLarge?.copyWith(
                                color: _colors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
