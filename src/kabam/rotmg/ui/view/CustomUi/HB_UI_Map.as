package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.game.GameSprite;

import kabam.rotmg.minimap.view.MiniMap;

import flash.events.Event;

public class HB_UI_Map extends MiniMap {
    private var gs_:GameSprite;
    private var ready:Boolean = false;

    public function HB_UI_Map(gs:GameSprite) {
        super(150, 150);
        this.gs_ = gs;
        this.x = 650;
        this.y = 0;

        onModelInitialized();



    }

    private function updateMiniMap(e:Event):void {
        if (ready) {
            this.draw();
        }
    }

    public function cleanup():void {;
        removeEventListener(Event.ENTER_FRAME, updateMiniMap);

        if (this.parent) {
            this.parent.removeChild(this);
        }
    }
    private function onModelInitialized():void {
        if (gs_.map && gs_.map.player_) {
            this.setMap(gs_.map);
            this.setFocus(gs_.map.player_);
            ready = true;
            trace("✅ Minimap initialized via modelInitialized signal");

            addEventListener(Event.ENTER_FRAME, updateMiniMap);
        }
    }
}
}