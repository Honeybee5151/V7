package kabam.rotmg.ui.view.CustomUi {
import flash.display.Sprite;
import flash.events.Event;
kabam.rotmg.ui.view.CustomUi.HB_UI_Equipment_BG;
import com.company.assembleegameclient.objects.Player;




public class HB_UI_Initializer extends Sprite{
    private var trackedPlayer:Player;

    private var initializeHB_UI_MPHP:HB_UI_MPHP = new HB_UI_MPHP();
    private var equipmentUI:HB_UI_Equipment;
    private var equipmentBG:HB_UI_Equipment_BG;
    private var inventory:HB_UI_Inventory;

    public function HB_UI_Initializer() {



    }





    public function HB_UI_Initialize(player:Player):void {
        this.trackedPlayer = player;

        if (!initializeHB_UI_MPHP) {
            initializeHB_UI_MPHP = new HB_UI_MPHP();
        }

        addChild(initializeHB_UI_MPHP);
        initializeHB_UI_MPHP.startUpdating(trackedPlayer);
    }






    public function HB_UI_cleanup():void {
        if (initializeHB_UI_MPHP) {
            initializeHB_UI_MPHP.stopUpdating();
            if (contains(initializeHB_UI_MPHP)) removeChild(initializeHB_UI_MPHP);
            initializeHB_UI_MPHP = null;
        }

        if (equipmentUI) {
            if (contains(equipmentUI)) removeChild(equipmentUI);
            equipmentUI.cleanup();
            equipmentUI = null;
        }

        if (equipmentBG) {
            if (contains(equipmentBG)) removeChild(equipmentBG);
            equipmentBG = null;
        }

        trackedPlayer = null;
    }
    public function onPlayerReady(player:Player):void {
        this.trackedPlayer = player;

        equipmentBG = new HB_UI_Equipment_BG();
        equipmentBG.drawPerfectSquares();
        addChild(equipmentBG);

        equipmentUI = new HB_UI_Equipment(trackedPlayer);
        addChild(equipmentUI);

        inventory = new HB_UI_Inventory(trackedPlayer);
        addChild(inventory);
    }

}
}
