import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<Category> categories;

  CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryLoaded extends CategoryState {
  final Category category;

  CategoryLoaded(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryCreated extends CategoryState {
  final Category category;

  CategoryCreated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryUpdated extends CategoryState {
  final Category category;

  CategoryUpdated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryDeleted extends CategoryState {}

class CategoryArchived extends CategoryState {
  final Category category;

  CategoryArchived(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryUnarchived extends CategoryState {
  final Category category;

  CategoryUnarchived(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
