import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'snake_game_screen.dart';
import 'snake_state.dart';

@injectable
class SnakeCubit extends Cubit<SnakeState> {
  static const int gridSize = 20;
  static const int maxScore = 25;

  // Speed tuning
  static const int initialIntervalMs = 400;   // very slow start
  static const int minIntervalMs = 80;
  static const int intervalDecrementPerPoint = 10;

  Timer? _timer;
  int _currentIntervalMs = initialIntervalMs;
  final Random _random = Random();
  Direction _nextDirection = Direction.right;

  SnakeCubit() : super(const SnakeState(
    snake: [],
    food: null,
    score: 0,
    gameOver: false,
    gameWin: false,
    direction: Direction.right,
  )) {
    startGame();
  }

  void startGame() {
    _timer?.cancel();
    _currentIntervalMs = initialIntervalMs;
    _nextDirection = Direction.right;

    final startX = gridSize ~/ 2;
    final startY = gridSize ~/ 2;

    final snake = [
      Point(startX, startY),
      Point(startX - 1, startY),
      Point(startX - 2, startY),
    ];

    final food = _generateFood(snake);
    if (food == null) return;

    emit(state.copyWith(
      snake: snake,
      food: food,
      score: 0,
      gameOver: false,
      gameWin: false,
      direction: Direction.right,
    ));

    _startTimer();
  }

  void changeDirection(Direction dir) {
    if (state.gameOver) return;
    if (dir != oppositeDirection(state.direction)) {
      _nextDirection = dir;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _currentIntervalMs),
      (_) => _tick(),
    );
  }

  void _updateSpeed() {
    int newInterval = initialIntervalMs - (state.score * intervalDecrementPerPoint);
    if (newInterval < minIntervalMs) newInterval = minIntervalMs;
    if (newInterval != _currentIntervalMs) {
      _currentIntervalMs = newInterval;
      _startTimer();
    }
  }

  void _tick() {
    if (state.gameOver) return;

    final currentDir = _nextDirection != oppositeDirection(state.direction)
        ? _nextDirection
        : state.direction;

    final head = state.snake.first;
    Point newHead;
    switch (currentDir) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    // Wall collision
    if (newHead.x < 0 || newHead.y < 0 ||
        newHead.x >= gridSize || newHead.y >= gridSize) {
      _endGame(false);
      return;
    }

    List<Point> newSnake = [newHead, ...state.snake];
    final bool ateFood = newHead == state.food;

    if (!ateFood) {
      newSnake.removeLast();
    }

    // Self collision
    if (newSnake.skip(1).contains(newHead)) {
      _endGame(false);
      return;
    }

    if (ateFood) {
      final newScore = state.score + 1;

      if (newScore >= maxScore) {
        _endGame(true);
        return;
      }

      final newFood = _generateFood(newSnake);
      if (newFood == null) return;

      emit(state.copyWith(
        snake: newSnake,
        food: newFood,
        score: newScore,
        direction: currentDir,
      ));
      _updateSpeed();
    } else {
      emit(state.copyWith(
        snake: newSnake,
        direction: currentDir,
      ));
    }
  }

  Point? _generateFood(List<Point> snake) {
    final occupied = snake.toSet();
    List<Point> free = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        final p = Point(i, j);
        if (!occupied.contains(p)) free.add(p);
      }
    }
    if (free.isEmpty) {
      _endGame(true);
      return null;
    }
    return free[_random.nextInt(free.length)];
  }

  void _endGame(bool win) {
    _timer?.cancel();
    emit(state.copyWith(gameOver: true, gameWin: win));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}