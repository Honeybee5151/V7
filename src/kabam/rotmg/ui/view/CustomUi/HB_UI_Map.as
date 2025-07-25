package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.objects.Player;
import flash.display.Sprite;
import com.company.assembleegameclient.game.GameSprite;
import flash.events.Event;
import kabam.rotmg.minimap.view.MiniMap;

public class HB_UI_Map extends Sprite {
    private const MAP_POSITION_X:uint = 650;
    private const MAP_POSITION_Y:uint = 0;

    private var miniMap:MiniMap;
    private var gs_:GameSprite;
    private var focusSet:Boolean = false;

    public function HB_UI_Map(gs:GameSprite) {
        this.gs_ = gs;

        miniMap = new MiniMap(150, 150);
        miniMap.x = MAP_POSITION_X;
        miniMap.y = MAP_POSITION_Y;

        addChild(miniMap);
        addEventListener(Event.ENTER_FRAME, waitForReady);
    }

    public function waitForReady(e:Event):void {
        if (gs_ && gs_.map && gs_.map.player_ && gs_.map.width_ > 1 && gs_.map.height_ > 1) {
            miniMap.setMap(gs_.map);
            miniMap.setFocus(gs_.map.player_);
            focusSet = true;
            removeEventListener(Event.ENTER_FRAME, waitForReady);
            addEventListener(Event.ENTER_FRAME, updateMiniMap);
        }
    }

    public function updateMiniMap(e:Event):void {
        if (focusSet) {
            miniMap.draw();
        }
    }

    public function cleanup():void {
        removeEventListener(Event.ENTER_FRAME, waitForReady);
        removeEventListener(Event.ENTER_FRAME, updateMiniMap);
        if (miniMap && contains(miniMap)) {
            removeChild(miniMap);
        }
    }
}}