import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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

  static const _nameSuggestions = [
    'ຕົ້ມ', 'ຜັດ', 'ຍ່າງ', 'ປີ້ງ',
    'ລາບ', 'ຍຳ', 'ແກງ', 'ຂົ້ວ',
    'ຂອງຫວານ', 'ຂອງກິນ',
  ];

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
        Get.snackbar('ບໍ່ຮອງຮັບ', 'ອຸປະກອນນີ້ບໍ່ຮອງຮັບການພິມສຽງ');
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
      Get.snackbar('ຜິດພາດ', 'ບໍ່ສາມາດເລີ່ມຟັງໄດ້: $e');
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
    final remaining = 3 - (existingUrls.length + newFiles.length);
    if (remaining <= 0) {
      Get.snackbar('ເຕືອນ', 'ໃສ່ໄດ້ສູງສຸດ 3 ຮູບ');
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
      Get.snackbar('ເຕືອນ', 'ກະລຸນາໃສ່ຊື່ເມນູ');
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
        Get.snackbar(
          'ສຳເລັດ',
          isEdit ? 'ແກ້ໄຂຮຽບຮ້ອຍແລ້ວ' : 'ເພີ່ມເມນູຮຽບຮ້ອຍແລ້ວ',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text(isEdit ? 'ແກ້ໄຂເມນູ' : 'ເພີ່ມເມນູໃໝ່'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section(
                '1',
                'ຊື່ ແລະ ປະເພດ',
                Icons.restaurant,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameC,
                      decoration: const InputDecoration(
                        labelText: 'ຊື່ເມນູ *',
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.restaurant, color: Colors.brown),
                        hintText: 'ຕົວຢ່າງ: ຕົ້ມຍຳ, ຜັດໄທ...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ຄຳແນະນຳ (ກົດເພື່ອເພີ່ມ):',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _nameSuggestions.map((text) {
                        return ActionChip(
                          label: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.brown.shade200),
                          onPressed: () => _insertName(text),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ປະເພດອາຫານ:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<RecipeCategory>(
                      value: category,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        prefixIcon:
                            Icon(Icons.category, color: Colors.brown),
                      ),
                      items: RecipeCategory.values.map((cat) {
                        return DropdownMenuItem<RecipeCategory>(
                          value: cat,
                          child: Text(
                            '${cat.emoji} ${cat.label}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => category = v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _section(
                '2',
                'ສ່ວນປະກອບ',
                Icons.egg_alt_outlined,
                Column(
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
                              hintText: 'ເຊັ່ນ: ໝູ, ຜັກ, ນ້ຳປາ',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filled(
                          onPressed: _addIngredient,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.brown.shade700,
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    if (ingredients.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ingredients.asMap().entries.map((e) {
                          return Chip(
                            label: Text(e.value,
                                style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 15),
                            onDeleted: () => setState(
                                () => ingredients.removeAt(e.key)),
                            backgroundColor: Colors.brown.shade50,
                            side: BorderSide(color: Colors.brown.shade200),
                          );
                        }).toList(),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'ຍັງບໍ່ໄດ້ໃສ່ສ່ວນປະກອບ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _section(
                '3',
                'ສູດອາຫານ',
                Icons.menu_book_outlined,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isListening
                              ? Colors.red.shade400
                              : Colors.brown.shade200,
                          width: _isListening ? 2 : 1.2,
                        ),
                      ),
                      child: TextField(
                        controller: stepsC,
                        minLines: 10,
                        maxLines: 20,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ພິມ ຫຼື ກົດໄມ 🎤 ເວົ້າເປັນພາສາລາວ...\n\n'
                              'ຕົວຢ່າງ:\n'
                              '1. ຕັ້ງໝໍ້ ໃສ່ນ້ຳພໍປະມານ\n'
                              '2. ປຸງລົດດ້ວຍ ນ້ຳປາ, ນ້ຳຕານ, ໝາກນາວ\n'
                              '3. ຕົ້ມໃຫ້ເດືອດ 10 ນາທີ\n'
                              '4. ຊີມລົດ ແລ້ວຕັກໃສ່ຈານ',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleListening,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening
                                  ? Colors.red.shade600
                                  : Colors.brown.shade700,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(
                              _isListening
                                  ? Icons.stop_circle
                                  : Icons.mic,
                              size: 22,
                            ),
                            label: Text(
                              _isListening
                                  ? 'ກຳລັງຟັງ... ກົດເພື່ອຢຸດ'
                                  : 'ກົດເພື່ອເວົ້າ (ລາວ)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (_isListening) ...[
                          const SizedBox(width: 10),
                          _pulseIndicator(),
                        ],
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(Icons.language,
                              size: 12, color: Colors.brown.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'ພາສາລາວເທົ່ານັ້ນ · lo_LA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _section(
                '4',
                'ສະຖານະ ແລະ ຄະແນນ',
                Icons.star_outline,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: RecipeStatus.values.map((s) {
                        final sel = status == s;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3),
                            child: InkWell(
                              onTap: () => setState(() => status = s),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? Colors.brown.shade700
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: sel
                                        ? Colors.brown.shade800
                                        : Colors.grey.shade300,
                                    width: sel ? 2 : 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    s.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: sel
                                          ? Colors.white
                                          : Colors.brown.shade800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ຄະແນນຄວາມມັກ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final on = i < rating;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 44, minHeight: 44),
                          onPressed: () => setState(() =>
                              rating =
                                  on && i + 1 == rating ? 0 : i + 1),
                          icon: Icon(
                            on ? Icons.star : Icons.star_border,
                            color: on
                                ? Colors.amber.shade700
                                : Colors.grey.shade400,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _section(
                '5',
                'ຮູບພາບ (ສູງສຸດ 3)',
                Icons.photo_library_outlined,
                _buildImagePicker(),
              ),
              const SizedBox(height: 14),
              _section(
                '6',
                'ໝາຍເຫດ',
                Icons.sticky_note_2_outlined,
                TextField(
                  controller: noteC,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'ໝາຍເຫດເພີ່ມເຕີມ (ຖ້າມີ)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.2, color: Colors.white),
                  )
                : const Icon(Icons.save, size: 22),
            label: Text(
              saving
                  ? 'ກຳລັງບັນທຶກ...'
                  : (isEdit ? 'ບັນທຶກການແກ້ໄຂ' : '💾 ບັນທຶກເມນູ'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pulseIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, v, child) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.shade600.withOpacity(0.3 + 0.5 * v),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4 * (1 - v)),
                blurRadius: 12 * v,
                spreadRadius: 4 * v,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePicker() {
    final tiles = <Widget>[];

    for (int i = 0; i < existingUrls.length; i++) {
      final url = existingUrls[i];
      tiles.add(_imageTile(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (c, u) => Container(color: Colors.brown.shade50),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
        ),
        onRemove: () => setState(() => existingUrls.removeAt(i)),
      ));
    }

    for (int i = 0; i < newFiles.length; i++) {
      tiles.add(_imageTile(
        child: Image.file(newFiles[i], fit: BoxFit.cover),
        onRemove: () => setState(() => newFiles.removeAt(i)),
      ));
    }

    if (tiles.length < 3) {
      tiles.add(GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.brown.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo,
                  color: Colors.brown.shade400, size: 24),
              const SizedBox(height: 3),
              Text(
                'ເພີ່ມຮູບ',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.brown.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    return Wrap(spacing: 8, runSpacing: 8, children: tiles);
  }

  Widget _imageTile({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 84, height: 84, child: child),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(
    String number,
    String title,
    IconData icon,
    Widget child,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.brown.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.brown, size: 17),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}