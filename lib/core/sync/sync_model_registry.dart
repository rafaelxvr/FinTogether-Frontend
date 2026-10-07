import '../../features/auth/data/models/user_model.dart';
import '../../features/budget/data/models/budget_model.dart';
import '../../features/budget/data/models/budget_member_model.dart';
import '../../features/account/data/models/account_model.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/credit_card/data/models/credit_card_model.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/merchant/data/models/merchant_model.dart';
import '../../features/transaction/data/models/installment_group_model.dart';

typedef FromJsonFactory<T> = T Function(Map<String, dynamic> json);

class SyncModelRegistry {
  static final Map<String, FromJsonFactory> _registry = {
    'user': (json) => UserModel.fromJson(json),
    'budget': (json) => BudgetModel.fromJson(json),
    'budget_member': (json) => BudgetMemberModel.fromJson(json),
    'account': (json) => AccountModel.fromJson(json),
    'category': (json) => CategoryModel.fromJson(json),
    'merchant': (json) => MerchantModel.fromJson(json),
    'credit_card': (json) => CreditCardModel.fromJson(json),
    'installment_group': (json) => InstallmentGroupModel.fromJson(json),
    'transaction': (json) => TransactionModel.fromJson(json),
  };

  static const List<String> pushOrder = [
    'user',
    'budget',
    'budget_member',
    'account',
    'category',
    'merchant',
    'credit_card',
    'installment_group',
    'transaction',
  ];

  static const List<String> deleteOrder = [
    'transaction',
    'installment_group',
    'credit_card',
    'merchant',
    'category',
    'account',
    'budget_member',
    'budget',
    'user',
  ];

  static T deserialize<T>(String entityType, Map<String, dynamic> json) {
    final factory = _registry[entityType];
    if (factory == null) {
      throw ArgumentError('Unknown entity type: $entityType');
    }
    return factory(json) as T;
  }

  static bool isValidEntityType(String entityType) =>
      _registry.containsKey(entityType);
}
