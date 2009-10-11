package com.whirled.contrib.cache
{
import aduros.util.F;

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.utils.Timer;

public class BasicURLImageCache extends EventDispatcher
{
    public static const URL_DATA_LOADED :String = "urlDataLoaded";

    public function BasicURLImageCache (
        maxValue :int = 1000, evaluator :CacheObjectEvaluator = null, evaluationTime :int = 1000,
        frequencyThreshold :int = 60000, frequencyCount :int = 5)
    {
        _maxValue = maxValue;
        _evaluator = evaluator == null ? new ObjectCountEvaluator() : evaluator;
        _timer = new Timer(evaluationTime, 1);
        _timer.addEventListener(TimerEvent.TIMER, evaluateCache);
        _frequencyThreshold = frequencyThreshold;
        _frequencyCount = frequencyCount;
    }

    // from Cache
    public function get cacheStats () :CacheStats
    {
        var stats :CacheStats = _stats;
        stats.fixTime();
        stats.setTotalValue(_lastEvaluationTotal);
        _stats = new CacheStats();
        return stats;
    }

    // from DataSource
    public function getObject (name :String) :Object
    {
        var value :FrequentURLBitmapObject = _cacheValues.get(name);
        if (value != null) {
            _stats.cacheHit();

        } else {
            _stats.cacheMiss();
            value = new FrequentURLBitmapObject(name, _frequencyThreshold, _frequencyCount, urlLoadedCallback);
            _cacheValues.put(name, value);
            // No point in running a cache that doesn't do its bets to return values quickly.
            // Run the evaluation later.
            _timer.start(); // only starts the timer if it's not already running
        }

        value.requested();
        return value.bitmap;
    }

    public function getBitmap (url :String) :Bitmap
    {
        if (url == null) {
            return null;
        }
        return getObject(url) as Bitmap;
    }

    protected function evaluateCache (...ignored) :void
    {
        _timer.reset(); // reset the timer, it will be run again after our next access.

        var values :Array = _cacheValues.values();
        for each (var freqObj :FrequentURLBitmapObject in values) {
            // So that the frequency isn't being constantly recalculated while the array is being
            // sorted (as would happen if the frequency calculation were being done in the frequency
            // getter), we iterate over the list and tell each obj to caculate its frequency first
            freqObj.calculateFrequency();
        }
        values.sortOn("frequency", Array.DESCENDING | Array.NUMERIC);

        var totalValue :int = 0;
        var toRemove :Array = [];
        for (var ii :int = 0; ii < values.length; ii++) {
            totalValue += 1;//_evaluator.getValue(values[ii].value);
            if (totalValue > _maxValue && ii > 0) { // ensure we keep at least on object
                toRemove = values.splice(ii);
                break;
            }
            // This value is copied down every time instead of outside of the loop so that when we
            // break out, it has already been set to the correct value.
            _lastEvaluationTotal = totalValue;
        }
        if (toRemove.length > 0) {
            _stats.cacheDropped(toRemove.length);
            for each (var value :FrequentURLBitmapObject in toRemove) {
                _cacheValues.remove(value.name);
            }
        }
    }

    protected function urlLoadedCallback (url :String) :void
    {
        dispatchEvent(new Event(URL_DATA_LOADED));
    }


    /** Url (String) -> BitmapData*/


    protected var _missSource :DataSource;
    protected var _maxValue :int;
    protected var _evaluator :CacheObjectEvaluator;
    protected var _cacheValues :Map = Maps.newMapOf(String);
    protected var _stats :CacheStats = new CacheStats();
    protected var _lastEvaluationTotal :int;
    protected var _timer :Timer;
    protected var _frequencyThreshold :int;
    protected var _frequencyCount :int;

    private static const log :Log = Log.getLog(LFUWeightedAgeCache);
}
}
import com.whirled.contrib.cache.CacheObjectEvaluator;
import com.whirled.contrib.cache.DataSource;
import flash.display.Bitmap;
import flash.net.URLRequest;
import flash.events.Event;
import aduros.util.F;
import flash.display.BitmapData;
import flash.display.DisplayObject;


import flash.utils.getTimer;
import com.threerings.ui.DisplayUtils;

class FrequentURLBitmapObject
{
    public function FrequentURLBitmapObject (name :String, threshold :int, maxTimes :int,
        urlLoadedCallback :Function) :void
    {
        _name = name;
        _threshold = threshold;
        _maxTimes = maxTimes;
        _urlLoadedCallback = urlLoadedCallback;
    }

    public function get frequency () :int
    {
        return _frequency;
    }

    public function get name () :String
    {
        return _name;
    }

    public function get bitmap () :Bitmap
    {
        if (_loaded) {
            return new Bitmap(_bitmapDataValue);
        }

        function callback (bd :BitmapData) :void {
            _bitmapDataValue = bd;
            _loaded = true;
            if (_urlLoadedCallback != null) {
                _urlLoadedCallback(_name);
            }
        }
        return DisplayUtils.loadBitmapFromUrl(_name, callback);
    }

    public function calculateFrequency () :void
    {
        var threshold :int = getTimer() - _threshold;
        _frequency = 0;
        _times.length = Math.min(_maxTimes, _times.length);
        for (var ii :int = 0; ii < _times.length; ii++) {
            if (_times[ii] < threshold) {
                _times.length = ii;
                break;
            }
            _frequency += _times[ii] - threshold;
        }
    }

    public function requested () :void
    {
        _times.unshift(getTimer());
    }

    protected var _times :Array = [];
    protected var _bitmapDataValue :BitmapData;
    protected var _name :String;
    protected var _frequency :int;
    protected var _threshold :int;
    protected var _maxTimes :int;
    protected var _loaded :Boolean = false;
    protected var _urlLoadedCallback :Function;
}
