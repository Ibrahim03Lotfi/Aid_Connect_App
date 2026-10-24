import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../services/local_storage_service.dart';
import '../../../domain/entities/case.dart';
import '../../../domain/repositories/user_repository.dart';

class FavoritesState extends Equatable {
  final Set<int> favoritedIds;
  final List<Case> favoriteCases;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.favoritedIds = const {},
    this.favoriteCases = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    Set<int>? favoritedIds,
    List<Case>? favoriteCases,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favoritedIds: favoritedIds ?? this.favoritedIds,
      favoriteCases: favoriteCases ?? this.favoriteCases,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [favoritedIds, favoriteCases, isLoading, errorMessage];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final UserRepository _userRepository;
  final LocalStorageService _localStorage;

  FavoritesCubit({
    required UserRepository userRepository,
    required LocalStorageService localStorage,
  })  : _userRepository = userRepository,
        _localStorage = localStorage,
        super(FavoritesState(favoritedIds: localStorage.getCachedFavoriteIds())) {
    loadFavorites();
  }

  bool isFavorited(int caseId) {
    return state.favoritedIds.contains(caseId);
  }

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _userRepository.getFavorites();

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'تعذر تحميل الحالات المفضلة',
        ));
      },
      (cases) {
        final ids = cases.map((c) => c.id).toSet();
        _localStorage.saveCachedFavoriteIds(ids);
        emit(state.copyWith(
          isLoading: false,
          favoriteCases: cases,
          favoritedIds: ids,
        ));
      },
    );
  }

  Future<void> toggleFavorite(Case caseItem) async {
    final currentIds = Set<int>.from(state.favoritedIds);
    final currentCases = List<Case>.from(state.favoriteCases);
    final isFav = currentIds.contains(caseItem.id);

    if (isFav) {
      currentIds.remove(caseItem.id);
      currentCases.removeWhere((c) => c.id == caseItem.id);
    } else {
      currentIds.add(caseItem.id);
      // Add or update to favorites list with isFavorited true
      final updatedCase = caseItem.copyWith(isFavorited: true);
      currentCases.insert(0, updatedCase);
    }

    // Immediate optimistic update
    _localStorage.saveCachedFavoriteIds(currentIds);
    emit(state.copyWith(
      favoritedIds: currentIds,
      favoriteCases: currentCases,
    ));

    // Sync with backend API
    try {
      if (isFav) {
        await _userRepository.removeFromFavorites(caseItem.id);
      } else {
        await _userRepository.addToFavorites(caseItem.id);
      }
    } catch (_) {
      // Keep optimistic or retry silently
    }
  }

  Future<void> removeFavorite(int caseId) async {
    final currentIds = Set<int>.from(state.favoritedIds)..remove(caseId);
    final currentCases = List<Case>.from(state.favoriteCases)
      ..removeWhere((c) => c.id == caseId);

    _localStorage.saveCachedFavoriteIds(currentIds);
    emit(state.copyWith(
      favoritedIds: currentIds,
      favoriteCases: currentCases,
    ));

    try {
      await _userRepository.removeFromFavorites(caseId);
    } catch (_) {}
  }
}
