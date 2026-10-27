import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    runApp(const SetupRequiredApp());
    return;
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const CricScoreApp());
}

class SetupRequiredApp extends StatelessWidget {
  const SetupRequiredApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: Scaffold(
      body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.sports_cricket, size: 64, color: Color(0xFFB8F34A)),
          SizedBox(height: 16),
          Text('Welcome to CricScore', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Supabase configuration is missing.\nRun the app with SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.',
            textAlign: TextAlign.center),
        ]),
      )),
    ),
  );
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF101820),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB8F34A), brightness: Brightness.dark),
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF101820), centerTitle: false),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, fillColor: const Color(0xFF1C2933),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  ),
);

class CricScoreApp extends StatelessWidget {
  const CricScoreApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CricScore',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: supabase.auth.onAuthStateChange,
    builder: (context, snapshot) {
      if (supabase.auth.currentSession != null) return const HomeScreen();
      return const AuthScreen();
    },
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool signup = false, busy = false;
  String? error;
  Future<void> submit() async {
    setState(() { busy = true; error = null; });
    try {
      if (signup) {
        await supabase.auth.signUp(email: email.text.trim(), password: password.text);
      } else {
        await supabase.auth.signInWithPassword(email: email.text.trim(), password: password.text);
      }
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = e.toString());
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.sports_cricket, size: 72, color: Color(0xFFB8F34A)),
          const SizedBox(height: 12),
          const Text('Welcome to CricScore', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Made by NK', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB8F34A))),
          const SizedBox(height: 32),
          Text(signup ? 'Create your account' : 'Sign in to continue', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
          const SizedBox(height: 18),
          FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Please wait…' : (signup ? 'Create account' : 'Sign in'))),
          TextButton(onPressed: () => setState(() { signup = !signup; error = null; }),
            child: Text(signup ? 'Already registered? Sign in' : 'New here? Create an account')),
        ],
      )),
    ))),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final titles = const ['Matches', 'Teams', 'Tournaments'];
  @override
  Widget build(BuildContext context) {
    final pages = [const MatchesPage(), const TeamsPage(), const TournamentsPage()];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [const Icon(Icons.sports_cricket, color: Color(0xFFB8F34A)), const SizedBox(width: 10), Text('CricScore · ${titles[index]}')]),
        actions: [IconButton(tooltip: 'Sign out', onPressed: () => supabase.auth.signOut(), icon: const Icon(Icons.logout))],
      ),
      body: pages[index],
      floatingActionButton: index == 0
        ? FloatingActionButton.extended(onPressed: () => showHostMatch(context), icon: const Icon(Icons.add), label: const Text('Host match'))
        : index == 1
          ? FloatingActionButton.extended(onPressed: () => showCreateTeam(context), icon: const Icon(Icons.add), label: const Text('Create team'))
          : FloatingActionButton.extended(onPressed: () => showCreateTournament(context), icon: const Icon(Icons.add), label: const Text('Create tournament')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.scoreboard), label: 'Matches'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Teams'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Tournaments'),
        ],
      ),
    );
  }
}

Future<void> showMessage(BuildContext context, String message) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> showCreateTeam(BuildContext context) async {
  final name = TextEditingController();
  await showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Create team'),
    content: TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Team name')),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      FilledButton(onPressed: () async {
        final n = name.text.trim();
        if (n.isEmpty) return;
        try {
          await supabase.from('teams').insert({'owner_id': supabase.auth.currentUser!.id, 'name': n});
          if (ctx.mounted) Navigator.pop(ctx);
          await showMessage(context, 'Team created');
        } catch (e) { await showMessage(context, 'Could not create team: $e'); }
      }, child: const Text('Create')),
    ],
  ));
  name.dispose();
}

