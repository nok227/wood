import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:wood/core/constants/specific/recipe_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';
import '../../../domain/entities/recipe.dart';
import '../../controllers/recipe_controller.dart';

class RecipeFormPage extends StatefulWidget {
  final RecipeEntity? existing;
  const RecipeFormPage({super.key, this.existing});

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final c = Get.find<RecipeController>();
  final picker = ImagePicker();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  String _sttLocale = 'lo_LA';

  late final TextEditingController nameC;
  late final TextEditingController ingC;
  late final TextEditingController stepsC;
  late final TextEditingController noteC;

  late RecipeCategory category;
  late RecipeStatus status;
  late int rating;
  late List<String> existingUrls;
  final List<File> newFiles = [];

  List<String> ingredients = [];
  bool saving = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    nameC = TextEditingController(text: e?.name ?? '');
    noteC = TextEditingController(text: e?.note ?? '');
    ingC = TextEditingController();
    stepsC = TextEditingController(text: e?.steps ?? '');
    category = e?.category ?? RecipeCategory.other;
    status = e?.status ?? RecipeStatus.never;
    rating = e?.rating ?? 0;
    existingUrls = List<String>.from(e?.imageUrls ?? []);
    ingredients = List<String>.from(e?.ingredients ?? []);
    _initSpeech();
  }

  // ══════════════════════════════════════════════
  // 🎤 Speech
  // ══════════════════════════════════════════════
  Future<void> _initSpeech() async {
    try {
      final ok = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (err) {
          if (!mounted) return;
          setState(() => _isListening = false);
          debugPrint('Speech error: $err');
        },
      );
      if (mounted) setState(() => _speechAvailable = ok);

      if (ok) {
        _sttLocale = 'lo_LA';
        debugPrint('ບັງຄັບໃຊ້ພາສາລາວ: $_sttLocale');
        try {
          final locales = await _speech.locales();
          final hasLao = locales.any(
            (l) => l.localeId.toLowerCase().startsWith('lo'),
          );
          debugPrint('ອຸປະກອນມີພາສາລາວ: $hasLao');
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Speech init error: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      final ok = await _speech.initialize();
      if (!ok) {
        AppSnackbar.warn(RecipeStyle.unsupported, RecipeStyle.unsupportedMsg);
        return;
      }
      if (mounted) setState(() => _speechAvailable = true);
    }

    final baseText = stepsC.text.trim();
    final basePrefix = baseText.isEmpty ? '' : '$baseText\n';

    setState(() => _isListening = true);

    try {
      await _speech.listen(
        localeId: _sttLocale,
        onResult: (result) {
          final words = result.recognizedWords;
          if (!mounted) return;
          final combined = basePrefix + words;
          stepsC.value = TextEditingValue(
            text: combined,
            selection: TextSelection.collapsed(offset: combined.length),
          );
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isListening = false);
      AppSnackbar.err(
        RecipeStyle.errorMsg,
        '${RecipeStyle.errorStartingMic}: $e',
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    nameC.dispose();
    ingC.dispose();
    stepsC.dispose();
    noteC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final remaining =
        RecipeStyle.maxImages - (existingUrls.length + newFiles.length);
    if (remaining <= 0) {
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
    setState(() => newFiles.add(File(p.path)));
  }

  void _addIngredient() {
    final t = ingC.text.trim();
    if (t.isEmpty) return;
    setState(() {
      ingredients.add(t);
      ingC.clear();
    });
  }

  void _insertName(String text) {
    final current = nameC.text.trim();
    final newText = current.isEmpty ? text : '$current $text';
    nameC.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    setState(() {});
  }

  Future<void> _save() async {
    if (saving) return;
    final name = nameC.text.trim();
    if (name.isEmpty) {
      AppSnackbar.warn(RecipeStyle.warningMsg, RecipeStyle.nameRequired);
      return;
    }

    setState(() => saving = true);

    try {
      final newUrls = <String>[];
      for (final f in newFiles) {
        final url = await c.uploadImage(f);
        if (url != null && url.isNotEmpty) newUrls.add(url);
      }
      final allUrls = [...existingUrls, ...newUrls];
      final stepsText = stepsC.text.trim();

      bool ok;
      if (isEdit) {
        ok = await c.updateRecipe(
          id: widget.existing!.id,
          name: name,
          category: category,
          ingredients: ingredients,
          status: status,
          rating: rating,
          imageUrls: allUrls,
          steps: stepsText.isEmpty ? null : stepsText,
          note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
        );
      } else {
        ok = await c.addRecipe(
          name: name,
          category: category,
          ingredients: ingredients,
          status: status,
          rating: rating,
          imageUrls: allUrls,
          steps: stepsText.isEmpty ? null : stepsText,
          note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
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
      if (mounted) setState(() => saving = false);
    }
  }

  // ══════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecipeStyle.bg,
      appBar: AppBar(
        title: Text(
          isEdit ? RecipeStyle.formTitleEdit : RecipeStyle.formTitleAdd,
        ),
        backgroundColor: RecipeStyle.primary,
        foregroundColor: RecipeStyle.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: RecipeStyle.padFormPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section(
                '1',
                RecipeStyle.sectionBasic,
                Icons.restaurant,
                _buildBasicSection(),
              ),
              RecipeStyle.gap14,
              _section(
                '2',
                RecipeStyle.sectionIngredients,
                Icons.egg_alt_outlined,
                _buildIngredientsSection(),
              ),
              RecipeStyle.gap14,
              _section(
                '3',
                RecipeStyle.sectionSteps,
                Icons.menu_book_outlined,
                _buildStepsSection(),
              ),
              RecipeStyle.gap14,
              _section(
                '4',
                RecipeStyle.sectionStatus,
                Icons.star_outline,
                _buildStatusSection(),
              ),
              RecipeStyle.gap14,
              _section(
                '5',
                RecipeStyle.sectionImages,
                Icons.photo_library_outlined,
                _buildImagePicker(),
              ),
              RecipeStyle.gap14,
              _section(
                '6',
                RecipeStyle.sectionNote,
                Icons.sticky_note_2_outlined,
                TextField(
                  controller: noteC,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: RecipeStyle.noteHint,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBasicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameC,
          decoration: InputDecoration(
            labelText: RecipeStyle.nameLabel,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(
              Icons.restaurant,
              color: RecipeStyle.primary,
            ),
            hintText: RecipeStyle.nameHint,
          ),
        ),
        RecipeStyle.gap12,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            RecipeStyle.suggestionLabel,
            style: RecipeStyle.fieldHint,
          ),
        ),
        RecipeStyle.gap6,
        Wrap(
          spacing: RecipeStyle.wrapSpacing,
          runSpacing: RecipeStyle.wrapRunSpacing,
          children: RecipeStyle.nameSuggestions.map((text) {
            return ActionChip(
              label: Text(
                text,
                style: RecipeStyle.chipText.copyWith(
                  color: RecipeStyle.primary,
                ),
              ),
              backgroundColor: RecipeStyle.white,
              side: const BorderSide(color: RecipeStyle.brown200),
              onPressed: () => _insertName(text),
            );
          }).toList(),
        ),
        RecipeStyle.gap14,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(RecipeStyle.categoryLabel, style: RecipeStyle.fieldHint),
        ),
        RecipeStyle.gap6,
        DropdownButtonFormField<RecipeCategory>(
          value: category,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: RecipeStyle.padDropdown,
            prefixIcon: Icon(Icons.category, color: RecipeStyle.primary),
          ),
          items: RecipeCategory.values.map((cat) {
            return DropdownMenuItem<RecipeCategory>(
              value: cat,
              child: Text(
                '${cat.emoji} ${cat.label}',
                style: RecipeStyle.dropdownItemText,
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => category = v);
          },
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ingC,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addIngredient(),
                decoration: const InputDecoration(
                  hintText: RecipeStyle.ingredientHint,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            RecipeStyle.gap6,
            IconButton.filled(
              onPressed: _addIngredient,
              style: IconButton.styleFrom(backgroundColor: RecipeStyle.primary),
              icon: const Icon(Icons.add, color: RecipeStyle.white),
            ),
          ],
        ),
        if (ingredients.isNotEmpty) ...[
          RecipeStyle.gap10,
          Wrap(
            spacing: RecipeStyle.wrapSpacing,
            runSpacing: RecipeStyle.wrapRunSpacing,
            children: ingredients.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value, style: RecipeStyle.chipTiny),
                deleteIcon: const Icon(Icons.close, size: RecipeStyle.iconSmMd),
                onDeleted: () => setState(() => ingredients.removeAt(e.key)),
                backgroundColor: RecipeStyle.brown50,
                side: const BorderSide(color: RecipeStyle.brown200),
              );
            }).toList(),
          ),
        ] else
          Padding(
            padding: RecipeStyle.padIngredientEmpty,
            child: Text(
              RecipeStyle.noIngredients,
              style: RecipeStyle.noIngredientsText,
            ),
          ),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: RecipeStyle.white,
            borderRadius: RecipeStyle.r10,
            border: Border.all(
              color: _isListening ? RecipeStyle.error400 : RecipeStyle.brown200,
              width: _isListening
                  ? RecipeStyle.borderWidthActive
                  : RecipeStyle.borderWidthNormal,
            ),
          ),
          child: TextField(
            controller: stepsC,
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
        ),
        RecipeStyle.gap10,
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleListening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening
                      ? RecipeStyle.error600
                      : RecipeStyle.primary,
                  foregroundColor: RecipeStyle.white,
                  padding: RecipeStyle.padVertical10,
                  shape: const RoundedRectangleBorder(
                    borderRadius: RecipeStyle.r10,
                  ),
                ),
                icon: Icon(
                  _isListening ? Icons.stop_circle : Icons.mic,
                  size: RecipeStyle.iconMdLg,
                ),
                label: Text(
                  _isListening ? RecipeStyle.micStop : RecipeStyle.micStart,
                  style: RecipeStyle.micBtnText,
                ),
              ),
            ),
            if (_isListening) ...[RecipeStyle.gap10, _pulseIndicator()],
          ],
        ),
        Padding(
          padding: RecipeStyle.padLangRow,
          child: Row(
            children: [
              const Icon(
                Icons.language,
                size: RecipeStyle.iconXs,
                color: RecipeStyle.brown600,
              ),
              RecipeStyle.gap4,
              Text(RecipeStyle.langLabel, style: RecipeStyle.langLabelStyle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: RecipeStatus.values.map((s) {
            final sel = status == s;
            return Expanded(
              child: Padding(
                padding: RecipeStyle.padFilterChip,
                child: InkWell(
                  onTap: () => setState(() => status = s),
                  borderRadius: RecipeStyle.r10,
                  child: Container(
                    padding: RecipeStyle.padVertical10,
                    decoration: BoxDecoration(
                      color: sel ? RecipeStyle.primary : RecipeStyle.white,
                      borderRadius: RecipeStyle.r10,
                      border: Border.all(
                        color: sel ? RecipeStyle.brown800 : RecipeStyle.grey300,
                        width: sel
                            ? RecipeStyle.borderWidthActive
                            : RecipeStyle.borderWidthNormal,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        s.label,
                        style: RecipeStyle.statusTab.copyWith(
                          color: sel ? RecipeStyle.white : RecipeStyle.brown800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        RecipeStyle.gap14,
        Text(RecipeStyle.ratingLabel, style: RecipeStyle.ratingLabelStyle),
        RecipeStyle.gap6,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final on = i < rating;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: RecipeStyle.starBtnConstraints,
              onPressed: () =>
                  setState(() => rating = on && i + 1 == rating ? 0 : i + 1),
              icon: Icon(
                on ? Icons.star : Icons.star_border,
                color: on ? RecipeStyle.amber700 : RecipeStyle.grey400,
                size: RecipeStyle.starSize,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final tiles = <Widget>[];

    for (int i = 0; i < existingUrls.length; i++) {
      final url = existingUrls[i];
      tiles.add(
        _imageTile(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (c, u) => Container(color: RecipeStyle.brown50),
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
          ),
          onRemove: () => setState(() => existingUrls.removeAt(i)),
        ),
      );
    }

    for (int i = 0; i < newFiles.length; i++) {
      tiles.add(
        _imageTile(
          child: Image.file(newFiles[i], fit: BoxFit.cover),
          onRemove: () => setState(() => newFiles.removeAt(i)),
        ),
      );
    }

    if (tiles.length < RecipeStyle.maxImages) {
      tiles.add(
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: RecipeStyle.imageTileSize,
            height: RecipeStyle.imageTileSize,
            decoration: BoxDecoration(
              color: RecipeStyle.white,
              border: Border.all(color: RecipeStyle.brown200),
              borderRadius: RecipeStyle.r10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_a_photo,
                  color: RecipeStyle.brown400,
                  size: RecipeStyle.iconAdd,
                ),
                RecipeStyle.gap3,
                Text(
                  RecipeStyle.addImageLabel,
                  style: RecipeStyle.addImageLabelStyle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: RecipeStyle.wrapImgSpacing,
      runSpacing: RecipeStyle.wrapImgSpacing,
      children: tiles,
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: RecipeStyle.padBottomBar,
        decoration: BoxDecoration(
          color: RecipeStyle.white,
          boxShadow: RecipeStyle.bottomBarShadow,
        ),
        child: ElevatedButton.icon(
          onPressed: saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: RecipeStyle.primary,
            foregroundColor: RecipeStyle.white,
            padding: RecipeStyle.padBottomBarBtn,
            shape: const RoundedRectangleBorder(borderRadius: RecipeStyle.r12),
            elevation: 0,
          ),
          icon: saving
              ? const SizedBox(
                  width: RecipeStyle.spinnerSmall,
                  height: RecipeStyle.spinnerSmall,
                  child: CircularProgressIndicator(
                    strokeWidth: RecipeStyle.spinnerStroke,
                    color: RecipeStyle.white,
                  ),
                )
              : const Icon(Icons.save, size: RecipeStyle.iconMdLg),
          label: Text(
            saving
                ? RecipeStyle.saving
                : (isEdit ? RecipeStyle.saveEditBtn : RecipeStyle.saveNewBtn),
            style: RecipeStyle.saveBtnText,
          ),
        ),
      ),
    );
  }

  Widget _pulseIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: RecipeStyle.pulseAnim,
      builder: (context, v, child) {
        return Container(
          width: RecipeStyle.iconPulse,
          height: RecipeStyle.iconPulse,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RecipeStyle.error600.withOpacity(
              RecipeStyle.pulseBase + RecipeStyle.pulseRange * v,
            ),
            boxShadow: [
              BoxShadow(
                color: RecipeStyle.errorRed.withOpacity(
                  RecipeStyle.pulseShadowBase * (1 - v),
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

  Widget _imageTile({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: RecipeStyle.r10,
          child: SizedBox(
            width: RecipeStyle.imageTileSize,
            height: RecipeStyle.imageTileSize,
            child: child,
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: RecipeStyle.padImgBadge,
              decoration: const BoxDecoration(
                color: RecipeStyle.textPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: RecipeStyle.imgCloseBadge,
                color: RecipeStyle.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(String number, String title, IconData icon, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: RecipeStyle.white,
        borderRadius: RecipeStyle.sectionRadius,
        border: Border.all(
          color: RecipeStyle.brown200,
          width: RecipeStyle.borderWidthNormal,
        ),
        boxShadow: RecipeStyle.sectionShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: RecipeStyle.padSectionHeader,
            decoration: const BoxDecoration(
              color: RecipeStyle.brown50,
              borderRadius: RecipeStyle.topR13,
            ),
            child: Row(
              children: [
                Container(
                  width: RecipeStyle.sectionNumberSize,
                  height: RecipeStyle.sectionNumberSize,
                  decoration: const BoxDecoration(
                    color: RecipeStyle.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(number, style: RecipeStyle.sectionNumber),
                  ),
                ),
                RecipeStyle.gapSm,
                Icon(
                  icon,
                  color: RecipeStyle.primary,
                  size: RecipeStyle.iconMdSm,
                ),
                RecipeStyle.gap6,
                Expanded(child: Text(title, style: RecipeStyle.sectionTitle)),
              ],
            ),
          ),
          Padding(padding: RecipeStyle.padSection, child: child),
        ],
      ),
    );
  }
}
