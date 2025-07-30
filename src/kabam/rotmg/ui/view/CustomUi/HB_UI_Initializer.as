package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.options.Options;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;

import kabam.rotmg.assets.EmbeddedAssets;
import kabam.rotmg.assets.HB_UI_Assets.EmbeddedAssets_BP;
import kabam.rotmg.assets.HB_UI_Assets.EmbeddedAssets_INVENTORY;
import kabam.rotmg.assets.HB_UI_Assets.EmbeddedAssets_OPTIONS2;
import kabam.rotmg.assets.HB_UI_Assets.EmbeddedAssets_STATS;


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
    private var positions:Array = [370 - 260, 385 - 260, 400 - 260, 415 - 260];
    private var buttonSize:int = 15;
    private var colors:Array = [0xcccccc, 0xcccccc, 0xcccccc, 0xcccccc];
    private var backpack:HB_UI_BP;
    private var stats:HB_UI_Stats;
    private var externalInventory:HB_UI_Inventory;
    private var externalBackpack:HB_UI_BP;
    private var interactivePanel:HB_UI_Interactivepanel;


    private const MAP_POSITION:Point = new Point(650 - 260, 0 - 555);
    private var gs_:GameSprite;
    private var mapChecker:int = 1;
    public var onToggleInventory:Signal = new Signal();
    public var onToggleStats:Signal = new Signal();
    public var onToggleBackpack:Signal = new Signal();
    public var onToggleOptions:Signal = new Signal();
    private var framework1:Bitmap = new EmbeddedAssets_framework.UI_Framework_ICON() as Bitmap;
    private var INVENTORYPNG:Bitmap = new EmbeddedAssets_INVENTORY.HB_UI_INVENTORY_ICON() as Bitmap;
    private var BACKPACKPNG:Bitmap = new EmbeddedAssets_BP.HB_UI_BP_ICON() as Bitmap;
    private var STATSPNG:Bitmap = new EmbeddedAssets_STATS.HB_UI_STATS_ICON() as Bitmap;
    private var OPTIONSPNG:Bitmap = new EmbeddedAssets_OPTIONS2.HB_UI_OPTIONS2_ICON() as Bitmap;
    private var optionsPanel:Options;



    public function HB_UI_Initializer(updatePotionInventory:UpdatePotionInventorySignal) {
        this.updatePotionInventory = updatePotionInventory;

        onToggleInventory.add(toggleInventoryVisibility);
        onToggleStats.add(togglestatsVisibility);
        onToggleBackpack.add(toggleBPVisibility);
        onToggleOptions.add(toggleOPTIONSVisibility);
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
        if (inventory && inventory.visible) {
            inventory.visible = false;
        }
        if (potions) {
            potions.stopUpdating(); // 👈 Stop the timer
            if (contains(potions)) removeChild(potions);
            potions = null;
        }
        if (interactivePanel) {
            interactivePanel.dispose();
        }
        if (framework1 && this.contains(framework1)) {
            this.removeChild(framework1);
        }
        if (INVENTORYPNG && this.contains(INVENTORYPNG)) {
            this.removeChild(INVENTORYPNG);
        }

        if (STATSPNG && this.contains(STATSPNG)) {
            this.removeChild(STATSPNG);
        }
        if (OPTIONSPNG && this.contains(OPTIONSPNG)) {
            this.removeChild(OPTIONSPNG);
        }
        if (BACKPACKPNG && this.contains(BACKPACKPNG)) {
            this.removeChild(BACKPACKPNG);

        }
    }

    public function onPlayerReady(player:Player):void {
        if (player && player.map_ && player.map_.gs_) {
            this.gs_ = player.map_.gs_;
        }
        framework1.x = 200 - 260;
        framework1.y = 530 - 555;
        framework1.scaleX = framework1.scaleY = 2.5;
        framework1.filters = [new DropShadowFilter(0, 0, 0, 1, 16, 16, 1)];
        addChild(framework1);
                this.trackedPlayer = player;

        equipmentBG = new HB_UI_Equipment_BG();
        equipmentBG.drawPerfectSquares();
        addChild(equipmentBG);

        equipmentUI = new HB_UI_Equipment(trackedPlayer);
        addChild(equipmentUI);




        potions = new HB_UI_Potions(updatePotionInventory);
        addChild(potions);
        potions.startUpdating(player);

        stats = new HB_UI_Stats();
        addChild(stats);
        stats.startStatsTimer(trackedPlayer)



        addControlButtons();
        INVENTORYPNG.x = 372.5 - 260;
        INVENTORYPNG.y = 556.5 - 555;
        INVENTORYPNG.scaleX = INVENTORYPNG.scaleY = 1.5;
        addChild(INVENTORYPNG);

        BACKPACKPNG.x = 386.25 - 260;
        BACKPACKPNG.y = 556.5 - 555;
        BACKPACKPNG.scaleX = BACKPACKPNG.scaleY = 1.5;
        addChild(BACKPACKPNG);

        STATSPNG.x = 401.25 - 260;
        STATSPNG.y = 556.5 - 555;
        STATSPNG.scaleX = STATSPNG.scaleY = 1.5;
        addChild(STATSPNG);

        OPTIONSPNG.x = 416.25 - 260;
        OPTIONSPNG.y = 556.5 - 555;
        OPTIONSPNG.scaleX = OPTIONSPNG.scaleY = 1.5;
        addChild(OPTIONSPNG);




        interactivePanel = new HB_UI_Interactivepanel(gs_);
        addChild(interactivePanel);





    }

    public function addControlButtons():void {
        for (var i:int = 0; i < 4; i++) {
            var btn:Sprite = createButton(positions[i], 555 - 555, buttonSize, buttonSize, colors[i]);
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
                onToggleBackpack.dispatch();
                break;
            case "toolBtn2":
                onToggleStats.dispatch();
                break;
            case "toolBtn3":
                onToggleOptions.dispatch();
                break;
        }
    }

    private function toggleInventoryVisibility():void {
        if (externalInventory) {
            if (externalBackpack && externalBackpack.visible) {
                externalBackpack.visible = false;
            }
            externalInventory.visible = !externalInventory.visible;
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
    private function toggleBPVisibility():void {
        if (externalBackpack) {
            if (externalInventory && externalInventory.visible) {

                externalInventory.visible = !externalInventory.visible;
            }
            externalBackpack.visible = !externalBackpack.visible;
        }

        if (stage) {
            stage.focus = null;
        }
    }

    private function toggleOPTIONSVisibility():void {
        if (optionsPanel && this.gs_.contains(optionsPanel)) {
            this.gs_.removeChild(optionsPanel);
            optionsPanel = null;
        } else {
            optionsPanel = new Options(this.gs_);
            this.gs_.addChild(optionsPanel);
        }

        if (stage) {
            stage.focus = null;
        }
    }



    private function onAddedToStage(e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        // ✅ Safe to use `stage` now

    }




    public function setExternalUIRefs(inv:HB_UI_Inventory, bp:HB_UI_BP):void {
        this.externalInventory = inv;
        this.externalBackpack = bp;
    }





    }





}
