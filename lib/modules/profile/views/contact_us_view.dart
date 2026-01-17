import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meatwaala_app/core/theme/app_colors.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meatwaala_app/modules/profile/controllers/cms_controller.dart';

class ContactUsView extends GetView<CmsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch Contact Us content on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchContactUs();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context);
        }

        if (controller.cmsContent.value == null) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.fetchContactUs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContentCard(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    final content = controller.cmsContent.value!;

    // Parse known fields from CMS content
    final raw = content.formattedContent;
    // Extract first non-empty line as main header (eg. "Get in Touch with Us!")
    final lines = raw.split(RegExp(r"\r?\n"));
    final firstLine = lines.firstWhere(
      (l) => l.trim().isNotEmpty,
      orElse: () => content.name,
    );
    final phone = _extractFirstMatch(raw,
            RegExp(r'Phone:\s*(\+?\d[\d\-\s]{6,}\d)', caseSensitive: false)) ??
        _extractFirstMatch(raw, RegExp(r'(\+?\d[\d\-\s]{6,}\d)'));
    final email = _extractFirstMatch(
            raw,
            RegExp(r'Email:\s*([\w\.\-]+@[\w\.\-]+\.\w+)',
                caseSensitive: false)) ??
        _extractFirstMatch(raw, RegExp(r'[\w\.\-]+@[\w\.\-]+\.\w+'));
    final facebook = _extractLabelValue(raw, 'Facebook');
    final instagram = _extractLabelValue(raw, 'Instagram');
    final twitter = _extractLabelValue(raw, 'Twitter');

    // Build remaining content without header, Customer Support, phone and email lines
    var remaining = raw;
    // Remove the extracted first line
    remaining = remaining.replaceFirst(firstLine, '');
    // Remove possible 'Customer Support' heading and following blank lines
    remaining = remaining.replaceAll(
      RegExp(r'^Customer Support:\s*', caseSensitive: false, multiLine: true),
      '',
    );
    // Remove explicit Phone and Email lines
    remaining = remaining.replaceAll(
      RegExp(r'^Phone:\s*.+(?:\r?\n)?', caseSensitive: false, multiLine: true),
      '',
    );
    remaining = remaining.replaceAll(
      RegExp(r'^Email:\s*.+(?:\r?\n)?', caseSensitive: false, multiLine: true),
      '',
    );
    // Remove Follow Us heading and social lines (Facebook/Instagram/Twitter)
    remaining = remaining.replaceAll(
      RegExp(r'^Follow Us:\s*', caseSensitive: false, multiLine: true),
      '',
    );
    remaining = remaining.replaceAll(
      RegExp(r'^Facebook:\s*.+(?:\r?\n)?',
          caseSensitive: false, multiLine: true),
      '',
    );
    remaining = remaining.replaceAll(
      RegExp(r'^Instagram:\s*.+(?:\r?\n)?',
          caseSensitive: false, multiLine: true),
      '',
    );
    remaining = remaining.replaceAll(
      RegExp(r'^Twitter:\s*.+(?:\r?\n)?',
          caseSensitive: false, multiLine: true),
      '',
    );
    // Clean up multiple blank lines
    remaining = remaining.replaceAll(RegExp(r'\n{2,}'), '\n\n').trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_support,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Top header line from CMS (e.g., "Get in Touch with Us!")
          Text(
            firstLine,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),

          // Customer Support block
          if (phone != null || email != null) ...[
            Text(
              'Customer Support',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            if (phone != null)
              _contactRow(context, Icons.phone, 'Phone', phone),
            if (email != null)
              _contactRow(context, Icons.email, 'Email', email),
            const SizedBox(height: 12),
          ],

          // Remaining details (address, hours, head office etc.) without duplicate phone/email
          if (remaining.isNotEmpty)
            Text(
              remaining,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                    fontSize: 15,
                  ),
            ),

          const SizedBox(height: 16),

          if (facebook != null || instagram != null || twitter != null) ...[
            Text(
              'Follow Us :',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (facebook != null)
                  _socialIcon(BoxIcons.bxl_facebook, 'Facebook', facebook),
                if (instagram != null)
                  _socialIcon(BoxIcons.bxl_instagram, 'Instagram', instagram),
                if (twitter != null)
                  _socialIcon(BoxIcons.bxl_twitter, 'Twitter', twitter),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
            ),
          ),
          // Open action (call or mail) where applicable
          IconButton(
            onPressed: () async {
              final opened = await _openContact(label, value);
              if (!opened) {
                Get.snackbar('Error', 'Could not open $label.');
                await Clipboard.setData(ClipboardData(text: value));
                Get.snackbar('Copied', 'Value copied to clipboard');
              }
            },
            icon: Icon(
              label.toLowerCase() == 'email' ? Icons.send : Icons.call,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData iconData, String label, String value) {
    final available = value.trim().isNotEmpty && value.trim() != '#';
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () async {
          if (!available) {
            Get.snackbar('Info', '$label link not available');
            return;
          }

          final opened = await _openSocialLink(label, value);
          if (!opened) {
            Get.snackbar('Info', 'Could not open $label. Value copied.');
            await Clipboard.setData(ClipboardData(text: value));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(available ? 0.08 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconData,
            color: available ? AppColors.primary : AppColors.primary,
          ),
        ),
      ),
    );
  }

  String? _extractFirstMatch(String text, RegExp regex) {
    final match = regex.firstMatch(text);
    if (match != null) return match.group(match.groupCount > 0 ? 1 : 0)?.trim();
    return null;
  }

  String? _extractLabelValue(String text, String label) {
    // Build regex dynamically and use RegExp flags instead of inline modifiers
    final pattern = label + r':\s*(.+)';
    final regex = RegExp(pattern, caseSensitive: false, multiLine: true);
    final match = regex.firstMatch(text);
    if (match != null && match.groupCount >= 1) return match.group(1)?.trim();
    return null;
  }

  Future<bool> _launchUrl(String raw) async {
    try {
      var url = raw.trim();
      if (!url.startsWith('http')) url = 'https://$url';
      final uri = Uri.parse(url);

      // Try launching without checking first
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }

  Future<bool> _openSocialLink(String label, String value) async {
    if (value.trim().isEmpty || value.trim() == '#') return false;

    try {
      var v = value.trim();

      // If direct URL, open it
      if (v.startsWith('http://') || v.startsWith('https://')) {
        return await _launchUrl(v);
      }

      // Remove leading @ or / or #
      v = v.replaceAll(RegExp(r'^[@#/\\]+'), '').trim();

      String url;
      switch (label.toLowerCase()) {
        case 'facebook':
          url = 'https://www.facebook.com/$v';
          break;
        case 'instagram':
          url = 'https://www.instagram.com/$v';
          break;
        case 'twitter':
          url = 'https://twitter.com/$v';
          break;
        default:
          url = v.startsWith('http') ? v : 'https://$v';
      }

      return await _launchUrl(url);
    } catch (e) {
      debugPrint('Error opening social link: $e');
      return false;
    }
  }

  /// Open phone dialer or email client. Returns true if launched.
  Future<bool> _openContact(String label, String value) async {
    try {
      print('✅✅Opening contact: $label -> $value');
      final v = value.trim();
      Uri uri;

      if (label.toLowerCase() == 'phone') {
        // Remove all non-digit characters except +
        final tel = v.replaceAll(RegExp(r'[^\d+]'), '');
        uri = Uri.parse('tel:$tel');
      } else if (label.toLowerCase() == 'email') {
        uri = Uri.parse('mailto:$v');
      } else {
        return false;
      }

      // Try launching directly without canLaunchUrl check
      await launchUrl(uri);
      return true;
    } catch (e) {
      debugPrint('Error opening contact: $e');
      return false;
    }
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load content',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.fetchContactUs,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No content available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
