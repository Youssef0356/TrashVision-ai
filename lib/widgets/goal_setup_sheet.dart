import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'glass.dart';

class GoalSetupSheet extends StatefulWidget {
  const GoalSetupSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoalSetupSheet(),
    );
  }

  @override
  State<GoalSetupSheet> createState() => _GoalSetupSheetState();
}

class _GoalSetupSheetState extends State<GoalSetupSheet> {
  late int _selectedGoal;

  @override
  void initState() {
    super.initState();
    _selectedGoal = GameService.instance.dailyGoal;
  }

  @override
  Widget build(BuildContext context) {
    final game = GameService.instance;
    final tn = game.isTunisian;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppleColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tn ? 'الهدف اليومي متاعك' : 'Your Daily Goal',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppleColors.ink,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppleColors.tertiary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: tn ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              tn
                  ? 'اختار قداش من وسخة تحب تنحي كل يوم باش تعاون حومتك'
                  : 'Choose how many litter items you want to clean each day.',
              style: const TextStyle(fontSize: 13, color: AppleColors.secondary),
            ),
          ),
          const SizedBox(height: 20),

          // Goal Counter Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppleColors.canvas,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppleColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minus button
                GestureDetector(
                  onTap: () {
                    if (_selectedGoal > 1) {
                      setState(() => _selectedGoal--);
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppleColors.primary.withAlpha(120)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10FF8C00),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(CupertinoIcons.minus, size: 18, color: AppleColors.primary),
                  ),
                ),

                // Number Display
                Column(
                  children: [
                    Text(
                      '$_selectedGoal',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppleColors.ink,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tn ? 'قطايع كل يوم' : 'items / day',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppleColors.secondary,
                      ),
                    ),
                  ],
                ),

                // Plus button
                GestureDetector(
                  onTap: () {
                    if (_selectedGoal < 100) {
                      setState(() => _selectedGoal++);
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppleColors.primary.withAlpha(120)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10FF8C00),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(CupertinoIcons.plus, size: 18, color: AppleColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Presets Row
          Row(
            children: [
              _PresetButton(
                label: tn ? '5 (خفيف نظيف)' : '5 (Casual)',
                selected: _selectedGoal == 5,
                onTap: () => setState(() => _selectedGoal = 5),
              ),
              const SizedBox(width: 8),
              _PresetButton(
                label: tn ? '10 (ناشط)' : '10 (Active)',
                selected: _selectedGoal == 10,
                onTap: () => setState(() => _selectedGoal = 10),
              ),
              const SizedBox(width: 8),
              _PresetButton(
                label: tn ? '20 (بطل)' : '20 (Champion)',
                selected: _selectedGoal == 20,
                onTap: () => setState(() => _selectedGoal = 20),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save button (Warm Sunset Gradient instead of black!)
          GestureDetector(
            onTap: () {
              game.setDailyGoal(_selectedGoal);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tn ? 'تم تثبيت هدفك اليومي: $_selectedGoal قطايع!' : 'Daily goal updated to $_selectedGoal items!',
                  ),
                  backgroundColor: AppleColors.ink,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                gradient: const LinearGradient(
                  colors: [AppleColors.sunsetStart, AppleColors.sunsetEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x35FF8C00),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  tn ? 'ثبّت الهدف' : 'Save Daily Goal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppleColors.primary : AppleColors.canvas,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppleColors.primary : AppleColors.border,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x25FF8C00),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppleColors.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
