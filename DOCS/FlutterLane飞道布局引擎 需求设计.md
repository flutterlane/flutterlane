0. 开源架构核心总纲（最终硬性定稿）
FlutterLane（飞道布局引擎）：Flutter 桌面端专属、自研分层 IDE 级布局开源库。
本框架完全独立内聚、零外部依赖、零后端绑定、零业务侵入，不以任何 Rust 服务、本地数据库、云端接口、业务工程作为运行前置依赖。所有布局状态、快照存储、配置读写、布局推演、交互逻辑全部由库内部闭环实现，是纯粹的「端内布局引擎 SDK」，可独立作为 Pub 开源包被任意 Flutter 桌面项目集成。
核心定位：不是普通 Flex/Stack 控件封装，是面向 IDE 工作台、可视化编辑器、复杂多面板桌面应用的专业布局引擎。
1. 整体架构分层总览
FlutterLane 采用自研三层分层泳道布局架构，自上而下层级严格隔离、职责单一、边界固化，所有交互、拖拽、状态、渲染均遵循层级约束，杜绝跨层污染、布局塌陷、滚动穿透等问题。
1.1 三层核心层级模型（固化不可修改）
- Swimlane 横向泳道（一级容器）：负责横向多列布局、左右尺寸Resize、横向拖拽排序，是最顶层布局容器，支持用户自由增删、清空。
- Section 垂直分组面板（二级容器）：隶属于单个泳道，负责垂直堆叠布局、上下高度Resize、垂直拖拽排序、整体折叠/展开。用户层面无删除限制，可清空单泳道全部Section，引擎底层自动注入空白占位Section做结构兜底，杜绝布局塌陷，用户无感知、布局结构永远合法稳定。
- Pane 视图标签页（三级容器）：隶属于单个Section，承载具体业务视图 ViewInstance，支持 Tab 切换、Tab 拖拽排序、关闭销毁，禁止空Pane，所有Pane必须绑定有效业务视图。
2. 核心交互范式（VSCode + Chrome 商用级定稿）
FlutterLane 统一融合主流桌面商用软件交互心智，全链路交互对标 VSCode 面板体系 + Chrome 标签体系，交互逻辑成熟统一、无自定义怪异逻辑。
2.1 悬浮热区无占位新增范式
- 新增泳道：泳道右侧悬浮热区 hover 触发，常态无UI、零占位。
- 新增分组：单泳道底部悬浮热区 hover 触发，常态无UI、零占位。
- 新增视图：Section TabBar 常驻+按钮，快速新增注册视图。
2.2 拖拽与Resize规则定稿
- 泳道：支持左右拖拽排序、左右分割条Resize宽度、最小宽度限制兜底。
- Section：同泳道内支持上下拖拽排序、垂直分割条Resize高度；收缩状态禁用Resize。
- Pane Tab：同Section内支持左右拖拽排序，状态实时保存。
- 全层级自由拖拽迁移（开源高灵活定稿）：彻底放开跨层级隔离限制，支持 Section 跨任意泳道迁移、支持 Pane 跨任意 Section/任意泳道拖拽迁移，用户可自由重组整个工作台布局，最大化自定义自由度；框架仅保留结构合法性兜底，不限制用户布局组合。
2.3 Section 折叠/展开规则
- 收缩状态：仅隐藏业务内容区，Section TabBar 永久常驻，所有按钮可正常交互。
- 自动展开触发：收缩状态下点击Tab、新增Pane、新增Section，自动展开内容区。
- 折叠状态参与全局布局快照持久化，重启/切换布局不丢失。
3. 视图滚动隔离机制（引擎核心独创能力）
FlutterLane 内置固化壳层固定、内容滚动隔离机制，彻底解决 Flutter 桌面端布局滚动冲突、裁切、穿透、错乱问题。
- 可滚动区域：仅 ViewInstance 纯业务内容区。
- 固定不滚动区域：所有 TabBar、标题栏、操作按钮、悬浮层、分割条、状态栏。
- 双向自适应：内容超宽自动水平滚动、内容超高自动垂直滚动；内容不足无多余滚动条。
- 滚动位置缓存：切Tab、折叠展开、Resize、重启布局，保留上次滚动偏移，不强制置顶。
- 悬浮层防裁切：所有下拉、Tooltip、悬浮按钮挂载布局壳层，永远置顶不被内容滚动裁切。
4. 多布局快照系统（内置本地持久化·完全内聚）
本模块为框架内置原生能力，无需任何后端、数据库、第三方存储依赖，彻底内聚在 FlutterLane 库内部，是开源独立库的核心标志性能力。
4.1 存储架构定稿（零外部依赖）
- 库内部自建文件持久化逻辑，自动读写用户本地隐藏目录：.flutterlane/
- 所有布局快照、配置、状态全部以结构化 JSON 本地文件托管，存放于应用工作目录，多应用完全独立隔离、互不干扰，纯端内闭环。
- 完全剥离历史 Rust_peer/后端存储依赖，开源版本不感知任何业务后台服务。
4.2 布局快照核心规则
- 实时自动覆盖保存：用户任意布局变更（拖拽、Resize、增删、折叠、排序、切Tab）自动覆盖当前激活布局快照。
- 多套快照命名管理：支持用户手动「另存为新布局」、重命名、删除、设为默认。
- 系统默认布局兜底：内置不可删除、不可篡改的系统默认布局，支持 HeaderBar 一键重置恢复。
- 快照隔离边界：仅持久化 FlutterLane 工作台布局，完全不影响顶层业务 Tab 页面、业务上下文数据。
5. 通用可插拔注册架构（开源解耦核心）
FlutterLane 彻底实现布局引擎与业务完全解耦，对外提供统一全局注册中心，业务只需要注册视图与组件，无需关心任何底层布局交互逻辑，真正做到「业务只写UI，引擎接管一切」。
5.1 全局唯一注册中心
统一入口：FlutterLaneRegistry
四大可插拔注册维度，全覆盖桌面应用顶层界面能力：
- WindowView：顶层全局标签页视图注册
- PaneView：工作台面板业务视图注册
- HeaderAction：顶部操作栏按钮/菜单注册
- StatusBarItem：底部状态栏组件注册
6. 完整最终定稿数据模型（Dart 扁平化、可直接落库）
所有模型扁平化设计、无嵌套冗余、无运行时临时字段、全部可序列化、全部可本地持久化，适配 .flutterlane 文件存储规范。
// ====================== 顶层布局快照模型（单模型闭环） ======================
/// 单套完整布局快照，可直接本地JSON落库
class LayoutState {
  final String snapshotId;           // 唯一UUID主键
  String layoutName;                 // 用户自定义布局名
  final bool isSystemDefault;        // 系统默认不可删改
  bool isCurrentActive;              // 当前全局唯一激活布局

