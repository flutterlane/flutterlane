# FlutterLane — IDE-Level Layout Engine for Flutter Desktop

> A professional, layered layout engine built exclusively for Flutter desktop applications.

[中文](README.md) · [Gitee](https://gitee.com/flutterlane/flutterlane) · [GitHub](https://github.com/flutterlane/flutterlane)

---

FlutterLane is a **Flutter desktop-exclusive** IDE-grade layout engine. It introduces a unique **Swimlane → Section → Pane** three-layer architecture that replicates the interaction paradigms of VSCode and Chrome, delivering professional-grade layout capabilities for complex workbenches, IDEs, and visual editors.

## Key Features

- **Three-Layer Architecture**: Swimlane (horizontal) → Section (vertical group) → Pane (tab), strictly isolated layers
- **Cross-Layer Drag & Drop**: Move Sections across swimlanes, move Panes across sections — free layout composition
- **Hover Zone Adding**: Swimlane right-side and Section bottom hot zones add new elements on hover with zero persistent UI
- **Section Collapse/Expand**: Content area hides, TabBar stays permanently visible
- **Multi-Layout Snapshots**: Save / switch / rename / delete / set default / one-click reset
- **Built-in Local Persistence**: Zero backend dependency, auto-saves to `.flutterlane/` local directory
- **3 Built-in Themes**: Light / Dark / Pure, with system-adaptive support
- **Custom Themes**: Full control over 27 color properties, auto-serialized and persisted
- **Workspace Isolation**: Multiple workspaces are fully independent with no shared state
- **Pluggable Registry**: Business registers views, engine handles all layout interactions
- **Zero External Dependencies**: Fully self-contained, pure client-side

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutterlane: ^1.0.0
```

Then run:

```bash
flutter pub get
```

> Requires Flutter SDK >= 3.10.0, Dart SDK >= 3.0.0

## Quick Start

### 1. Create a Workspace and Manager

```dart
import 'package:flutterlane/flutterlane.dart';

final workspace = Workspace.defaults(
  workspaceId: 'my-workspace',
  workspaceName: 'My Workspace',
);
final manager = FlutterLaneManager(workspace: workspace);
await manager.init();
```

### 2. Register Business Views

```dart
manager.registry.registerPaneView(const ViewInstanceMeta(
  viewTypeId: 'editor',
  viewDisplayName: 'Editor',
  icon: Icons.code,
  viewBuilder: (ctx, context, state) => EditorWidget(),
));

manager.registry.registerPaneView(const ViewInstanceMeta(
  viewTypeId: 'terminal',
  viewDisplayName: 'Terminal',
  icon: Icons.terminal,
  viewBuilder: (ctx, context, state) => TerminalWidget(),
));
```

### 3. Add Swimlanes and Sections

```dart
manager.addSwimlane();
manager.addSectionToSwimlane(0);
manager.addPaneToSection(0, 0, Pane(
  viewInstance: ViewInstance(viewTypeId: 'editor'),
));
```

### 4. Render the Layout

```dart
FlutterLaneWorkbench(
  manager: manager,
  onTabTap: (paneId, sectionId) {},
  onClosePane: (paneId, sectionId) {},
  onAddPane: (sectionId) {},
  onAddSwimlane: () {},
  onAddSection: (swimlaneId) {},
)
```

## Theme System

### Built-in Themes

```dart
// Switch to a specific theme
await manager.themeManager.setTheme(FlutterLaneThemeType.dark);

// Cycle through themes (light → dark → pure → light …)
await manager.themeManager.cycleTheme();
```

### Custom Themes

```dart
manager.setCustomTheme(const FlutterLaneThemeData(
  swimlaneBackground: Color(0xFF1A1A2E),
  sectionBackground: Color(0xFF16213E),
  tabBarBackground: Color(0xFF0F3460),
  // ... all 27 color properties
));

// Clear custom theme, revert to built-in
manager.setCustomTheme(null);
```

### System Adaptive

```dart
await manager.themeManager.setFollowSystem(true);
await manager.themeManager.adaptToSystem(Brightness.dark);
```

## Multi-Workspace Isolation

```dart
final crmManager = FlutterLaneManager(workspace: Workspace.defaults(
  workspaceId: 'crm',
  workspaceName: 'CRM',
));
final productManager = FlutterLaneManager(workspace: Workspace.defaults(
  workspaceId: 'product',
  workspaceName: 'Product',
));

// Switch workspace by swapping the manager in the widget tree
setState(() => _activeManager = crmManager);
```

Each workspace maintains independent layout snapshots, theme settings, and view registry — no cross-workspace state leakage.

## Layout Snapshots

```dart
// Save as new layout
await manager.saveAsNewLayout('My Layout');

// Switch layout
await manager.switchToLayout(layout.snapshotId);

// Rename
await manager.renameLayout(layout.snapshotId, 'Renamed');

// Delete (system default and active layout are protected)
await manager.deleteLayout(layout.snapshotId);

// Set as default
await manager.setDefaultLayout(layout.snapshotId);

// Reset to system default
await manager.resetToDefaultLayout();
```

All changes are auto-persisted — no manual save required.

## Registry

```dart
// Pane views
manager.registry.registerPaneView(ViewInstanceMeta(...));

// Top-level window views
manager.registry.registerWindowView(WindowViewMeta(...));

// Header action buttons
manager.registry.registerHeaderAction(HeaderActionMeta(...));

// Status bar items
manager.registry.registerStatusBarItem(StatusBarItemMeta(...));
```

## Data Model

```
Workspace
  └── FlutterLaneManager (scoped to workspace)
        ├── LayoutStorage (workspace-isolated)
        ├── ThemeManager (workspace-isolated)
        ├── FlutterLaneRegistry (view registry)
        └── LayoutState (layout snapshot)
              └── Swimlane (horizontal lane)
                    └── Section (vertical group)
                          └── Pane (tab)
                                └── ViewInstance (business view instance)
```

## Storage Structure

```
.flutterlane/
  └── workspaces/
        └── {workspaceId}/
              ├── layouts.json     # layout snapshots
              ├── active_id.txt    # active layout ID
              └── theme.json       # theme settings (including custom theme)
```

Multi-app and multi-workspace configurations are fully isolated.

## Boundary Constraints

| Rule | Description |
|------|-------------|
| Empty workspace allowed | Users can delete all swimlanes |
| Auto-injected Section | Empty swimlane gets a placeholder Section |
| No empty Panes | Every tab must bind a valid view |
| Minimum size safety | Bidirectional scrolling prevents content truncation |
| Cross-layer drag safety | View state fully preserved after migration |
| Theme is visual-only | No layout structure or interaction logic changes |

## Testing

```bash
flutter test test/
```

## Contributing

1. Fork the repository
2. Create a `Feat_xxx` branch
3. Commit your code
4. Create a Pull Request

## License

MIT License
