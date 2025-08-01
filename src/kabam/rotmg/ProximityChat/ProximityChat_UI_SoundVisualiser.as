package kabam.rotmg.ProximityChat {
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.media.Microphone;
import flash.utils.Timer;

public class ProximityChat_UI_SoundVisualiser extends Sprite {
    private var mic:Microphone;
    private var g = graphics;
    private var xPos:int = 0;
    private var baseline:int = 100;
    private var timer:Timer;

    // ✅ Accept mic as an argument
    public function ProximityChat_UI_SoundVisualiser(micRef:Microphone) {
        this.mic = micRef;

        g.lineStyle(1, 0x00FF00);
        g.moveTo(0, baseline);

        timer = new Timer(50);
        timer.addEventListener(TimerEvent.TIMER, onTimer);
        timer.start();
    }

    private function onTimer(e:TimerEvent):void {
        g.lineTo(xPos, baseline - mic.activityLevel);
        xPos += 2;
        if (xPos > stage.stageWidth) {
            xPos = 0;
            g.clear();
            g.lineStyle(1, 0x00FF00);
            g.moveTo(0, baseline);
        }
    }
}
}