  final int createTime;
  int updateTime;

  List<Swimlane> swimlanes;          // 完整布局结构
}

// 横向泳道
class Swimlane {
  final String id;
  double flex;
  double minWidth;
  final List<Section> sections;
}

// 垂直分组面板
class Section {
  final String sectionId;
  String title;
  IconData? icon;
  bool isExpanded;
  double? flex;
  List<Pane> panes;
  String? activePaneId;
}

// 视图标签载体
class Pane {
  final String paneId;
  final ViewInstance viewInstance;
}

// 业务视图实例（带状态缓存）
class ViewInstance {
  final String viewTypeId;
  final String businessContext;
  final Map<String,dynamic> viewState;
}

6.1 本地存储规则定稿
- 存储根目录：./.flutterlane/当前应用工作目录下的隐藏目录 ，隔离多应用配置，避免不同FlutterLane应用全局目录互相覆盖冲突
- 文件格式：标准结构化 JSON，可读性强、无加密、开源透明
- 存储内容：全部 LayoutState 快照列表、当前激活快照ID、基础引擎配置
- 读写时机：布局变更自动增量写入、引擎启动全量读取
- 权限隔离：系统默认布局只读、用户自定义布局可完全编辑
7. 全套注册元数据结构体（开源SDK对外API定稿）
/// 全局唯一注册中心
class FlutterLaneRegistry {
  void registerWindowView(WindowViewMeta meta);
  void registerPaneView(ViewInstanceMeta meta);
  void registerHeaderAction(HeaderActionMeta meta);
  void registerStatusBarItem(StatusBarItemMeta meta);
}

/// 顶层窗口视图注册元数据
class WindowViewMeta {
  final String viewTypeId;
  final String viewName;
  final IconData icon;
  final bool canPinned;
  final bool keepAlive;
  final Widget Function(BuildContext context) viewBuilder;
  final List<String> supportBusinessContexts;
}

/// 工作台面板视图注册元数据
class ViewInstanceMeta {
  final String viewTypeId;
  final String viewDisplayName;
  final IconData icon;
  final bool isSystemBuiltIn;
  final List<String> supportBusinessContexts;
  final Widget Function(BuildContext context, String businessContext, Map<String, dynamic> viewState) viewBuilder;
  final Map<String, dynamic> defaultViewState;
}

/// 顶部操作按钮注册元数据
class HeaderActionMeta {
  final String actionId;
  final String actionName;
  final IconData icon;
  final String? shortcutKey;
  final bool disabled;
  final VoidCallback onTap;
  final List<String>? bindBusinessContexts;
  final bool alwaysVisible;
}

