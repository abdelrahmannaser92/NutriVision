import 'package:flutter/material.dart';
import 'package:sofrah_project/screens/home_screen.dart';

import '../core/app_theme.dart';
import '../services/meal_service.dart';
import '../widgets/glass_widgets.dart';

class NutritionSummaryScreen extends StatelessWidget {
  final String selectedGoal;

  NutritionSummaryScreen({super.key, this.selectedGoal = 'maintain'});

  final MealService mealService = MealService();

  String get goalTitle {
    switch (selectedGoal) {
      case 'lose':
        return 'خسارة الوزن';
      case 'gain':
        return 'زيادة الوزن';
      default:
        return 'الحفاظ على الوزن';
    }
  }

  String get goalDescription {
    switch (selectedGoal) {
      case 'lose':
        return 'خطة غذائية تساعدك على خسارة الوزن بطريقة صحية';
      case 'gain':
        return 'خطة غذائية تساعدك على زيادة الوزن بطريقة صحية';
      default:
        return 'خطة غذائية تساعدك على الحفاظ على وزنك الحالي';
    }
  }

  int get dailyCalories {
    switch (selectedGoal) {
      case 'lose':
        return 1800;
      case 'gain':
        return 2600;
      default:
        return 2200;
    }
  }

  int get protein {
    switch (selectedGoal) {
      case 'lose':
        return 120;
      case 'gain':
        return 130;
      default:
        return 110;
    }
  }

  int get carbs {
    switch (selectedGoal) {
      case 'lose':
        return 180;
      case 'gain':
        return 320;
      default:
        return 250;
    }
  }

  int get fat {
    switch (selectedGoal) {
      case 'lose':
        return 60;
      case 'gain':
        return 75;
      default:
        return 70;
    }
  }

  double _progress(double current, double target) {
    if (target <= 0) return 0;
    return (current / target).clamp(0.0, 1.0);
  }

  Widget _macroCard({
    required String title,
    required String amount,
    required String unit,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 12),
            Text(title, style: AppText.body(14, color: AppColors.textSoft)),
            const SizedBox(height: 12),
            SizedBox(
              width: 65,
              height: 65,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      amount,
                      style: AppText.body(15, weight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              unit,
              textAlign: TextAlign.center,
              style: AppText.body(11, color: AppColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: mealService.getTodayMeals(),
      builder: (context, snapshot) {
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;

        if (snapshot.hasData) {
          for (final meal in snapshot.data!.docs) {
            final data = meal.data();

            totalCalories += (data['calories'] as num?)?.toDouble() ?? 0;

            totalProtein += (data['protein'] as num?)?.toDouble() ?? 0;

            totalCarbs += (data['carbs'] as num?)?.toDouble() ?? 0;

            totalFat += (data['fat'] as num?)?.toDouble() ?? 0;
          }
        }

        final calorieProgress = _progress(
          totalCalories,
          dailyCalories.toDouble(),
        );

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF101B3A),
                  AppColors.bgDark,
                  Color(0xFF08152D),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '07 / 09',
                          style: AppText.body(14, color: AppColors.textSoft),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Text('خطة التغذية بتاعتك', style: AppText.title(28)),

                    const SizedBox(height: 10),

                    Text(
                      goalDescription,
                      style: AppText.body(15, color: AppColors.textSoft),
                    ),

                    const SizedBox(height: 28),

                    if (snapshot.hasError)
                      const Text(
                        'حدث خطأ في تحميل بيانات التغذية',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    else if (!snapshot.hasData)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: AppColors.orange,
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'السعرات الحرارية اليومية',
                              style: AppText.body(
                                16,
                                color: AppColors.textSoft,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalCalories.toStringAsFixed(0),
                              style: AppText.title(42, color: AppColors.orange),
                            ),
                            Text(
                              'من $dailyCalories سعرة حرارية',
                              style: AppText.body(
                                14,
                                color: AppColors.textSoft,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: calorieProgress,
                                minHeight: 10,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              totalCalories >= dailyCalories
                                  ? 'وصلت لهدفك اليومي ❤️'
                                  : 'متبقي ${(dailyCalories - totalCalories).toStringAsFixed(0)} سعرة حرارية',
                              style: AppText.body(
                                13,
                                color: AppColors.textSoft,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text('توزيع العناصر الغذائية', style: AppText.title(21)),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _macroCard(
                            title: 'بروتين',
                            amount: totalProtein.toStringAsFixed(0),
                            unit: 'من $protein جرام',
                            progress: _progress(
                              totalProtein,
                              protein.toDouble(),
                            ),
                            color: AppColors.cyan,
                            icon: Icons.fitness_center,
                          ),
                          const SizedBox(width: 10),
                          _macroCard(
                            title: 'كربوهيدرات',
                            amount: totalCarbs.toStringAsFixed(0),
                            unit: 'من $carbs جرام',
                            progress: _progress(totalCarbs, carbs.toDouble()),
                            color: AppColors.orange,
                            icon: Icons.grain,
                          ),
                          const SizedBox(width: 10),
                          _macroCard(
                            title: 'دهون',
                            amount: totalFat.toStringAsFixed(0),
                            unit: 'من $fat جرام',
                            progress: _progress(totalFat, fat.toDouble()),
                            color: const Color(0xFFB388FF),
                            icon: Icons.water_drop,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 25),

                    GlassCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            color: AppColors.orange,
                            size: 35,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رحلتك لهدفك',
                                  style: AppText.body(
                                    17,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  goalTitle,
                                  style: AppText.body(
                                    12,
                                    color: AppColors.textSoft,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'حوالي 3 شهور',
                                  style: AppText.title(
                                    22,
                                    color: AppColors.cyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    GradientButton(
                      text: 'التالي',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
