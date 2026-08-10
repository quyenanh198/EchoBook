import 'package:flutter/material.dart';

import '../../../services/parsing/parsed_book.dart';

Future<int?> showTocSheet(
  BuildContext context, {
  required List<ParsedChapter> chapters,
  required int currentIndex,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Table of Contents', style: Theme.of(ctx).textTheme.titleLarge),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: chapters.length,
                itemBuilder: (ctx, i) {
                  final selected = i == currentIndex;
                  return ListTile(
                    selected: selected,
                    leading: Text('${i + 1}', style: Theme.of(ctx).textTheme.bodySmall),
                    title: Text(
                      chapters[i].title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
                    ),
                    onTap: () => Navigator.pop(ctx, i),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
