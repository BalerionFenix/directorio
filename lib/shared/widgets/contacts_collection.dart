import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../data/models/contact.dart';
import 'contact_card.dart';
import 'glass_panel.dart';
import 'loading_skeleton.dart';
import 'pop_in.dart';

/// Grilla (pantalla ancha) y lista (pantalla angosta) de contactos.
///
/// Ambas se construyen de forma diferida con slivers: Flutter solo crea los
/// elementos visibles más un margen (`cacheExtent`) y destruye los que se
/// alejan. Por eso el "pop" se controla aquí: solo anima el primer lote que
/// se ve al cargar o al cambiar un filtro ([filterKey]); lo que aparece después
/// con scroll se muestra directo.

typedef ContactCallback = void Function(Contact contact);

const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: AppDimens.gridItemMaxWidth,
  mainAxisExtent: AppDimens.gridItemHeight,
  crossAxisSpacing: AppDimens.spaceMd - 2,
  mainAxisSpacing: AppDimens.spaceMd - 2,
);

/// Decide qué elementos hacen pop: los del primer frame tras cargar o filtrar.
mixin _PopOnce<T extends StatefulWidget> on State<T> {
  final _seen = <int>{};
  bool _batchOpen = true;

  String get filterKey;

  void _openBatch() {
    _seen.clear();
    _batchOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _batchOpen = false);
  }

  bool shouldPop(int id) => _seen.add(id) && _batchOpen;

  @override
  void initState() {
    super.initState();
    _openBatch();
  }

  void checkFilterChange(String oldKey) {
    if (oldKey != filterKey) _openBatch();
  }
}

class ContactsGridSliver extends StatefulWidget {
  final List<Contact> contacts;
  final Set<int> favoriteIds;
  final int? selectedId;
  final String filterKey;
  final ContactCallback onTap;
  final ContactCallback onToggleFavorite;

  const ContactsGridSliver({
    super.key,
    required this.contacts,
    required this.favoriteIds,
    required this.selectedId,
    required this.filterKey,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  State<ContactsGridSliver> createState() => _ContactsGridSliverState();
}

class _ContactsGridSliverState extends State<ContactsGridSliver> with _PopOnce {
  @override
  String get filterKey => widget.filterKey;

  @override
  void didUpdateWidget(ContactsGridSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkFilterChange(oldWidget.filterKey);
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: _gridDelegate,
      itemCount: widget.contacts.length,
      itemBuilder: (context, index) {
        final contact = widget.contacts[index];
        return PopIn(
          key: ValueKey(contact.id),
          index: index,
          animate: shouldPop(contact.id),
          child: ContactCard(
            contact: contact,
            isFavorite: widget.favoriteIds.contains(contact.id),
            isSelected: contact.id == widget.selectedId,
            onTap: () => widget.onTap(contact),
            onToggleFavorite: () => widget.onToggleFavorite(contact),
          ),
        );
      },
    );
  }
}

class ContactsListSliver extends StatefulWidget {
  final List<Contact> contacts;
  final Set<int> favoriteIds;
  final String filterKey;
  final ContactCallback onTap;
  final ContactCallback onToggleFavorite;

  const ContactsListSliver({
    super.key,
    required this.contacts,
    required this.favoriteIds,
    required this.filterKey,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  State<ContactsListSliver> createState() => _ContactsListSliverState();
}

class _ContactsListSliverState extends State<ContactsListSliver> with _PopOnce {
  @override
  String get filterKey => widget.filterKey;

  @override
  void didUpdateWidget(ContactsListSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkFilterChange(oldWidget.filterKey);
  }

  @override
  Widget build(BuildContext context) {
    return _GlassSliver(
      sliver: SliverList.separated(
        itemCount: widget.contacts.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final contact = widget.contacts[index];
          return PopIn(
            key: ValueKey(contact.id),
            index: index,
            animate: shouldPop(contact.id),
            child: ContactTile(
              contact: contact,
              isFavorite: widget.favoriteIds.contains(contact.id),
              onTap: () => widget.onTap(contact),
              onToggleFavorite: () => widget.onToggleFavorite(contact),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton de la grilla: 6 tarjetas fantasma.
class GridSkeletonSliver extends StatelessWidget {
  const GridSkeletonSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: _gridDelegate,
      itemCount: 6,
      itemBuilder: (_, _) => const Shimmer(child: ContactCardSkeleton()),
    );
  }
}

/// Skeleton de la lista: 8 filas fantasma.
class ListSkeletonSliver extends StatelessWidget {
  const ListSkeletonSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return _GlassSliver(
      sliver: SliverList.builder(
        itemCount: 8,
        itemBuilder: (_, _) => const Shimmer(child: ContactTileSkeleton()),
      ),
    );
  }
}

/// Fondo de vidrio para una lista diferida (sin desenfoque: va dentro de un scroll).
class _GlassSliver extends StatelessWidget {
  final Widget sliver;

  const _GlassSliver({required this.sliver});

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: AppColors.glassStrong,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: GlassPanel.defaultShadow,
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.all(AppDimens.spaceSm),
        sliver: sliver,
      ),
    );
  }
}
