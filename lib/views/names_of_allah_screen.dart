import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sadqah_jariyah_app/controllers/names_controller.dart';
import 'package:sadqah_jariyah_app/model/allah_name.dart';

class NamesOfAllahScreen extends StatelessWidget {
  const NamesOfAllahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NamesController()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أسماء الله الحسنى'),
          centerTitle: true,
        ),
        body: const _NamesBody(),
      ),
    );
  }
}

class _NamesBody extends StatelessWidget {
  const _NamesBody();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<NamesController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: context.read<NamesController>().search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث عن اسم',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(child: _buildContent(context, c)),
      ],
    );
  }

  Widget _buildContent(BuildContext context, NamesController c) {
    if (c.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 42),
            const SizedBox(height: 12),
            const Text('تعذر تحميل الأسماء'),
            TextButton(
              onPressed: context.read<NamesController>().load,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final names = c.names;
    if (names.isEmpty) {
      return const Center(child: Text('لا توجد نتائج'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 60,
      ),
      itemCount: names.length,
      itemBuilder: (_, i) => _NameTile(item: names[i]),
    );
  }
}

class _NameTile extends StatelessWidget {
  const _NameTile({required this.item});
  final AllahName item;
  //ع
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: افتح شاشة التفاصيل وجيب /asma-al-husna/{item.id}
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primary.withValues(alpha: 0.15),
                child: Text(
                  '${item.id}',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
