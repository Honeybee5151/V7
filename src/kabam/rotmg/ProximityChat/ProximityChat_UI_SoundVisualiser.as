package kabam.rotmg.ProximityChat {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.media.Microphone;
import flash.utils.Timer;

public class ProximityChat_UI_SoundVisualiser extends Sprite {
    private var mic:Microphone;
    private var canvas:Sprite;
    private var g;
    private var timer:Timer;
    private var xPos:int = 0;
    private var baseline:int = 60;
    private var maxHeight:int = 40;

    public function ProximityChat_UI_SoundVisualiser(micRef:Microphone) {
        this.mic = micRef;

        // Visualiser canvas
        canvas = new Sprite();
        addChild(canvas);
        g = canvas.graphics;
        g.lineStyle(2, 0x00FF00);
        g.moveTo(0, baseline);

        // Start drawing
        timer = new Timer(50); // ~20 FPS
        timer.addEventListener(TimerEvent.TIMER, onTimer);
        timer.start();

        addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
    }

    private function onTimer(e:TimerEvent):void {
        var level:Number = mic.activityLevel / 100; // normalize 0–1
        var height:Number = level * maxHeight;
        var y:Number = baseline - height;

        g.lineTo(xPos, y);
        xPos += 2;

        if (xPos >= stage.stageWidth) {
            xPos = 0;
            g.clear();
            g.lineStyle(2, 0x00FF00);
            g.moveTo(0, baseline);
        }
    }

    private function cleanup(e:Event):void {
        timer.stop();
        timer.removeEventListener(TimerEvent.TIMER, onTimer);
    }
}
}