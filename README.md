# Cursor Buddy 🦞

An AI companion that lives near your cursor and helps you as you work.

Inspired by [@FarzaTV's cursor buddy concept](https://x.com/FarzaTV/status/1976456495132025030).

## Features

- **Floating companion** - Small, non-intrusive window that follows your cursor
- **Screen awareness** - Can capture and analyze what you're looking at
- **Keyboard shortcuts**:
  - `⌘⇧B` - Toggle visibility
  - `⌘⇧F` - Toggle cursor following

## Getting Started

```bash
npm install
npm start
```

## Permissions

On macOS, you'll need to grant:
- **Screen Recording** permission (for screen capture/analysis)

## Architecture

- **Electron** - Cross-platform desktop app framework
- **Transparent window** - Always-on-top, click-through overlay
- **Cursor tracking** - Follows mouse position with smooth offset

## Roadmap

- [ ] Vision API integration (Claude/GPT-4V) for screen analysis
- [ ] Proactive suggestions based on context
- [ ] Integration with OpenClaw for deeper awareness
- [ ] Custom personas/avatars
- [ ] Plugin system for app-specific tips

## License

MIT
