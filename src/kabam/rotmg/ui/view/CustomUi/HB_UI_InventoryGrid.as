package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.ItemGrid;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InventoryTile;
import kabam.rotmg.ui.view.CustomUi.HB_UI_InventoryTile;

public class HB_UI_InventoryGrid extends ItemGrid{
    private const NUM_SLOTS:uint = 8;

    private var tiles:Vector.<HB_UI_InventoryTile>;

    private var isBackpack:Boolean;



    public function HB_UI_InventoryGrid(gridOwner:GameObject, currentPlayer:Player, itemIndexOffset:int = 0, isBackpack:Boolean = false)
    {
        var tile:HB_UI_InventoryTile = null;
        super(gridOwner,currentPlayer,itemIndexOffset);
        this.tiles = new Vector.<HB_UI_InventoryTile>(this.NUM_SLOTS);
        this.isBackpack = isBackpack;
        for (var i:int = 0; i < this.NUM_SLOTS; i++) {
            tile = new HB_UI_InventoryTile(i + indexOffset, this, interactive);
            tile.addTileNumber(i + 1);

            tile.scaleX = tile.scaleY = 0.75; // scale each tile

            addToGrid(tile, 2, i);
            this.tiles[i] = tile;
        }
    }

    override public function setItems(items:Vector.<int>, datas:Vector.<int>, itemIndexOffset:int = 0) : void
    {
        var numItems:int = 0;
        var i:int = 0;
        var refresh:Boolean = false;
        if(items)
        {
            numItems = items.length;
            for(i = 0; i < this.NUM_SLOTS; i++)
            {
                if(i + indexOffset < numItems)
                {
                    if (this.tiles[i].setItem(items[i + indexOffset], datas[i + indexOffset])) {
                        refresh = true;
                    }
                }
                else
                {
                    if (this.tiles[i].setItem(-1, -1)) {
                        refresh = true;
                    }
                }
            }
            if (refresh) {
                refreshTooltip();
            }
        }
    }
}
}
