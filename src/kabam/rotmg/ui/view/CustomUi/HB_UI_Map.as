package kabam.rotmg.ui.view.CustomUi {
import flash.display.Sprite;
import com.company.assembleegameclient.game.GameSprite;
import kabam.rotmg.minimap.view.MiniMap;
import com.company.assembleegameclient.map.Map;




public class HB_UI_Map extends Sprite {
    private var MAP_POSITION_x:uint = 650;
    private var MAP_POSITION_y:uint = 0
    public function HB_UI_Map() {


       var miniMap:MiniMap = new MiniMap(150, 150);
        miniMap.x = MAP_POSITION_x;
        miniMap.y = MAP_POSITION_y;
        miniMap.draw();

        miniMap.setMap(gs_.map);     // must come before the first UPDATE packet
        addChild(miniMap);

    }
}
}
