import 'package:flutter/material.dart';
import '../../theme.dart';
import '../quiz_page.dart';
import 'package:confetti/confetti.dart';
import 'utils.dart';

class PlayTab extends StatefulWidget {
  final bool loading;
  final List<String> levels;
  final String selectedLevel;
  final List<String> unlocked;
  final ConfettiController confettiController;
  final Animation<double> breatheAnim;
  final Function(String) onLevelSelected;
  final VoidCallback onQuizEnd;

  const PlayTab({
    super.key,
    required this.loading,
    required this.levels,
    required this.selectedLevel,
    required this.unlocked,
    required this.confettiController,
    required this.breatheAnim,
    required this.onLevelSelected,
    required this.onQuizEnd,
  });

  @override
  State<PlayTab> createState() => _PlayTabState();
}

class _PlayTabState extends State<PlayTab> {
  late String selectedLevel;

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.selectedLevel;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return const Center(child: CircularProgressIndicator());

    final pageController = PageController(
      viewportFraction: 0.56,
      initialPage: widget.levels.indexOf(selectedLevel),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        glassCard(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: glowingText(
                      'Choose difficulty',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(Icons.settings, color: Colors.white.withOpacity(0.65)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: pageController,
                  physics: const ClampingScrollPhysics(),
                  pageSnapping: false,
                  itemCount: widget.levels.length,
                  onPageChanged: (index) {
                    setState(() {
                      selectedLevel = widget.levels[index];
                      widget.onLevelSelected(selectedLevel);
                    });
                  },
                  itemBuilder: (context, index) {
                    double scale = 0.8;
                    double opacity = 0.6;

                    final pageOffset = pageController.hasClients
                        ? pageController.page ?? pageController.initialPage.toDouble()
                        : pageController.initialPage.toDouble();

                    final distance = (pageOffset - index).clamp(-1.0, 1.0);
                    scale = 0.8 + (1 - distance.abs()) * 0.25;
                    opacity = 0.5 + (1 - distance.abs()) * 0.5;

                    final isSelected = index == pageOffset.round();

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(distance * 0.35),
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: levelCard(widget.levels[index],
                              widget.unlocked.contains(widget.levels[index]),
                              isSelected: isSelected),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              ScaleTransition(
                scale: widget.breatheAnim,
                child: ElevatedButton(
                  onPressed: widget.unlocked.contains(selectedLevel)
                      ? () async {
                          widget.confettiController.play();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => QuizPage(level: selectedLevel)),
                          );
                          widget.onQuizEnd();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppTheme.primary.withOpacity(0.95),
                  ),
                  child: glowingText('Start Quiz', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget levelCard(String level, bool enabled, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.95),
                  AppTheme.accent.withOpacity(0.9)
                ],
              )
            : LinearGradient(
                colors: [Colors.white.withOpacity(0.03), Colors.white.withOpacity(0.02)],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: AppTheme.primary.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8))
              ]
            : [],
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            level == 'easy'
                ? Icons.looks_one
                : level == 'medium'
                    ? Icons.looks_two
                    : Icons.looks_3,
            size: 34,
            color: isSelected ? Colors.white : Colors.white70,
          ),
          const SizedBox(height: 12),
          glowingText(level.toUpperCase(),
              fontWeight: FontWeight.bold, opacity: isSelected ? 1 : 0.85),
          const SizedBox(height: 8),
          glowingText(enabled ? 'Unlocked' : 'Locked',
              fontSize: 12, opacity: isSelected ? 0.7 : 0.55),
        ],
      ),
    );
  }
}
