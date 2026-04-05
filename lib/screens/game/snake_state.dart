import 'package:equatable/equatable.dart';
import 'snake_game_screen.dart';

class SnakeState extends Equatable {
  final List<Point> snake;
  final Point? food;
  final int score;
  final bool gameOver;
  final bool gameWin;
  final Direction direction;

  const SnakeState({
    required this.snake,
    required this.food,
    required this.score,
    required this.gameOver,
    required this.gameWin,
    required this.direction,
  });

  SnakeState copyWith({
    List<Point>? snake,
    Point? food,
    int? score,
    bool? gameOver,
    bool? gameWin,
    Direction? direction,
  }) {
    return SnakeState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      score: score ?? this.score,
      gameOver: gameOver ?? this.gameOver,
      gameWin: gameWin ?? this.gameWin,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object?> get props => [snake, food, score, gameOver, gameWin, direction];
}