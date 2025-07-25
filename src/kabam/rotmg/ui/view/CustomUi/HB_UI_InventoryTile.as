package kabam.rotmg.ui.view.CustomUi{
import com.company.assembleegameclient.ui.panels.itemgrids.ItemGrid;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InteractiveItemTile;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTile;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;
import com.company.ui.SimpleText;
import flash.display.Bitmap;
import flash.display.BitmapData;

public class HB_UI_InventoryTile extends InteractiveItemTile
{


    public var hotKey:int;

    private var hotKeyBMP:Bitmap;

    public function HB_UI_InventoryTile(id:int, parentGrid:ItemGrid, isInteractive:Boolean)
    {
        super(id,parentGrid,isInteractive);
    }

    public function addTileNumber(tileNumber:int) : void
    {
        this.hotKey = tileNumber;
        this.buildHotKeyBMP();
    }

    public function buildHotKeyBMP() : void
    {
        var tempText:SimpleText = new SimpleText(26,3552822,false,0,0);
        tempText.text = String(this.hotKey);
        tempText.setBold(true);
        tempText.updateMetrics();
        var bmpData:BitmapData = new BitmapData(26,30,true,0);
        bmpData.draw(tempText);
        this.hotKeyBMP = new Bitmap(bmpData);
        this.hotKeyBMP.x = 30 / 2 - tempText.width / 2;
        this.hotKeyBMP.y = 30 / 2 - 18;
        addChildAt(this.hotKeyBMP,0);
    }

    override public function setItemSprite(itemTileSprite:ItemTileSprite):void {
        super.setItemSprite(itemTileSprite);

        itemTileSprite.scaleX = itemTileSprite.scaleY = 0.75;
        itemTileSprite.x = 30 / 2;
        itemTileSprite.y = 30 / 2;
    }

    override public function setItem(itemId:int, itemData:int) : Boolean
    {
        var changed:Boolean = super.setItem(itemId, itemData);
        if(changed)
        {
            this.hotKeyBMP.visible = itemSprite.itemId <= 0;
        }
        return changed;
    }

    override protected function beginDragCallback() : void
    {
        this.hotKeyBMP.visible = true;
    }

    override protected function endDragCallback() : void
    {
        this.hotKeyBMP.visible = itemSprite.itemId <= 0;
    }



}
}

