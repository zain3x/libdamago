package libdamago.dataview.server
{
import aduros.net.RemoteProvider;
import aduros.util.F;

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.contrib.EventHandlerBase;

import flash.events.Event;

/**
 * Creates and manages a "view" on a set of data.
 * Used for e.g. sharing a screen among different players.
 * For each new data view, create a new DataViewServer.
 *
 */
public class DataViewServer extends EventHandlerBase
{
    public function DataViewServer (ctrl :AVRServerGameControl, id :String)
    {
        _ctrl = ctrl;
        _controllingPlayerIds = owningPlayerIds;
        _publicAllowed = publicView;
        _id = Constants.DARA_VIEW_PREFIX + id;
        _remoteProvider = new RemoteProvider(_ctrl.game, _id, F.konst(this));

        registerListener(_ctrl.game, Event.UNLOAD, F.adapt(shutdown));

        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME, handlePlayerJoinedGame);
        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME, handlePlayerQuitGame);
    }

    override protected function shutdown () :void
    {
        super.shutdown();
        _remoteProvider.unload();
        _remoteProvider = null;
        _ctrl = null;
    }

    protected function handlePlayerJoinedGame (e :AVRGameControlEvent) :void
    {

    }

    protected function handlePlayerQuitGame (e :AVRGameControlEvent) :void
    {

    }
    
    

    REMOTE function registerDataView (playerId :int, playerIdsAllowedToEdit :Array, 
        isPublic :Boolean = true) :void
    {
        log.debug("registerData", "playerIds", playerIds);
    }

    REMOTE function delta (playerId :int, key :int, deltaObject :Object) :void
    {
        log.debug("delta", "playerId", playerId, "deltaObject", deltaObject);
    }

    protected var _mapPlayerId2ModelId :HashMap = new HashMap();
    protected var _mapModelId2RoomId :HashMap = new HashMap();

    protected var _ctrl :AVRServerGameControl;
    protected var _id :String;
    protected var _remoteProvider :RemoteProvider;
    protected var _controllingPlayerIds :Array;
    protected var _publicAllowed :Boolean;

    protected static var MODEL_ID_COUNTER :int;//Used to create unique model ids.
    protected static const log :Log = Log.getLog(DataViewServer);
}
}
