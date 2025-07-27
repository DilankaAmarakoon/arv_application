import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../Models/staff_task_data_model.dart';
import '../constants/static_data.dart';
import '../constants/theme.dart';

class StaffCart extends StatefulWidget {
  final StaffTaskDataModel task;
  final int index;
  final VoidCallback onTaskUpdated;

  const StaffCart({
    super.key,
    required this.task,
    required this.index,
    required this.onTaskUpdated,
  });

  @override
  State<StaffCart> createState() => _StaffCartState();
}

class _StaffCartState extends State<StaffCart>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late TextEditingController _remarkController;

  double _slideOffset = 0.0;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.task.remarks);
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.2, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _slideOffset += details.delta.dx;
          _slideOffset = _slideOffset.clamp(-80.0, 0.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_slideOffset < -40) {
          setState(() {
            _slideOffset = -80.0;
          });
        } else {
          setState(() {
            _slideOffset = 0.0;
          });
        }
      },
      child: Stack(
        children: [
          _buildActionBackground(),
          Transform.translate(
            offset: Offset(_slideOffset, 0),
            child: _buildTaskCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBackground() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: IconButton(
              onPressed: _showRemarkDialog,
              icon: const Icon(
                Icons.comment_outlined,
                color: AppColors.onPrimary,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard() {
    final isCompleted = widget.task.isCompleted ?? false;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withOpacity(0.3)
              : AppColors.divider,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTaskIcon(isCompleted),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _buildTaskContent(),
          ),
          _buildTaskSwitch(),
        ],
      ),
    );
  }

  Widget _buildTaskIcon(bool isCompleted) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted ? Icons.check_circle : Icons.assignment,
        color: isCompleted ? AppColors.success : AppColors.primary,
        size: 26,
      ),
    );
  }

  Widget _buildTaskContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.taskName ?? 'Unknown Task',
          style: AppTextStyles.subtitle1.copyWith(
            decoration: widget.task.isCompleted == true
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          widget.task.taskDesc ?? 'No description',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.onSurfaceVariant,
            decoration: widget.task.isCompleted == true
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        if (widget.task.remarks?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 14,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    widget.task.remarks!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.info,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaskSwitch() {
    return Column(
      children: [
        if (_isUpdating)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        else
          Switch(
            value: widget.task.isCompleted ?? false,
            onChanged: _handleSwitchChanged,
            activeColor: AppColors.success,
            inactiveThumbColor: AppColors.disabled,
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          widget.task.isCompleted == true ? 'Done' : 'Pending',
          style: AppTextStyles.caption.copyWith(
            color: widget.task.isCompleted == true
                ? AppColors.success
                : AppColors.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _handleSwitchChanged(bool value) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      widget.task.isCompleted = value;
      await _saveCompletedState();
      widget.onTaskUpdated();

      _showStatusSnackBar(
        value ? 'Task completed!' : 'Task marked as pending',
        value ? AppColors.success : AppColors.warning,
      );
    } catch (e) {
      // Revert the change on error
      widget.task.isCompleted = !value;
      _showStatusSnackBar('Failed to update task', AppColors.error);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showRemarkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Remark'),
        content: TextField(
          controller: _remarkController,
          decoration: const InputDecoration(
            hintText: 'Enter your remark...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveRemark,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveRemark() async {
    try {
      widget.task.remarks = _remarkController.text;
      await _saveRemarks();
      widget.onTaskUpdated();
      Navigator.pop(context);
      _showStatusSnackBar('Remark saved successfully', AppColors.success);
    } catch (e) {
      _showStatusSnackBar('Failed to save remark', AppColors.error);
    }
  }

  void _showStatusSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }

  Future<void> _saveCompletedState() async {
    final dio = Dio();
    await dio.post(
      '${baseUrl}api/task_complete',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        "task_line_id": widget.task.id,
        "is_complete": widget.task.isCompleted,
      },
    );
  }

  Future<void> _saveRemarks() async {
    final dio = Dio();
    await dio.post(
      '${baseUrl}api/task_remark',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        "task_line_id": widget.task.id,
        "remark": widget.task.remarks,
      },
    );
  }
}