# Cursor Buddy - Product Requirements

## Vision
An AI companion that extends OpenClaw's senses onto your computer. It observes your workflows, learns your patterns, and proactively suggests ways I (Molty) can help automate repetitive tasks.

**Not just a cute floating bubble** - this is the eyes and ears that let me actually understand what you're doing so I can be more helpful.

## Inspiration
- [@FarzaTV's cursor buddy](https://x.com/FarzaTV/status/1976456495132025030) - "ai cursor that lives on my screen as a buddy + recommends me new stuff"
- His key insight: "cursor form factor doesn't feel intrusive"

## Core Features

### 1. Workflow Observer
- **Screen awareness**: Capture what's happening on screen
- **App detection**: Know which app is active (Figma, Chrome, Terminal, etc.)
- **Action tracking**: Observe click patterns, keyboard shortcuts, sequences
- **Pattern recognition**: Identify repetitive multi-step tasks

### 2. Proactive Suggestions
When the companion notices a pattern:
> "Hey, I noticed you copy from Figma → paste into Notion → format as bullet points about 5x today. Want me to turn this into a workflow I can do for you?"

### 3. OpenClaw Integration
- Sends observations back to OpenClaw (me)
- I can then offer to automate via existing tools (browser, exec, etc.)
- Creates a feedback loop: observe → suggest → automate → learn

### 4. Cursor Companion UI
- Small, non-intrusive floating window near cursor
- Click-through by default (doesn't block work)
- Pops up with messages when it has something useful
- Keyboard shortcuts to toggle visibility/following

## Technical Requirements

### Platform
- **macOS native (Swift/SwiftUI)**
- Menu bar app with floating companion window
- Accessibility APIs for action observation
- Screen capture for visual context

### Privacy & Security
- All processing local by default
- User controls what gets observed
- Explicit consent before sending anything to OpenClaw
- No keylogging of sensitive fields (passwords, etc.)

### Permissions Needed
- Screen Recording (for visual context)
- Accessibility (for action observation)

## Architecture

```
┌─────────────────────────────────────────────┐
│              Cursor Buddy App               │
├─────────────────────────────────────────────┤
│  ┌─────────┐  ┌──────────┐  ┌───────────┐  │
│  │ Screen  │  │ Action   │  │ Pattern   │  │
│  │ Capture │→ │ Observer │→ │ Detector  │  │
│  └─────────┘  └──────────┘  └───────────┘  │
│                                     │       │
│                              ┌──────▼─────┐ │
│                              │ Suggestion │ │
│                              │  Engine    │ │
│                              └──────┬─────┘ │
│                                     │       │
│  ┌─────────────────────────────────▼─────┐ │
│  │         Floating Companion UI         │ │
│  └───────────────────────────────────────┘ │
│                      │                      │
└──────────────────────┼──────────────────────┘
                       │
                       ▼
              ┌────────────────┐
              │    OpenClaw    │
              │  (automation)  │
              └────────────────┘
```

## MVP Scope (v0.1)

1. ✅ Floating companion window that follows cursor
2. [ ] Swift/macOS rewrite (replace Electron)
3. [ ] Screen capture on demand
4. [ ] Active app detection
5. [ ] Send context to OpenClaw on request
6. [ ] Basic "what am I looking at?" analysis

## Future (v0.2+)

- Action sequence tracking
- Pattern detection
- Proactive workflow suggestions
- Workflow recording ("watch me do this")
- One-click "automate this" to OpenClaw

## Success Metrics

- I (Molty) can see what you're working on
- I can proactively suggest helpful automations
- You feel like I'm actually present on your machine, not just in a chat window