Future<void> showCreateTournament(BuildContext context) async {
  final name = TextEditingController();
  String format = 'T20';
  await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
    title: const Text('Create tournament'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Tournament name')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: format, items: ['T20','ODI','Test','Custom'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (v) => setState(() => format = v ?? 'T20'), decoration: const InputDecoration(labelText: 'Format')),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      FilledButton(onPressed: () async {
        if (name.text.trim().isEmpty) return;
        try {
          await supabase.from('tournaments').insert({'organizer_id': supabase.auth.currentUser!.id, 'name': name.text.trim(), 'format': format});
          if (ctx.mounted) Navigator.pop(ctx);
          await showMessage(context, 'Tournament created');
        } catch (e) { await showMessage(context, 'Could not create tournament: $e'); }
      }, child: const Text('Create')),
    ],
  )));
  name.dispose();
}

Future<void> showHostMatch(BuildContext context) async {
  final a = TextEditingController(), b = TextEditingController(), venue = TextEditingController();
  String format = 'T20'; int overs = 20;
  await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
    title: const Text('Host a match'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: a, decoration: const InputDecoration(labelText: 'Team A')),
      const SizedBox(height: 10),
      TextField(controller: b, decoration: const InputDecoration(labelText: 'Team B')),
      const SizedBox(height: 10),
      TextField(controller: venue, decoration: const InputDecoration(labelText: 'Venue (optional)')),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(value: format, items: ['T20','ODI','Test','Custom'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (v) => setState(() { format = v ?? 'T20'; overs = format == 'ODI' ? 50 : format == 'Test' ? 90 : 20; }), decoration: const InputDecoration(labelText: 'Format')),
      const SizedBox(height: 10),
      TextFormField(initialValue: '$overs', keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Overs per innings'), onChanged: (v) => overs = int.tryParse(v) ?? overs),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      FilledButton(onPressed: () async {
        if (a.text.trim().isEmpty || b.text.trim().isEmpty || a.text.trim() == b.text.trim()) {
          await showMessage(context, 'Enter two different team names'); return;
        }
        try {
          final row = await supabase.from('matches').insert({
            'host_id': supabase.auth.currentUser!.id, 'team_a_name': a.text.trim(), 'team_b_name': b.text.trim(),
            'format': format, 'overs_per_innings': overs.clamp(1,1000), 'venue': venue.text.trim().isEmpty ? null : venue.text.trim(),
            'status': 'LIVE', 'visibility': 'public',
          }).select().single();
          await supabase.from('innings').insert({
            'match_id': row['id'], 'innings_number': 1, 'batting_team_name': a.text.trim(),
            'bowling_team_name': b.text.trim(),
          });
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ScorePage(matchId: row['id'].toString())));
        } catch (e) { await showMessage(context, 'Could not host match: $e'); }
      }, child: const Text('Start match')),
    ],
  )));
  a.dispose(); b.dispose(); venue.dispose();
}

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Map<String,dynamic>>>(
    stream: supabase.from('teams').stream(primaryKey: ['id']).eq('owner_id', supabase.auth.currentUser!.id).order('created_at'),
    builder: (context, snap) {
      if (snap.hasError) return ErrorView(error: snap.error.toString());
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      if (snap.data!.isEmpty) return const EmptyState(icon: Icons.groups, title: 'No teams yet', subtitle: 'Create a team to get started.');
      return ListView(padding: const EdgeInsets.all(16), children: snap.data!.map((t) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.shield)), title: Text(t['name'] ?? 'Team'), subtitle: const Text('Your team')))).toList());
    },
  );
}

