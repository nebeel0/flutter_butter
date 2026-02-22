import 'package:flutter/material.dart';

/// Top-level style configuration for [ButterChatView].
///
/// All properties are optional — sensible defaults are derived from the
/// current Material 3 [ColorScheme] and [TextTheme].
class ButterChatStyle {
  const ButterChatStyle({
    this.backgroundColor,
    this.padding,
    this.messageSpacing,
    this.messageStyle,
    this.inputStyle,
    this.codeBlockStyle,
    this.planIndicatorStyle,
    this.actionStyle,
    this.statusBarStyle,
    this.branchNavigatorStyle,
    this.suggestionStyle,
    this.clarifyingQuestionStyle,
    this.maxContentWidth = 1024.0,
  });

  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? messageSpacing;
  final ButterMessageStyle? messageStyle;
  final ButterInputStyle? inputStyle;
  final ButterCodeBlockStyle? codeBlockStyle;
  final ButterPlanIndicatorStyle? planIndicatorStyle;
  final ButterActionStyle? actionStyle;
  final ButterStatusBarStyle? statusBarStyle;
  final ButterBranchNavigatorStyle? branchNavigatorStyle;
  final ButterSuggestionStyle? suggestionStyle;
  final ButterClarifyingQuestionStyle? clarifyingQuestionStyle;

  /// Maximum content width for the centered column (messages, input, status).
  /// Set to `null` for full-width. Defaults to 768.0.
  final double? maxContentWidth;

  /// Alias for [messageStyle] — kept for backwards compatibility.
  @Deprecated('Use messageStyle instead')
  ButterMessageStyle? get bubbleStyle => messageStyle;

  ButterChatStyle copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    double? messageSpacing,
    ButterMessageStyle? messageStyle,
    ButterInputStyle? inputStyle,
    ButterCodeBlockStyle? codeBlockStyle,
    ButterPlanIndicatorStyle? planIndicatorStyle,
    ButterActionStyle? actionStyle,
    ButterStatusBarStyle? statusBarStyle,
    ButterBranchNavigatorStyle? branchNavigatorStyle,
    ButterSuggestionStyle? suggestionStyle,
    ButterClarifyingQuestionStyle? clarifyingQuestionStyle,
    double? maxContentWidth,
  }) {
    return ButterChatStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      messageSpacing: messageSpacing ?? this.messageSpacing,
      messageStyle: messageStyle ?? this.messageStyle,
      inputStyle: inputStyle ?? this.inputStyle,
      codeBlockStyle: codeBlockStyle ?? this.codeBlockStyle,
      planIndicatorStyle: planIndicatorStyle ?? this.planIndicatorStyle,
      actionStyle: actionStyle ?? this.actionStyle,
      statusBarStyle: statusBarStyle ?? this.statusBarStyle,
      branchNavigatorStyle: branchNavigatorStyle ?? this.branchNavigatorStyle,
      suggestionStyle: suggestionStyle ?? this.suggestionStyle,
      clarifyingQuestionStyle:
          clarifyingQuestionStyle ?? this.clarifyingQuestionStyle,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    );
  }

  /// Resolves style with theme-derived defaults.
  ButterChatStyle resolve(BuildContext context) {
    return this;
  }
}

/// Style for user and assistant messages.
class ButterMessageStyle {
  const ButterMessageStyle({
    this.userBackgroundColor,
    this.assistantBackgroundColor,
    this.userForegroundColor,
    this.assistantForegroundColor,
    this.userBorderRadius,
    this.userPadding,
    this.assistantPadding,
    this.avatarBuilder,
    this.showTimestamps,
  });

  final Color? userBackgroundColor;

  /// Background color for assistant messages. Defaults to transparent (no bubble).
  final Color? assistantBackgroundColor;
  final Color? userForegroundColor;
  final Color? assistantForegroundColor;

  /// Border radius for user message bubble. Defaults to 24.0 (3xl).
  final BorderRadius? userBorderRadius;
  final EdgeInsetsGeometry? userPadding;
  final EdgeInsetsGeometry? assistantPadding;

