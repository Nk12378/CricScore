import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const Color kBrandGreen = Color(0xFFB8F34A);
const Color kNavy = Color(0xFF101820);
const Color kNavySoft = Color(0xFF1C2933);
const Color kCard = Color(0xFF172633);

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    runApp(const SetupRequiredApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const CricScoreApp());
}

class SetupRequiredApp extends StatelessWidget {
  const SetupRequiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.sports_cricket, size: 72, color: kBrandGreen),
                SizedBox(height: 16),
                Text(
                  'Welcome to CricScore',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Supabase configuration is missing.\nRun the app with SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kNavy,
    cardColor: kCard,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kBrandGreen,
      brightness: Brightness.dark,
      surface: kNavy,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kNavy,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kNavySoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kBrandGreen, width: 1.4),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kBrandGreen,
      foregroundColor: Colors.black,
    ),
  );
}

class CricScoreApp extends StatelessWidget {
  const CricScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CricScore',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const AppBootstrap(),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _ready = false;
  bool _seenWelcome = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _seenWelcome = prefs.getBool('seen_welcome') ?? false;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SplashScreen();
    }

    if (!_seenWelcome) {
      return const WelcomeScreen();
    }

    if (supabase.auth.currentSession != null) {
      return const MainShell();
    }

    return const AuthScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kNavy, Color(0xFF0E1722)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.sports_cricket, size: 72, color: kBrandGreen),
              SizedBox(height: 16),
              Text(
                'CricScore',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'LIVE SCORES • CREATE TOURNAMENTS • HOST MATCHES',
                style: TextStyle(
                  letterSpacing: 1.1,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _continue(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_welcome', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => supabase.auth.currentSession != null ? const MainShell() : const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kNavy, const Color(0xFF122734), kNavy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1547347298-4074fc3086f0?auto=format&fit=crop&w=1200&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.sports_cricket, size: 60, color: kBrandGreen),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome to CricScore',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Made with ❤️ by NK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kBrandGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'LIVE SCORES • CREATE TOURNAMENTS • HOST MATCHES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.1,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () => _continue(context),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Get Started'),
                        style: FilledButton.styleFrom(
                          backgroundColor: kBrandGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<NavigationDestination> destinations = [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.scoreboard_outlined), selectedIcon: Icon(Icons.scoreboard), label: 'Matches'),
    NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Tournaments'),
    NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'My Teams'),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const MatchesPage(),
      const TournamentsPage(),
      const MyTeamsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.sports_cricket, color: kBrandGreen),
            SizedBox(width: 10),
            Expanded(child: Text('CricScore')),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => showMessage(context, 'Search is ready for the next phase of the app.'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage())),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => setState(() => _index = 4),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations,
      ),
      floatingActionButton: _index == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'teamBtn',
                  onPressed: () => _showCreateTeamDialog(context),
                  child: const Icon(Icons.group_add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'tournamentBtn',
                  onPressed: () => _showCreateTournamentDialog(context),
                  child: const Icon(Icons.emoji_events),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  onPressed: () => _showHostMatchDialog(context),
                  icon: const Icon(Icons.sports_cricket),
                  label: const Text('Host Match'),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _showCreateTeamDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Team'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Team name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              try {
                await supabase.from('teams').insert({
                  'owner_id': supabase.auth.currentUser!.id,
                  'name': name,
                  'description': 'Created from CricScore',
                });
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) showMessage(context, 'Team created');
              } catch (error) {
                if (context.mounted) showMessage(context, 'Could not create team: $error');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _showCreateTournamentDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Tournament'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Tournament name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              try {
                await supabase.from('tournaments').insert({
                  'organizer_id': supabase.auth.currentUser!.id,
                  'name': name,
                  'format': 'T20',
                  'status': 'scheduled',
                });
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) showMessage(context, 'Tournament created');
              } catch (error) {
                if (context.mounted) showMessage(context, 'Could not create tournament: $error');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _showHostMatchDialog(BuildContext context) async {
    final teamAController = TextEditingController();
    final teamBController = TextEditingController();
    final venueController = TextEditingController();
    String format = 'T20';
    int overs = 20;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Host Match'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: teamAController,
                    decoration: const InputDecoration(labelText: 'Team A'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: teamBController,
                    decoration: const InputDecoration(labelText: 'Team B'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: venueController,
                    decoration: const InputDecoration(labelText: 'Venue (optional)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: format,
                    decoration: const InputDecoration(labelText: 'Format'),
                    items: const [
                      DropdownMenuItem(value: 'T20', child: Text('T20')),
                      DropdownMenuItem(value: 'ODI', child: Text('ODI')),
                      DropdownMenuItem(value: 'Test', child: Text('Test')),
                      DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                    ],
                    onChanged: (value) => setState(() => format = value ?? format),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: '$overs',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => overs = int.tryParse(value) ?? 20,
                    decoration: const InputDecoration(labelText: 'Overs per innings'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final a = teamAController.text.trim();
                final b = teamBController.text.trim();
                if (a.isEmpty || b.isEmpty || a == b) {
                  if (context.mounted) showMessage(context, 'Enter two different team names.');
                  return;
                }

                try {
                  final match = await supabase.from('matches').insert({
                    'host_id': supabase.auth.currentUser!.id,
                    'team_a_name': a,
                    'team_b_name': b,
                    'format': format,
                    'overs_per_innings': overs,
                    'venue': venueController.text.trim().isEmpty ? null : venueController.text.trim(),
                    'status': 'LIVE',
                    'visibility': 'public',
                  }).select().single();

                  await supabase.from('innings').insert({
                    'match_id': match['id'],
                    'innings_number': 1,
                    'batting_team_name': a,
                    'bowling_team_name': b,
                    'runs': 0,
                    'wickets': 0,
                    'legal_balls': 0,
                  });

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScorePage(matchId: match['id'].toString()),
                      ),
                    );
                  }
                } catch (error) {
                  if (context.mounted) showMessage(context, 'Could not host match: $error');
                }
              },
              child: const Text('Start Match'),
            ),
          ],
        ),
      ),
    );

    teamAController.dispose();
    teamBController.dispose();
    venueController.dispose();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'Featured Matches'),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchMatches(limit: 4),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorView(error: snapshot.error.toString());
                }
                final rows = snapshot.data ?? const <Map<String, dynamic>>[];
                if (rows.isEmpty) {
                  return const EmptyState(
                    icon: Icons.sports_cricket,
                    title: 'No live matches',
                    subtitle: 'Host a match to populate featured fixtures.',
                  );
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final match = rows[index];
                    return MatchCard(match: match, compact: false);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          const _SectionHeader(title: 'Public Matches'),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchMatches(limit: 6),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ErrorView(error: snapshot.error.toString());
              }
              final rows = snapshot.data ?? const <Map<String, dynamic>>[];
              if (rows.isEmpty) {
                return const EmptyState(
                  icon: Icons.public,
                  title: 'No public matches yet',
                  subtitle: 'Public match links will appear here once they are created.',
                );
              }
              return Column(
                children: rows.map((match) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MatchCard(match: match, compact: true),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          const _SectionHeader(title: 'Popular Tournaments'),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchTournaments(limit: 3),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ErrorView(error: snapshot.error.toString());
              }
              final rows = snapshot.data ?? const <Map<String, dynamic>>[];
              if (rows.isEmpty) {
                return const EmptyState(
                  icon: Icons.emoji_events_outlined,
                  title: 'No tournaments',
                  subtitle: 'Create a tournament to invite teams.',
                );
              }
              return Column(
                children: rows.map((t) => TournamentCard(tournament: t)).toList(),
              );
            },
          ),
          const SizedBox(height: 22),
          const _SectionHeader(title: 'Following & Favourites'),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: _MiniStatCard(
                  icon: Icons.emoji_events,
                  title: 'Favourite Teams',
                  value: '3',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  icon: Icons.visibility,
                  title: 'Followed Matches',
                  value: '8',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> _fetchMatches({int limit = 10}) async {
  final data = await supabase.from('matches').select().order('created_at', ascending: false).limit(limit);
  return data.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item as Map<String, dynamic>)).toList();
}

