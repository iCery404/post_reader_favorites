import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0x26B08968)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final List<Offset> points = <Offset>[];
    for (double y = 8; y < size.height; y += 14) {
      for (double x = 8; x < size.width; x += 14) {
        points.add(Offset(x, y));
      }
    }
    canvas.drawPoints(ui.PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = const Color(0x66FFFFFF);
    for (double x = 2; x < size.width; x += 8) {
      canvas.drawCircle(Offset(x, size.height / 2), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 1.5),
      ),
    );
  }
}

class TitleBarContent extends StatelessWidget {
  const TitleBarContent({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _WindowDot(color: AppColors.creamLight),
        const SizedBox(width: 5),
        const _WindowDot(color: AppColors.sageLight),
        const SizedBox(width: 5),
        const _WindowDot(color: AppColors.cream),
        const SizedBox(width: 12),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: SizedBox(
            height: 6,
            child: CustomPaint(painter: _DottedLinePainter()),
          ),
        ),
      ],
    );
  }
}

class CozyScaffold extends StatelessWidget {
  const CozyScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: canPop ? 0 : 16,
        leading: canPop
            ? CozyIconButton(
                tooltip: 'Back',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: TitleBarContent(title: title),
        actions: <Widget>[
          ...actions,
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: AppColors.outline),
        ),
      ),
      floatingActionButton: floatingActionButton,
      body: CustomPaint(
        painter: const _DotPatternPainter(),
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox.expand(
            child: SafeArea(top: false, child: body),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.text,
    this.icon,
    this.trailing,
  });

  final String text;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, color: AppColors.cocoa, size: 26),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sageDark, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: AppColors.sageDark,
        ),
      ),
    );
  }
}

class IdBadge extends StatelessWidget {
  const IdBadge({super.key, required this.id, this.size = 42});

  final int id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.sageDark, width: 2),
      ),
      child: Text(
        '$id',
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w900,
          color: AppColors.sageDark,
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final int milliseconds = index < 8 ? 350 + index * 80 : 300;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: milliseconds),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

enum CozyButtonStyle { primary, sage, cream, danger }

class _ButtonColors {
  const _ButtonColors(
    this.background,
    this.foreground,
    this.border,
    this.shadow,
  );

  final Color background;
  final Color foreground;
  final Color border;
  final Color shadow;

  factory _ButtonColors.of(CozyButtonStyle style) {
    switch (style) {
      case CozyButtonStyle.primary:
        return const _ButtonColors(
          AppColors.caramel,
          Colors.white,
          AppColors.caramelDark,
          AppColors.caramelDark,
        );
      case CozyButtonStyle.sage:
        return const _ButtonColors(
          AppColors.sage,
          AppColors.ink,
          AppColors.sageDark,
          AppColors.sageDark,
        );
      case CozyButtonStyle.cream:
        return const _ButtonColors(
          AppColors.rowAlt,
          AppColors.cocoa,
          AppColors.caramel,
          AppColors.caramel,
        );
      case CozyButtonStyle.danger:
        return const _ButtonColors(
          AppColors.blush,
          Colors.white,
          AppColors.danger,
          AppColors.danger,
        );
    }
  }
}

class CozyButton extends StatefulWidget {
  const CozyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = CozyButtonStyle.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CozyButtonStyle style;
  final bool expand;

  @override
  State<CozyButton> createState() => _CozyButtonState();
}

