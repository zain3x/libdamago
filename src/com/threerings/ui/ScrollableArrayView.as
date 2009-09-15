package com.threerings.ui
{
import com.threerings.display.DisplayUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.util.MathUtil;
import com.whirled.contrib.EventHandlerManager;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import flash.geom.Point;

/**
 * A scrolling view of DisplayObjects.
 */
public class ScrollableArrayView extends ArrayView
{

    public function ScrollableArrayView (type :OrientationType,
                                         media :DisplayObject,
                                         elementContainer :DisplayObjectContainer,
                                         leftUpButton :InteractiveObject = null,
                                         bottomDownButton :InteractiveObject = null,
                                         leftUpScroll1Page :InteractiveObject = null,
                                         rightBottomScroll1Page :InteractiveObject = null,
                                         firstIdxButton :InteractiveObject = null,
                                         lastIdxButton :InteractiveObject = null)
    {
        super(type);
        _type = type;
        addChild(media);
        _elementContainer = elementContainer;
        _elementContainerCenterPosition = OrientationType.HORIZONTAL ?
            _elementContainer.height / 2:
            _elementContainer.width / 2;

        if (leftUpButton != null) {
            _events.registerListener(leftUpButton, MouseEvent.CLICK, scrollLeftUp);
        }

        if (bottomDownButton != null) {
            _events.registerListener(bottomDownButton, MouseEvent.CLICK, scrollDownRight);
        }

        if (leftUpScroll1Page != null) {
            _events.registerListener(leftUpScroll1Page, MouseEvent.CLICK, scrollLeftUp1Page);
        }

        if (rightBottomScroll1Page != null) {
            _events.registerListener(rightBottomScroll1Page, MouseEvent.CLICK, scrollRightDown1Page);
        }

        if (firstIdxButton != null) {
            _events.registerListener(firstIdxButton, MouseEvent.CLICK, scrollMaxLeftUp);
        }

        if (lastIdxButton != null) {
            _events.registerListener(lastIdxButton, MouseEvent.CLICK, scrollMaxRightDown);
        }

    }

    protected function scrollDownRight (...ignored) :Boolean
    {
        if (_bottomRightIdx == _elements.length - 1) {
            return false;
        }
        _topLeftIdx++;
        _topLeftIdx = MathUtil.clamp(_topLeftIdx, 0, _elements.length - 1);
        redrawElements();
        return true;
    }

    protected function scrollLeftUp (...ignored) :void
    {
        _topLeftIdx--;
        _topLeftIdx = MathUtil.clamp(_topLeftIdx, 0, _elements.length - 1);
        redrawElements();
    }

    protected function scrollRightDown1Page (...ignored) :void
    {
        var elementSize :int = _bottomRightIdx - _topLeftIdx;
        _topLeftIdx = MathUtil.clamp(_topLeftIdx + elementSize + 1, 0, _elements.length - elementSize - 1);
        redrawElements();
    }

    protected function scrollLeftUp1Page (...ignored) :void
    {
        var elementSize :int = _bottomRightIdx - _topLeftIdx;
        _topLeftIdx = MathUtil.clamp(_topLeftIdx - elementSize - 1, 0, _elements.length - 1);
        redrawElements();
    }

    protected function scrollMaxLeftUp (...ignored) :void
    {
        _topLeftIdx = 0;
        redrawElements();
    }

    protected function scrollMaxRightDown (...ignored) :void
    {
        while (scrollDownRight()) {}
    }

    override public function remove (d :DisplayObject) :void
    {
        _topLeftIdx = MathUtil.clamp(_topLeftIdx, 0, _elements.length - 1);
        super.remove(d);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _elements = null;
    }

    override public function redrawElements () :void
    {
        var idx :int;
        //Detach elements above/left
        for (idx = 0; idx < _topLeftIdx; ++idx) {
            DisplayUtils.detach(_elements[idx]);
        }

        //Position units until out of space
        var maxLength :int = _type == OrientationType.HORIZONTAL ? _elementContainer.width :
            _elementContainer.height;
        var curLength :int = 0;
        var obj :DisplayObject;
        var loc :Point;
        _bottomRightIdx = _topLeftIdx;
        for (idx = _topLeftIdx; curLength < maxLength && idx < _elements.length; ++idx) {
            obj = _elements[idx] as DisplayObject;
            if (obj == null) {
                trace("obj == null, elements=" + _elements);
                continue;
            }
            var objectSize :Number = _type == OrientationType.HORIZONTAL ? obj.width : obj.height;
            if (curLength + objectSize >= maxLength) {
                break;
            }

            _bottomRightIdx = idx;

            if (obj.parent != _elementContainer) {
                _elementContainer.addChild(obj);
            }

            var xPos :Number = _type == OrientationType.HORIZONTAL ? curLength : 0;
            var yPos :Number = _type == OrientationType.HORIZONTAL ? 0 : curLength;
            DisplayUtil.positionBounds(obj, xPos, yPos);
            curLength += _type == OrientationType.HORIZONTAL ? obj.width : obj.height;
        }

        //Detach elements below/right
        for (; idx < _elements.length; ++idx) {
            DisplayUtils.detach(_elements[idx]);
        }
    }

    protected var _centerElements :Boolean;
    protected var _elementContainerCenterPosition :Number
    protected var _topLeftIdx :int = 0;
    protected var _bottomRightIdx :int = 0;
    protected var _elementContainer :DisplayObjectContainer;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}