class TournamentsPage extends StatelessWidget {
  const TournamentsPage({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Map<String,dynamic>>>(
    stream: supabase.from('tournaments').stream(primaryKey: ['id']).eq('organizer_id', supabase.auth.currentUser!.id).order('created_at'),
    builder: (context, snap) {
      if (snap.hasError) return ErrorView(error: snap.error.toString());
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      if (snap.data!.isEmpty) return const EmptyState(icon: Icons.emoji_events, title: 'No tournaments yet', subtitle: 'Create a tournament and organize your teams.');
      return ListView(padding: const EdgeInsets.all(16), children: snap.data!.map((t) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.emoji_events)), title: Text(t['name'] ?? 'Tournament'), subtitle: Text('${t['format'] ?? 'T20'} · Tournament')))).toList());
    },
  );
}

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Map<String,dynamic>>>(
    stream: supabase.from('matches').stream(primaryKey: ['id']).eq('visibility', 'public').order('created_at', ascending: false),
    builder: (context, snap) {
      if (snap.hasError) return ErrorView(error: snap.error.toString());
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final rows = snap.data!;
      if (rows.isEmpty) return const EmptyState(icon: Icons.scoreboard, title: 'No public matches', subtitle: 'Host a match and it can appear here for viewers.');
      return ListView.separated(padding: const EdgeInsets.all(16), itemCount: rows.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (context, i) {
        final m = rows[i];
        return Card(child: ListTile(
          leading: Icon(m['status'] == 'LIVE' ? Icons.circle : Icons.sports_cricket, color: m['status'] == 'LIVE' ? Colors.redAccent : const Color(0xFFB8F34A)),
          title: Text('${m['team_a_name']} vs ${m['team_b_name']}'),
          subtitle: Text('${m['format']} · ${m['venue'] ?? 'Venue not set'} · ${m['status']}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScorePage(matchId: m['id'].toString(), viewerMode: m['host_id'] != supabase.auth.currentUser?.id))),
        ));
      });
    },
  );
}

