package com.threerings.ui
{
import com.threerings.display.DisplayUtil;
import com.whirled.contrib.debug.DebugUtil;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

public class SimpleScrollableArrayView extends ScrollableArrayView
{
    public function SimpleScrollableArrayView (type :OrientationType, panelWidth :int, panelHeight :int)
    {
        var container :Sprite = new Sprite();

        var elementContainer :Sprite = new Sprite();
        container.addChild(elementContainer);
        DebugUtil.drawRect(elementContainer.graphics, panelWidth, panelHeight, 0xffffff);

        var buttonSize :int = type == OrientationType.HORIZONTAL ? panelHeight : panelWidth;
        var buttonColor :uint = 0x4281ff;
        var leftUpButton :Sprite = createSingleTriangleButton(buttonSize, (type == OrientationType.HORIZONTAL ? 180 : -90), buttonColor);
        var rightDownButton :Sprite = createSingleTriangleButton(buttonSize, (type == OrientationType.HORIZONTAL ? 0 : 90), buttonColor);
        container.addChild(leftUpButton);
        container.addChild(rightDownButton);

        if (type == OrientationType.HORIZONTAL) {
            DisplayUtil.positionBounds(leftUpButton, -leftUpButton.width - 1, 0);
            DisplayUtil.positionBounds(rightDownButton, panelWidth + 1, 0);
        } else {//Vertical
            DisplayUtil.positionBounds(leftUpButton, 0, -leftUpButton.height - 1);
            DisplayUtil.positionBounds(rightDownButton, 0, panelHeight + 1);
        }

        //Scroll 1 page left/right buttons
        var scrollLeftUp1PageButton :Sprite = createDoubleTriangleButton(buttonSize, (type == OrientationType.HORIZONTAL ? 180 : -90), buttonColor);
        var scrollRightDown1PageButton :Sprite = createDoubleTriangleButton(buttonSize, (type == OrientationType.HORIZONTAL ? 0 : 90), buttonColor);
        container.addChild(scrollLeftUp1PageButton);
        container.addChild(scrollRightDown1PageButton);

        if (type == OrientationType.HORIZONTAL) {
            DisplayUtil.positionBoundsRelative(scrollLeftUp1PageButton, container, -leftUpButton.width - 1 - scrollLeftUp1PageButton.width, 0);
            DisplayUtil.positionBoundsRelative(scrollRightDown1PageButton, container, panelWidth + 1 + rightDownButton.width, 0);
        } else {//Vertical
            DisplayUtil.positionBoundsRelative(scrollLeftUp1PageButton, container, 0, -leftUpButton.height - 1 - scrollLeftUp1PageButton.height);
            DisplayUtil.positionBoundsRelative(scrollRightDown1PageButton, container, 0, panelHeight + 1 + rightDownButton.height);
        }

        //Hard left/right buttons
        var buttonWidth :Number = type == OrientationType.HORIZONTAL ? buttonSize / 3 : buttonSize;
        var buttonHeight :Number = type == OrientationType.HORIZONTAL ? panelHeight : buttonSize / 3;
        var hardLeftButton :Sprite = new Sprite();
        var hardRightButton :Sprite = new Sprite();
        DebugUtil.fillRect(hardLeftButton.graphics, buttonWidth, buttonHeight, buttonColor);
        DebugUtil.fillRect(hardRightButton.graphics, buttonWidth, buttonHeight, buttonColor);
        if (type == OrientationType.HORIZONTAL) {
            DisplayUtil.positionBoundsRelative(hardLeftButton, container, -leftUpButton.width - 1 - scrollLeftUp1PageButton.width - hardLeftButton.width, 0);
            DisplayUtil.positionBoundsRelative(hardRightButton, container, panelWidth + 1 + rightDownButton.width + scrollRightDown1PageButton.width, 0);
        } else {//Vertical
            DisplayUtil.positionBoundsRelative(hardLeftButton, container, 0, -leftUpButton.height - 1 - scrollLeftUp1PageButton.height - hardLeftButton.height);
            DisplayUtil.positionBoundsRelative(hardRightButton, container, 0, panelHeight + 1 + rightDownButton.height + scrollRightDown1PageButton.height);
        }
        container.addChild(hardLeftButton);
        container.addChild(hardRightButton);

        super(type, container, elementContainer, leftUpButton, rightDownButton, scrollLeftUp1PageButton, scrollRightDown1PageButton, hardLeftButton, hardRightButton);
    }

    protected static function drawTriangle (g :Graphics, color :uint, size :Number) :void
    {
        g.moveTo(0, -size / 2);
        g.beginFill(color);
        g.lineStyle(1, color);
        g.lineTo(size / 2, 0);
        g.lineTo(0, size / 2);
        g.lineTo(0, -size / 2);
        g.endFill();
    }

    protected static function createSingleTriangleButton (size :int, angle :Number, color :uint) :Sprite
    {
        var s :Sprite = new Sprite();
        var t :Shape = new Shape();
        drawTriangle(t.graphics, color, size);
        t.rotation = angle;
        s.addChild(t);
        return s;
    }

    protected static function createDoubleTriangleButton (size :int, angle :Number, color :uint) :Sprite
    {
        var s :Sprite = new Sprite();
        var t :Shape = new Shape();
        drawTriangle(t.graphics, color, size);
        s.addChild(t);

        var t2 :Shape = new Shape();
        drawTriangle(t2.graphics, color, size);
        s.addChild(t2);
        t2.x = size / 4;
        s.rotation = angle;
        return s;
    }

}
}