import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.board,
    required this.isMyTurn,
    required this.onCellTap,
  });

  final List<List<int>> board;
  final bool isMyTurn;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppConstants.boardSize,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: AppConstants.boardSize * AppConstants.boardSize,
        itemBuilder: (context, index) {
          final row = index ~/ AppConstants.boardSize;
          final col = index % AppConstants.boardSize;
          final cell = CellState.fromValue(board[row][col]);

          return _BoardCell(
            cell: cell,
            enabled: isMyTurn && cell == CellState.empty,
            onTap: () => onCellTap(row, col),
          );
        },
      ),
    );
  }
}

class _BoardCell extends StatefulWidget {
  const _BoardCell({
    required this.cell,
    required this.enabled,
    required this.onTap,
  });

  final CellState cell;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    if (widget.cell != CellState.empty) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_BoardCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cell == CellState.empty && widget.cell != CellState.empty) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _cellColor {
    switch (widget.cell) {
      case CellState.player1:
        return AppColors.player1Blue;
      case CellState.player2:
        return AppColors.player2Red;
      case CellState.empty:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: widget.cell == CellState.empty
              ? Colors.white
              : _cellColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.enabled
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: widget.enabled ? 2 : 1,
          ),
        ),
        child: Center(
          child: widget.cell != CellState.empty
              ? ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _cellColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _cellColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                )
              : widget.enabled
                  ? Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary.withValues(alpha: 0.3),
                      size: 20,
                    )
                  : null,
        ),
      ),
    );
  }
}
