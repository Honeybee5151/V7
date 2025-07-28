package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.map.Map;
import flash.display.Sprite;
import kabam.rotmg.minimap.view.MiniMap;

public class MiniMap_Initializer extends Sprite {
    private var miniMap:MiniMap;

    public function initialize(map:Map):void {
        this.miniMap = new MiniMap(192, 192);
        this.miniMap.x = 0;
        this.miniMap.y = 0;
        this.miniMap.setMap(map); // 🔁 this is key to linking it
        addChild(this.miniMap);
    }

    public function getMiniMap():MiniMap {
        return this.miniMap;
    }
}
}