/// 状态栏组件注册元数据
class StatusBarItemMeta {
  final String itemId;
  final int sortWeight;
  final IconData? icon;
  String Function() textBuilder;
  final String? tooltip;
  final bool isSpacer;
  final List<String>? bindBusinessContexts;
  final VoidCallback? onTap;
}

8. 内置主题体系设计（开源原生能力）
FlutterLane 布局引擎原生内置多套主题方案，零UI框架依赖、零外部主题包依赖，主题能力完全内聚库内部。支持全局一键切换、主题状态本地持久化、跟随系统自适应，统一整套布局壳层（泳道、面板、Tab栏、分割条、状态栏、悬浮热区）视觉样式，业务视图可自适应适配框架主题。
8.1 内置默认主题清单（定稿）
引擎默认内置 3 套官方主题，覆盖桌面端主流使用场景，开箱即用、无需额外配置：
- 经典亮色主题（Light）：默认出厂主题，适配日间办公场景，低饱和度、高对比度，满足长时间办公视觉舒适需求，对标主流IDE亮色视觉规范。
- 暗黑极致主题（Dark）：专业开发深色主题，全局深底色、弱高亮控件，降低屏幕眩光，适配夜间开发、长时间编码场景，所有布局层级、分割边框、悬浮状态对比度清晰。
- 纯净极简主题（Pure）：低干扰无渐变极简风格，去除多余视觉装饰，层级依靠灰度区分，适合演示、投屏、极简工作台场景。
8.2 主题作用范围
框架主题全权托管布局引擎壳层所有UI样式，统一全局视觉规范，包含：
- 泳道、Section面板背景、层级底色
- TabBar、标签选中/未选中、Hover、激活状态样式
- 拖拽占位预览、落点悬浮高亮、拖拽轨迹样式
- Resize分割条、边框、分隔线样式
- 悬浮热区、按钮、Tooltip、弹窗背景文字色值
- 顶部操作栏、底部状态栏全局样式
业务视图（ViewInstance）支持主动适配框架主题参数，业务层可通过引擎主题回调实现UI跟随切换，也可保留自定义独立样式，互不冲突。
8.3 主题核心能力规则
- 状态持久化：用户切换的主题方案自动写入本地 .flutterlane 配置文件，重启应用自动还原上次主题，无需重复设置。
- 系统自适应兜底：支持跟随系统亮暗模式自动切换对应内置主题，可手动关闭自适应、锁定固定主题。
- 主题无侵入布局：主题仅修改视觉样式，不改变任何布局结构、拖拽逻辑、交互规则、快照数据，换主题不影响用户自定义布局。
- 可扩展自定义主题：开放主题注册接口，支持业务基于内置主题拓展自定义配色、样式，无需修改引擎源码。
9. 边界规则强约束（引擎底层兜底）
- ✅ 允许删除全部泳道、允许完全空白工作台，无强制保留限制
- ✅ 支持单泳道删除全部 Section（用户完全自由）：用户层面无删除限制，可清空单泳道所有分组；技术底层自动兜底，泳道清空后引擎自动注入一个空白占位 Section，防止布局塌陷、结构失效，占位Section无业务视图、无多余UI，用户无感知。
- ✅ 允许空Section（结构合法占位）
- ✅ 严格禁止空Pane，所有标签必须绑定有效视图实例
- ✅ 极小面板尺寸完全兜底，依靠双向滚动保证内容不截断、不崩溃
- ✅ 所有布局变更（含跨层级拖拽重组、Resize、增删、折叠、排序、主题切换）自动增量持久化，无手动保存冗余操作，变更即时生效
- ✅ 跨层级拖拽容错兜底：Pane/Section跨泳道迁移全程无卡顿、无闪烁、无布局错乱，迁移后视图实例、状态数据完整保留，不丢失配置与滚动状态
- ✅ 拖拽边界智能限制：禁止拖拽溢出可视区域、无效落点自动驳回，非法拖拽行为无副作用、不破坏原有布局结构
10. 全场景验收标准（可直接QA落地打勾）
10.1 HeaderBar 布局快照能力验收
10.2 增删能力验收
10.3 拖拽、Resize、折叠、滚动综合验收
10.4 主题体系专项验收
验收项
验收标准
布局菜单入口
顶部常驻布局下拉菜单，包含：保存新布局、切换布局、重命名、删除、设为默认、一键重置
自动覆盖保存
任意布局改动实时覆盖当前激活快照，应用工作目录下 ./.flutterlane/ 配置文件同步更新，多应用配置相互隔离无冲突
多布局切换
多套布局可无缝切换，100%还原尺寸、排序、状态、视图
一键重置
仅重置工作台布局，不影响顶层业务页面，恢复系统默认布局
9.2 增删能力验收
层级
验收项
标准
泳道
新增/删除
悬浮新增、支持全部删除清空工作台
Section
新增/删除
悬浮新增，用户可删除泳道内全部Section，引擎底层自动生成空白占位Section防布局塌陷，用户无感知
Pane
新增/删除
仅可注册视图、禁止空Pane，关闭后保留Section壳层
9.3 拖拽、Resize、折叠、滚动综合验收
验收模块
详细验收标准
全层级拖拽排序 & 跨域迁移

