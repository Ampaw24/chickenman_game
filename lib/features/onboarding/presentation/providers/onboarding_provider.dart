import 'package:chickenmangame/gen/resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Avatar model ──────────────────────────────────────────────────────────────

class AvatarOption {
  final String assetPath;
  final String label;

  const AvatarOption({required this.assetPath, required this.label});
}

const List<AvatarOption> kAvatarOptions = [
  AvatarOption(
    assetPath: AppAvatars.avatar58f94cc3,
    label: 'Warrior',
  ),
  AvatarOption(
    assetPath: AppAvatars.avatar9306614,
    label: 'Champion',
  ),
  AvatarOption(
    assetPath: AppAvatars.avatar9806510,
    label: 'Legend',
  ),
  AvatarOption(
    assetPath: AppAvatars.imgEllipse303,
    label: 'Titan',
  ),
];

// ── State ─────────────────────────────────────────────────────────────────────

class OnboardingState {
  final String nickname;
  final int selectedAvatarIndex;
  final String authProvider; // 'google' | 'apple'

  const OnboardingState({
    this.nickname = '',
    this.selectedAvatarIndex = -1,
    this.authProvider = '',
  });

  OnboardingState copyWith({
    String? nickname,
    int? selectedAvatarIndex,
    String? authProvider,
  }) {
    return OnboardingState(
      nickname: nickname ?? this.nickname,
      selectedAvatarIndex: selectedAvatarIndex ?? this.selectedAvatarIndex,
      authProvider: authProvider ?? this.authProvider,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setAuthProvider(String provider) =>
      state = state.copyWith(authProvider: provider);

  void setNickname(String nickname) =>
      state = state.copyWith(nickname: nickname.trim());

  void setAvatarIndex(int index) =>
      state = state.copyWith(selectedAvatarIndex: index);
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (_) => OnboardingNotifier(),
);
