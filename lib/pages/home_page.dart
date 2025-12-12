import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../services/auth_service.dart';
import '../services/quiz_service.dart';
import 'quiz_page.dart';
import 'shop_page.dart';
import '../theme.dart';
import 'sign_in_page.dart';
import 'tabs/play_tab.dart';
import 'tabs/leaderboard_tab.dart';
import 'tabs/shop_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AuthService auth = AuthService();
  final QuizService quizService = QuizService();

  List<String> unlocked = ['easy'];
  String selectedLevel = 'easy';
  bool loading = true;
  final levels = ['easy', 'medium', 'hard'];

  late ConfettiController confettiController;
  String username = 'Guest';
  String? equippedBackgroundUrl;
  int coins = 0;

  int activeIndex = 0;
  late PageController _pageController;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _pageController = PageController();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.98, end: 1.03).animate(
        CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut));

    _loadUsername();
    _loadUnlocked();
    _loadCoins();
  }

  @override
  void dispose() {
    confettiController.dispose();
    _pageController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> _loadCoins() async {
    final c = await auth.fetchCoins();
    if (!mounted) return;
    setState(() => coins = c);
  }

  Future<void> _loadUsername() async {
    final userId = auth.currentUser?.id;
    if (userId == null) return;
    final res = await auth.supabase
        .from('users')
        .select('username')
        .eq('id', userId)
        .maybeSingle();
    if (!mounted) return;
    setState(() {
      username = res?['username'] ?? 'Guest';
    });
  }

  Future<void> _loadUnlocked() async {
    setState(() => loading = true);
    final u = await auth.fetchUnlockedLevels();
    if (!mounted) return;
    setState(() {
      unlocked = u;
      if (!unlocked.contains(selectedLevel)) selectedLevel = unlocked.first;
      loading = false;
    });
  }

  void updateCoins(int newCoins) {
    setState(() => coins = newCoins);
  }

  void _onNavTap(int idx) {
    setState(() => activeIndex = idx);
    _pageController.animateToPage(idx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const ParticleBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _glassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor:
                                    AppTheme.primary.withOpacity(0.12),
                                child: Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : 'G',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Hello, $username',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.95))),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(Icons.monetization_on,
                                      color: Colors.green, size: 18),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$coins',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 8.0,
                                          color: Colors.white.withOpacity(0.8),
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      await auth.signOut();
                                      if (!mounted) return;
                                      Navigator.of(context)
                                          .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SignInPage()),
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      'Sign out',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (idx) => setState(() => activeIndex = idx),
                      children: [
                        PlayTab(
                          loading: loading,
                          levels: levels,
                          selectedLevel: selectedLevel,
                          unlocked: unlocked,
                          confettiController: confettiController,
                          breatheAnim: _breatheAnim,
                          onLevelSelected: (lvl) =>
                              setState(() => selectedLevel = lvl),
                          onQuizEnd: () async {
                            await _loadUnlocked();
                            await _loadCoins();
                          },
                        ),
                        LeaderboardTabWidget(
                          auth: auth,
                          quizService: quizService,
                          selectedLevel: selectedLevel,
                        ),
                        ShopTab(
                          coins: coins,
                          onCoinsChanged: updateCoins,
                          onEquipBackground: (url) =>
                              setState(() => equippedBackgroundUrl = url),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 78),
                ],
              ),
            ),
          ),
          Positioned(
              top: 10,
              right: 8,
              child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: [AppTheme.primary, AppTheme.accent, Colors.amber])),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Center(
              child: _FloatingGlassNav(
                activeIndex: activeIndex,
                onTap: _onNavTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

class _FloatingGlassNav extends StatelessWidget {
  final int activeIndex;
  final void Function(int) onTap;
  const _FloatingGlassNav({required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 22,
              offset: const Offset(0, 12))
        ],
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
              icon: Icons.play_circle_fill,
              label: 'Play',
              selected: activeIndex == 0,
              onTap: () => onTap(0)),
          _NavItem(
              icon: Icons.leaderboard,
              label: 'Leaders',
              selected: activeIndex == 1,
              onTap: () => onTap(1)),
          _CenterBlob(onPressed: () => onTap(2), active: activeIndex == 2),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: selected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14))
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: selected ? AppTheme.primary : Colors.white70),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: selected ? AppTheme.primary : Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _CenterBlob extends StatefulWidget {
  final VoidCallback onPressed;
  final bool active;
  const _CenterBlob({required this.onPressed, required this.active});

  @override
  State<_CenterBlob> createState() => _CenterBlobState();
}

class _CenterBlobState extends State<_CenterBlob> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.08)
            .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primary.withOpacity(0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Icon(Icons.storefront, color: Colors.white),
        ),
      ),
    );
  }
}

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});
  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Node> nodes = [];
  final Random rng = Random();
  static const int nodeCount = 30;
  static const double maxDist = 110;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _ctrl.addListener(() {
      for (final n in nodes) {
        n.pos += n.vel;
        if (n.pos.dx < 0 || n.pos.dx > n.screenSize.width) {
          n.vel = Offset(-n.vel.dx, n.vel.dy);
        }
        if (n.pos.dy < 0 || n.pos.dy > n.screenSize.height) {
          n.vel = Offset(n.vel.dx, -n.vel.dy);
        }
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _ensureNodes(Size s) {
    if (nodes.isNotEmpty && nodes.first.screenSize == s) return;
    nodes.clear();
    for (var i = 0; i < nodeCount; i++) {
      nodes.add(_Node(
        pos: Offset(rng.nextDouble() * s.width, rng.nextDouble() * s.height),
        vel: Offset((rng.nextDouble() - 0.5) * 0.6, (rng.nextDouble() - 0.5) * 0.6),
        screenSize: s,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final s = Size(constraints.maxWidth, constraints.maxHeight);
      _ensureNodes(s);
      return CustomPaint(
        size: s,
        painter: _ParticlePainter(nodes: nodes, maxDist: maxDist),
      );
    });
  }
}

class _Node {
  Offset pos;
  Offset vel;
  final Size screenSize;
  _Node({required this.pos, required this.vel, required this.screenSize});
}

class _ParticlePainter extends CustomPainter {
  final List<_Node> nodes;
  final double maxDist;
  _ParticlePainter({required this.nodes, required this.maxDist});

  final Paint dotPaint = Paint()..color = Colors.white.withOpacity(0.85);
  final Paint linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.9;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final grad = LinearGradient(
        colors: [
          const Color(0xFF081226).withOpacity(0.45),
          const Color(0xFF061222).withOpacity(0.45)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter);
    canvas.drawRect(rect, Paint()..shader = grad.createShader(rect));

    for (int i = 0; i < nodes.length; i++) {
      final a = nodes[i].pos;
      canvas.drawCircle(a, 2.3, dotPaint);
      for (int j = i + 1; j < nodes.length; j++) {
        final b = nodes[j].pos;
        final d = (a - b).distance;
        if (d < maxDist) {
          final alpha = (1.0 - (d / maxDist)) * 0.55;
          linePaint.color = Colors.white.withOpacity(alpha * 0.9);
          canvas.drawLine(a, b, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
