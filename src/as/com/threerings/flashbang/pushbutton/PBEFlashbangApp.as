package com.threerings.flashbang.pushbutton
{
import com.threerings.flashbang.Config;
import com.threerings.flashbang.MainLoop;
import com.threerings.flashbang.audio.AudioManager;
import com.threerings.flashbang.resource.ImageResource;
import com.threerings.flashbang.resource.ResourceManager;
import com.threerings.flashbang.resource.SWFResourceWithList;
import com.threerings.flashbang.resource.SoundResource;
import com.threerings.flashbang.resource.XmlResource;

import flash.display.Sprite;
import flash.events.IEventDispatcher;

public class PBEFlashbangApp
{
    public function PBEFlashbangApp (sgContext :PBEContext, config :Config = null)
    {
        if (config == null) {
            config = new Config();
        }

        _ctx = sgContext;
        _ctx.mainLoop = new MainLoop(_ctx, config.minFrameRate);
        _ctx.audio = new AudioManager(_ctx, config.maxAudioChannels);
        _ctx.mainLoop.addUpdatable(_ctx.audio);


        if (config.externalResourceManager == null && _ctx.rsrcs == null) {
            _ctx.rsrcs = new ResourceManager();
            _ownsResourceManager = true;

            // add resource factories
            _ctx.rsrcs.registerResourceType("image", ImageResource);
            _ctx.rsrcs.registerResourceType("swf", SWFResourceWithList);
            _ctx.rsrcs.registerResourceType("xml", XmlResource);
            _ctx.rsrcs.registerResourceType("sound", SoundResource);

        } else {
            _ctx.rsrcs = _ctx.rsrcs == null ? config.externalResourceManager : _ctx.rsrcs;
            _ownsResourceManager = false;
        }
    }

    public function run (hostSprite :Sprite, keyDispatcher :IEventDispatcher = null) :void
    {
        _ctx.mainLoop.setup();
        _ctx.mainLoop.run(hostSprite, keyDispatcher);
    }

    public function shutdown () :void
    {
        _ctx.mainLoop.shutdown();
        _ctx.audio.shutdown();

        if (_ownsResourceManager) {
            _ctx.rsrcs.shutdown();
        }
    }

    public function get ctx () :PBEContext
    {
        return _ctx;
    }

    protected var _ctx :PBEContext;
    protected var _ownsResourceManager :Boolean;

}
}
