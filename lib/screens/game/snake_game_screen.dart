import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_game/utils/dependency_injection/get_it_setup.dart';
import 'snake_cubit.dart';
import 'snake_state.dart';

// Point and Direction definitions (same as before)
class Point {
  final int x;
  final int y;
  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) {
    return other is Point && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

enum Direction {
  up,
  down,
  left,
  right,
}

Direction oppositeDirection(Direction dir) {
  switch (dir) {
    case Direction.up:
      return Direction.down;
    case Direction.down:
      return Direction.up;
    case Direction.left:
      return Direction.right;
    case Direction.right:
      return Direction.left;
  }
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return _SnakeView();
  }
}

class _SnakeView extends StatelessWidget {
  const _SnakeView();

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<SnakeCubit>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Snake Game',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<SnakeCubit, SnakeState>(
            bloc: cubit, // explicitly provide cubit
            buildWhen: (p, c) => p.score != c.score,
            builder: (_, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Container(
                  key: ValueKey(state.score),
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Score: ${state.score}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game board
              BlocBuilder<SnakeCubit, SnakeState>(
                bloc: cubit,
                buildWhen: (p, c) =>
                    p.snake != c.snake ||
                    p.food != c.food ||
                    p.gameOver != c.gameOver ||
                    p.gameWin != c.gameWin,
                builder: (_, state) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(400, 400),
                            painter: ModernSnakePainter(
                              snake: state.snake,
                              food: state.food,
                              cellSize: 20,
                              gridSize: 20,
                            ),
                          ),
                          if (state.gameOver)
                            Container(
                              width: 400,
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.gameWin ? 'YOU WIN!' : 'GAME OVER',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                        shadows: [
                                          Shadow(blurRadius: 10, color: Colors.cyan),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () => cubit.startGame(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyan.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 8,
                                      ),
                                      child: const Text(
                                        'RESTART',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Direction controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: Icons.arrow_left,
                      onTap: () => cubit.changeDirection(Direction.left),
                    ),
                    const SizedBox(width: 12),
                    _buildControlButton(
                      icon: Icons.arrow_upward,
                      onTap: () => cubit.changeDirection(Direction.up),
                    ),
                    const SizedBox(width: 12),
                    _buildControlButton(
                      icon: Icons.arrow_downward,
                      onTap: () => cubit.changeDirection(Direction.down),
                    ),
                    const SizedBox(width: 12),
                    _buildControlButton(
                      icon: Icons.arrow_right,
                      onTap: () => cubit.changeDirection(Direction.right),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => cubit.startGame(),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'RESTART GAME',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  elevation: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade700, Colors.grey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.cyan.shade300, size: 32),
        ),
      ),
    );
  }
}

// Modern painter with rounded cells and glow effects
class ModernSnakePainter extends CustomPainter {
  final List<Point> snake;
  final Point? food;
  final double cellSize;
  final int gridSize;

  const ModernSnakePainter({
    required this.snake,
    required this.food,
    required this.cellSize,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (int i = 0; i <= gridSize; i++) {
      final double x = i * cellSize;
      final double y = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Food with glow
    if (food != null) {
      final glowPaint = Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            food!.x * cellSize + 1,
            food!.y * cellSize + 1,
            cellSize - 2,
            cellSize - 2,
          ),
          const Radius.circular(6),
        ),
        glowPaint,
      );
      final foodPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Colors.redAccent, Colors.orange],
        ).createShader(Rect.fromLTWH(
          food!.x * cellSize,
          food!.y * cellSize,
          cellSize,
          cellSize,
        ))
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            food!.x * cellSize,
            food!.y * cellSize,
            cellSize - 0.5,
            cellSize - 0.5,
          ),
          const Radius.circular(6),
        ),
        foodPaint,
      );
    }

    // Snake body
    for (int i = 0; i < snake.length; i++) {
      final point = snake[i];
      final isHead = i == 0;

      // Shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            point.x * cellSize + 1,
            point.y * cellSize + 1,
            cellSize - 2,
            cellSize - 2,
          ),
          const Radius.circular(6),
        ),
        shadowPaint,
      );

      // Gradient fill
      final gradient = isHead
          ? const LinearGradient(
              colors: [Colors.greenAccent, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          :  LinearGradient(
              colors: [Colors.green, Colors.green.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );
      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(
          point.x * cellSize,
          point.y * cellSize,
          cellSize,
          cellSize,
        ))
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            point.x * cellSize,
            point.y * cellSize,
            cellSize - 0.5,
            cellSize - 0.5,
          ),
          const Radius.circular(6),
        ),
        paint,
      );

      // Eyes for head
      if (isHead) {
        final eyeSize = cellSize * 0.2;
        final eyeOffsetX = cellSize * 0.25;
        final eyeOffsetY = cellSize * 0.3;
        final eyePaint = Paint()..color = Colors.white;
        canvas.drawCircle(
          Offset(point.x * cellSize + eyeOffsetX, point.y * cellSize + eyeOffsetY),
          eyeSize,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(point.x * cellSize + cellSize - eyeOffsetX, point.y * cellSize + eyeOffsetY),
          eyeSize,
          eyePaint,
        );
        final pupilPaint = Paint()..color = Colors.black;
        canvas.drawCircle(
          Offset(point.x * cellSize + eyeOffsetX, point.y * cellSize + eyeOffsetY),
          eyeSize * 0.5,
          pupilPaint,
        );
        canvas.drawCircle(
          Offset(point.x * cellSize + cellSize - eyeOffsetX, point.y * cellSize + eyeOffsetY),
          eyeSize * 0.5,
          pupilPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ModernSnakePainter oldDelegate) {
    return oldDelegate.snake != snake ||
        oldDelegate.food != food ||
        oldDelegate.cellSize != cellSize;
  }
}