1. 泳道拖拽：多泳道支持左右自由排序、分割条Resize宽度，最小宽度兜底规则生效，拖拽实时预览占位，松手精准落位；
2. Section拖拽：支持同泳道上下排序、跨任意泳道自由迁移，可拖拽至目标泳道顶部/中间/底部，自动适配目标布局结构，无结构丢失、无塌陷；
3. Pane标签拖拽：支持同Section左右排序、跨Section/跨泳道任意迁移，拖拽后自动挂载至目标面板，正常激活展示；
4. 落点交互：全程悬浮占位预览、智能吸附，区分顶部插入/中间嵌入/底部追加三类落点，交互对标主流IDE；
5. 结构兜底：跨层级拖拽不产生非法空结构，原布局、目标布局自动重整，符合引擎底层约束；
6. 状态持久化：所有拖拽重组操作自动写入本地快照，重启/切换布局可100%还原自定义布局。

尺寸 Resize 调整

1. 泳道支持左右拖拽Resize宽度，最小宽度限制兜底，防止尺寸过小布局异常；
2. Section支持垂直拖拽Resize高度，尺寸限制规则生效；
3. Section折叠状态自动禁用Resize功能，避免无效操作；
4. 所有尺寸变更实时生效、自动持久化保存。

面板折叠 / 展开

1. 折叠状态仅隐藏业务内容区，Section TabBar永久常驻，所有按钮正常交互；
2. 点击Tab、新增Pane、新增Section可自动展开折叠面板；
3. 折叠/展开状态支持持久化，重启、布局切换不丢失状态；
4. 交互逻辑统一，无卡顿、无状态错乱问题。

双向滚动隔离

1. 严格遵循壳层固定、内容滚动机制，仅业务视图内容可滚动，TabBar、操作栏、悬浮层永久固定；
2. 内容溢出自动开启横竖双向滚动，内容不足自动隐藏滚动条，无多余空白滚动区域；
3. 支持滚动位置缓存，切Tab、折叠、Resize、重启布局保留上次滚动偏移，不强制置顶；
4. 所有悬浮弹窗、Tooltip挂载壳层，永不被内容滚动裁切，层级置顶稳定。

9.4 主题体系专项验收
验收模块
详细验收标准
内置主题能力
1. 引擎默认内置三套官方主题：经典亮色（Light）、暗黑极致（Dark）、纯净极简（Pure），开箱即用无需额外依赖；2. 主题切换全覆盖布局壳层：泳道/Section面板底色、Tab栏状态、拖拽预览、分割条、悬浮热区、Tooltip、顶部/状态栏样式全部同步刷新；3. 主题仅变更视觉样式，不改动任何布局结构、拖拽规则、快照数据、视图状态，无布局错乱、状态丢失问题；4. 支持手动一键切换主题，切换过程流畅无卡顿、无闪屏，全局样式统一无局部漏刷。
主题持久化能力
1. 用户手动切换的主题配置自动写入当前应用工作目录下的 ./.flutterlane/ 配置文件，实时保存，多应用主题配置完全隔离、互不覆盖；
系统自适应能力
1. 支持跟随系统亮暗模式自动适配亮色/暗黑主题，自适应开关可手动开启/关闭；2. 关闭自适应后可锁定固定主题，不受系统模式切换影响；3. 系统模式切换时，全局主题平滑刷新，布局结构、用户自定义布局完全保留。
自定义主题拓展
1. 开放主题注册拓展接口，支持业务自定义配色、样式拓展，无需修改引擎源码；2. 自定义主题可继承内置主题基础样式，仅差异化覆盖所需配置；3. 自定义主题同样支持持久化、切换、自适应适配，与官方主题能力对齐。










11. 开源最终架构定稿结论
FlutterLane 飞道布局引擎 整体架构、三层层级模型、交互范式、拖拽规则、滚动隔离、多快照布局系统、本地持久化方案、注册式SDK、数据模型、验收规范全部最终定稿。
框架彻底满足开源独立Library标准：能力完全内聚、零后端依赖、零业务耦合、纯端内闭环，区别于所有通用 Flex/Stack 控件，是 Flutter 桌面端唯一自研 IDE 级分层布局开源解决方案。后续仅可扩展业务注册视图与通用引擎能力，不修改底层基础架构与核心交互规则。