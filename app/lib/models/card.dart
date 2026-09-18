class CardModel {
  final int? id;
  final int userId;
  final String holder;
  final String number;
  final String expiry;
  final String last4;
  final bool isDefault;

  const CardModel({
    this.id,
    required this.userId,
    required this.holder,
    required this.number,
    required this.expiry,
    required this.last4,
    this.isDefault = false,
  });

  String get maskedNumber => '••••  ••••  ••••  $last4';

  String get maskedLabel => '•••• $last4';

  String get summary => 'Tarjeta terminada en $last4';

  factory CardModel.fromMap(Map<String, Object?> map) {
    return CardModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      holder: map['holder'] as String? ?? '',
      number: map['number'] as String? ?? '',
      expiry: map['expiry'] as String? ?? '',
      last4: map['last4'] as String? ?? '',
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }
}