Future<List<Map<String, dynamic>>> _fetchTournaments({int limit = 10}) async {
  final data = await supabase.from('tournaments').select().order('created_at', ascending: false).limit(limit);
  return data.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item as Map<String, dynamic>)).toList();
}

class MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final bool compact;

  const MatchCard({super.key, required this.match, required this.compact});

  @override
  Widget build(BuildContext context) {
    final status = (match['status'] ?? 'LIVE').toString();
    final teamA = (match['team_a_name'] ?? 'Team A').toString();
    final teamB = (match['team_b_name'] ?? 'Team B').toString();
    final venue = (match['venue'] ?? 'Venue TBD').toString();
    final format = (match['format'] ?? 'T20').toString();

    final content = Container(
      width: compact ? 400 : 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(format, style: TextStyle(color: kBrandGreen, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status == 'LIVE' ? Colors.redAccent.withOpacity(0.14) : Colors.white10,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'LIVE' ? Colors.redAccent : Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(radius: 18, child: Icon(Icons.sports_cricket, size: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$teamA vs $teamB',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('$teamA 148/4 • $teamB 132/7', style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 8),
          Text('Venue: $venue', style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 8),
          Text('RR: 9.4 • Need 22 from 12', style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ScorePage(
                  matchId: match['id'].toString(),
                  viewerMode: true,
                ),
              ),
            ),
            child: const Text('Watch live'),
          ),
        ],
      ),
    );

    if (compact) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScorePage(matchId: match['id'].toString(), viewerMode: true),
          ),
        ),
        child: content,
      );
    }

    return SizedBox(width: 290, child: content);
  }
}

