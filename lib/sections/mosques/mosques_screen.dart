import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/services/location_service.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/sections/mosques/location_actions.dart';
import 'package:moschee_app/sections/mosques/radius_sheet.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_detail_screen.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/sections/mosques/mosque_list_tile.dart';
import 'package:moschee_app/sections/shell/tab_top_bar.dart';
import 'package:moschee_app/shared/fuzzy.dart';
import 'package:moschee_app/shared/widgets/app_empty_state.dart';
import 'package:moschee_app/shared/widgets/sliding_segments.dart';

enum _View { map, list }

/// Alle Moscheen: Karte (OpenStreetMap) oder Liste, Suche, Filter nach
/// Region und Umkreis.
class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  /// In Widget-Tests keine Kacheln aus dem Netz laden.
  static bool tilesEnabled = !Platform.environment.containsKey('FLUTTER_TEST');

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  final _data = DataRepository.instance;
  final _settings = SettingsService.instance;
  final _map = MapController();
  _View _view = _View.map;
  String _query = '';
  int? _region;
  bool _onlyRadius = false;
  Mosque? _selected;

  List<Mosque> get _filtered {
    final radius = _settings.radiusKm;
    var list = _data.mosques.where((m) {
      if (_region != null && m.region != _region) return false;
      if (_onlyRadius) {
        final d = _data.distanceOf(m);
        if (d != null && d > radius) return false;
      }
      return true;
    }).toList();
    if (_query.trim().isNotEmpty) {
      final scored = [
        for (final m in list)
          (m, fuzzyScore(_query, '${m.name} ${m.city} ${m.postalCode}')),
      ].where((e) => e.$2 > 0).toList()..sort((a, b) => b.$2.compareTo(a.$2));
      return [for (final e in scored) e.$1];
    }
    // Nach Nähe (Standort oder Hauptmoschee), sonst nach Name.
    if (_data.origin != null) {
      list.sort((a, b) => _data.distanceOf(a)!.compareTo(_data.distanceOf(b)!));
    }
    return list;
  }

  /// Karte auf die gefilterten Moscheen ausrichten.
  void _fit(List<Mosque> list) {
    if (_view != _View.map || list.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (list.length == 1) {
          _map.move(LatLng(list.first.lat, list.first.lng), 13);
        } else {
          _map.fitCamera(
            CameraFit.coordinates(
              coordinates: [for (final m in list) LatLng(m.lat, m.lng)],
              padding: const EdgeInsets.all(48),
              maxZoom: 13,
            ),
          );
        }
      } catch (_) {
        // Karte noch nicht aufgebaut.
      }
    });
  }

  void _setFilter(VoidCallback change) {
    setState(() {
      change();
      _selected = null;
    });
    _fit(_filtered);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: TabTopBar(
        leading: TextField(
          decoration: AppFormStyles.decoration(
            context,
            hintText: t.mosques_search_hint,
            prefixIcon: const Icon(AppIcons.search),
          ),
          onChanged: (v) => _setFilter(() => _query = v),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _data,
          _settings,
          LocationService.instance,
        ]),
        builder: (context, _) {
          if (_data.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = _filtered;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SlidingSegments<_View>(
                  options: [
                    (
                      value: _View.map,
                      label: t.mosques_view_map,
                      icon: AppIcons.map,
                    ),
                    (
                      value: _View.list,
                      label: t.mosques_view_list,
                      icon: AppIcons.list,
                    ),
                  ],
                  value: _view,
                  onChanged: (v) {
                    setState(() => _view = v);
                    _fit(list);
                  },
                ),
              ),
              _Filters(
                region: _region,
                onlyRadius: _onlyRadius,
                onRegion: (r) => _setFilter(() => _region = r),
                onRadius: _data.origin == null
                    ? null
                    : () async {
                        final km = await showRadiusSheet(
                          context,
                          allowOff: true,
                          off: !_onlyRadius,
                        );
                        if (km != null) _setFilter(() => _onlyRadius = km > 0);
                      },
              ),
              Expanded(
                child: list.isEmpty
                    ? AppEmptyState(
                        icon: AppIcons.mosque,
                        title: t.mosques_empty,
                        message: '',
                      )
                    : _view == _View.map
                    ? _MosqueMap(
                        controller: _map,
                        mosques: list,
                        selected: _selected,
                        showRadius: _onlyRadius,
                        onSelect: (m) => setState(() => _selected = m),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
                        itemCount: list.length,
                        itemBuilder: (context, i) => MosqueListTile(
                          mosque: list[i],
                          onTap: () => openMosque(context, list[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Filterzeile: Umkreis und Regionen (mit Farbpunkt wie auf der Karte).
class _Filters extends StatelessWidget {
  const _Filters({
    required this.region,
    required this.onlyRadius,
    required this.onRegion,
    required this.onRadius,
  });

  final int? region;
  final bool onlyRadius;
  final ValueChanged<int?> onRegion;
  final VoidCallback? onRadius;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (onRadius != null) ...[
            FilterChip(
              avatar: const Icon(AppIcons.radius, size: 16),
              label: Text(
                onlyRadius
                    ? t.mosques_only_radius(SettingsService.instance.radiusKm)
                    : t.mosques_radius,
              ),
              selected: onlyRadius,
              onSelected: (_) => onRadius!(),
            ),
            const SizedBox(width: 8),
          ],
          ChoiceChip(
            label: Text(t.mosques_all_regions),
            selected: region == null,
            onSelected: (_) => onRegion(null),
          ),
          for (final r in data.regions) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: CircleAvatar(
                radius: 6,
                backgroundColor: regionColor(r, theme),
              ),
              label: Text(t.region_label(r.number)),
              selected: region == r.number,
              onSelected: (_) => onRegion(region == r.number ? null : r.number),
            ),
          ],
        ],
      ),
    );
  }
}

class _MosqueMap extends StatelessWidget {
  const _MosqueMap({
    required this.controller,
    required this.mosques,
    required this.selected,
    required this.showRadius,
    required this.onSelect,
  });

  final MapController controller;
  final List<Mosque> mosques;
  final Mosque? selected;
  final bool showRadius;
  final ValueChanged<Mosque?> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    final origin = data.origin;
    final me = LocationService.instance.position;
    final accent = theme.colorScheme.primary;
    final points = [for (final m in mosques) LatLng(m.lat, m.lng)];
    // Start: Umgebung (Standort oder Hauptmoschee), nicht ganz Württemberg.
    final start = origin != null
        ? CameraFit.coordinates(
            coordinates: [
              LatLng(origin.lat, origin.lng),
              for (final m in mosques)
                if ((data.distanceOf(m) ?? 0) <=
                    SettingsService.instance.radiusKm)
                  LatLng(m.lat, m.lng),
            ],
            padding: const EdgeInsets.all(48),
            maxZoom: 12,
          )
        : points.length > 1
        ? CameraFit.coordinates(
            coordinates: points,
            padding: const EdgeInsets.all(48),
            maxZoom: 13,
          )
        : null;
    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCameraFit: start,
            initialCenter: points.first,
            initialZoom: 11,
            minZoom: 5,
            maxZoom: 18,
            onTap: (_, _) => onSelect(null),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            if (MosquesScreen.tilesEnabled)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.moscheeapp',
              ),
            if (showRadius && origin != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(origin.lat, origin.lng),
                    radius: SettingsService.instance.radiusKm * 1000.0,
                    useRadiusInMeter: true,
                    color: accent.withValues(alpha: 0.08),
                    borderColor: accent.withValues(alpha: 0.5),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final m in mosques)
                  Marker(
                    point: LatLng(m.lat, m.lng),
                    width: m == selected ? 40 : 28,
                    height: m == selected ? 40 : 28,
                    child: GestureDetector(
                      onTap: () => onSelect(m),
                      child: _Pin(
                        color: regionColor(data.region(m.region), theme),
                        mine: data.isMine(m.id),
                      ),
                    ),
                  ),
              ],
            ),
            if (me != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(me.lat, me.lng),
                    width: 22,
                    height: 22,
                    child: const _MyPosition(),
                  ),
                ],
              ),
            // Pflichtangabe für OpenStreetMap, eingeklappt als „i“.
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution(
                  t.map_attribution,
                  prependCopyright: false,
                ),
              ],
            ),
          ],
        ),
        // Eigener Standort: einschalten bzw. dorthin springen.
        Positioned(
          right: 12,
          bottom: selected != null ? 104 : 24,
          child: FloatingActionButton.small(
            heroTag: 'map-locate',
            tooltip: AppLocalizations.of(context)!.location_mine,
            onPressed: () async {
              if (LocationService.instance.position == null &&
                  !await enableLocation(context)) {
                return;
              }
              final p = LocationService.instance.position;
              if (p != null) controller.move(LatLng(p.lat, p.lng), 12);
            },
            child: const Icon(AppIcons.myLocation),
          ),
        ),
        if (selected != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 28,
            child: Material(
              color: theme.colorScheme.surface,
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: MosqueListTile(
                mosque: selected!,
                onTap: () => openMosque(context, selected!),
                trailing: const Icon(AppIcons.chevron),
              ),
            ),
          ),
      ],
    );
  }
}

/// Eigener Standort: blauer Punkt mit weißem Rand und Hof.
class _MyPosition extends StatelessWidget {
  const _MyPosition();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.myLocation,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [
        BoxShadow(
          color: AppColors.myLocation.withValues(alpha: 0.35),
          blurRadius: 0,
          spreadRadius: 8,
        ),
      ],
    ),
  );
}

class _Pin extends StatelessWidget {
  const _Pin({required this.color, required this.mine});

  final Color color;
  final bool mine;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: mine ? 3 : 2),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
      ],
    ),
    child: FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          mine ? AppIcons.star : AppIcons.mosque,
          color: Colors.white,
        ),
      ),
    ),
  );
}
