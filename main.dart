import 'package:flutter/material.dart';

void main() => runApp(const SmartTrafficApp());

class SmartTrafficApp extends StatelessWidget {
  const SmartTrafficApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Smart Traffic + AI Prediction',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB), brightness: Brightness.light),
          scaffoldBackgroundColor: const Color(0xFFF3F6FB),
          cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        ),
        home: const TrafficHome(),
      );
}

class TrafficSegment {
  final String name;
  final String location;
  final int speed;
  final int predictedSpeed;
  final int volume;
  final int queue;
  final int risk;
  final String action;
  const TrafficSegment(this.name, this.location, this.speed, this.predictedSpeed, this.volume, this.queue, this.risk, this.action);
  String get level => risk < 25 ? 'LOW' : risk < 50 ? 'MODERATE' : risk < 75 ? 'HIGH' : 'CRITICAL';
  Color get color => risk < 25 ? const Color(0xFF16A34A) : risk < 50 ? const Color(0xFFEAB308) : risk < 75 ? const Color(0xFFF97316) : const Color(0xFFDC2626);
}

const demoSegments = <TrafficSegment>[
  TrafficSegment('NH-16 City Center', 'Vijayawada', 18, 12, 920, 34, 68, 'Monitor congestion and suggest an alternate route.'),
  TrafficSegment('MG Road', 'Benz Circle', 32, 25, 640, 18, 43, 'Monitor density and signal waiting time.'),
  TrafficSegment('Ring Road', 'Enikepadu', 56, 48, 420, 7, 18, 'Continue monitoring; no immediate action.'),
  TrafficSegment('Airport Road', 'Gannavaram', 28, 18, 710, 22, 61, 'Review congestion and signal timing.'),
  TrafficSegment('Vijayawada Bypass', 'Outer Ring', 62, 58, 300, 4, 12, 'Traffic is flowing normally.'),
];

class TrafficHome extends StatefulWidget {
  const TrafficHome({super.key});
  @override
  State<TrafficHome> createState() => _TrafficHomeState();
}

