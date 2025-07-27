package kabam.rotmg.ui.view.CustomUi {



import com.company.assembleegameclient.objects.Player;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import org.osflash.signals.Signal;
import kabam.rotmg.ui.signals.UpdatePotionInventorySignal;
import kabam.rotmg.game.model.PotionInventoryModel;

public class HB_UI_Potions extends Sprite{
    private var mpPots:Vector.<Shape> = new Vector.<Shape>();
    private var hpPots:Vector.<Shape> = new Vector.<Shape>();
    private static const MAX_POTS:int = 6;   //  ← add this line
    private var onPotionsChanged:Signal;
    private var updatePotionInventory:UpdatePotionInventorySignal;

    public function HB_UI_Potions(updatePotionInventory:UpdatePotionInventorySignal) {
        super();
        this.updatePotionInventory = updatePotionInventory;

        this.updatePotionInventory.add(this.onPotionChanged);
        drawHPMPBackground()
        drawRightMPRec();
        drawLeftHPRec()

    }




            public function drawLeftHPRec():void {
                for (var j:uint = 0; j < 6; j++) {
                    var rect2:Shape = new Shape();
                    rect2.x = 340 - 260 + j * 5;
                    rect2.y = 555 - 555;
                    rect2.graphics.lineStyle(1, 0x000000, 1); // thickness: 2px, color: black, alpha: 1 (fully visible)
                    rect2.graphics.beginFill(0xFF0000);

                    rect2.graphics.beginFill(0xff002b, 1);

                    rect2.graphics.drawRect(0, 0, 5, 15);
                    rect2.graphics.endFill();


                    addChild(rect2);
                    hpPots.push(rect2);
                }

            }


            public function drawRightMPRec():void {
                for (var n:uint = 0; n < 6; n++) {
                    var rect6:Shape = new Shape();
                    rect6.x = 430 - 260 + n * 5;
                    rect6.y = 555 - 555;
                    rect6.graphics.lineStyle(1, 0x000000, 1); // thickness: 2px, color: black, alpha: 1 (fully visible)
                    rect6.graphics.beginFill(0xFF0000);
                    rect6.graphics.beginFill(0x002bff, 1);
                    rect6.graphics.drawRect(0, 0, 5, 15);
                    rect6.graphics.endFill();

                    addChild(rect6);
                    mpPots.push(rect6);
                }
            }

            public function drawHPMPBackground():void {
                for (var l:uint = 0; l < 12; l++) {
                    var rect4:Shape = new Shape();
                    rect4.graphics.lineStyle(1, 0x000000, 1);
                    if (l < 6) {
                        rect4.x = 340 - 260 + l * 5;
                        rect4.y = 555 - 555;

                        rect4.graphics.beginFill(0x808080 , 1);
                        rect4.graphics.drawRect(0, 0, 5, 15);
                        rect4.graphics.endFill();
                        addChild(rect4);
                    } else
                    {
                        rect4.x = 400 - 260 + l * 5;
                        rect4.y = 555 - 555;

                        rect4.graphics.beginFill(0x808080, 1);
                        rect4.graphics.drawRect(0, 0, 5, 15);
                        rect4.graphics.endFill();
                        addChild(rect4);
                    }
                }
            }
    public function updatePotBars(player:Player):void {
        if (!player) return;

        var currentHP:int = player.getPotionCount(PotionInventoryModel.HEALTH_POTION_ID);
        var currentMP:int = player.getPotionCount(PotionInventoryModel.MAGIC_POTION_ID);

        for (var i:int = 0; i < hpPots.length; i++) {
            hpPots[i].visible = (i >= MAX_POTS - currentHP);
        }

        for (var j:int = 0; j < mpPots.length; j++) {
            mpPots[j].visible = (j < currentMP);
        }
    }


    private function onPotionChanged(player:Player):void {
        if (player) {
            updatePotBars(player);
        }
    }

}

        }












