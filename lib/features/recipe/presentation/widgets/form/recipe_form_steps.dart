import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/recipe_style.dart';

import '../../controllers/recipe_form_controller.dart';

class RecipeFormSteps extends StatelessWidget {
  final RecipeFormController controller;
  const RecipeFormSteps({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final listening = controller.isListening.value;
          return Container(
            decoration: BoxDecoration(
              color: RecipeStyle.white,
              borderRadius: RecipeStyle.r10,
              border: Border.all(
                color:
                    listening ? RecipeStyle.error400 : RecipeStyle.brown200,
                width: listening
                    ? RecipeStyle.borderWidthActive
                    : RecipeStyle.borderWidthNormal,
              ),
            ),
            child: TextField(
              controller: controller.stepsCtrl,
              minLines: 10,
              maxLines: 20,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              style: RecipeStyle.stepsFieldText,
              decoration: InputDecoration(
                hintText: RecipeStyle.stepsHint,
                hintStyle: RecipeStyle.stepsHintText,
                border: InputBorder.none,
                contentPadding: RecipeStyle.padSection,
              ),
            ),
          );
        }),
        RecipeStyle.gap10,
        Obx(() {
          final listening = controller.isListening.value;
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.toggleListening,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: listening
                        ? RecipeStyle.error600
                        : RecipeStyle.primary,
                    foregroundColor: RecipeStyle.white,
                    padding: RecipeStyle.padVertical10,
                    shape: const RoundedRectangleBorder(
                      borderRadius: RecipeStyle.r10,
                    ),
                  ),
                  icon: Icon(
                    listening ? Icons.stop_circle : Icons.mic,
                    size: RecipeStyle.iconMdLg,
                  ),
                  label: Text(
                    listening ? RecipeStyle.micStop : RecipeStyle.micStart,
                    style: RecipeStyle.micBtnText,
                  ),
                ),
              ),
              if (listening) ...[
                RecipeStyle.gap10,
                const _PulseIndicator(),
              ],
            ],
          );
        }),
        Padding(
          padding: RecipeStyle.padLangRow,
          child: Row(
            children: [
              const Icon(Icons.language,
                  size: RecipeStyle.iconXs, color: RecipeStyle.brown600),
              RecipeStyle.gap4,
              Text(RecipeStyle.langLabel, style: RecipeStyle.langLabelStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _PulseIndicator extends StatelessWidget {
  const _PulseIndicator();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: RecipeStyle.pulseAnim,
      builder: (context, v, child) {
        return Container(
          width: RecipeStyle.iconPulse,
          height: RecipeStyle.iconPulse,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RecipeStyle.error600.withValues(
              alpha: RecipeStyle.pulseBase + RecipeStyle.pulseRange * v,
            ),
            boxShadow: [
              BoxShadow(
                color: RecipeStyle.errorRed.withValues(
                  alpha: RecipeStyle.pulseShadowBase * (1 - v),
                ),
                blurRadius: RecipeStyle.pulseBlur * v,
                spreadRadius: RecipeStyle.pulseSpread * v,
              ),
            ],
          ),
        );
      },
    );
  }
}