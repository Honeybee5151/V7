package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.ui.panels.itemgrids.EquippedGrid;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.EquipmentTile;
import com.company.assembleegameclient.objects.Player;

import flash.display.Shape;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;

public class HB_UI_Equipment extends EquippedGrid {
    private var updateTimer:Timer;
    // keep a typed reference to the four slots so we can tweak them
    private var slots:Vector.<EquipmentTile> = new <EquipmentTile>[];

    public function HB_UI_Equipment(player:Player) {
        super(player, player.slotTypes_, player);   // builds the 4 default tiles
        updateTimer = new Timer(250);
        updateTimer.addEventListener(TimerEvent.TIMER, HB_UI_Equipment_UpdateDim);
        updateTimer.start();
        // 1) collect the tiles that the super‑ctor just created
        for (var i:int = 0; i < numChildren; i++) {
            var t:EquipmentTile = getChildAt(i) as EquipmentTile;
            if (t) slots.push(t);
        }

        // 2) enlarge each tile to 60×60 instead of the default 40×40
        for each (t in slots) {
            t.scaleX = t.scaleY = 0.75;
        }

        // 3) lay them out in a tight square again


        setItems(player.equipment_, player.slotTypes_, 0);

        relayoutTiles();


        // 4) move the whole grid to wherever you want on‑screen
        this.x = 340;      // whole panel’s position
        this.y = 570;

    }

    private function relayoutTiles():void {
        const GAP:int  = 0;             // space between slots
        const TILE:int = 40 * 0.75;     // 30 px after your scale

        for (var i:int = 0; i < slots.length; i++) {
            var tile:EquipmentTile = slots[i];
            tile.x = i * (TILE + GAP);  // ← horizontal row
            tile.y = 0;                 // ← all on the same line
        }

        // (optional) expand or remove the scrollRect so nothing gets clipped
        // scrollRect = null;
        // or
        // scrollRect = new Rectangle(0, 0, slots.length * (TILE + GAP), TILE);
    }
private function HB_UI_Equipment_UpdateDim(e:TimerEvent):void {
    if (this.owner && this.owner.equipment_) {
        // Refresh all equipment tiles from current player data
        this.setItems(this.owner.equipment_, this.owner.slotTypes_, 0);
    }
}
    public function cleanup():void {
        if (updateTimer) {
            updateTimer.stop();
            updateTimer.removeEventListener(TimerEvent.TIMER, HB_UI_Equipment_UpdateDim);
            updateTimer = null;
        }
    }
}



}