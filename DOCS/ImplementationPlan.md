# FlutterLane implementation plan

## 1. Architecture baseline
- Define the three-layer layout model: Swimlane -> Section -> Pane.
- Keep the engine independent from business code and backend dependencies.

## 2. Core model layer
- Implement serializable layout snapshots in `LayoutState`, `Swimlane`, `Section`, `Pane`, and `ViewInstance`.
- Ensure placeholder fallback behavior prevents invalid empty structures.
- Maintain deep-clone and JSON round-trip support for persistence.

## 3. Registry and theme layer
- Provide global registration for pane views, window views, header actions, and status bar items.
- Include theme types for Light, Dark, and Pure with runtime switching and persistence.
- Keep theme changes visual-only so layout state remains stable.

## 4. Storage and lifecycle layer
- Persist layouts and theme settings under `.flutterlane`.
- Restore the active snapshot on startup and keep layout mutations synchronized.
- Centralize orchestration in `FlutterLaneManager`.

## 5. Workbench and interaction layer
- Render the active layout in `FlutterLaneWorkbench`.
- Add swimlane and section injection hot zones, pane tabs, drag-and-drop support, and section resize handles.
- Keep UI shell fixed while business content scrolls independently.

## 6. Validation
- Run `flutter test` to verify the engine and widgets remain consistent with the design.
- If tests conflict with the intended hover-only UX, treat the design as the source of truth and align the assertions with the product behavior.

## Current repo status
- The implementation is present in the model, registry, storage, theme, and widget layers.
- The design intent is consistent with the codebase, especially for hover-only add zones and title-driven section labeling.
- Fresh verification results show the suite is currently failing because the tests assert different behavior than the design contract.