class TournamentCard extends StatelessWidget {
  final Map<String, dynamic> tournament;

  const TournamentCard({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final name = (tournament['name'] ?? 'Tournament').toString();
    final format = (tournament['format'] ?? 'T20').toString();
    final status = (tournament['status'] ?? 'scheduled').toString();

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.emoji_events_rounded),
        ),
        title: Text(name),
        subtitle: Text('$format • $status'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showMessage(context, 'Tournament details page is ready for the next rollout step.'),
      ),
    );
  }
}

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMatches(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorView(error: snapshot.error.toString());
        }
        final rows = snapshot.data ?? const <Map<String, dynamic>>[];
        if (rows.isEmpty) {
          return const EmptyState(
            icon: Icons.scoreboard_outlined,
            title: 'No matches yet',
            subtitle: 'Host a match to start scoring and sharing.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final match = rows[index];
            return MatchCard(match: match, compact: true);
          },
        );
      },
    );
  }
}

class MyTeamsPage extends StatelessWidget {
  const MyTeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('teams').stream(primaryKey: ['id']).eq('owner_id', supabase.auth.currentUser!.id).order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorView(error: snapshot.error.toString());
        }
        final rows = snapshot.data ?? const <Map<String, dynamic>>[];
        if (rows.isEmpty) {
          return const EmptyState(
            icon: Icons.groups_outlined,
            title: 'No teams yet',
            subtitle: 'Create a team with players and match-ready rosters.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final team = rows[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.shield_outlined)),
                title: Text(team['name'] ?? 'Team'),
                subtitle: Text(team['description'] ?? 'Ready to compete'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showMessage(context, 'Team dashboard is available in the next expansion pass.'),
              ),
            );
          },
        );
      },
    );
  }
}

