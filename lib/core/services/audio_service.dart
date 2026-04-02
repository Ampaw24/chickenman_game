import 'package:audioplayers/audioplayers.dart';

/// Central audio service — holds one [AudioPlayer] per sound slot so that
/// short effects can overlap (e.g. tap while match is playing).
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  bool _muted = false;
  bool get isMuted => _muted;

  // One player per sound so they don't cancel each other.
  final _tap = AudioPlayer();
  final _swap = AudioPlayer();
  final _match = AudioPlayer();
  final _combo = AudioPlayer();
  final _invalid = AudioPlayer();
  final _gameOver = AudioPlayer();
  final _gameStart = AudioPlayer();
  final _win = AudioPlayer();
  final _lose = AudioPlayer();
  final _introSelect = AudioPlayer();

  // Background music gets its own looping player.
  final _bgm = AudioPlayer();
  bool _bgmPlaying = false;

  Future<void> init() async {
    await _bgm.setReleaseMode(ReleaseMode.loop);
  }

  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      _bgm.setVolume(0);
    } else {
      _bgm.setVolume(0.35);
    }
  }

  // ── One-shot SFX ───────────────────────────────────────────────────────────

  Future<void> playTap() => _play(_tap, 'audio/tap.wav');
  Future<void> playSwap() => _play(_swap, 'audio/swap.wav');
  Future<void> playMatch() => _play(_match, 'audio/match.wav');
  Future<void> playCombo() => _play(_combo, 'audio/combo.wav');
  Future<void> playInvalid() => _play(_invalid, 'audio/invalid.wav');
  Future<void> playGameOver() => _play(_gameOver, 'audio/game_over.wav');
  Future<void> playGameStart() => _play(_gameStart, 'audio/game_start.wav');
  Future<void> playWin() => _play(_win, 'audio/win.wav');
  Future<void> playLose() => _play(_lose, 'audio/lose.wav');
  Future<void> playIntroSelect() => _play(_introSelect, 'audio/intro_select.wav');

  Future<void> _play(AudioPlayer player, String asset) async {
    if (_muted) return;
    try {
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (_) {
      // Swallow audio errors — they must never crash gameplay.
    }
  }

  // ── Background music ───────────────────────────────────────────────────────

  Future<void> startBgm() async {
    if (_bgmPlaying) return;
    _bgmPlaying = true;
    try {
      await _bgm.setVolume(_muted ? 0 : 0.35);
      await _bgm.play(AssetSource('audio/game_start.wav'));
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    _bgmPlaying = false;
    try {
      await _bgm.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    for (final p in [_tap, _swap, _match, _combo, _invalid, _gameOver, _gameStart, _win, _lose, _introSelect, _bgm]) {
      await p.dispose();
    }
  }
}