class _CozyButtonState extends State<CozyButton> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (!mounted) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final _ButtonColors colors = _ButtonColors.of(widget.style);
    final bool enabled = widget.onPressed != null;
    final TextStyle textStyle = Theme.of(context)
        .textTheme
        .labelLarge!
        .copyWith(color: colors.foreground);
    final BorderRadius radius = BorderRadius.circular(12);

    double dy = 0;
    if (enabled && _pressed) {
      dy = 4;
    } else if (enabled && _hovered) {
      dy = -2;
    }

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, dy, 0),
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: <BoxShadow>[
              BoxShadow(color: colors.shadow, offset: Offset(0, 4 - dy)),
            ],
          ),
          child: Material(
            color: colors.background,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: colors.border, width: 2),
            ),
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: _setPressed,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisSize:
                      widget.expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (widget.icon != null) ...<Widget>[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.elasticOut,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          widget.icon,
                          key: ValueKey<IconData?>(widget.icon),
                          size: 18,
                          color: colors.foreground,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          widget.label,
                          key: ValueKey<String>(widget.label),
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CozyIconButton extends StatefulWidget {
  const CozyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color = Colors.white,
    this.badgeCount = 0,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color color;
  final int badgeCount;
  final bool compact;

  @override
  State<CozyIconButton> createState() => _CozyIconButtonState();
}

class _CozyIconButtonState extends State<CozyIconButton> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (!mounted) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1;
    if (_pressed) {
      scale = 0.8;
    } else if (_hovered) {
      scale = 1.15;
    }

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Listener(
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: IconButton(
          tooltip: widget.tooltip,
          onPressed: widget.onPressed,
          visualDensity: widget.compact ? VisualDensity.compact : null,
          icon: Badge(
            isLabelVisible: widget.badgeCount > 0,
            backgroundColor: AppColors.sageDark,
            textColor: Colors.white,
            label: Text('${widget.badgeCount}'),
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Icon(widget.icon, color: widget.color),
            ),
          ),
        ),
      ),
    );
  }
}

class CozyFab extends StatefulWidget {
  const CozyFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<CozyFab> createState() => _CozyFabState();
}

class _CozyFabState extends State<CozyFab> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (!mounted) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);

    double dy = 0;
    if (_pressed) {
      dy = 4;
    } else if (_hovered) {
      dy = -2;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (BuildContext context, double scale, Widget? child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: Listener(
          onPointerDown: (_) => _setPressed(true),
          onPointerUp: (_) => _setPressed(false),
          onPointerCancel: (_) => _setPressed(false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, dy, 0),
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.caramelDark,
                  offset: Offset(0, 4 - dy),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: widget.onPressed,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              backgroundColor: AppColors.caramel,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: const BorderSide(color: AppColors.caramelDark, width: 2),
              ),
              icon: Icon(widget.icon),
              label: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}

enum MessageKind { success, error, info }

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.message,
    this.kind = MessageKind.info,
    this.onClose,
  });

  final String message;
  final MessageKind kind;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color border;
    late final IconData icon;
    switch (kind) {
      case MessageKind.success:
        bg = AppColors.sageLight;
        border = AppColors.sageDark;
        icon = Icons.check_circle_rounded;
        break;
      case MessageKind.error:
        bg = AppColors.blushLight;
        border = AppColors.danger;
        icon = Icons.error_rounded;
        break;
      case MessageKind.info:
        bg = AppColors.rowAlt;
        border = AppColors.caramel;
        icon = Icons.info_rounded;
        break;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(color: border, offset: const Offset(0, 3)),
          ],
        ),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: <Widget>[
                Icon(icon, color: AppColors.cocoa),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (onClose != null)
                  CozyIconButton(
                    tooltip: 'Dismiss',
                    icon: Icons.close_rounded,
                    color: AppColors.cocoa,
                    compact: true,
                    onPressed: onClose!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedBanner extends StatelessWidget {
  const AnimatedBanner({
    super.key,
    required this.message,
    required this.messageId,
    required this.kind,
    required this.onClose,
  });

  final String? message;
  final int messageId;
  final MessageKind kind;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity, height: 0)
          : Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: StatusBanner(
                key: ValueKey<int>(messageId),
                message: message!,
                kind: kind,
                onClose: onClose,
              ),
            ),
    );
  }
}

class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.rows = 8});

  final int rows;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar(double height, double factor) {
    return FractionallySizedBox(
      widthFactor: factor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.sageLight,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.rows,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: index.isEven ? AppColors.creamLight : AppColors.rowAlt,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.sageLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _bar(14, 0.7),
                      const SizedBox(height: 8),
                      _bar(10, 0.95),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CozyPlaceholder extends StatelessWidget {
  const CozyPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (BuildContext context, double scale, Widget? child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sageDark, width: 2.5),
                ),
                child: Icon(icon, size: 44, color: AppColors.sageDark),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              CozyButton(
                label: actionLabel!,
                icon: Icons.refresh_rounded,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CozyDialogFrame extends StatelessWidget {
  const CozyDialogFrame({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        builder: (BuildContext context, double scale, Widget? child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outline, width: 3),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: AppColors.shadowNavy, offset: Offset(4, 5)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 46,
                    color: AppColors.caramel,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    child: TitleBarContent(title: title),
                  ),
                  Container(height: 3, color: AppColors.outline),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: child,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 10,
                      children: actions,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