  /// Builder for avatar widgets shown next to messages.
  final Widget Function(BuildContext context, bool isUser)? avatarBuilder;

  /// Whether to show timestamps on hover. Defaults to true.
  final bool? showTimestamps;

  ButterMessageStyle copyWith({
    Color? userBackgroundColor,
    Color? assistantBackgroundColor,
    Color? userForegroundColor,
    Color? assistantForegroundColor,
    BorderRadius? userBorderRadius,
    EdgeInsetsGeometry? userPadding,
    EdgeInsetsGeometry? assistantPadding,
    Widget Function(BuildContext context, bool isUser)? avatarBuilder,
    bool? showTimestamps,
  }) {
    return ButterMessageStyle(
      userBackgroundColor: userBackgroundColor ?? this.userBackgroundColor,
      assistantBackgroundColor:
          assistantBackgroundColor ?? this.assistantBackgroundColor,
      userForegroundColor: userForegroundColor ?? this.userForegroundColor,
      assistantForegroundColor:
          assistantForegroundColor ?? this.assistantForegroundColor,
      userBorderRadius: userBorderRadius ?? this.userBorderRadius,
      userPadding: userPadding ?? this.userPadding,
      assistantPadding: assistantPadding ?? this.assistantPadding,
      avatarBuilder: avatarBuilder ?? this.avatarBuilder,
      showTimestamps: showTimestamps ?? this.showTimestamps,
    );
  }
}

/// Backwards-compatible alias for [ButterMessageStyle].
@Deprecated('Use ButterMessageStyle instead')
typedef ButterBubbleStyle = ButterMessageStyle;

/// Style for the message input bar.
class ButterInputStyle {
  const ButterInputStyle({
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.hintText,
    this.hintStyle,
    this.textStyle,
    this.sendButtonColor,
    this.stopButtonColor,
    this.padding,
    this.maxLines,
    this.elevation,
    this.useBackdropBlur,
  });

  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BorderSide? border;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color? sendButtonColor;
  final Color? stopButtonColor;
  final EdgeInsetsGeometry? padding;
  final int? maxLines;

  /// Shadow elevation for the input container. Defaults to 2.0.
  final double? elevation;

  /// Whether to apply a backdrop blur effect. Defaults to true.
  final bool? useBackdropBlur;

  ButterInputStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    BorderSide? border,
    String? hintText,
    TextStyle? hintStyle,
    TextStyle? textStyle,
    Color? sendButtonColor,
    Color? stopButtonColor,
    EdgeInsetsGeometry? padding,
    int? maxLines,
    double? elevation,
    bool? useBackdropBlur,
  }) {
    return ButterInputStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      hintText: hintText ?? this.hintText,
      hintStyle: hintStyle ?? this.hintStyle,
      textStyle: textStyle ?? this.textStyle,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      stopButtonColor: stopButtonColor ?? this.stopButtonColor,
      padding: padding ?? this.padding,
      maxLines: maxLines ?? this.maxLines,
      elevation: elevation ?? this.elevation,
      useBackdropBlur: useBackdropBlur ?? this.useBackdropBlur,
    );
  }
}

/// Style for code blocks within messages.
class ButterCodeBlockStyle {
  const ButterCodeBlockStyle({
    this.backgroundColor,
    this.textStyle,
    this.borderRadius,
    this.padding,
    this.copyButtonColor,
    this.languageLabelStyle,
  });

  final Color? backgroundColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? copyButtonColor;
  final TextStyle? languageLabelStyle;

  ButterCodeBlockStyle copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    Color? copyButtonColor,
    TextStyle? languageLabelStyle,
  }) {
    return ButterCodeBlockStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      copyButtonColor: copyButtonColor ?? this.copyButtonColor,
      languageLabelStyle: languageLabelStyle ?? this.languageLabelStyle,
    );
  }
}

