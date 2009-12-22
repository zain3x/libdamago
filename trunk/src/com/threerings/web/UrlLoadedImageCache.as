package com.threerings.web {
import aduros.util.F;

import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;

public class UrlLoadedImageCache
{
    public static function preloadPicFromUrl (url :String) :void
    {
        loadPicFromUrl(url);
    }

    public static function getPicFromUrl (url :String, callback :Function = null) :Sprite
    {
        if (url == null || url.length == 0) {
            return null;
        }

        if (_urlPicCache.containsKey(url)) {
            var bd :BitmapData = _urlPicCache.get(url) as BitmapData;
            var sprite :Sprite = new Sprite();
            addBitmapToSpriteAndCenterAndSize(bd, sprite);
            if (callback != null) {
                callback(sprite);
            }
            return sprite;
        } else {
            return loadPicFromUrl(url, callback);
        }
    }

    protected static function addBitmapToSpriteAndCenterAndSize (bd :BitmapData, sprite :Sprite) :void
    {
        var bm :Bitmap = new Bitmap(bd);
//        if (maxSize > 0) {
//            var max :int = Math.max(bm.width, bm.height);
//            if (max > maxSize) {
//                bm.scaleX = bm.scaleY = Number(maxSize) / max;
//                trace("bm.scaleX=" + bm.scaleX);
//            }
//        }
        sprite.addChild(bm);
//        DisplayUtils.centerOn(bm);
    }

    protected static function loadPicFromUrl (url :String, callback :Function = null) :Sprite
    {
        var holdingSprite :Sprite = new Sprite();
		
		if (url == null || url.length == 0) {
			if (callback != null) {
				callback(null);
			}
			return null;
		}
		
        if (!_holdingSprites.containsKey(url)) {
            _holdingSprites.put(url, new Array());
            _holdingCallbacks.put(url, new Array());
			
            var imageLoader :Loader = new Loader();
            var loaderContext :LoaderContext = new LoaderContext();
            loaderContext.checkPolicyFile = true;

            var request :URLRequest = new URLRequest(url);
			try {
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, F.justOnce(onComplete));
				imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFail);
				
//				imageLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e :IOErrorEvent) :void {
//					trace("!!!!!!!!!!!!!");	
//				});
//				imageLoader.addEventListener(IOErrorEvent.NETWORK_ERROR, function(e :IOErrorEvent) :void {
//					trace("!!!!!!!!!!!!!");	
//				});
//				imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, function(e :IOErrorEvent) :void {
//					trace("!!!!!!!!!!!!!");	
//				});
//				imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e :IOErrorEvent) :void {
//					trace("!!!!!!!!!!!!!");	
//				});
				
				
				
				
				
	            imageLoader.load(request, loaderContext);
				
				function free () :void {
					_holdingSprites.remove(url);
					_holdingCallbacks.remove(url);
				}
	
	            function onComplete (e :Event) :void {
	                if (imageLoader.content != null && imageLoader.content is DisplayObject) {
	                    var bd :BitmapData = createBitmapData(imageLoader.content as DisplayObject);
	                    _urlPicCache.put(url, bd);
	
	                    var sprites :Array = _holdingSprites.get(url) as Array;
	                    var callbacks :Array = _holdingCallbacks.get(url) as Array;
	                    if (sprites != null) {
	                            //Add to the holding sprite, in case we're waiting for it.
	                        for (var ii :int = 0; ii < sprites.length; ++ii) {
	                            var toCopySprite :Sprite = sprites[ii] as Sprite;
	                            var localCallback :Function = callbacks[ii] as Function;
	                            addBitmapToSpriteAndCenterAndSize(bd, toCopySprite);
	                            if (localCallback != null) {
	                                localCallback(toCopySprite);
	                            }
	                        }
	
	                    }
	                } else {
						trace("There is no image at " + url);
					}
					free();
					
	            }
				function onFail (e :IOErrorEvent) :void {
					trace("URL failed to load: " + url);
					free();
				}
			} catch (err :IOError) {
				trace("Failed to load " + url);
				free();
			}
			
			
        }

        var holdingArray :Array = _holdingSprites.get(url) as Array;
        if (null != holdingArray) {
            holdingArray.push(holdingSprite);
        }

        var holdingCallbacks :Array = _holdingCallbacks.get(url) as Array;
        if (null != holdingCallbacks) {
            holdingCallbacks.push(callback);
        }
        return holdingSprite;
    }

    protected static function createBitmapData (disp :DisplayObject, width :int = -1,
        height :int = -1, uniformScale :Boolean = true) :BitmapData
    {
        var bounds :Rectangle = disp.getBounds(disp);

        if (width < 0) {
            width = bounds.width;
        }
        if (height < 0) {
            height = bounds.height;
        }

        var scaleX :Number = width / bounds.width;
        var scaleY :Number = height / bounds.height;
        if (uniformScale) {
            scaleX = scaleY = Math.min(scaleX, scaleY);
        }

        var bd :BitmapData = new BitmapData(width, height, true, 0);
        bd.draw(disp, new Matrix(scaleX, 0, 0, scaleY, -bounds.x * scaleX, -bounds.y * scaleY));
        return bd;
    }

    // Map<url:String, DisplayObject>
    protected static var _urlPicCache :Map = Maps.newMapOf(String);
    // Map<url:String, Array<Sprite>>
    protected static var _holdingSprites :Map = Maps.newMapOf(String);
    // Map<url:String, Array<Function>>
    protected static var _holdingCallbacks :Map = Maps.newMapOf(String);
//	protected static var _events :EventHandlerManager = new EventHandlerManager();

}
}