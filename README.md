# FlutterLane 飞道布局引擎

> Flutter 桌面端专属、自研 IDE 级分层布局引擎

[English](README.en.md) · [Gitee](https://gitee.com/flutterlane/flutterlane) · [GitHub](https://github.com/flutterlane/flutterlane)

---

FlutterLane 是一款 **Flutter 桌面端专属**的分层 IDE 级布局引擎库。独创「泳道 → 分组 → 标签页」三层布局架构，复刻 VSCode + Chrome 双端交互范式，为桌面端复杂工作台、IDE、可视化编辑器提供专业级布局能力。

## 核心特性

- **三层泳道架构**：Swimlane（横向泳道）→ Section（垂直分组）→ Pane（标签页），层级严格隔离
- **全层级拖拽**：支持跨泳道 Section 迁移、跨 Section Pane 迁移，自由重组布局
- **热区无占位新增**：泳道右侧、Section 底部悬浮热区 hover 触发新增，常态零 UI
- **Section 折叠/展开**：内容区隐藏，TabBar 永久常驻
- **多布局快照**：保存/切换/重命名/删除/设为默认/一键重置
- **内置本地持久化**：零后端依赖，布局变更自动写入 `.flutterlane/` 本地目录
- **内置 3 套主题**：经典亮色 / 暗黑极致 / 纯净极简，支持跟随系统自适应
- **自定义主题**：27 个颜色属性完整控制，自动序列化持久化
- **Workspace 隔离**：多个工作区完全独立，无共享状态
- **注册式视图体系**：业务注册视图，引擎接管一切布局交互
- **零外部后端依赖**：能力完全内聚，纯端内闭环

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutterlane: ^1.0.0
```

执行：

```bash
flutter pub get
```

> 要求 Flutter SDK >= 3.10.0，Dart SDK >= 3.0.0

## 快速开始

### 1. 创建 Workspace 和 Manager

```dart
import 'package:flutterlane/flutterlane.dart';

final workspace = Workspace.defaults(
  workspaceId: 'my-workspace',
  workspaceName: 'My Workspace',
);
final manager = FlutterLaneManager(workspace: workspace);
await manager.init();
```

### 2. 注册业务视图

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

### 3. 添加泳道和分组

```dart
manager.addSwimlane();
manager.addSectionToSwimlane(0);
manager.addPaneToSection(0, 0, Pane(
  viewInstance: ViewInstance(viewTypeId: 'editor'),
));
```

### 4. 渲染布局

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

## 主题系统

### 内置主题

```dart
// 切换主题
await manager.themeManager.setTheme(FlutterLaneThemeType.dark);

// 循环切换（light → dark → pure → light …）
await manager.themeManager.cycleTheme();
```

### 自定义主题

```dart
manager.setCustomTheme(const FlutterLaneThemeData(
  swimlaneBackground: Color(0xFF1A1A2E),
  sectionBackground: Color(0xFF16213E),
  tabBarBackground: Color(0xFF0F3460),
  // ... 共 27 个颜色属性
));

// 清除自定义主题，恢复内置主题
manager.setCustomTheme(null);
```

### 跟随系统

```dart
await manager.themeManager.setFollowSystem(true);
await manager.themeManager.adaptToSystem(Brightness.dark);
```

## 多工作区隔离

```dart
final crmManager = FlutterLaneManager(workspace: Workspace.defaults(
  workspaceId: 'crm',
  workspaceName: 'CRM',
));
final productManager = FlutterLaneManager(workspace: Workspace.defaults(
  workspaceId: 'product',
  workspaceName: 'Product',
));

// 切换工作区：在 widget tree 中替换 manager
setState(() => _activeManager = crmManager);
```

每个工作区拥有独立的布局快照、主题设置、视图注册中心，互不干扰。

## 多布局快照

```dart
// 另存为新布局
await manager.saveAsNewLayout('My Layout');

// 切换布局
await manager.switchToLayout(layout.snapshotId);

// 重命名
await manager.renameLayout(layout.snapshotId, 'Renamed');

// 删除（保护系统默认和当前激活布局）
await manager.deleteLayout(layout.snapshotId);

// 设为默认
await manager.setDefaultLayout(layout.snapshotId);

// 一键重置为系统默认
await manager.resetToDefaultLayout();
```

布局变更自动持久化，无需手动保存。

## 注册中心

```dart
// 面板视图
manager.registry.registerPaneView(ViewInstanceMeta(...));

// 顶层窗口视图
manager.registry.registerWindowView(WindowViewMeta(...));

// 顶部操作按钮
manager.registry.registerHeaderAction(HeaderActionMeta(...));

// 底部状态栏
manager.registry.registerStatusBarItem(StatusBarItemMeta(...));
```

## 数据模型

```
Workspace
  └── FlutterLaneManager（scoped to workspace）
        ├── LayoutStorage（workspace 隔离）
        ├── ThemeManager（workspace 隔离）
        ├── FlutterLaneRegistry（视图注册中心）
        └── LayoutState（布局快照）
              └── Swimlane（横向泳道）
                    └── Section（垂直分组）
                          └── Pane（标签页）
                                └── ViewInstance（业务视图实例）
```

## 存储结构

```
.flutterlane/
  └── workspaces/
        └── {workspaceId}/
              ├── layouts.json     # 布局快照列表
              ├── active_id.txt    # 当前激活布局 ID
              └── theme.json       # 主题设置（含自定义主题）
```

多应用、多工作区配置完全隔离，互不干扰。

## 边界约束

| 规则 | 说明 |
|------|------|
| 允许空白工作台 | 用户可删除全部泳道 |
| 自动兜底 Section | 泳道清空后自动注入占位 Section |
| 禁止空 Pane | 所有标签页必须绑定有效视图 |
| 最小尺寸兜底 | 保证内容不截断、双向滚动 |
| 跨层拖拽安全 | 迁移后视图状态完整保留 |
| 主题仅改视觉 | 不改变任何布局结构和交互逻辑 |

## 测试

```bash
flutter test test/
```

## 参与贡献

1. Fork 本仓库
2. 新建 `Feat_xxx` 分支
3. 提交代码
4. 新建 Pull Request

## 开源协议

MIT License
