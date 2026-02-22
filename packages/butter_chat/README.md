# ButterChat

An AI chat widget for Flutter with streaming, plan/thinking mode, message branching, and markdown rendering.

## Features

- **Streaming** — display responses token by token
- **Plan/thinking mode** — collapsible thinking section that auto-expands during generation
- **Message branching** — edit messages or regenerate responses to create conversation branches
- **Branch navigation** — navigate between alternative branches with `< 1/2 >` arrows
- **Markdown** — AI-optimized rendering via `gpt_markdown` with code block copy buttons
- **Status indicators** — labeled status bar ("Searching...", "Analyzing...")
- **Message actions** — copy, edit, regenerate buttons
- **Customizable** — full style system with theme-derived defaults and builder overrides

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  butter_chat: ^0.1.0
```

## Quick Start

```dart
import 'package:butter_chat/butter_chat.dart';

final controller = ButterChatController();

ButterChatView(
  controller: controller,
  onSendMessage: (text) async {
    controller.addUserMessage(id: 'u1', content: text);

    final assistantId = 'a1';
    controller.addAssistantMessage(id: assistantId, parentId: 'u1');
    controller.setMessageStatus(assistantId, ButterChatMessageStatus.streaming);

    await for (final token in yourLLMStream) {
      controller.appendContent(assistantId, token);
    }

    controller.setMessageStatus(assistantId, ButterChatMessageStatus.complete);
  },
  onStopGeneration: () => controller.stopStreaming(),
);
```

## Usage

### Controller

`ButterChatController` manages the conversation tree. It does **not** make network calls — your code drives streaming.

| Method | Purpose |
|--------|---------|
| `addUserMessage(id, content)` | Add a user message |
| `addAssistantMessage(id)` | Add assistant placeholder for streaming |
| `appendContent(id, token)` | Append token during streaming |
| `appendThinkingContent(id, token)` | Append to thinking/plan section |
| `setMessageStatus(id, status)` | Update message status |
| `setStatusLabel(label)` | Set status bar text |
| `stopStreaming()` | Stop current generation |
| `editUserMessage(id, newContent, newId)` | Create branch from edit |
| `regenerateResponse(id, newId)` | Create sibling branch |
| `switchBranch(id, index)` | Navigate between branches |
| `activeMessages` | Linear path through tree (what to display) |
| `isStreaming` | Whether any message is streaming |

### Plan/Thinking Mode

```dart
controller.setMessageStatus(id, ButterChatMessageStatus.thinking);
controller.setStatusLabel('Analyzing...');
controller.appendThinkingContent(id, 'Let me consider...');

// Switch to streaming response
controller.setMessageStatus(id, ButterChatMessageStatus.streaming);
controller.setStatusLabel(null);
controller.appendContent(id, 'Here is my answer...');
```

### Branching

```dart
// Edit a user message (creates new branch)
controller.editUserMessage('msg1', 'New content', newId: 'msg1b');

// Regenerate an assistant response (creates sibling)
controller.regenerateResponse('msg2', newId: 'msg2b');

// Navigate between branches
controller.switchBranch('parentId', 0); // first branch
controller.switchBranch('parentId', 1); // second branch
```

### Style Customization

```dart
ButterChatView(
  controller: controller,
  onSendMessage: (text) { ... },
  style: ButterChatStyle(
    backgroundColor: Colors.grey[50],
    messageSpacing: 12,
    bubbleStyle: ButterBubbleStyle(
      userBackgroundColor: Colors.blue[100],
      assistantBackgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    inputStyle: ButterInputStyle(
      hintText: 'Ask anything...',
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);
```

### Builder Overrides

```dart
ButterChatView(
  controller: controller,
  onSendMessage: (text) { ... },
  markdownBuilder: (context, content) => MyCustomMarkdown(content),
  codeBlockBuilder: (context, code, lang) => MyCodeBlock(code, lang),
  welcomeBuilder: (context) => MyWelcomeScreen(),
  messageBubbleBuilder: (context, message, child) => Card(child: child),
);
```

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `controller` | `ButterChatController` | Required. Manages conversation state. |
| `onSendMessage` | `ValueChanged<String>` | Required. Called when user sends a message. |
| `onStopGeneration` | `VoidCallback?` | Called when user stops generation. |
| `onEditMessage` | `ValueChanged<String>?` | Called when user edits a message. |
| `onRegenerateResponse` | `ValueChanged<String>?` | Called when user regenerates. |
| `onCopyMessage` | `ValueChanged<String>?` | Called when user copies a message. |
| `style` | `ButterChatStyle?` | Style configuration. |
| `markdownBuilder` | `Function?` | Custom markdown renderer. |
| `codeBlockBuilder` | `Function?` | Custom code block renderer. |
| `welcomeBuilder` | `WidgetBuilder?` | Custom empty state widget. |
| `messageBubbleBuilder` | `Function?` | Wraps each message bubble. |
| `inputFocusNode` | `FocusNode?` | Focus node for input field. |
