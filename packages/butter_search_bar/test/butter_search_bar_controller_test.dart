import 'package:butter_search_bar/butter_search_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ButterSearchBarController controller;

  setUp(() {
    controller = ButterSearchBarController();
  });

  tearDown(() {
    controller.dispose();
  });

  test('initial text is empty', () {
    expect(controller.text, '');
  });

  test('initial text from constructor', () {
    final c = ButterSearchBarController(text: 'hello');
    expect(c.text, 'hello');
    c.dispose();
  });

  test('setting text notifies listeners', () {
    var notified = false;
    controller.addListener(() => notified = true);
    controller.text = 'world';
    expect(controller.text, 'world');
    expect(notified, isTrue);
  });

  test('textEditingController reflects text changes', () {
    controller.text = 'foo';
    expect(controller.textEditingController.text, 'foo');
  });

  test('expand and collapse', () {
    expect(controller.isExpanded, isFalse);
    controller.expand();
    expect(controller.isExpanded, isTrue);
    controller.collapse();
    expect(controller.isExpanded, isFalse);
  });

  test('expand does not notify when already expanded', () {
    controller.expand();
    var notified = false;
    controller.addListener(() => notified = true);
    controller.expand();
    expect(notified, isFalse);
  });

  test('collapse does not notify when already collapsed', () {
    var notified = false;
    controller.addListener(() => notified = true);
    controller.collapse();
    expect(notified, isFalse);
  });

  test('toggle flips expansion state', () {
    expect(controller.isExpanded, isFalse);
    controller.toggle();
    expect(controller.isExpanded, isTrue);
    controller.toggle();
    expect(controller.isExpanded, isFalse);
  });

  test('showOverlay and hideOverlay', () {
    expect(controller.isOverlayVisible, isFalse);
    controller.showOverlay();
    expect(controller.isOverlayVisible, isTrue);
    controller.hideOverlay();
    expect(controller.isOverlayVisible, isFalse);
  });

  test('showOverlay does not notify when already visible', () {
    controller.showOverlay();
    var notified = false;
    controller.addListener(() => notified = true);
    controller.showOverlay();
    expect(notified, isFalse);
  });

  test('clear resets text and hides overlay', () {
    controller.text = 'something';
    controller.showOverlay();
    controller.clear();
    expect(controller.text, '');
    expect(controller.isOverlayVisible, isFalse);
  });
}
