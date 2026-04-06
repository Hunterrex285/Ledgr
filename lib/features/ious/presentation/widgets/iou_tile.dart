import 'package:flutter/material.dart';
import '../../domain/entities/iou.dart';

class IouTile extends StatelessWidget {
  final Iou iou;
  final VoidCallback? onSettle;
  final VoidCallback onDelete;

  const IouTile({
    super.key,
    required this.iou,
    required this.onSettle,
    required this.onDelete,
  });

  String _initials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String _dateLabel(DateTime date) {
    return '${date.day} ${const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isLent = iou.type == IouType.lent;
    final color = isLent ? Colors.green : Colors.red;
    final sign = isLent ? '+' : '-';
    final label = isLent ? 'Lent' : 'Borrowed';

    return Dismissible(
      key: Key(iou.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(iou.personName),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    iou.personName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateLabel(iou.date),
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (iou.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      iou.note!,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Amount + settle button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign₹${iou.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: iou.isSettled ? Colors.grey : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                if (iou.isSettled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Settled',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey)),
                  )
                else if (onSettle != null)
                  GestureDetector(
                    onTap: onSettle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Settle',
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}