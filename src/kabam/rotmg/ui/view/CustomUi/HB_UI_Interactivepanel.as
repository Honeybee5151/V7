package kabam.rotmg.ui.view.CustomUi {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.ui.panels.InteractPanel;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.IInteractiveObject;
import com.company.util.PointUtil;

import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.display.Sprite;

public class HB_UI_Interactivepanel extends Sprite {
    public var interactPanel:InteractPanel;
    private var gs_:GameSprite;
    private var updateTimer:Timer;

    public function HB_UI_Interactivepanel(gs:GameSprite) {
        this.gs_ = gs;

        var player:Player = this.gs_.map.player_;
        this.interactPanel = new InteractPanel(this.gs_, player, 200, 100);
        this.interactPanel.requestInteractive = getNearestInteractiveObject;
        this.interactPanel.visible = false;
        this.interactPanel.x = 300 - 260;
        this.interactPanel.y = 460 - 555;

        addChild(this.interactPanel);

        startUpdateTimer();
    }

    private function getNearestInteractiveObject(player:Player):IInteractiveObject {
        if (!player || !gs_ || !gs_.map) return null;

        var minDist:Number = 1.0;
        var closest:IInteractiveObject = null;

        for each (var go:GameObject in gs_.map.goDict_) {
            var io:IInteractiveObject = go as IInteractiveObject;
            if (io) {
                var dist:Number = PointUtil.distanceXY(go.x_, go.y_, player.x_, player.y_);
                if (dist < minDist) {
                    minDist = dist;
                    closest = io;
                }
            }
        }

        return closest;
    }


    private function onUpdate(event:TimerEvent):void {
        if (!this.interactPanel || !gs_ || !this.gs_.map || !this.gs_.map.player_) return;

        var nearest:IInteractiveObject = this.getNearestInteractiveObject(this.gs_.map.player_);
        this.interactPanel.visible = (nearest != null);
        if (nearest) {
            this.interactPanel.draw();
        }
    }

    private function startUpdateTimer():void {
        updateTimer = new Timer(250); // every 250ms
        updateTimer.addEventListener(TimerEvent.TIMER, onUpdate);
        updateTimer.start();
    }

    public function dispose():void {
        if (updateTimer) {
            updateTimer.stop();
            updateTimer.removeEventListener(TimerEvent.TIMER, onUpdate);
            updateTimer = null;
        }

        if (interactPanel && interactPanel.parent) {
            interactPanel.parent.removeChild(interactPanel);
        }

        this.interactPanel = null;
        this.gs_ = null;
    }


}
}