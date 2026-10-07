import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/credit_card_invoice_model.dart';
import '../models/credit_card_model.dart';

part 'credit_card_remote_datasource.g.dart';

/// Credit Card Remote Data Source
/// Retrofit API client for credit card endpoints
@RestApi(baseUrl: "")
abstract class CreditCardRemoteDataSource {
  factory CreditCardRemoteDataSource(Dio dio, {String baseUrl}) =
      _CreditCardRemoteDataSource;

  /// Get all credit cards for a budget, optionally filtered by updatedSince
  @GET("/api/credit-cards")
  Future<List<CreditCardModel>> getCreditCards(
    @Query("budgetId") String budgetId,
    @Query("activeOnly") bool activeOnly,
    @Query("updatedSince") String? updatedSince,
  );

  /// Get credit card by ID
  @GET("/api/credit-cards/{id}")
  Future<CreditCardModel> getCreditCardById(@Path("id") String id);

  /// Create a new credit card
  @POST("/api/credit-cards")
  Future<CreditCardModel> createCreditCard(
    @Body() Map<String, dynamic> request,
  );

  /// Update credit card
  @PUT("/api/credit-cards/{id}")
  Future<CreditCardModel> updateCreditCard(
    @Path("id") String id,
    @Body() Map<String, dynamic> request,
  );

  /// Delete credit card
  @DELETE("/api/credit-cards/{id}")
  Future<void> deleteCreditCard(@Path("id") String id);

  /// Toggle credit card status
  @PUT("/api/credit-cards/{id}/toggle-status")
  Future<CreditCardModel> toggleStatus(
    @Path("id") String id,
    @Body() Map<String, dynamic> request,
  );

  /// Link account to credit card
  @PUT("/api/credit-cards/{id}/link-account")
  Future<CreditCardModel> linkAccount(
    @Path("id") String id,
    @Body() Map<String, dynamic> request,
  );

  /// Unlink account from credit card
  @DELETE("/api/credit-cards/{id}/unlink-account")
  Future<CreditCardModel> unlinkAccount(@Path("id") String id);

  /// Get invoice for a credit card and month
  @GET("/api/credit-cards/{cardId}/invoices/{month}")
  Future<CreditCardInvoiceModel> getInvoice(
    @Path("cardId") String cardId,
    @Path("month") String month,
  );

  /// Get invoice summaries for a credit card
  @GET("/api/credit-cards/{cardId}/invoices")
  Future<List<InvoiceSummaryModel>> getInvoiceSummaries(
    @Path("cardId") String cardId,
    @Query("monthsBack") int monthsBack,
  );
}
