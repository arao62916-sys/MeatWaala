import 'package:flutter/material.dart';

class StaticPageView extends StatelessWidget {
  final String title;
  final String content;

  const StaticPageView({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageView(
      title: 'About Us',
      content: '''Welcome to MeatWaala!

We are your trusted partner for fresh, hygienic, and premium quality meat delivered right to your doorstep.

Our Mission:
To provide the freshest and highest quality meat products to our customers while ensuring complete hygiene and safety standards.

Why Choose Us:
• 100% Fresh & Hygienic Products
• Sourced from Trusted Suppliers
• Fast & Reliable Delivery
• Competitive Pricing
• Quality Guaranteed

We believe in transparency, quality, and customer satisfaction. Every product goes through strict quality checks before reaching you.

Thank you for choosing MeatWaala!''',
    );
  }
}

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageView(
      title: 'Contact Us',
      content: '''Get in Touch with Us!

Customer Support:
Phone: +91 1800-123-4567
Email: support@meatwaala.com

Business Hours:
Monday - Saturday: 6:00 AM - 10:00 PM
Sunday: 6:00 AM - 8:00 PM

Head Office:
MeatWaala Pvt. Ltd.
123 Business Park, Mumbai
Maharashtra - 400001
India

For any queries, complaints, or feedback, please feel free to reach out to us. We're here to help!

Follow Us:
Facebook: @meatwaala
Instagram: @meatwaala
Twitter: @meatwaala''',
    );
  }
}

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageView(
      title: 'Privacy Policy',
      content: '''Privacy Policy

Last updated: December 2024

At MeatWaala, we respect your privacy and are committed to protecting your personal data.

Information We Collect:
• Name, email, phone number
• Delivery addresses
• Order history
• Payment information (processed securely)

How We Use Your Information:
• To process and deliver your orders
• To communicate about your orders
• To improve our services
• To send promotional offers (with your consent)

Data Security:
We implement appropriate security measures to protect your personal information from unauthorized access, alteration, or disclosure.

Your Rights:
• Access your personal data
• Request data correction or deletion
• Opt-out of marketing communications

Contact Us:
For privacy-related queries, email us at privacy@meatwaala.com

By using our app, you agree to this Privacy Policy.''',
    );
  }
}

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageView(
      title: 'Terms & Conditions',
      content: '''Terms & Conditions

Last updated: December 2024

Welcome to MeatWaala. By using our app, you agree to these terms.

1. Orders & Delivery:
• All orders are subject to availability
• Delivery times are estimates
• We reserve the right to cancel orders in exceptional circumstances

2. Pricing:
• All prices are in INR and inclusive of taxes
• Prices may change without notice
• Payment must be made as per selected method

3. Returns & Refunds:
• Due to the nature of our products, returns are only accepted for quality issues
• Refunds will be processed within 7-10 business days
• Contact customer support within 24 hours of delivery for any issues

4. User Responsibilities:
• Provide accurate delivery information
• Be available to receive orders
• Use the app lawfully

5. Limitation of Liability:
MeatWaala is not liable for any indirect or consequential damages arising from use of our services.

6. Changes to Terms:
We reserve the right to modify these terms at any time.

For questions, contact us at legal@meatwaala.com''',
    );
  }
}
