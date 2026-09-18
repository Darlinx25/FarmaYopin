import 'card.dart';

enum PaymentMethod { cash, card }

class PaymentSelection {
  final PaymentMethod method;
  final CardModel? card;

  const PaymentSelection({required this.method, this.card});
}