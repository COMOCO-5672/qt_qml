---
name: qt-qml-code-guidelines
description: Qt/QML architecture, code style, event-handling, ViewModel, model/delegate, deployment, and security guardrails for maintainable QML applications. Use when Codex creates, edits, reviews, or refactors Qt Quick/QML, JavaScript helpers used by QML, C++ QObject ViewModels exposed to QML, QAbstractItemModel classes consumed by QML, qrc resource packaging, or QML release/deployment guidance.
---

# Qt QML Code Guidelines

## Overview

Use this skill to keep QML as a thin declarative view layer and push business state, validation, IO, models, and security-sensitive logic into C++ ViewModels, models, services, or server-side code.

## First Checks

- Read the nearest project guideline first if present: `docs/QML_CODE_STANDARD.md`.
- Prefer existing project components, style tokens, ViewModels, models, and QML import patterns.
- Treat QML/JS as easier to inspect or reverse than compiled C++; never place secrets, license checks, or core proprietary algorithms there.

## Architecture Rules

Keep responsibilities separated:

- QML: layout, visual state, animations, input event entry points, lightweight formatting.
- C++ ViewModel: state, commands, validation, derived properties, business decisions.
- C++ Model: large lists/tables/trees via `QAbstractListModel`, `QAbstractTableModel`, or proxy models.
- Service/server: IO, network, database, licensing, encryption, secrets, long-running work.

When editing QML, avoid adding business logic directly to event handlers. Prefer:

```qml
Button {
    enabled: userVM.canSave
    onClicked: userVM.save()
}
```

Avoid:

```qml
Button {
    onClicked: {
        // validation, branching, IO, persistence, licensing, etc.
    }
}
```

## QML Style Rules

Follow Qt's declaration order:

1. `id`
2. `property`
3. `signal`
4. JavaScript functions
5. ordinary object properties
6. `states` / `transitions`
7. child objects

Use `id: root` for component roots. Use semantic ids such as `saveButton`, `nameField`, `userList`.

Use explicit parent/component ids instead of unqualified lookups:

```qml
Item {
    id: root
    property int rowHeight: 36

    Rectangle {
        height: root.rowHeight
    }
}
```

Extract repeated UI into QML components. Expose only necessary `property`, `property alias`, and `signal`; do not rely on external access to internal ids.

## Binding Rules

Prefer simple bindings:

```qml
enabled: userVM.canSave
text: userVM.statusText
```

Move repeated or business-heavy predicates into ViewModel properties. Remember that direct assignment breaks an existing binding; only use `Qt.binding(...)` intentionally for examples or controlled dynamic rebinding.

## Event Rules

Use local QML handlers for local UI interaction:

- `TapHandler` / `MouseArea` for clicks.
- `HoverHandler` for hover.
- `DragHandler` for drag.
- `WheelHandler` for wheel.
- `Keys` for focused keyboard handling.
- `Action` / `Shortcut` for shared commands.

Use C++ `installEventFilter` or a custom `QQuickItem` only for global, native, hardware, input-method, or low-level event interception.

If an event handler exceeds about 5 lines, extract a function or call a ViewModel command. If a QML/JS function exceeds about 15 lines, strongly prefer C++.

## C++ Exposure Rules

Expose bindable state with `Q_PROPERTY(... NOTIFY ...)`. Setters must ignore unchanged values and emit all dependent property notifications.

```cpp
Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
Q_PROPERTY(bool canSave READ canSave NOTIFY canSaveChanged)
Q_INVOKABLE void save();
```

QML should call ViewModel commands and bind to ViewModel properties; it should not directly coordinate services.

## Deployment And Security Rules

Use qrc resources for project QML/JS and load entry QML via `qrc:/` or `qrc:///`. Do not deploy the project's source QML tree as loose files unless explicitly required for plugins or user customization.

Do not claim QRC, qmlcachegen, or Qt Quick Compiler is encryption. They reduce loose source exposure and can improve startup or compile-time diagnostics, but determined users may still inspect resources or reverse engineer binaries.

For sensitive logic, move it out of QML/JS. For commercial releases, also ensure release builds do not expose QML debugging endpoints.

## Review Checklist

Before finishing a QML change, check:

- QML events only call ViewModel commands or emit component signals.
- No secrets, license checks, or core algorithms live in QML/JS.
- Repeated UI is a component.
- Business predicates are ViewModel properties.
- `Q_PROPERTY` has accurate `NOTIFY`.
- List delegates are thin.
- Project QML/JS is packaged through qrc or Qt 6 QML modules.
- Build or smoke test was run when feasible.
