import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:wood/core/constants/specific/recipe_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';

import '../../domain/entities/recipe.dart';
import 'recipe_controller.dart';

class RecipeFormController extends GetxController {
  final RecipeEntity? existing;
  RecipeFormController({this.existing});

  final RecipeController recipeCtrl = Get.find<RecipeController>();
  final ImagePicker picker = ImagePicker();
  final stt.SpeechToText speech = stt.SpeechToText();

  bool get isEdit => existing != null;

  // ── Text controllers ──
  final nameCtrl = TextEditingController();
  final ingredientCtrl = TextEditingController();
  final stepsCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  // ── State ──
  final ingredients = <String>[].obs;
  final existingUrls = <String>[].obs;
  final newFiles = <File>[].obs;
  final category = RecipeCategory.other.obs;
  final status = RecipeStatus.never.obs;
  final rating = 0.obs;
  final isListening = false.obs;
  final speechAvailable = false.obs;
  final saving = false.obs;

  String sttLocale = 'lo_LA';

  @override
  void onInit() {
    super.onInit();
    _hydrate();
    _initSpeech();
  }

  @override
  void onClose() {
    speech.stop();
    nameCtrl.dispose();
    ingredientCtrl.dispose();
    stepsCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }

  void _hydrate() {
    final e = existing;
    if (e == null) return;
    nameCtrl.text = e.name;
    noteCtrl.text = e.note ?? '';
    stepsCtrl.text = e.steps ?? '';
    category.value = e.category;
    status.value = e.status;
    rating.value = e.rating;
    existingUrls.assignAll(e.imageUrls);
    ingredients.assignAll(e.ingredients);
  }

  // ══════════════════════════════════════════
  // Speech
  // ══════════════════════════════════════════
  Future<void> _initSpeech() async {
    try {
      final ok = await speech.initialize(
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (_) => isListening.value = false,
      );
      speechAvailable.value = ok;
    } catch (_) {}
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      await speech.stop();
      isListening.value = false;
      return;
    }

    if (!speechAvailable.value) {
      final ok = await speech.initialize();
      if (!ok) {
        AppSnackbar.warn(RecipeStyle.unsupported, RecipeStyle.unsupportedMsg);
        return;
      }
      speechAvailable.value = true;
    }

    final base = stepsCtrl.text.trim();
    final prefix = base.isEmpty ? '' : '$base\n';

    isListening.value = true;
    try {
      await speech.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          final combined = prefix + words;
          stepsCtrl.value = TextEditingValue(
            text: combined,
            selection: TextSelection.collapsed(offset: combined.length),
          );
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: sttLocale,
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (e) {
      isListening.value = false;
      AppSnackbar.err(
        RecipeStyle.errorMsg,
        '${RecipeStyle.errorStartingMic}: $e',
      );
    }
  }

  // ══════════════════════════════════════════
  // Ingredients
  // ══════════════════════════════════════════
  void addIngredient() {
    final t = ingredientCtrl.text.trim();
    if (t.isEmpty) return;
    ingredients.add(t);
    ingredientCtrl.clear();
  }

  void removeIngredient(int i) => ingredients.removeAt(i);

  // ══════════════════════════════════════════
  // Name suggestion
  // ══════════════════════════════════════════
  void insertNameSuggestion(String text) {
    final current = nameCtrl.text.trim();
    final merged = current.isEmpty ? text : '$current $text';
    nameCtrl.value = TextEditingValue(
      text: merged,
      selection: TextSelection.collapsed(offset: merged.length),
    );
  }

  // ══════════════════════════════════════════
  // Images
  // ══════════════════════════════════════════
  int get remainingImageSlots =>
      RecipeStyle.maxImages - (existingUrls.length + newFiles.length);

  Future<void> pickImage() async {
    if (remainingImageSlots <= 0) {
      AppSnackbar.warn(RecipeStyle.warningMsg, RecipeStyle.maxImagesMsg);
      return;
    }
    final p = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 75,
    );
    if (p == null) return;
    newFiles.add(File(p.path));
  }

  void removeExistingUrl(int i) => existingUrls.removeAt(i);
  void removeNewFile(int i) => newFiles.removeAt(i);

  // ══════════════════════════════════════════
  // Status / Rating / Category
  // ══════════════════════════════════════════
  void setStatus(RecipeStatus s) => status.value = s;
  void setRating(int r) => rating.value = r;
  void setCategory(RecipeCategory c) => category.value = c;

  // ══════════════════════════════════════════
  // Save
  // ══════════════════════════════════════════
  Future<void> save() async {
    if (saving.value) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      AppSnackbar.warn(RecipeStyle.warningMsg, RecipeStyle.nameRequired);
      return;
    }

    saving.value = true;
    try {
      final newUrls = <String>[];
      for (final f in newFiles) {
        final url = await recipeCtrl.uploadImage(f);
        if (url != null && url.isNotEmpty) newUrls.add(url);
      }
      final allUrls = [...existingUrls, ...newUrls];
      final stepsText = stepsCtrl.text.trim();

      bool ok;
      if (isEdit) {
        ok = await recipeCtrl.updateRecipe(
          id: existing!.id,
          name: name,
          category: category.value,
          ingredients: ingredients.toList(),
          status: status.value,
          rating: rating.value,
          imageUrls: allUrls,
          steps: stepsText.isEmpty ? null : stepsText,
          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        );
      } else {
        ok = await recipeCtrl.addRecipe(
          name: name,
          category: category.value,
          ingredients: ingredients.toList(),
          status: status.value,
          rating: rating.value,
          imageUrls: allUrls,
          steps: stepsText.isEmpty ? null : stepsText,
          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        );
      }

      if (ok) {
        Get.back(result: true);
        AppSnackbar.ok(
          RecipeStyle.successMsg,
          isEdit ? RecipeStyle.savedEdit : RecipeStyle.savedNew,
        );
      }
    } finally {
      saving.value = false;
    }
  }
}