package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.objects.Player;

import flash.display.Sprite;

public class HB_UI_InventoryBP_Wrapper extends Sprite {

    private var trackedPlayer:Player;
    private var inventory:HB_UI_Inventory;
    private var backpack:HB_UI_BP;

    public function HB_UI_InventoryBP_Wrapper()  {
    }



    public function Initialize(player:Player):void{
        trackedPlayer = player;
        inventory = new HB_UI_Inventory(trackedPlayer);
        addChild(inventory);
        backpack = new HB_UI_BP(trackedPlayer);
        if (player.hasBackpack_) {
            addChild(backpack);
        }
    }
    public function getInventory():HB_UI_Inventory {
        return inventory;
    }

    public function getBackpack():HB_UI_BP {
        return backpack;
    }

}
}
