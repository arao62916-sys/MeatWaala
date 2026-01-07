import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Service to handle add to cart animations
class AddToCartAnimation {
  /// Trigger the add to cart animation
  /// 
  /// [context] - BuildContext to create overlay
  /// [imageUrl] - Product image URL to animate
  /// [startKey] - GlobalKey of the product widget
  /// [cartKey] - GlobalKey of the cart icon in AppBar
  /// [onComplete] - Callback when animation completes
  static Future<void> animate({
    required BuildContext context,
    required String imageUrl,
    required GlobalKey startKey,
    required GlobalKey cartKey,
    required VoidCallback onComplete,
  }) async {
    // Get start and end positions
    final startBox = startKey.currentContext?.findRenderObject() as RenderBox?;
    final cartBox = cartKey.currentContext?.findRenderObject() as RenderBox?;

    if (startBox == null || cartBox == null) {
      onComplete();
      return;
    }

    final startPosition = startBox.localToGlobal(Offset.zero);
    final startSize = startBox.size;
    final cartPosition = cartBox.localToGlobal(Offset.zero);
    final cartSize = cartBox.size;

    // Calculate end position (center of cart icon)
    final endPosition = Offset(
      cartPosition.dx + (cartSize.width / 2) - 20,
      cartPosition.dy + (cartSize.height / 2) - 20,
    );

    // Create overlay entry
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedProductImage(
        imageUrl: imageUrl,
        startPosition: startPosition,
        startSize: startSize,
        endPosition: endPosition,
        onComplete: () {
          overlayEntry.remove();
          onComplete();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

/// Animated product image widget
class _AnimatedProductImage extends StatefulWidget {
  final String imageUrl;
  final Offset startPosition;
  final Size startSize;
  final Offset endPosition;
  final VoidCallback onComplete;

  const _AnimatedProductImage({
    required this.imageUrl,
    required this.startPosition,
    required this.startSize,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<_AnimatedProductImage> createState() => _AnimatedProductImageState();
}

class _AnimatedProductImageState extends State<_AnimatedProductImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Create curved animations for smooth movement
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    // Position animation (from product to cart) with slight curve
    _positionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: widget.startPosition,
          end: Offset(
            (widget.startPosition.dx + widget.endPosition.dx) / 2,
            widget.startPosition.dy - 50, // Arc upward
          ),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(
            (widget.startPosition.dx + widget.endPosition.dx) / 2,
            widget.startPosition.dy - 50,
          ),
          end: widget.endPosition,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Scale animation (shrink as it moves)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ));

    // Opacity animation (fade out near the end)
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Slight rotation for more dynamic feel
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: widget.startSize.width.clamp(60.0, 100.0),
                  height: widget.startSize.height.clamp(60.0, 100.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.shopping_bag, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Cart icon with bounce animation
class AnimatedCartIcon extends StatefulWidget {
  final GlobalKey iconKey;
  final VoidCallback onPressed;
  final int itemCount;

  const AnimatedCartIcon({
    super.key,
    required this.iconKey,
    required this.onPressed,
    this.itemCount = 0,
  });

  @override
  State<AnimatedCartIcon> createState() => AnimatedCartIconState();
}

class AnimatedCartIconState extends State<AnimatedCartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _badgeAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_bounceController);

    // Badge pulse animation
    _badgeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  /// Trigger bounce animation (called from outside)
  void bounce() {
    _bounceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: child,
        );
      },
      child: IconButton(
        key: widget.iconKey,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 26),
            if (widget.itemCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: AnimatedBuilder(
                  animation: _badgeAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _badgeAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      widget.itemCount > 99 ? '99+' : widget.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}