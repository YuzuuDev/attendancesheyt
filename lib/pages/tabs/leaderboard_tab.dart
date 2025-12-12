import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/auth_service.dart';
import '../../services/quiz_service.dart';
import 'utils.dart';

class LeaderboardTabWidget extends StatefulWidget {
  final AuthService auth;
  final QuizService quizService;
  final String selectedLevel;

  const LeaderboardTabWidget({
    super.key,
    required this.auth,
    required this.quizService,
    required this.selectedLevel,
  });

  @override
  State<LeaderboardTabWidget> createState() => _LeaderboardTabWidgetState();
}

class _LeaderboardTabWidgetState extends State<LeaderboardTabWidget> {
  int leaderboardSubTabIndex = 0;
  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  List<Map<String, dynamic>> allLeaderboard = [];
  List<Map<String, dynamic>> paginatedLeaderboard = [];

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  int getTrueRank({
    required Map<String, dynamic> user,
    required List<Map<String, dynamic>> fullList,
    required bool isFastestTab,
  }) {
    fullList.sort((a, b) {
      if (isFastestTab) {
        return ((a['time_ms'] ?? double.infinity) as num)
            .compareTo((b['time_ms'] ?? double.infinity) as num);
      } else {
        return (b['coins'] as int).compareTo(a['coins'] as int);
      }
    });
    return fullList.indexOf(user) + 1;
  }

  void applyPagination() {
    final filtered = allLeaderboard.where((entry) {
      final username = entry['users']?['username'] ?? entry['username'] ?? '';
      return username.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    totalPages = (filtered.length / pageSize).ceil().clamp(1, 10);
    if (currentPage > totalPages) currentPage = totalPages;
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filtered.length);
    paginatedLeaderboard = filtered.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        glassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: glowingText(
                  'Leaderboard — ${widget.selectedLevel.toUpperCase()}',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              const Icon(Icons.leaderboard, color: Colors.white54),
            ],
          ),
        ),
        const SizedBox(height: 12),

        glassCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  leaderboardSubTabIndex = 0;
                  currentPage = 1;
                }),
                child: glowingText(
                  'Fastest Time',
                  fontWeight: leaderboardSubTabIndex == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: leaderboardSubTabIndex == 0
                      ? Colors.greenAccent
                      : Colors.white54,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  leaderboardSubTabIndex = 1;
                  currentPage = 1;
                }),
                child: glowingText(
                  'Most Coins',
                  fontWeight: leaderboardSubTabIndex == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: leaderboardSubTabIndex == 1
                      ? Colors.greenAccent
                      : Colors.white54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        glassCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: TextField(
            key: const ValueKey('leaderboard-search'),
            controller: searchController,
            focusNode: searchFocusNode,
            style: const TextStyle(color: Colors.white),
            cursorColor: AppTheme.primary,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search username...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                          currentPage = 1;
                        });
                        FocusScope.of(context).requestFocus(searchFocusNode);
                      },
                      child: const Icon(Icons.close, color: Colors.white54),
                    )
                  : null,
            ),
            onChanged: (val) => setState(() {
              searchQuery = val;
              currentPage = 1;
            }),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: leaderboardSubTabIndex == 0
                ? widget.quizService
                    .fetchLeaderboard(level: widget.selectedLevel, limit: 100)
                : widget.auth.supabase
                    .from('users')
                    .select('username, coins')
                    .gt('coins', 0)
                    .order('coins', ascending: false)
                    .limit(100) as Future<List<Map<String, dynamic>>>,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              allLeaderboard = snap.data ?? [];

              if (leaderboardSubTabIndex == 1) {
                allLeaderboard = allLeaderboard
                    .where((e) => (e['coins'] ?? 0) >= 100)
                    .toList();

                allLeaderboard.sort(
                    (a, b) => (b['coins'] as int).compareTo(a['coins'] as int));
              }

              applyPagination();

              if (paginatedLeaderboard.isEmpty) {
                return Center(
                  child: glowingText(
                    'No users found',
                    opacity: 0.7,
                    color: Colors.greenAccent,
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: paginatedLeaderboard.length,
                      itemBuilder: (_, idx) {
                        final entry = paginatedLeaderboard[idx];
                        final displayValue = leaderboardSubTabIndex == 0
                            ? (entry['time_ms'] != null
                                ? '${(entry['time_ms'] / 1000).toStringAsFixed(2)}s'
                                : '--')
                            : '${entry['coins']}';

                        int trueRank = getTrueRank(
                          user: entry,
                          fullList: allLeaderboard,
                          isFastestTab: leaderboardSubTabIndex == 0,
                        );

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppTheme.primary.withOpacity(0.14),
                                child: glowingText(
                                  '$trueRank',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: glowingText(
                                  entry['users']?['username'] ??
                                      entry['username'] ??
                                      'Unknown',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              glowingText(
                                displayValue,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back_ios, color: Colors.white70),
                        onPressed: currentPage > 1
                            ? () => setState(() => currentPage--)
                            : null,
                      ),
                      glowingText(
                        '$currentPage / $totalPages',
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white70),
                        onPressed: currentPage < totalPages
                            ? () => setState(() => currentPage++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
