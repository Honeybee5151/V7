package kabam.rotmg.ui.view.CustomUi {
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.ui.signals.UpdatePotionInventorySignal;

import org.osflash.signals.Signal;

import kabam.rotmg.ui.view.CustomUi.HB_UI_Equipment_BG;
import com.company.assembleegameclient.objects.Player;
import flash.display.Bitmap;
import kabam.rotmg.assets.Frameworks.EmbeddedAssets_framework;



public class HB_UI_Initializer extends Sprite {
    private var trackedPlayer:Player;
    private var updatePotionInventory:UpdatePotionInventorySignal;
    private var initializeHB_UI_MPHP:HB_UI_MPHP = new HB_UI_MPHP();
    private var equipmentUI:HB_UI_Equipment;
    private var equipmentBG:HB_UI_Equipment_BG;
    private var inventory:HB_UI_Inventory;
    private var potions:HB_UI_Potions;
    private var labels:Array = ["inv", "stats", "bp", "other"];
    private var positions:Array = [370, 385, 400, 415];
    private var buttonSize:int = 15;
    private var colors:Array = [0xcccccc, 0xcccccc, 0xcccccc, 0xcccccc];
    private var backpack:HB_UI_BP;
    private var stats:HB_UI_Stats;

    public var onToggleInventory:Signal = new Signal();
    public var onToggleStats:Signal = new Signal();
    public var onToggleBackpack:Signal = new Signal();
    public var onToggleOther:Signal = new Signal();


    public function HB_UI_Initializer(updatePotionInventory:UpdatePotionInventorySignal) {
        this.updatePotionInventory = updatePotionInventory;
        var framework1:Bitmap = new EmbeddedAssets_framework.UI_Framework_ICON() as Bitmap;
        framework1.x = 200;
        framework1.y = 530;
        framework1.scaleX = framework1.scaleY = 2.5;
        addChild(framework1);
        onToggleInventory.add(toggleInventoryVisibility);
        onToggleStats.add(togglestatsVisibility);
        if (stage) {
            onAddedToStage(null);
        } else {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
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
        if (stats) {
            trackedPlayer = null;
            stats.stopStatsTimer();
        }

        if (backpack && backpack.visible) {
            backpack.visible = false;
        }

        if (stats && stats.visible) {
            stats.visible = false;


        }
        if (inventory && inventory.visible )
                inventory.visible = false;
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

        backpack = new HB_UI_BP(trackedPlayer);
        if (player.hasBackpack_) {
            addChild(backpack);
        }
        potions = new HB_UI_Potions(updatePotionInventory);
        addChild(potions);

        stats = new HB_UI_Stats();
        addChild(stats);
        stats.startStatsTimer(trackedPlayer);

        addControlButtons();



    }

    public function addControlButtons():void {
        for (var i:int = 0; i < 4; i++) {
            var btn:Sprite = createButton(positions[i], 555, buttonSize, buttonSize, colors[i]);
            btn.name = "toolBtn" + i;
            btn.addEventListener(MouseEvent.CLICK, onClick);
            addChild(btn);
        }
    }


    private function createButton(x:int, y:int, w:int, h:int, color:uint):Sprite {
        var btn:Sprite = new Sprite();
        btn.x = x;
        btn.y = y;
        btn.buttonMode = true;
        btn.mouseChildren = false;
        btn.useHandCursor = true;

        var bg:Shape = new Shape();
        bg.graphics.beginFill(color);
        bg.graphics.lineStyle(1, 0x000000);
        bg.graphics.drawRect(0, 0, w, h);
        bg.graphics.endFill();
        btn.addChild(bg);

        return btn;
    }

    private function onClick(e:MouseEvent):void {
        switch (e.currentTarget.name) {
            case "toolBtn0":
                onToggleInventory.dispatch();
                break;
            case "toolBtn1":
                onToggleStats.dispatch();
                break;
            case "toolBtn2":
                onToggleBackpack.dispatch();
                break;
            case "toolBtn3":
                onToggleOther.dispatch();
                break;
        }
    }

    private function toggleInventoryVisibility():void {
        if (inventory) {
            inventory.visible = !inventory.visible;
        }
        if (backpack) {
            backpack.visible = !backpack.visible;
        }
        if (stage) {
            stage.focus = null;
        }
    }

    private function togglestatsVisibility():void {
        if (stats) {
            stats.visible = !stats.visible;

            if (!stats.visible) {
                stats.stopStatsTimer();
            } else {
                stats.startStatsTimer(trackedPlayer); // Restart when visible again
            }
        }
        if (stage) {
        stage.focus = null;
            }
    }
    private function onAddedToStage(e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        // ✅ Safe to use `stage` now
        
    }
}
}
