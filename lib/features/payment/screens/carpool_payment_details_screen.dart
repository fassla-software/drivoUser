import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolPaymentDetailsScreen extends StatefulWidget {
  final String tripId;
  final String carpoolType;
  final int totalPrice;
  final List<Map<String, dynamic>> paymentAccounts;
  final Map<String, dynamic>? proration;

  const CarpoolPaymentDetailsScreen({
    super.key,
    required this.tripId,
    required this.carpoolType,
    required this.totalPrice,
    required this.paymentAccounts,
    this.proration,
  });

  @override
  State<CarpoolPaymentDetailsScreen> createState() =>
      _CarpoolPaymentDetailsScreenState();
}

class _CarpoolPaymentDetailsScreenState
    extends State<CarpoolPaymentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  File? _screenshot;
  bool _isSubmitting = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _screenshot = File(image.path);
          _currentStep = 2; // Move active step to "Confirm Booking"
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick screenshot: $e',
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    }
  }

  void _removeImage() {
    setState(() {
      _screenshot = null;
      _currentStep = 1; // Back to upload step
    });
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    Get.snackbar(
      'Copied!',
      '$label copied to clipboard',
      backgroundColor: Colors.black,
      colorText: Colors.white,
      icon: const Icon(Icons.copy, color: Colors.white, size: 20),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
    setState(() {
      _currentStep = 1; // Move active step to "Upload screenshot" after copying
    });
  }

  Future<void> _submitPayment() async {
    if (_screenshot == null) {
      Get.snackbar(
        'Screenshot Required',
        'Please upload the transfer screenshot receipt first.',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final bool success = await Get.find<RideController>().submitCarpoolPayment(
      tripRequestId: widget.tripId,
      screenshotPath: _screenshot!.path,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'payment_submitted'.tr,
                  style: textBold.copyWith(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'your_transfer_receipt_submitted'.tr,
                  style: textRegular.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.offAll(() => const DashboardScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'go_to_home'.tr,
                      style: textSemiBold.copyWith(
                        fontSize: 15,
                        color: Colors.white,
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

  String get _carpoolTypeLabel {
    switch (widget.carpoolType) {
      case 'travel':
        return 'Travel';
      case 'routine':
        return 'Daily Routine';
      case 'north_coast':
        return 'North Coast';
      default:
        return 'Trip';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              _PaymentAppBar(carpoolTypeLabel: _carpoolTypeLabel),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PriceSummaryCard(
                        totalPrice: widget.totalPrice,
                        carpoolType: widget.carpoolType,
                        proration: widget.proration,
                        tripId: widget.tripId,
                      ),
                      const SizedBox(height: 24),
                      _StepsCard(
                        currentStep: _currentStep,
                        onStepChanged: (step) =>
                            setState(() => _currentStep = step),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Payment Accounts'),
                      const SizedBox(height: 12),
                      ...widget.paymentAccounts
                          .map((account) => _PaymentAccountCard(
                                account: account,
                                onCopy: _copyToClipboard,
                              )),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Upload Transfer Screenshot'),
                      const SizedBox(height: 12),
                      _ScreenshotUploadCard(
                        screenshot: _screenshot,
                        onPick: _pickImage,
                        onRemove: _removeImage,
                      ),
                      const SizedBox(height: 36),
                      _ConfirmButton(
                        onPressed: _submitPayment,
                        isSubmitting: _isSubmitting,
                        isReady: _screenshot != null,
                      ),
                      const SizedBox(height: 32),
                    ],
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

// ─── Sub-widgets (StatelessWidgets per user guidelines) ─────────────────────────

class _PaymentAppBar extends StatelessWidget {
  final String carpoolTypeLabel;

  const _PaymentAppBar({required this.carpoolTypeLabel});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      carpoolTypeLabel.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete Payment',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  final int totalPrice;
  final String carpoolType;
  final Map<String, dynamic>? proration;
  final String tripId;

  const _PriceSummaryCard({
    required this.totalPrice,
    required this.carpoolType,
    required this.proration,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasProration = proration != null;
    final double totalFare = totalPrice.toDouble();
    final int? remainingDays = proration?['remaining_days'] as int?;
    final int? totalDays = proration?['total_days_in_month'] as int?;
    final double? prorationRatio =
        (proration?['proration_ratio'] as num?)?.toDouble();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AMOUNT DUE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.pending_actions,
                          size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Pending Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'EGP ${totalFare.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            if (hasProration && remainingDays != null && totalDays != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Prorated for $remainingDays of $totalDays days'
                        '${prorationRatio != null ? ' (${(prorationRatio * 100).toStringAsFixed(0)}%)' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.15), height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.confirmation_number_outlined,
                    size: 13, color: Colors.white.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(
                  'Trip ID: ${tripId.substring(0, tripId.length.clamp(0, 12))}...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onStepChanged;

  const _StepsCard({
    required this.currentStep,
    required this.onStepChanged,
  });

  static const List<_StepData> _steps = [
    _StepData(
      icon: Icons.copy_rounded,
      title: 'Copy Account details',
      description: 'Copy the Instapay wallet details below.',
    ),
    _StepData(
      icon: Icons.upload_file_rounded,
      title: 'Upload Transfer screenshot',
      description: 'Take a screenshot of the completed transfer.',
    ),
    _StepData(
      icon: Icons.check_circle_rounded,
      title: 'Submit and confirm',
      description: 'Submit receipt and wait for instant activation.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Complete Verification',
              style: textBold.copyWith(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < _steps.length; i++) ...[
              _StepItem(
                step: _steps[i],
                index: i,
                isActive: currentStep == i,
                isCompleted: currentStep > i,
                onTap: () => onStepChanged(i),
              ),
              if (i < _steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Container(
                    width: 2,
                    height: 20,
                    color: currentStep > i ? Colors.black : Colors.grey[200],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String title;
  final String description;

  const _StepData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _StepItem extends StatelessWidget {
  final _StepData step;
  final int index;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  const _StepItem({
    required this.step,
    required this.index,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor = isCompleted
        ? Colors.black
        : isActive
            ? Colors.black
            : Colors.grey[100]!;
    final Color iconColor = isCompleted
        ? Colors.white
        : isActive
            ? Colors.white
            : Colors.grey[400]!;
    final Color textColor = isActive ? Colors.black : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                border: isActive && !isCompleted
                    ? Border.all(color: Colors.black, width: 1.5)
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Icon(step.icon, color: iconColor, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textBold.copyWith(
        fontSize: 16,
        color: Colors.black,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _PaymentAccountCard extends StatelessWidget {
  final Map<String, dynamic> account;
  final void Function(String value, String label) onCopy;

  const _PaymentAccountCard({
    required this.account,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final String method = (account['method'] as String?) ?? 'instapay';
    final String label = (account['label'] as String?) ?? '';
    final String labelAr = (account['label_ar'] as String?) ?? '';
    final String accountNumber = (account['account_number'] as String?) ?? '';
    final String accountHolder = (account['account_holder'] as String?) ?? '';
    final String instructions = (account['instructions'] as String?) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    method == 'instapay'
                        ? Icons.mobile_friendly
                        : Icons.account_balance,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        label.isNotEmpty ? label : labelAr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _CopyableField(
                  label: 'Account / Wallet Number',
                  value: accountNumber,
                  onCopy: onCopy,
                  isHighlighted: true,
                ),
                const SizedBox(height: 12),
                _CopyableField(
                  label: 'Account Holder Name',
                  value: accountHolder,
                  onCopy: onCopy,
                ),
                if (instructions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.black, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            instructions,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyableField extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String value, String label) onCopy;
  final bool isHighlighted;

  const _CopyableField({
    required this.label,
    required this.value,
    required this.onCopy,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onCopy(value, label),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHighlighted ? Colors.black : Colors.grey[200]!,
            width: isHighlighted ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isHighlighted ? FontWeight.w900 : FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: isHighlighted ? 0.5 : 0.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isHighlighted ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.copy_rounded,
                size: 14,
                color: isHighlighted ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenshotUploadCard extends StatelessWidget {
  final File? screenshot;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ScreenshotUploadCard({
    required this.screenshot,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (screenshot != null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                screenshot!,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text(
                    'Screenshot uploaded successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black12,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.black,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload Transfer Screenshot',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to open your photo library (Required)',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSubmitting;
  final bool isReady;

  const _ConfirmButton({
    required this.onPressed,
    required this.isSubmitting,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isReady ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: isReady ? Colors.white : Colors.black38,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'I\'ve Transferred — Confirm Booking',
                      style: textBold.copyWith(
                        color: isReady ? Colors.white : Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