class ScorePage extends StatefulWidget {
  final String matchId; final bool viewerMode;
  const ScorePage({super.key, required this.matchId, this.viewerMode = false});
  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  bool busy = false;
  String? message;
  Future<void> addBall(int runs, {bool wicket = false, String? extra, bool legal = true}) async {
    if (widget.viewerMode || busy) return;
    setState(() { busy = true; message = null; });
    try {
      final m = await supabase.from('matches').select().eq('id', widget.matchId).single();
      if (m['host_id'] != supabase.auth.currentUser!.id) throw Exception('Only the match host can score this match.');
      final inn = await supabase.from('innings').select().eq('match_id', widget.matchId).eq('innings_number', m['current_innings'] ?? 1).single();
      final existing = await supabase.from('deliveries').select('sequence_no').eq('match_id', widget.matchId).eq('innings_id', inn['id']).order('sequence_no', ascending: false).limit(1);
      final seq = existing.isEmpty ? 1 : (existing.first['sequence_no'] as int) + 1;
      final legalBalls = (inn['legal_balls'] as int? ?? 0) + (legal ? 1 : 0);
      final extras = extra == null ? 0 : 1;
      await supabase.from('deliveries').insert({
        'match_id': widget.matchId, 'innings_id': inn['id'], 'sequence_no': seq,
        'over_number': legalBalls ~/ 6, 'ball_in_over': legalBalls % 6,
        'batter_runs': runs, 'extra_type': extra, 'extra_runs': extras,
        'is_legal': legal, 'is_wicket': wicket, 'created_by': supabase.auth.currentUser!.id,
      });
      await supabase.from('innings').update({
        'runs': (inn['runs'] as int? ?? 0) + runs + extras,
        'wickets': ((inn['wickets'] as int? ?? 0) + (wicket ? 1 : 0)).clamp(0,10),
        'legal_balls': legalBalls,
      }).eq('id', inn['id']);
      if (runs == 4 || runs == 6 || wicket) {
        await supabase.from('scoring_events').insert({
          'match_id': widget.matchId, 'event_type': wicket ? 'WICKET' : (runs == 6 ? 'BOUNDARY_SIX' : 'BOUNDARY_FOUR'),
          'payload': {'runs': runs}, 'created_by': supabase.auth.currentUser!.id,
        });
      }
    } catch (e) { setState(() => message = 'Scoring failed: $e'); }
    finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Live score')),
    body: StreamBuilder<List<Map<String,dynamic>>>(
      stream: supabase.from('matches').stream(primaryKey: ['id']).eq('id', widget.matchId),
      builder: (context, matchSnap) {
        if (matchSnap.hasError) return ErrorView(error: matchSnap.error.toString());
        if (!matchSnap.hasData || matchSnap.data!.isEmpty) return const Center(child: CircularProgressIndicator());
        final m = matchSnap.data!.first;
        return StreamBuilder<List<Map<String,dynamic>>>(
          stream: supabase.from('innings').stream(primaryKey: ['id']).eq('match_id', widget.matchId).order('innings_number'),
          builder: (context, innSnap) {
            if (innSnap.hasError) return ErrorView(error: innSnap.error.toString());
            if (!innSnap.hasData) return const Center(child: CircularProgressIndicator());
            final inn = innSnap.data!.isEmpty ? <String,dynamic>{} : innSnap.data!.last;
            final balls = inn['legal_balls'] as int? ?? 0;
            final overText = '${balls ~/ 6}.${balls % 6}';
            return ListView(padding: const EdgeInsets.all(16), children: [
              Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1C2933), borderRadius: BorderRadius.circular(20)), child: Column(children: [
                Text('${m['team_a_name']}  vs  ${m['team_b_name']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text('${inn['runs'] ?? 0}/${inn['wickets'] ?? 0}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFFB8F34A))),
                Text('Overs $overText / ${m['overs_per_innings'] ?? 20}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                Text('${inn['batting_team_name'] ?? m['team_a_name']} batting', style: const TextStyle(color: Colors.white70)),
                Text('Status: ${m['status']}', style: const TextStyle(color: Colors.white70)),
              ])),
              const SizedBox(height: 20),
              if (!widget.viewerMode) ...[
                const Text('Record delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final r in [0,1,2,3,4,6])
                    FilledButton.tonal(onPressed: busy ? null : () => addBall(r), child: Text('$r run${r == 1 ? '' : 's'}')),
                  FilledButton.tonal(onPressed: busy ? null : () => addBall(0, wicket: true), child: const Text('Wicket')),
                  FilledButton.tonal(onPressed: busy ? null : () => addBall(0, extra: 'wide', legal: false), child: const Text('Wide +1')),
                  FilledButton.tonal(onPressed: busy ? null : () => addBall(0, extra: 'no_ball', legal: false), child: const Text('No-ball +1')),
                ]),
                const SizedBox(height: 8),
                const Text('MVP scorer: player selection, strike rotation, dismissal details, innings switching and score corrections are not implemented yet.', style: TextStyle(color: Colors.white60)),
              ] else const Text('Viewer mode · scores refresh from Supabase in real time.'),
              if (busy) const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
              if (message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(message!, style: const TextStyle(color: Colors.redAccent))),
              const SizedBox(height: 20),
              const Text('Recent deliveries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              StreamBuilder<List<Map<String,dynamic>>>(
                stream: supabase.from('deliveries').stream(primaryKey: ['id']).eq('match_id', widget.matchId).order('sequence_no', ascending: false),
                builder: (context, ds) {
                  if (!ds.hasData) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                  if (ds.data!.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('No deliveries yet.'));
                  return Column(children: ds.data!.take(12).map((d) => ListTile(
                    dense: true, leading: CircleAvatar(child: Text('${d['batter_runs'] ?? 0}')),
                    title: Text(d['is_wicket'] == true ? 'Wicket' : (d['extra_type'] == null ? 'Delivery' : '${d['extra_type']}')),
                    subtitle: Text('Ball #${d['sequence_no']}'),
                  )).toList());
                },
              ),
            ]);
          },
        );
      },
    ),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 60, color: const Color(0xFFB8F34A)), const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
    ]),
  ));
}

class ErrorView extends StatelessWidget {
  final String error;
  const ErrorView({super.key, required this.error});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
      const SizedBox(height: 12), const Text('Could not load data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
    ]),
  ));
}
