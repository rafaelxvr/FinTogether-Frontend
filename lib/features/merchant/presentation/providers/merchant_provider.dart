import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/usecases/archive_merchant_usecase.dart';
import '../../domain/usecases/create_merchant_usecase.dart';
import '../../domain/usecases/delete_merchant_usecase.dart';
import '../../domain/usecases/get_merchant_by_id_usecase.dart';
import '../../domain/usecases/get_merchants_usecase.dart';
import '../../domain/usecases/search_merchants_usecase.dart';
import '../../domain/usecases/unarchive_merchant_usecase.dart';
import '../../domain/usecases/update_merchant_usecase.dart';
import 'merchant_state.dart';

class MerchantNotifier extends StateNotifier<MerchantState> {
  final GetMerchantsUseCase getMerchantsUseCase;
  final GetMerchantByIdUseCase getMerchantByIdUseCase;
  final SearchMerchantsUseCase searchMerchantsUseCase;
  final CreateMerchantUseCase createMerchantUseCase;
  final UpdateMerchantUseCase updateMerchantUseCase;
  final DeleteMerchantUseCase deleteMerchantUseCase;
  final ArchiveMerchantUseCase archiveMerchantUseCase;
  final UnarchiveMerchantUseCase unarchiveMerchantUseCase;

  List<Merchant> _merchants = [];

  MerchantNotifier({
    required this.getMerchantsUseCase,
    required this.getMerchantByIdUseCase,
    required this.searchMerchantsUseCase,
    required this.createMerchantUseCase,
    required this.updateMerchantUseCase,
    required this.deleteMerchantUseCase,
    required this.archiveMerchantUseCase,
    required this.unarchiveMerchantUseCase,
  }) : super(MerchantInitial());

  Future<void> loadMerchants({required String budgetId}) async {
    state = MerchantLoading();
    final result = await getMerchantsUseCase(budgetId: budgetId);
    result.fold(
      (failure) => state = MerchantError(failure.message),
      (merchants) {
        _merchants = merchants;
        state = MerchantsLoaded(merchants);
      },
    );
  }

  Future<void> searchMerchants({
    required String budgetId,
    required String query,
  }) async {
    final result = await searchMerchantsUseCase(
      budgetId: budgetId,
      query: query,
    );
    result.fold(
      (failure) => state = MerchantError(failure.message),
      (merchants) => state = MerchantsLoaded(merchants),
    );
  }

  Future<void> getMerchantById(String id) async {
    state = MerchantLoading();
    final result = await getMerchantByIdUseCase(id);
    result.fold(
      (failure) => state = MerchantError(failure.message),
      (merchant) => state = MerchantLoaded(merchant),
    );
  }

  Future<void> createMerchant({
    required String budgetId,
    required String name,
    String? displayName,
    String? color,
    String? defaultCategoryId,
  }) async {
    state = MerchantLoading();
    final result = await createMerchantUseCase(
      budgetId: budgetId,
      name: name,
      displayName: displayName,
      color: color,
      defaultCategoryId: defaultCategoryId,
    );
    result.fold(
      (failure) => state = MerchantError(failure.message),
      (merchant) {
        _merchants = [..._merchants, merchant];
        state = MerchantCreated(merchant);
        loadMerchants(budgetId: budgetId);
      },
    );
  }

  Future<void> updateMerchant({
    required String budgetId,
    required String id,
    required String name,
    String? displayName,
    String? color,
    String? defaultCategoryId,
  }) async {
    state = MerchantLoading();
    final result = await updateMerchantUseCase(
      id: id,
      name: name,
      displayName: displayName,
      color: color,
      defaultCategoryId: defaultCategoryId,
    );
    result.fold(
      (failure) => state = MerchantError(failure.message),
      (merchant) {
        _merchants = _merchants
            .map((m) => m.id == merchant.id ? merchant : m)
            .toList();
        state = MerchantUpdated(merchant);
        loadMerchants(budgetId: budgetId);
      },
    );
  }

  Future<void> deleteMerchant({
    required String budgetId,
    required String id,
  }) async {
    state = MerchantLoading();
    final result = await deleteMerchantUseCase(id);
    result.fold(
      (failure) => state = MerchantError(failure.message),
      (_) {
        _merchants = _merchants.where((m) => m.id != id).toList();
        state = MerchantDeleted();
        loadMerchants(budgetId: budgetId);
      },
    );
  }

  Future<void> archiveMerchant({
    required String budgetId,
    required String id,
  }) async {
    state = MerchantLoading();
    final result = await archiveMerchantUseCase(id);
    result.fold(
      (failure) => state = MerchantError(failure.message),
      (merchant) {
        _merchants = _merchants
            .map((m) => m.id == merchant.id ? merchant : m)
            .toList();
        state = MerchantArchived(merchant);
        loadMerchants(budgetId: budgetId);
      },
    );
  }

  Future<void> unarchiveMerchant({
    required String budgetId,
    required String id,
  }) async {
    state = MerchantLoading();
    final result = await unarchiveMerchantUseCase(id);
    result.fold(
      (failure) => state = MerchantError(failure.message),
      (merchant) {
        _merchants = _merchants
            .map((m) => m.id == merchant.id ? merchant : m)
            .toList();
        state = MerchantUnarchived(merchant);
        loadMerchants(budgetId: budgetId);
      },
    );
  }

  List<Merchant> get merchants => _merchants;
  List<Merchant> get activeMerchants =>
      _merchants.where((m) => !m.archived).toList();
  List<Merchant> get archivedMerchants =>
      _merchants.where((m) => m.archived).toList();
}

final merchantProvider =
    StateNotifierProvider<MerchantNotifier, MerchantState>(
  (ref) => MerchantNotifier(
    getMerchantsUseCase: getIt<GetMerchantsUseCase>(),
    getMerchantByIdUseCase: getIt<GetMerchantByIdUseCase>(),
    searchMerchantsUseCase: getIt<SearchMerchantsUseCase>(),
    createMerchantUseCase: getIt<CreateMerchantUseCase>(),
    updateMerchantUseCase: getIt<UpdateMerchantUseCase>(),
    deleteMerchantUseCase: getIt<DeleteMerchantUseCase>(),
    archiveMerchantUseCase: getIt<ArchiveMerchantUseCase>(),
    unarchiveMerchantUseCase: getIt<UnarchiveMerchantUseCase>(),
  ),
);
