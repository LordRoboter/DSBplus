import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class PriorityRow extends MultiChildRenderObjectWidget {
  PriorityRow({
    super.key,
    required Widget left,
    required Widget right,
    Widget? trailing,
    this.spacing = 8,
    this.trailingSpacing = 4,
  }) : super(children: [left, right, ?trailing]);

  final double spacing;
  final double trailingSpacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _PriorityRowRenderObject(
      spacing: spacing,
      trailingSpacing: trailingSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _PriorityRowRenderObject renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..trailingSpacing = trailingSpacing;
  }
}

class _PriorityRowParentData extends ContainerBoxParentData<RenderBox> {}

class _PriorityRowRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PriorityRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PriorityRowParentData> {
  _PriorityRowRenderObject({
    required this._spacing,
    required double trailingSpacing,
  }) : _trailingSpacing = trailingSpacing;

  double _spacing;
  double _trailingSpacing;

  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  set trailingSpacing(double value) {
    if (_trailingSpacing == value) return;
    _trailingSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PriorityRowParentData) {
      child.parentData = _PriorityRowParentData();
    }
  }

  @override
  void performLayout() {
    final children = getChildrenAsList();

    final left = children[0];
    final right = children[1];
    final trailing = children.length > 2 ? children[2] : null;

    // ------------------------------------------------------------
    // 1. Measure the fixed trailing widget.
    // ------------------------------------------------------------

    if (trailing != null) {
      trailing.layout(
        BoxConstraints.loose(constraints.biggest),
        parentUsesSize: true,
      );
    }

    final double trailingWidth = trailing?.size.width ?? 0.0;
    final double trailingHeight = trailing?.size.height ?? 0.0;

    // Width available for the left + right sections.
    final double priorityWidth = math.max(
      0.0,
      constraints.maxWidth -
          trailingWidth -
          (trailing != null ? _trailingSpacing : 0.0),
    );

    // ------------------------------------------------------------
    // 2. Measure both children at their natural width.
    // ------------------------------------------------------------

    left.layout(
      BoxConstraints.loose(Size(priorityWidth, constraints.maxHeight)),
      parentUsesSize: true,
    );

    right.layout(
      BoxConstraints.loose(Size(priorityWidth, constraints.maxHeight)),
      parentUsesSize: true,
    );

    final double leftNaturalWidth = left.size.width;
    final double rightNaturalWidth = right.size.width;

    // ------------------------------------------------------------
    // 3. Decide how much width each child gets.
    // ------------------------------------------------------------

    final double availableForBoth = math.max(0.0, priorityWidth - _spacing);

    late final double leftWidth;
    late final double rightWidth;

    final bool fitsNaturally =
        leftNaturalWidth + rightNaturalWidth <= availableForBoth;

    if (fitsNaturally) {
      // Both children get exactly the space they need.
      leftWidth = leftNaturalWidth;
      rightWidth = rightNaturalWidth;
    } else {
      // Not enough space.
      //
      // LEFT HAS PRIORITY.
      //
      // Give the left child everything it wants, unless even that
      // doesn't fit. The right child gets whatever remains.
      leftWidth = math.min(leftNaturalWidth, availableForBoth);

      rightWidth = math.max(0.0, availableForBoth - leftWidth);
    }

    // ------------------------------------------------------------
    // 4. Lay out the children using their final widths.
    // ------------------------------------------------------------

    left.layout(
      BoxConstraints.tightFor(width: leftWidth),
      parentUsesSize: true,
    );

    right.layout(
      BoxConstraints.tightFor(width: rightWidth),
      parentUsesSize: true,
    );

    // ------------------------------------------------------------
    // 5. Determine our size.
    // ------------------------------------------------------------

    final double width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : leftWidth +
              _spacing +
              rightWidth +
              (trailing != null ? _trailingSpacing + trailingWidth : 0.0);

    final double height = math.max(
      math.max(left.size.height, right.size.height),
      trailingHeight,
    );

    size = constraints.constrain(Size(width, height));

    // ------------------------------------------------------------
    // 6. Position children.
    // ------------------------------------------------------------

    final leftData = left.parentData! as _PriorityRowParentData;

    final rightData = right.parentData! as _PriorityRowParentData;

    leftData.offset = Offset.zero;

    if (fitsNaturally) {
      // There is free space.
      //
      // Push the RIGHT child all the way to the right side of the
      // priority area. This is the important part.
      rightData.offset = Offset(priorityWidth - rightWidth, 0);
    } else {
      // No free space.
      //
      // Put the right child immediately after the left child.
      rightData.offset = Offset(leftWidth + _spacing, 0);
    }

    // ------------------------------------------------------------
    // 7. Position trailing widget at the absolute right edge.
    // ------------------------------------------------------------

    if (trailing != null) {
      final trailingData = trailing.parentData! as _PriorityRowParentData;

      trailingData.offset = Offset(size.width - trailingWidth, 0);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