/// Style for the collapsible thinking/plan indicator.
class ButterPlanIndicatorStyle {
  const ButterPlanIndicatorStyle({
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.iconColor,
    this.labelStyle,
    this.contentStyle,
    this.padding,
  });

  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BorderSide? border;
  final Color? iconColor;
  final TextStyle? labelStyle;
  final TextStyle? contentStyle;
  final EdgeInsetsGeometry? padding;

  ButterPlanIndicatorStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    BorderSide? border,
    Color? iconColor,
    TextStyle? labelStyle,
    TextStyle? contentStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return ButterPlanIndicatorStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      iconColor: iconColor ?? this.iconColor,
      labelStyle: labelStyle ?? this.labelStyle,
      contentStyle: contentStyle ?? this.contentStyle,
      padding: padding ?? this.padding,
    );
  }
}

/// Style for message action buttons (copy, edit, regenerate).
class ButterActionStyle {
  const ButterActionStyle({
    this.iconColor,
    this.iconSize,
    this.hoverOnly,
    this.spacing,
    this.hoverBackgroundColor,
  });

  final Color? iconColor;
  final double? iconSize;

  /// If true, action buttons are only visible on hover/long press.
  final bool? hoverOnly;
  final double? spacing;

  /// Background color shown on action button hover.
  final Color? hoverBackgroundColor;

  ButterActionStyle copyWith({
    Color? iconColor,
    double? iconSize,
    bool? hoverOnly,
    double? spacing,
    Color? hoverBackgroundColor,
  }) {
    return ButterActionStyle(
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      hoverOnly: hoverOnly ?? this.hoverOnly,
      spacing: spacing ?? this.spacing,
      hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
    );
  }
}

/// Style for the status bar (e.g. "Searching...", "Analyzing...").
class ButterStatusBarStyle {
  const ButterStatusBarStyle({
    this.backgroundColor,
    this.textStyle,
    this.iconColor,
    this.padding,
  });

  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  ButterStatusBarStyle copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    Color? iconColor,
    EdgeInsetsGeometry? padding,
  }) {
    return ButterStatusBarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      iconColor: iconColor ?? this.iconColor,
      padding: padding ?? this.padding,
    );
  }
}

/// Style for the branch navigation arrows (< 2/3 >).
class ButterBranchNavigatorStyle {
  const ButterBranchNavigatorStyle({
    this.iconColor,
    this.textStyle,
    this.iconSize,
  });

  final Color? iconColor;
  final TextStyle? textStyle;
  final double? iconSize;

  ButterBranchNavigatorStyle copyWith({
    Color? iconColor,
    TextStyle? textStyle,
    double? iconSize,
  }) {
    return ButterBranchNavigatorStyle(
      iconColor: iconColor ?? this.iconColor,
      textStyle: textStyle ?? this.textStyle,
      iconSize: iconSize ?? this.iconSize,
    );
  }
}

/// Style for suggestion prompt cards on the welcome screen.
class ButterSuggestionStyle {
  const ButterSuggestionStyle({
    this.backgroundColor,
    this.borderRadius,
    this.textStyle,
    this.subtitleStyle,
    this.padding,
  });

  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsetsGeometry? padding;

  ButterSuggestionStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    TextStyle? subtitleStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return ButterSuggestionStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      textStyle: textStyle ?? this.textStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      padding: padding ?? this.padding,
    );
  }
}

/// Style for clarifying question cards.
class ButterClarifyingQuestionStyle {
  const ButterClarifyingQuestionStyle({
    this.backgroundColor,
    this.resolvedBackgroundColor,
    this.borderRadius,
    this.border,
    this.questionTextStyle,
    this.optionLabelStyle,
    this.optionDescriptionStyle,
    this.selectedOptionColor,
    this.unselectedOptionColor,
    this.submitButtonStyle,
    this.padding,
    this.optionPadding,
    this.optionBorderRadius,
  });

  final Color? backgroundColor;
  final Color? resolvedBackgroundColor;
  final BorderRadius? borderRadius;
  final BorderSide? border;
  final TextStyle? questionTextStyle;
  final TextStyle? optionLabelStyle;
  final TextStyle? optionDescriptionStyle;
  final Color? selectedOptionColor;
  final Color? unselectedOptionColor;
  final ButtonStyle? submitButtonStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? optionPadding;
  final BorderRadius? optionBorderRadius;

