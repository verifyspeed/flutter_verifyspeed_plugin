enum VerifySpeedMethodType {
  telegram('telegram-message'),
  whatsapp('whatsapp-message'),
  smsOtp('sms-otp');

  const VerifySpeedMethodType(this.value);

  final String value;

  factory VerifySpeedMethodType.fromMap(String value) =>
      VerifySpeedMethodType.values.firstWhere(
        (e) => e.value == value.toLowerCase(),
      );
}
