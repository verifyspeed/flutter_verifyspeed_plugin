enum VerifySpeedMethodType {
  telegram('telegram-message'),
  whatsapp('whatsapp-message');

  const VerifySpeedMethodType(this.value);

  final String value;

  factory VerifySpeedMethodType.fromMap(String value) =>
      VerifySpeedMethodType.values.firstWhere(
        (e) => e.value == value.toLowerCase(),
      );
}
