package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.ui.panels.itemgrids.InventoryGrid;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InventoryTile;


public class HB_UI_Inventory extends InventoryGrid {


    public function HB_UI_Inventory(player:Player) {
        super(player, player, 4, false)
        editHB_UI_Inventory()


    }


    public function editHB_UI_Inventory():void {
        for (var i:int = 0; i < this.numChildren; i++) {
            var tile:HB_UI_InventoryTile  = this.getChildAt(i) as HB_UI_InventoryTile ;
            if (tile != null) {
                tile.scaleX = tile.scaleY = 1.0;
                tile.x = (i % 2) * 30;
                tile.y = int(i / 2) * 30;
            }
        }
    }









}
}