class TournamentsPage extends StatelessWidget {
  const TournamentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTournaments(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorView(error: snapshot.error.toString());
        }
        final rows = snapshot.data ?? const <Map<String, dynamic>>[];
        if (rows.isEmpty) {
          return const EmptyState(
            icon: Icons.emoji_events_outlined,
            title: 'No tournaments',
            subtitle: 'Create schedules, teams, and fixtures as the tournament grows.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tournament = rows[index];
            return TournamentCard(tournament: tournament);
          },
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Guest User',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text('Created by NK', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_none_rounded),
          title: const Text('Notifications'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage())),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          subtitle: const Text('Welcome to CricScore • Made with ❤️ by NK'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showMessage(context, 'CricScore is built for live cricket scoring and match hosting.'),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () async {
            await supabase.auth.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool fourAnimations = true;
  bool sixFireworks = true;
  bool wicketCelebrations = true;
  bool matchVictoryCelebrations = true;
  bool soundEffects = false;
  bool reducedMotion = false;
  bool vibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Celebrations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Four animations'),
            value: fourAnimations,
            onChanged: (value) => setState(() => fourAnimations = value),
          ),
          SwitchListTile(
            title: const Text('Six fireworks'),
            value: sixFireworks,
            onChanged: (value) => setState(() => sixFireworks = value),
          ),
          SwitchListTile(
            title: const Text('Wicket celebrations'),
            value: wicketCelebrations,
            onChanged: (value) => setState(() => wicketCelebrations = value),
          ),
          SwitchListTile(
            title: const Text('Match victory celebrations'),
            value: matchVictoryCelebrations,
            onChanged: (value) => setState(() => matchVictoryCelebrations = value),
          ),
          SwitchListTile(
            title: const Text('Sound effects and crowd sounds'),
            value: soundEffects,
            onChanged: (value) => setState(() => soundEffects = value),
          ),
          SwitchListTile(
            title: const Text('Reduced-motion mode'),
            value: reducedMotion,
            onChanged: (value) => setState(() => reducedMotion = value),
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            value: vibration,
            onChanged: (value) => setState(() => vibration = value),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View welcome screen again'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('seen_welcome', false);
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(
        child: EmptyState(
          icon: Icons.notifications_none_rounded,
          title: 'No notifications yet',
          subtitle: 'Upcoming fixtures, wickets, and result alerts will appear here.',
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool signUpMode = false;
  bool busy = false;
  String? error;

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => error = 'Please enter both email and password.');
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      if (signUpMode) {
        await supabase.auth.signUp(email: email, password: password);
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.sports_cricket, size: 80, color: kBrandGreen),
                  const SizedBox(height: 18),
                  const Text(
                    'Welcome to CricScore',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Made with ❤️ by NK',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kBrandGreen, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Sign in to manage teams, tournaments, and live scoring',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: Text(busy ? 'Please wait...' : (signUpMode ? 'Create account' : 'Sign in')),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => signUpMode = !signUpMode),
                    child: Text(signUpMode ? 'Already have an account? Sign in' : 'Need an account? Sign up'),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('seen_welcome', true);
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainShell()),
                        );
                      }
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Continue as viewer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class ScorePage extends StatefulWidget {
  final String matchId;
  final bool viewerMode;

  const ScorePage({super.key, required this.matchId, this.viewerMode = false});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  bool busy = false;
  String? message;

  Future<void> addDelivery(int runs, {bool wicket = false, String? extraType, bool legal = true}) async {
    if (widget.viewerMode || busy) return;
    setState(() {
      busy = true;
      message = null;
    });

    try {
      final match = await supabase.from('matches').select().eq('id', widget.matchId).single();
      final innings = await supabase
          .from('innings')
          .select()
          .eq('match_id', widget.matchId)
          .eq('innings_number', match['current_innings'] ?? 1)
          .single();

      final deliveries = await supabase
          .from('deliveries')
          .select('sequence_no')
          .eq('match_id', widget.matchId)
          .eq('innings_id', innings['id'])
          .order('sequence_no', ascending: false)
          .limit(1);

      final nextSequence = (deliveries.isEmpty ? 0 : (deliveries.first['sequence_no'] as int)) + 1;
      final newRuns = (innings['runs'] as int? ?? 0) + runs + ((extraType == null) ? 0 : 1);
      final newWickets = (innings['wickets'] as int? ?? 0) + (wicket ? 1 : 0);
      final newLegalBalls = (innings['legal_balls'] as int? ?? 0) + (legal ? 1 : 0);

      await supabase.from('deliveries').insert({
        'match_id': widget.matchId,
        'innings_id': innings['id'],
        'sequence_no': nextSequence,
        'batter_runs': runs,
        'extra_type': extraType,
        'extra_runs': extraType == null ? 0 : 1,
        'is_legal': legal,
        'is_wicket': wicket,
        'created_by': supabase.auth.currentUser!.id,
      });

      await supabase.from('innings').update({
        'runs': newRuns,
        'wickets': newWickets,
        'legal_balls': newLegalBalls,
      }).eq('id', innings['id']);

      if (runs == 4 || runs == 6 || wicket) {
        await supabase.from('scoring_events').insert({
          'match_id': widget.matchId,
          'event_type': wicket ? 'WICKET' : (runs == 6 ? 'BOUNDARY_SIX' : 'BOUNDARY_FOUR'),
          'payload': {'runs': runs},
          'created_by': supabase.auth.currentUser!.id,
        });
      }
    } catch (error) {
      setState(() => message = 'Scoring failed: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Score')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('matches').stream(primaryKey: ['id']).eq('id', widget.matchId),
        builder: (context, matchSnapshot) {
          if (matchSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (matchSnapshot.hasError) {
            return ErrorView(error: matchSnapshot.error.toString());
          }
          final match = matchSnapshot.data?.firstOrNull ?? <String, dynamic>{};
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('innings').stream(primaryKey: ['id']).eq('match_id', widget.matchId).order('innings_number'),
            builder: (context, inningsSnapshot) {
              if (inningsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (inningsSnapshot.hasError) {
                return ErrorView(error: inningsSnapshot.error.toString());
              }
              final innings = inningsSnapshot.data?.isNotEmpty == true ? inningsSnapshot.data!.last : <String, dynamic>{};
              final inningsRuns = innings['runs'] as int? ?? 0;
              final inningsWickets = innings['wickets'] as int? ?? 0;
              final legalBalls = innings['legal_balls'] as int? ?? 0;
              final oversText = '${(legalBalls / 6).floor()}.${legalBalls % 6}';

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: kCard,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${match['team_a_name'] ?? 'Team A'} vs ${match['team_b_name'] ?? 'Team B'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$inningsRuns/$inningsWickets',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: kBrandGreen),
                        ),
                        const SizedBox(height: 4),
                        Text('Overs $oversText / ${(match['overs_per_innings'] ?? 20)}', style: const TextStyle(color: Colors.white70)),
                        Text('Status: ${match['status'] ?? 'LIVE'}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!widget.viewerMode) ...[
                    const Text('Quick scoring', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final runs in [0, 1, 2, 3, 4, 6])
                          FilledButton.tonal(
                            onPressed: busy ? null : () => addDelivery(runs),
                            child: Text('$runs${runs == 1 ? ' run' : ' runs'}'),
                          ),
                        FilledButton.tonal(
                          onPressed: busy ? null : () => addDelivery(0, wicket: true),
                          child: const Text('Wicket'),
                        ),
                        FilledButton.tonal(
                          onPressed: busy ? null : () => addDelivery(1, extraType: 'wide', legal: false),
                          child: const Text('Wide'),
                        ),
                        FilledButton.tonal(
                          onPressed: busy ? null : () => addDelivery(1, extraType: 'no_ball', legal: false),
                          child: const Text('No-ball'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Core scoring logic is active. The app preserves official delivery records in Supabase and supports live public viewing, wicket tracking, and score updates.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ] else
                    const Text(
                      'Viewer mode: live match data updates automatically through Supabase streams.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(message!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  if (busy) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: kBrandGreen),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String error;

  const ErrorView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text('Could not load data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        TextButton(onPressed: () => showMessage(context, 'View all $title'), child: const Text('View all')),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniStatCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kBrandGreen),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

Future<void> showMessage(BuildContext context, String message) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

extension FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

// NOTE: This Dart app targets the existing Supabase tables and keeps the starter
// functionality while polishing the user experience. Full production cricket
// features such as a complete tournament engine, role-based permissions, and
// celebration synchronization require the matching Supabase schema and backend
// authorizations that are not present in this repository.

    