  ButterClarifyingQuestionStyle copyWith({
    Color? backgroundColor,
    Color? resolvedBackgroundColor,
    BorderRadius? borderRadius,
    BorderSide? border,
    TextStyle? questionTextStyle,
    TextStyle? optionLabelStyle,
    TextStyle? optionDescriptionStyle,
    Color? selectedOptionColor,
    Color? unselectedOptionColor,
    ButtonStyle? submitButtonStyle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? optionPadding,
    BorderRadius? optionBorderRadius,
  }) {
    return ButterClarifyingQuestionStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      resolvedBackgroundColor:
          resolvedBackgroundColor ?? this.resolvedBackgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      questionTextStyle: questionTextStyle ?? this.questionTextStyle,
      optionLabelStyle: optionLabelStyle ?? this.optionLabelStyle,
      optionDescriptionStyle:
          optionDescriptionStyle ?? this.optionDescriptionStyle,
      selectedOptionColor: selectedOptionColor ?? this.selectedOptionColor,
      unselectedOptionColor:
          unselectedOptionColor ?? this.unselectedOptionColor,
      submitButtonStyle: submitButtonStyle ?? this.submitButtonStyle,
      padding: padding ?? this.padding,
      optionPadding: optionPadding ?? this.optionPadding,
      optionBorderRadius: optionBorderRadius ?? this.optionBorderRadius,
    );
  }
}

/// Style for the side panel.
class ButterSidePanelStyle {
  const ButterSidePanelStyle({
    this.backgroundColor,
    this.width,
    this.dividerColor,
    this.headerPadding,
    this.searchBarStyle,
    this.sessionTileStyle,
  });

  final Color? backgroundColor;
  final double? width;
  final Color? dividerColor;
  final EdgeInsetsGeometry? headerPadding;
  final ButterSidePanelSearchStyle? searchBarStyle;
  final ButterSessionTileStyle? sessionTileStyle;

  ButterSidePanelStyle copyWith({
    Color? backgroundColor,
    double? width,
    Color? dividerColor,
    EdgeInsetsGeometry? headerPadding,
    ButterSidePanelSearchStyle? searchBarStyle,
    ButterSessionTileStyle? sessionTileStyle,
  }) {
    return ButterSidePanelStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      width: width ?? this.width,
      dividerColor: dividerColor ?? this.dividerColor,
      headerPadding: headerPadding ?? this.headerPadding,
      searchBarStyle: searchBarStyle ?? this.searchBarStyle,
      sessionTileStyle: sessionTileStyle ?? this.sessionTileStyle,
    );
  }
}

/// Style for the side panel search bar.
class ButterSidePanelSearchStyle {
  const ButterSidePanelSearchStyle({
    this.backgroundColor,
    this.borderRadius,
    this.hintStyle,
    this.textStyle,
    this.iconColor,
  });

  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color? iconColor;

  ButterSidePanelSearchStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    TextStyle? hintStyle,
    TextStyle? textStyle,
    Color? iconColor,
  }) {
    return ButterSidePanelSearchStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      hintStyle: hintStyle ?? this.hintStyle,
      textStyle: textStyle ?? this.textStyle,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}

/// Style for individual session tiles in the side panel.
class ButterSessionTileStyle {
  const ButterSessionTileStyle({
    this.activeBackgroundColor,
    this.hoverBackgroundColor,
    this.titleStyle,
    this.subtitleStyle,
    this.timestampStyle,
    this.padding,
    this.borderRadius,
  });

  final Color? activeBackgroundColor;
  final Color? hoverBackgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? timestampStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  ButterSessionTileStyle copyWith({
    Color? activeBackgroundColor,
    Color? hoverBackgroundColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? timestampStyle,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return ButterSessionTileStyle(
      activeBackgroundColor:
          activeBackgroundColor ?? this.activeBackgroundColor,
      hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      timestampStyle: timestampStyle ?? this.timestampStyle,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