class _TrafficHomeState extends State<TrafficHome> {
  int _index = 0;
  String _filter = 'ALL';
  final Set<String> _acknowledged = {};
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
      _mapPage(),
      _predictionPage(),
      _alertsPage(),
      _analyticsPage(),
    ];
    return Theme(
      data: _dark ? ThemeData.dark(useMaterial3: true) : Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 18,
          title: const Row(children: [Icon(Icons.traffic, color: Color(0xFF2563EB), size: 31), SizedBox(width: 10), Expanded(child: Text('Smart Traffic + AI Prediction', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)))]),
          actions: [IconButton(tooltip: 'Toggle theme', onPressed: () => setState(() => _dark = !_dark), icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode)), const SizedBox(width: 8)],
        ),
        body: SafeArea(child: IndexedStack(index: _index, children: pages)),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Live Map'),
            NavigationDestination(icon: Icon(Icons.psychology_outlined), selectedIcon: Icon(Icons.psychology), label: 'Prediction'),
            NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Analytics'),
          ],
        ),
      ),
    );
  }

  Widget _pageTitle(String title, String subtitle) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Colors.grey.shade600))]),
      );

  Widget _dashboard() => ListView(padding: const EdgeInsets.only(bottom: 20), children: [
        _pageTitle('Traffic overview', 'Monitor roads and predict congestion risk.'),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: _DemoBanner()),
        Padding(padding: const EdgeInsets.all(14), child: GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.45, children: [
          _metric('Road segments', '${demoSegments.length}', Icons.alt_route, const Color(0xFF2563EB)),
          _metric('Average speed', '${(demoSegments.map((e) => e.speed).reduce((a,b) => a+b) / demoSegments.length).round()} km/h', Icons.speed, const Color(0xFF0D9488)),
          _metric('High/Critical risk', '${demoSegments.where((e) => e.risk >= 50).length}', Icons.warning_amber, const Color(0xFFEA580C)),
          _metric('Incidents flagged', '2', Icons.crisis_alert, const Color(0xFFDC2626)),
        ])),
        _sectionHeader('Road risk summary'),
        ...demoSegments.map(_segmentCard),
        _sectionHeader('Next-hour outlook'),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _panel(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Congestion may increase on NH-16 City Center and Airport Road.', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 7), Text('Demo forecast based on the sample speed and traffic-volume values. Connect a traffic feed and validated model for real predictions.')]))),
      ]);

  Widget _mapPage() => ListView(padding: const EdgeInsets.only(bottom: 20), children: [
    _pageTitle('Live traffic map', 'Schematic road view · sample data'),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _DemoBanner()),
    Padding(padding: const EdgeInsets.all(16), child: Container(height: 270, decoration: BoxDecoration(color: const Color(0xFFE3EAF4), borderRadius: BorderRadius.circular(22)), clipBehavior: Clip.antiAlias, child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: RoadMapPainter())),
      for (int i = 0; i < demoSegments.length; i++) Positioned(left: [48.0, 220.0, 130.0, 260.0, 65.0][i], top: [48.0, 105.0, 190.0, 205.0, 135.0][i], child: _mapPin(demoSegments[i])),
      const Positioned(left: 14, bottom: 12, child: Text('Illustrative road layout — not GPS navigation', style: TextStyle(fontSize: 11, color: Color(0xFF475569)))),
    ]))),
    _sectionHeader('Risk legend'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final pair in [('LOW', const Color(0xFF16A34A)), ('MODERATE', const Color(0xFFEAB308)), ('HIGH', const Color(0xFFF97316)), ('CRITICAL', const Color(0xFFDC2626))]) Chip(avatar: CircleAvatar(backgroundColor: pair.$2, radius: 6), label: Text(pair.$1))])),
    _sectionHeader('Road segments'), ...demoSegments.map(_segmentCard),
  ]);

  Widget _mapPin(TrafficSegment s) => Tooltip(message: '${s.name}: ${s.level}', child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: s.color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: const Icon(Icons.directions_car, size: 17, color: Colors.white)));

  Widget _predictionPage() => ListView(padding: const EdgeInsets.only(bottom: 20), children: [
    _pageTitle('AI traffic prediction', 'Compare current speed with the demo forecast.'),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _DemoBanner()),
    ...demoSegments.map((s) => Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 0), child: _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))), _riskBadge(s)]),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: _smallStat('Current speed', '${s.speed} km/h')), Expanded(child: _smallStat('In 30 minutes', '${s.predictedSpeed} km/h')), Expanded(child: _smallStat('Risk score', '${s.risk}/100'))]),
      const SizedBox(height: 16),
      const Text('Speed outlook (illustrative)', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      _speedBars(s),
      const SizedBox(height: 10),
      Text('Recommendation: ${s.action}'),
      const SizedBox(height: 6),
      Text('Risk is a rule-based demo score, not a trained-model probability.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
    ])))),
  ]);

  Widget _alertsPage() {
    final alerts = demoSegments.where((s) => s.risk >= 40 && ( _filter == 'ALL' || s.level == _filter)).toList();
    return ListView(padding: const EdgeInsets.only(bottom: 20), children: [
      _pageTitle('Traffic alerts', 'Review and acknowledge elevated-risk roads.'),
      SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [for (final f in ['ALL', 'MODERATE', 'HIGH', 'CRITICAL']) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f))])),),
      if (alerts.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No alerts match this filter.')),
      ...alerts.map((s) => Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 0), child: _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.warning_amber_rounded, color: s.color), const SizedBox(width: 8), Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800))), _riskBadge(s)]), const SizedBox(height: 8), Text('Predicted speed falls from ${s.speed} to ${s.predictedSpeed} km/h.'), const SizedBox(height: 6), Text(s.action), const SizedBox(height: 10), Align(alignment: Alignment.centerRight, child: OutlinedButton.icon(onPressed: () => setState(() => _acknowledged.add(s.name)), icon: Icon(_acknowledged.contains(s.name) ? Icons.check_circle : Icons.check), label: Text(_acknowledged.contains(s.name) ? 'Acknowledged' : 'Acknowledge')))])))),
    ]);
  }

  Widget _analyticsPage() => ListView(padding: const EdgeInsets.only(bottom: 20), children: [
    _pageTitle('Traffic analytics', 'Compare sample road speeds and risk scores.'),
    Padding(padding: const EdgeInsets.all(16), child: _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Current vs predicted speed (km/h)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 18), for (final s in demoSegments) _comparisonBars(s)]))),
    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Risk distribution', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 16), for (final level in ['LOW', 'MODERATE', 'HIGH', 'CRITICAL']) _riskDistribution(level)]))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _panel(child: const Text('Evaluation note: model accuracy, precision, recall, F1-score, and latency must be calculated using a labelled test dataset. This demo does not claim measured ML performance.'))),
  ]);

  Widget _metric(String title, String value, IconData icon, Color color) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: color), Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)), Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))])));
  Widget _panel({required Widget child}) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.35))), child: child);
  Widget _sectionHeader(String text) => Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 8), child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)));
  Widget _riskBadge(TrafficSegment s) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: s.color.withOpacity(.13), borderRadius: BorderRadius.circular(20)), child: Text('${s.level} ${s.risk}', style: TextStyle(color: s.color, fontWeight: FontWeight.w800, fontSize: 11)));
  Widget _segmentCard(TrafficSegment s) => Padding(padding: const EdgeInsets.fromLTRB(16, 5, 16, 5), child: _panel(child: Column(children: [Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text(s.location, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))])), _riskBadge(s)]), const SizedBox(height: 12), Row(children: [Expanded(child: _smallStat('Speed', '${s.speed} km/h')), Expanded(child: _smallStat('Predicted', '${s.predictedSpeed} km/h')), Expanded(child: _smallStat('Volume', '${s.volume}/h'))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: s.risk / 100, minHeight: 7, color: s.color, backgroundColor: s.color.withOpacity(.12)),), const SizedBox(height: 8), Align(alignment: Alignment.centerLeft, child: Text(s.action, style: const TextStyle(fontSize: 12)))])));
  Widget _smallStat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))]);
  Widget _speedBars(TrafficSegment s) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [for (final item in [('Now', s.speed), ('15m', (s.speed + s.predictedSpeed) ~/ 2), ('30m', s.predictedSpeed), ('60m', (s.predictedSpeed * .9).round())]) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Column(children: [Text('${item.$2}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Container(height: (item.$2 * 1.4).clamp(12, 85).toDouble(), decoration: BoxDecoration(color: s.color.withOpacity(item.$1 == 'Now' ? .5 : .9), borderRadius: BorderRadius.circular(6))), const SizedBox(height: 5), Text(item.$1, style: const TextStyle(fontSize: 11))])))]);
  Widget _comparisonBars(TrafficSegment s) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), Row(children: [const SizedBox(width: 66, child: Text('Current', style: TextStyle(fontSize: 11))), Expanded(child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: s.speed / 70, child: Container(height: 12, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(5))))), const SizedBox(width: 35, child: Text('km/h', style: TextStyle(fontSize: 10)))]), const SizedBox(height: 4), Row(children: [const SizedBox(width: 66, child: Text('Predicted', style: TextStyle(fontSize: 11))), Expanded(child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: s.predictedSpeed / 70, child: Container(height: 12, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(5))))), SizedBox(width: 35, child: Text('${s.predictedSpeed}', style: const TextStyle(fontSize: 10)))]) ]));
  Widget _riskDistribution(String level) { final items = demoSegments.where((s) => s.level == level).length; final color = demoSegments.firstWhere((s) => s.level == level, orElse: () => demoSegments[0]).color; return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [SizedBox(width: 90, child: Text(level, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: items / demoSegments.length, minHeight: 10, color: color, backgroundColor: color.withOpacity(.12)))), const SizedBox(width: 10), Text('$items') ])); }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF7D6), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF2D36B))), child: const Row(children: [Icon(Icons.info_outline, color: Color(0xFF925F00)), SizedBox(width: 9), Expanded(child: Text('DEMO DATA — values are illustrative, not live traffic readings.', style: TextStyle(color: Color(0xFF795000), fontWeight: FontWeight.w700, fontSize: 12)))]));
}

class RoadMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = const Color(0xFFB7C4D5)..strokeWidth = 22..strokeCap = StrokeCap.round;
    final center = Paint()..color = Colors.white..strokeWidth = 2..strokeCap = StrokeCap.round;
    final paths = <Path>[
      Path()..moveTo(-10, size.height * .28)..cubicTo(size.width * .2, size.height * .18, size.width * .5, size.height * .55, size.width + 10, size.height * .32),
      Path()..moveTo(size.width * .25, -10)..cubicTo(size.width * .34, size.height * .3, size.width * .18, size.height * .6, size.width * .48, size.height + 10),
      Path()..moveTo(-10, size.height * .76)..cubicTo(size.width * .3, size.height * .6, size.width * .62, size.height * .9, size.width + 10, size.height * .72),
      Path()..moveTo(size.width * .72, -10)..cubicTo(size.width * .55, size.height * .3, size.width * .85, size.height * .55, size.width * .66, size.height + 10),
    ];
    for (final p in paths) { canvas.drawPath(p, road); canvas.drawPath(p, center); }
    final green = Paint()..color = const Color(0xFFBFE7C9);
    canvas.drawCircle(Offset(size.width * .85, size.height * .12), 25, green);
    canvas.drawCircle(Offset(size.width * .12, size.height * .52), 18, green);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
