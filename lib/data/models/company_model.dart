/// Company Model for storing company/business information
class CompanyModel {
  final String company;
  final String displayName;
  final String logoUrl;
  final String iconUrl;
  final String loginIcon;
  final String loginBg;
  final String phone;
  final String emailId;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pin;
  final String facebook;
  final String instagram;
  final String twitter;
  final String youtube;
  final String linkedin;

  CompanyModel({
    required this.company,
    required this.displayName,
    required this.logoUrl,
    required this.iconUrl,
    required this.loginIcon,
    required this.loginBg,
    required this.phone,
    required this.emailId,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pin,
    required this.facebook,
    required this.instagram,
    required this.twitter,
    required this.youtube,
    required this.linkedin,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      company: json['company'] ?? '',
      displayName: json['display_name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      loginIcon: json['login_icon'] ?? '',
      loginBg: json['login_bg'] ?? '',
      phone: json['phone'] ?? '',
      emailId: json['email_id'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pin: json['pin'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
      youtube: json['youtube'] ?? '',
      linkedin: json['linkedin'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'display_name': displayName,
      'logo_url': logoUrl,
      'icon_url': iconUrl,
      'login_icon': loginIcon,
      'login_bg': loginBg,
      'phone': phone,
      'email_id': emailId,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pin': pin,
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
      'youtube': youtube,
      'linkedin': linkedin,
    };
  }

  @override
  String toString() {
    return 'CompanyModel(displayName: $displayName, logoUrl: $logoUrl)';
  }
}
