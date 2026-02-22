import 'package:flutter/material.dart';

/// An image carousel with page indicators and optional navigation arrows.
///
/// Displays a horizontal [PageView] of network images with dot indicators
/// and left/right arrow buttons. Supports arbitrary child widgets via
/// [itemBuilder] for non-image content.
class SmoothCarousel extends StatefulWidget {
  /// Network image URLs to display. Ignored if [itemBuilder] is provided.
  final List<String> imageUrls;

  /// Optional custom builder for each page. When provided, [imageUrls] is
  /// only used for [itemCount] if [itemCount] is not set.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Number of pages. Defaults to [imageUrls.length].
  final int? itemCount;

  /// Height of the carousel.
  final double height;

  /// Border radius applied to the carousel container.
  final BorderRadius borderRadius;

  /// Whether to show left/right navigation arrows.
  final bool showArrows;

  /// Whether to show dot indicators at the bottom.
  final bool showIndicators;

  /// Size of the active indicator dot.
  final double activeDotSize;

  /// Size of the inactive indicator dots.
  final double inactiveDotSize;

  /// Color of the active indicator dot.
  final Color activeDotColor;

  /// Color of inactive indicator dots.
  final Color inactiveDotColor;

  /// Duration of the page change animation.
  final Duration animationDuration;

  /// Curve of the page change animation.
  final Curve animationCurve;

  /// Widget shown when a network image fails to load.
  final Widget? errorWidget;

  /// BoxFit for network images.
  final BoxFit imageFit;

  const SmoothCarousel({
    super.key,
    this.imageUrls = const [],
    this.itemBuilder,
    this.itemCount,
    this.height = 300,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.showArrows = true,
    this.showIndicators = true,
    this.activeDotSize = 12,
    this.inactiveDotSize = 8,
    this.activeDotColor = Colors.white,
    this.inactiveDotColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.errorWidget,
    this.imageFit = BoxFit.cover,
  });

  @override
  State<SmoothCarousel> createState() => _SmoothCarouselState();
}

class _SmoothCarouselState extends State<SmoothCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  int get _pageCount =>
      widget.itemCount ?? widget.imageUrls.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pageCount == 0) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: widget.height,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pageCount,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: widget.itemBuilder ?? _defaultItemBuilder,
            ),
          ),
          // Left arrow
          if (widget.showArrows && _pageCount > 1)
            Positioned(
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _currentIndex > 0
                    ? () => _goToPage(_currentIndex - 1)
                    : null,
              ),
            ),
          // Right arrow
          if (widget.showArrows && _pageCount > 1)
            Positioned(
              right: 10,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: _currentIndex < _pageCount - 1
                    ? () => _goToPage(_currentIndex + 1)
                    : null,
              ),
            ),
          // Dot indicators
          if (widget.showIndicators && _pageCount > 1)
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pageCount, (index) {
                  final isActive = _currentIndex == index;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive
                        ? widget.activeDotSize
                        : widget.inactiveDotSize,
                    height: isActive
                        ? widget.activeDotSize
                        : widget.inactiveDotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? widget.activeDotColor
                          : widget.inactiveDotColor,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _defaultItemBuilder(BuildContext context, int index) {
    assert(
      index < widget.imageUrls.length,
      'SmoothCarousel: index $index out of range for imageUrls '
      '(length ${widget.imageUrls.length}). '
      'Provide an itemBuilder or matching imageUrls.',
    );
    return Image.network(
      widget.imageUrls[index],
      fit: widget.imageFit,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            const Center(child: Icon(Icons.broken_image, size: 48));
      },
    );
  }
}
