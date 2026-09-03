# 命名调整定稿
> 将内部的 `TabBar` 重命名为 **SectionTabBar**，用来和顶层的 `WindowTabBar`（HeaderBar里Chrome浏览器风格顶层标签）做明确区分，消除命名混淆。

- `WindowTabBar`：位于 HeaderBar，全局顶层浏览器式标签，绑定 `ViewInstance`，类似Chrome网页标签。
- `SectionTabBar`：属于Section内部，永久渲染；左侧▶/▼折叠开关、中间若干带关闭×的Tab、右侧`+`下拉视图选择器。

## 更新后 Widget层级
```
HeaderBar
├─ CompactSystemMenu
├─ WindowTabBar      // 顶层浏览器标签栏
└─ HeaderActionBar

↓

SwimlanesArea【Row横向排布】
    ├─ Swimlane A
    │    └─ Column 垂直堆叠若干 Section
    │         └─ Section
    │              ├─ SectionTabBar【永久渲染】
    │              │   ├─ 最左侧：▶/▼ 整块Section折叠开关
    │              │   ├─ 多个平级Tab，每个Tab附带关闭×
    │              │   └─ 最右侧：+下拉选择视图类型
    │              └─ if(isExpanded == true) → 渲染active Pane的 ViewInstance内容
    └─ Swimlane B

↓

StatusBar
```

## Dart伪代码更新
```dart
// Section内部渲染
Widget build(BuildContext context) {
  return Column(
    children: [
      // 重命名：SectionTabBar，不再叫TabBar
      SectionTabBar(
        toggleIcon: section.isExpanded ? Icons.expand_more : Icons.chevron_right,
        panes: section.panes,
        activePaneId: section.activePaneId,
        onToggleSectionExpand: () { /*切换 isExpanded */ },
        onSelectPane: (paneId) {},
        onClosePane: (paneId) {},
        onAddViewSelect: (viewTypeId) {},
      ),
      if (section.isExpanded)
        ActivePaneContentView(pane: activePane),
    ],
  );
}
```

### 两者职责边界再梳理
|组件|位置|作用|
|---|---|---|
|`WindowTabBar`|HeaderBar顶部行|全局顶层标签，类似Chrome网页Tab；打开业务对象实例|
|`SectionTabBar`|Section内部|容器内面板标签，对标VSCode底部面板tab集合；受Section ▶/▼整体折叠控制|

整套数据模型、交互逻辑、序列化规则全部保持不变，仅做标识符改名，避免后续开发时两个TabBar混淆。
