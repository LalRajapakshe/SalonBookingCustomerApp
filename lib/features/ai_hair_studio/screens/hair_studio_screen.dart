import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../services/studio_result_exporter.dart';
import '../state/hair_studio_bindings.dart';
import '../state/hair_studio_controller.dart';
import '../state/hair_studio_scope.dart';
import '../widgets/before_after_compare.dart';
import '../widgets/example_look_card.dart';
import '../widgets/hair_color_selector.dart';
import '../widgets/hair_style_gallery.dart';
import '../widgets/privacy_notice.dart';

class HairStudioScreen extends StatefulWidget {
  const HairStudioScreen({this.bindings, super.key});

  final HairStudioBindings? bindings;

  @override
  State<HairStudioScreen> createState() => _HairStudioScreenState();
}

class _HairStudioScreenState extends State<HairStudioScreen> {
  HairStudioController? _controller;

  @override
  void initState() {
    super.initState();
    final bindings = widget.bindings;
    if (bindings != null) {
      _attach(HairStudioController(bindings: bindings));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _attach(HairStudioController(bindings: HairStudioScope.of(context)));
    }
  }

  void _attach(HairStudioController controller) {
    _controller = controller;
    controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_rebuild);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return PopScope(
      canPop: controller.canLeave,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          controller.back();
        }
      },
      child: Scaffold(
        key: const Key('ai-hair-studio-screen'),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(_title(controller.step)),
          leading: IconButton(
            key: const Key('hair-studio-back'),
            tooltip: 'Back',
            onPressed: () {
              if (!controller.back()) {
                Navigator.of(context).maybePop();
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                key: ValueKey(controller.step),
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  4,
                  AppDimensions.screenPadding,
                  20,
                ),
                children: _content(controller),
              ),
            ),
            if (controller.step != HairStudioStep.result)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding,
                    8,
                    AppDimensions.screenPadding,
                    12,
                  ),
                  child: _actions(controller),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _title(HairStudioStep step) {
    return switch (step) {
      HairStudioStep.landing => 'AI Hair Studio',
      HairStudioStep.photo => 'Your photo',
      HairStudioStep.style => 'Choose a look',
      HairStudioStep.review => 'Generate',
      HairStudioStep.result => 'Your look',
    };
  }

  List<Widget> _content(HairStudioController controller) {
    return switch (controller.step) {
      HairStudioStep.landing => _landing(controller),
      HairStudioStep.photo => _photo(controller),
      HairStudioStep.style => _style(controller),
      HairStudioStep.review => _review(controller),
      HairStudioStep.result => _result(controller),
    };
  }

  List<Widget> _landing(HairStudioController controller) {
    return [
      Text(
        'A new hairstyle, on your photo',
        style: AppTextStyles.sectionTitle.copyWith(fontSize: 26),
      ),
      const SizedBox(height: 8),
      const Text(
        'Choose a portrait, pick an example hairstyle and an optional colour, then generate the look when you are ready.',
        style: AppTextStyles.body,
      ),
      const SizedBox(height: 16),
      const ExampleLookCard(),
      const SizedBox(height: 22),
      const SectionHeader(title: 'Hairstyles'),
      const SizedBox(height: 12),
      HairStyleGallery(
        selectedId: controller.selectedStyle?.id,
        onSelected: controller.selectStyle,
      ),
      const SizedBox(height: 22),
      const SectionHeader(title: 'Hair colour'),
      const SizedBox(height: 4),
      const Text(
        'Optional. The try-on follows the example photo, including the colour shown in it. This choice is kept with your request only.',
        style: AppTextStyles.caption,
      ),
      const SizedBox(height: 12),
      HairColorSelector(
        selectedId: controller.selectedColor?.id ?? 'keep',
        onSelected: controller.selectColor,
      ),
      const SizedBox(height: 16),
      const PrivacyNotice(),
    ];
  }

  List<Widget> _photo(HairStudioController controller) {
    final photo = controller.photoBytes;
    return [
      const Text(
        'Choose a photo from your gallery or take one with the camera. It stays on this device until you agree to generate a look.',
        style: AppTextStyles.body,
      ),
      const SizedBox(height: 16),
      if (controller.picking)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Opening your photos…', style: AppTextStyles.caption),
        ),
      if (photo != null) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: StudioMemoryImage(
              key: const Key('photo-preview'),
              bytes: photo,
              semanticLabel: 'Selected photo',
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
      _PhotoActions(controller: controller, hasPhoto: photo != null),
      if (controller.photoMessage != null) ...[
        const SizedBox(height: 12),
        _MessageBanner(message: controller.photoMessage!),
      ],
      if (controller.selectedStyle != null) ...[
        const SizedBox(height: 12),
        Text(
          'Selected look: ${controller.selectedStyle!.name}',
          style: AppTextStyles.caption,
        ),
      ],
    ];
  }

  List<Widget> _style(HairStudioController controller) {
    return [
      const Text(
        'Pick an example hairstyle photo. Colour is optional.',
        style: AppTextStyles.body,
      ),
      const SizedBox(height: 16),
      HairStyleGallery(
        selectedId: controller.selectedStyle?.id,
        onSelected: controller.selectStyle,
      ),
      const SizedBox(height: 18),
      const SectionHeader(title: 'Hair colour'),
      const SizedBox(height: 12),
      HairColorSelector(
        selectedId: controller.selectedColor?.id ?? 'keep',
        onSelected: controller.selectColor,
      ),
      if (controller.styleMessage != null) ...[
        const SizedBox(height: 12),
        _MessageBanner(message: controller.styleMessage!),
      ],
    ];
  }

  List<Widget> _review(HairStudioController controller) {
    final photo = controller.photoBytes;
    final style = controller.selectedStyle;
    final color = controller.selectedColor;
    return [
      if (photo != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: StudioMemoryImage(
              key: const Key('review-photo'),
              bytes: photo,
              semanticLabel: 'Photo ready to generate',
            ),
          ),
        ),
      const SizedBox(height: 14),
      Text(style?.name ?? 'No hairstyle selected', style: AppTextStyles.cardTitle),
      const SizedBox(height: 4),
      Text(style?.summary ?? '', style: AppTextStyles.body),
      const SizedBox(height: 8),
      Text(
        color == null ? 'No colour change' : color.name,
        key: const Key('review-colour'),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'Perfect Corp processes this photo only after you agree and tap Generate my look. The selected example photo is the style reference. Your face may stay recognisable, but an exact match is not guaranteed. Nothing is stored on your salon profile.',
        style: AppTextStyles.caption,
      ),
      CheckboxListTile(
        key: const Key('generation-consent'),
        value: controller.hasConsent,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text(
          'I agree to send this photo to Perfect Corp for hairstyle try-on.',
          style: AppTextStyles.caption,
        ),
        onChanged: controller.generating
            ? null
            : (value) => controller.setConsent(value ?? false),
      ),
    ];
  }

  List<Widget> _result(HairStudioController controller) {
    final before = controller.photoBytes;
    final after = controller.resultBytes;
    if (before == null || after == null) {
      return const [
        Text(
          'There is no generated look to show.',
          style: AppTextStyles.body,
        ),
      ];
    }
    return [
      const Text(
        'Generated from the photo you submitted.',
        style: AppTextStyles.body,
      ),
      const SizedBox(height: 6),
      const Text(
        'This is the image returned for that photo. It is not an example style, and an exact face match is not guaranteed.',
        style: AppTextStyles.caption,
      ),
      const SizedBox(height: 12),
      BeforeAfterCompare(before: before, after: after),
      const SizedBox(height: 16),
      AppPrimaryButton(
        key: const Key('try-another-style'),
        label: 'Try another style',
        onPressed: controller.tryAnotherStyle,
      ),
      const SizedBox(height: 10),
      AppSecondaryButton(
        key: const Key('save-result'),
        label: 'Save to photos',
        onPressed: () {
          _export(controller.saveResult);
        },
      ),
      const SizedBox(height: 10),
      AppSecondaryButton(
        key: const Key('share-result'),
        label: 'Share',
        onPressed: () {
          _export(controller.shareResult);
        },
      ),
    ];
  }

  Widget _actions(HairStudioController controller) {
    return switch (controller.step) {
      HairStudioStep.landing => AppPrimaryButton(
          key: const Key('try-on-my-photo'),
          label: 'Try on my photo',
          onPressed: controller.openPhoto,
        ),
      HairStudioStep.photo => AppPrimaryButton(
          key: const Key('continue-photo'),
          label: 'Continue',
          onPressed: controller.continueFromPhoto,
        ),
      HairStudioStep.style => AppPrimaryButton(
          key: const Key('continue-style'),
          label: 'Continue',
          onPressed: controller.continueFromStyle,
        ),
      HairStudioStep.review => _generateActions(controller),
      HairStudioStep.result => const SizedBox.shrink(),
    };
  }

  Widget _generateActions(HairStudioController controller) {
    if (controller.generating) {
      return const Column(
        key: Key('generation-progress'),
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 10),
          Text(
            'Creating your look…',
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle,
          ),
          SizedBox(height: 4),
          Text(
            'This can take up to two minutes. Keep this screen open.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      );
    }

    final failure = controller.failure;
    return Column(
      children: [
        if (failure != null) ...[
          _MessageBanner(
            key: const Key('generation-error'),
            message: failure.message,
          ),
          const SizedBox(height: 10),
          AppPrimaryButton(
            key: const Key('retry-generation'),
            label: 'Try again',
            onPressed: () {
              controller.generate();
            },
          ),
        ] else
          AppPrimaryButton(
            key: const Key('generate-my-look'),
            label: 'Generate my look',
            onPressed: () {
              controller.generate();
            },
          ),
      ],
    );
  }

  Future<void> _export(Future<StudioExportResult> Function() action) async {
    final result = await action();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }
}

class _PhotoActions extends StatelessWidget {
  const _PhotoActions({required this.controller, required this.hasPhoto});

  final HairStudioController controller;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final enabled = !controller.picking;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SourceButton(
                key: Key(hasPhoto ? 'replace-photo' : 'pick-gallery'),
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onPressed: enabled
                    ? () {
                        controller.pickFromGallery();
                      }
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SourceButton(
                key: const Key('pick-camera'),
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                onPressed: enabled
                    ? () {
                        controller.captureWithCamera();
                      }
                    : null,
              ),
            ),
          ],
        ),
        if (hasPhoto) ...[
          const SizedBox(height: 10),
          AppSecondaryButton(
            key: const Key('remove-photo'),
            label: 'Remove photo',
            onPressed: enabled ? controller.removePhoto : null,
          ),
        ],
      ],
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.heading,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: AppTextStyles.button.copyWith(fontSize: 15)),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3D2A4)),
        ),
        child: Text(message, style: AppTextStyles.caption.copyWith(color: AppColors.heading)),
      ),
    );
  }
}
