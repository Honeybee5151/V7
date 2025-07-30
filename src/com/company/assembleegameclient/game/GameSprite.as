package com.company.assembleegameclient.game {
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.IInteractiveObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.Projectile;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.parameters.ScreenParameters;
import com.company.assembleegameclient.ui.GuildText;
import com.company.assembleegameclient.ui.RankText;
import com.company.assembleegameclient.ui.TextBox;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.CachingColorTransformer;
import com.company.util.MoreColorUtil;
import com.company.util.MoreObjectUtil;
import com.company.util.PointUtil;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.filters.ColorMatrixFilter;
import flash.sampler.getSavedThis;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import kabam.lib.loopedprocs.LoopedCallback;
import kabam.lib.loopedprocs.LoopedProcess;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.core.model.MapModel;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.game.view.CreditDisplay;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.messaging.impl.incoming.MapInfo;
import kabam.rotmg.minimap.view.MiniMapMediator;
import kabam.rotmg.stage3D.Renderer;
import kabam.rotmg.ui.UIUtils;
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.signals.UpdateBackpackTabSignal;
import kabam.rotmg.ui.signals.UpdatePotionInventorySignal;
import kabam.rotmg.ui.view.CustomUi.HB_UI_BP;
import kabam.rotmg.ui.view.CustomUi.HB_UI_Inventory;
import kabam.rotmg.ui.view.CustomUi.HB_UI_InventoryBP_Wrapper;
import kabam.rotmg.ui.view.CustomUi.MiniMap_Initializer_Signal;

import kabam.rotmg.ui.view.HUDView;
import kabam.rotmg.ui.view.CustomUi.MiniMap_Initializer;
import kabam.rotmg.minimap.view.MiniMap;

import org.osflash.signals.Signal;

import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.ui.view.CustomUi.HB_UI_Initializer;

import org.swiftsuspenders.Injector;


import robotlegs.bender.framework.api.IContext;
import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap


public class GameSprite extends Sprite {
   public const closed:Signal = new Signal();
   public const modelInitialized:Signal = new Signal();
   public const drawCharacterWindow:Signal = new Signal(Player);
   public var map:Map;
   public var camera_:Camera;
   public var gsc_:GameServerConnection;
   public var mui_:MapUserInput;
   public var textBox_:TextBox;
   public var isNexus_:Boolean = false;
   public var hudView:HUDView;
   public var rankText_:RankText;
   public var guildText_:GuildText;
   public var creditDisplay_:CreditDisplay;
   public var isEditor:Boolean;
   public var lastUpdate_:int = 0;
   public var firstUpdate:Boolean = true;
   public var mapModel:MapModel;
   public var model:PlayerModel;
   private var focus:GameObject;
   private var isGameStarted:Boolean;
   private var displaysPosY:uint = 4;
   private var potionSignal:UpdatePotionInventorySignal;
   public var Initialize_HB_UI_Initializer:HB_UI_Initializer;
   public const playerReady:Signal = new Signal(Player);
   private var hasDispatchedPlayerReady:Boolean = false;
   private var checkerForPlayer:Boolean = false;
   private var hasInitializedUI:Boolean = false;
   //private var miniMap:HB_UI_Map;
   private const mapReady:Signal = new Signal(Player);
   private var savedPos:Object;
   public var miniMap:MiniMap_Initializer;
   private var trackedPlayer:Player;
   private var inventory:HB_UI_Inventory;
   private var backpack:HB_UI_BP;
   public var inventoryWrapper:HB_UI_InventoryBP_Wrapper;
   private var position_of_map_when_customUI:uint = 608
   private var position_of_map_when_originalUI:uint = 604
   private var lastStageWidth:int = -1;
   private var lastStageHeight:int = -1;


   public function GameSprite(gameId:int, createCharacter:Boolean, charId:int, model:PlayerModel, mapJSON:String) {

      this.camera_ = new Camera();
      super();
      this.model = model;
      this.map = new Map(this);
      addChild(this.map);
      this.gsc_ = new GameServerConnection(this, gameId, createCharacter, charId, mapJSON);
      this.mui_ = new MapUserInput(this);
      this.textBox_ = new TextBox(this, 600, 600);
      addChild(this.textBox_);
      this.potionSignal = new UpdatePotionInventorySignal();
      this.Initialize_HB_UI_Initializer = new HB_UI_Initializer(this.potionSignal);
      Initialize_HB_UI_Initializer.x += 260;
      Initialize_HB_UI_Initializer.y += 555;



   }

   public function setFocus(focus:GameObject):void {
      focus = focus || this.map.player_;
      this.focus = focus;
   }

   public function applyMapInfo(mapInfo:MapInfo):void {
      this.map.setProps(mapInfo.width_, mapInfo.height_, mapInfo.name_, mapInfo.background_, mapInfo.allowPlayerTeleport_, mapInfo.showDisplays_);
   }


   public function miniMapInitializer():void {
      miniMap = new MiniMap_Initializer();
      addChild(miniMap);
      trace("MiniMap has run")
      if (this.contains(this.miniMap)) {
         this.setChildIndex(this.miniMap, this.numChildren - 1);
      }



   }

   public function hudModelInitialized():void {
      if (!Parameters.data_.uitoggle) {
         this.hudView = new HUDView();
         this.hudView.x = 600;
         if (!Parameters.uitoggle)
            addChild(this.hudView);


      }
   }


   public function HB_UI_Start():void {
      addChild(Initialize_HB_UI_Initializer);
      this.trackedPlayer = this.map.player_;

      waitForPlayerReady();
      if (savedPos) { ScreenParameters.execute(Initialize_HB_UI_Initializer, savedPos); }





      trace("HB_UI_Initializer added:", this.contains(Initialize_HB_UI_Initializer)); // Should be true
      trace("HB_UI_Initializer pos:", Initialize_HB_UI_Initializer.x, Initialize_HB_UI_Initializer.y);
      trace("HB_UI_Initializer scale:", Initialize_HB_UI_Initializer.scaleX, Initialize_HB_UI_Initializer.scaleY);
      trace("savedPos ?", JSON.stringify(savedPos));

   }


   public function HB_UI_Stop():void {
      removeChild(Initialize_HB_UI_Initializer);
      Initialize_HB_UI_Initializer.HB_UI_cleanup();
      if (inventoryWrapper && contains(inventoryWrapper)) {
         removeChild(inventoryWrapper);
         inventoryWrapper = null;
      }
      hasInitializedUI = false;

      }



   public function initialize():void {





      this.map.initialize();

      this.creditDisplay_ = new CreditDisplay(this);
      this.creditDisplay_.x = 594;
      this.creditDisplay_.y = 0;
      addChild(this.creditDisplay_);
      this.modelInitialized.dispatch();

      if (this.map.showDisplays_) {
         this.showSafeAreaDisplays();
      }

      if (this.map.name_ == "Nexus") {
         isNexus_ = true;
      }


   }

   private function showSafeAreaDisplays():void {
      this.showRankText();
      this.showGuildText();
   }

   private function showGuildText():void {
      this.guildText_ = new GuildText("", -1);
      this.guildText_.x = 64;
      this.guildText_.y = 6;
      addChild(this.guildText_);
   }

   private function showRankText():void {
      this.rankText_ = new RankText(-1, true, false);
      this.rankText_.x = 8;
      this.rankText_.y = this.displaysPosY;
      this.displaysPosY = this.displaysPosY + UIUtils.NOTIFICATION_SPACE;
      addChild(this.rankText_);
   }

   private function callTracking(functionName:String):void {
      if (ExternalInterface.available == false) {
         return;
      }
      try {
         ExternalInterface.call(functionName);
      } catch (err:Error) {
      }
   }

   private function updateNearestInteractive():void {
      var dist:Number = NaN;
      var go:GameObject = null;
      var iObj:IInteractiveObject = null;
      if (!this.map || !this.map.player_) {
         return;
      }
      var player:Player = this.map.player_;
      var minDist:Number = GeneralConstants.MAXIMUM_INTERACTION_DISTANCE;
      var closestInteractive:IInteractiveObject = null;
      var playerX:Number = player.x_;
      var playerY:Number = player.y_;
      for each(go in this.map.goDict_) {
         iObj = go as IInteractiveObject;
         if (iObj) {
            if (Math.abs(playerX - go.x_) < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE || Math.abs(playerY - go.y_) < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE) {
               dist = PointUtil.distanceXY(go.x_, go.y_, playerX, playerY);
               if (dist < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE && dist < minDist) {
                  minDist = dist;
                  closestInteractive = iObj;
               }
            }
         }
      }
      this.mapModel.currentInteractiveTarget = closestInteractive;
   }

   public function connect():void {
      if (!this.isGameStarted) {
         this.isGameStarted = true;
         Renderer.inGame = true;
         this.gsc_.connect();
         this.lastUpdate_ = getTimer();
         stage.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
         LoopedProcess.addProcess(new LoopedCallback(100, this.updateNearestInteractive));
         stage.focus = null;
         stage.addEventListener(Event.RESIZE, onResize);

         var injector:Injector = StaticInjectorContext.getInjector();
         var hudModel:HUDModel = injector.getInstance(HUDModel);
         hudModel.gameSprite = this;

         // ✅ If you have a custom signal:
         var minimapSignal:MiniMap_Initializer_Signal = injector.getInstance(MiniMap_Initializer_Signal);
         minimapSignal.dispatch(); // <- this will trigger the mediator

         // OR simply call your UI initializer directly:
         this.miniMapInitializer();  // if you're not going signal-based

         if (Parameters.data_.uitoggle) {
            miniMap.x = position_of_map_when_customUI

         }
         if (!Parameters.data_.uitoggle) {
            miniMap.x = position_of_map_when_originalUI

         }
         if (Initialize_HB_UI_Initializer.scaleX == 1 && stage.stageWidth > 800) {
            if (!savedPos) {
               savedPos = ScreenParameters.positionRelations(Initialize_HB_UI_Initializer);
               trace("savedPos was missing — created manually.");
               hasInitializedUI = true;
            }
            if (savedPos) {
               onResize(null); // ✅ Only resize if savedPos exists
               trace("Resize not skipped");
            } else {
               trace("Resize skipped — savedPos not ready");
            }


         }

      }
   }
   public function disconnect():void {
      if (this.isGameStarted) {
         this.isGameStarted = false;
         Renderer.inGame = false;
         this.gsc_.serverConnection.disconnect();
         stage.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
         LoopedProcess.destroyAll();
         contains(this.map) && removeChild(this.map);
         this.map.dispose();
         CachingColorTransformer.clear();
         TextureRedrawer.clearCache();
         this.gsc_.disconnect();
         if (Parameters.data_.uitoggle) {
            HB_UI_Stop();
         }
        // miniMap.cleanup();
         //removeChild(miniMap);
         stage.removeEventListener(Event.RESIZE, onResize);
      }


   }

   private function onEnterFrame(event:Event):void {
      var time:int = getTimer();
      var player:Player = this.map.player_;
      if (player != null) {
         var dt:int = time - this.lastUpdate_;
         LoopedProcess.runProcesses(time);
         this.map.update(time, dt);
         this.camera_.update(dt);

         if (this.focus) {
            this.camera_.configureCamera(this.focus, player.isHallucinating());
            this.map.draw(this.camera_, time);
         }

         this.creditDisplay_.draw(player.credits_, player.fame_);
         this.drawCharacterWindow.dispatch(player);
         if (this.map.showDisplays_) {
            this.rankText_.draw(player.numStars_);
            this.guildText_.draw(player.guildName_, player.guildRank_);
         }
      }
      this.lastUpdate_ = time;


      if (player != null && !hasDispatchedPlayerReady) {
         hasDispatchedPlayerReady = true;
         playerReady.dispatch(player);
      }
      if (Parameters.data_.uitoggle && !checkerForPlayer) {
         HB_UI_Start();
         checkerForPlayer = true;

      }


   }

   private function waitForPlayerReady():void {
      if (!hasInitializedUI) {
         addEventListener(Event.ENTER_FRAME, onCheckPlayerReady);
      }
   }

   private function onCheckPlayerReady(e:Event):void {
      var player:Player = map.player_;
      if (player && player.equipment_ && player.equipment_.length > 3) {
         removeEventListener(Event.ENTER_FRAME, onCheckPlayerReady);

         // 🔧 ONLY create savedPos if it doesn't exist
         if (!savedPos) {
            savedPos = ScreenParameters.positionRelations(Initialize_HB_UI_Initializer);
         }

         Initialize_HB_UI_Initializer.onPlayerReady(player);
         Initialize_HB_UI_Initializer.HB_UI_Initialize(player);

         inventoryWrapper = new HB_UI_InventoryBP_Wrapper();
         inventoryWrapper.Initialize(this.map.player_);
         addChild(inventoryWrapper);

         Initialize_HB_UI_Initializer.setExternalUIRefs(
                 inventoryWrapper.getInventory(),
                 inventoryWrapper.getBackpack()
         );

         hasInitializedUI = true; // Also add this
      }
   }
   private function onResize(e:Event):void {
      if (contains(Initialize_HB_UI_Initializer) && savedPos){
         ScreenParameters.execute(Initialize_HB_UI_Initializer, savedPos);
         trace("savedPos →", JSON.stringify(savedPos));
      }
      else{
         trace("gamesprite's onresize's savedd pos it not avialable");
      }



   }


}
}