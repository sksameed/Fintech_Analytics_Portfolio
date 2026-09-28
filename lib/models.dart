// lib/models.dart
// Plain Dart data models for Credit Cards, Transactions, and Rewards.
// Implements manual fromJson/toJson methods to avoid heavy code-generation
// packages (like build_runner), making the codebase easy for an intern to explain.

class CreditCard {
  final String id;
  final String cardholderName;
  final String cardNumber;
  final String network;
  final double totalLimit;
  final double outstandingBalance;
  final String dueDate;
  final String billMonth;

  const CreditCard({
    required this.id,
    required this.cardholderName,
    required this.cardNumber,
    required this.network,
    required this.totalLimit,
    required this.outstandingBalance,
    required this.dueDate,
    required this.billMonth,
  });

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'] as String,
      cardholderName: json['cardholderName'] as String,
      cardNumber: json['cardNumber'] as String,
      network: json['network'] as String,
      totalLimit: (json['totalLimit'] as num).toDouble(),
      outstandingBalance: (json['outstandingBalance'] as num).toDouble(),
      dueDate: json['dueDate'] as String,
      billMonth: json['billMonth'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardholderName': cardholderName,
      'cardNumber': cardNumber,
      'network': network,
      'totalLimit': totalLimit,
      'outstandingBalance': outstandingBalance,
      'dueDate': dueDate,
      'billMonth': billMonth,
    };
  }
}

class Transaction {
  final String id;
  final String merchant;
  final String category;
  final double amount;
  final DateTime date;
  final String cardId;

  const Transaction({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.date,
    required this.cardId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      merchant: json['merchant'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      cardId: json['cardId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant': merchant,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'cardId': cardId,
    };
  }
}

class Reward {
  final String id;
  final String title;
  final String description;
  final String discountCode;
  final bool isScratched;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.discountCode,
    required this.isScratched,
  });

  Reward copyWith({bool? isScratched}) {
    return Reward(
      id: id,
      title: title,
      description: description,
      discountCode: discountCode,
      isScratched: isScratched ?? this.isScratched,
    );
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      discountCode: json['discountCode'] as String,
      isScratched: json['isScratched'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountCode': discountCode,
      'isScratched': isScratched,
    };
  }
}
