package kabam.rotmg.ProximityChat {
import flash.display.Sprite;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.media.Microphone;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;
import flash.events.TimerEvent;

public class ProximityChat_UI_Initializer extends Sprite {
    private var mic:Microphone;
    private var micIndex:int = 0;
    private var micList:Array;
    private var micLabel:TextField;
    private var activityTimer:Timer;

    public function ProximityChat_UI_Initializer() {
        if (stage) {
            init();
        } else {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
    }

    private function onAddedToStage(e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        init();
    }

    private function init():void {
        trace("🎤 Initializing mic selector...");

        micList = Microphone.names;
        if (micList.length == 0) {
            trace("❌ No microphones available.");
            return;
        }

        trace("🔊 Found input devices:");
        for (var i:int = 0; i < micList.length; i++) {
            trace("[" + i + "]: " + micList[i]);
        }

        // Mic name label
        micLabel = new TextField();
        micLabel.textColor = 0xFFFFFF;
        micLabel.autoSize = TextFieldAutoSize.LEFT;
        micLabel.x = 10;
        micLabel.y = 10;
        addChild(micLabel);

        // Switch mic button
        var btn:SimpleButton = createButton("Next Mic");
        btn.x = 10;
        btn.y = 40;
        btn.addEventListener(MouseEvent.CLICK, onNextMic);
        addChild(btn);

        selectMic(micIndex);
    }

    private function onNextMic(e:MouseEvent):void {
        micIndex = (micIndex + 1) % micList.length;
        selectMic(micIndex);
    }

    private function selectMic(index:int):void {
        trace("🔁 Switching to mic index: " + index + " → " + micList[index]);
        mic = Microphone.getMicrophone(index);

        if (!mic) {
            trace("❌ Microphone at index " + index + " not available.");
            return;
        }

        mic.setLoopBack(false);
        mic.setUseEchoSuppression(true);
        mic.gain = 80;
        mic.rate = 11;
        mic.setSilenceLevel(5, 1000);
        mic.addEventListener(StatusEvent.STATUS, onMicStatus);

        micLabel.text = "🎤 Using: " + mic.name;

        // Start or reset polling
        if (activityTimer) activityTimer.stop();

        activityTimer = new Timer(500);
        activityTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            trace("📈 Mic activity: " + mic.activityLevel);
        });
        activityTimer.start();
    }

    private function onMicStatus(e:StatusEvent):void {
        if (e.code === "Microphone.Unmuted") {
            trace("✅ Mic access granted.");
        } else if (e.code === "Microphone.Muted") {
            trace("❌ Mic access denied.");
        }
    }

    private function createButton(label:String):SimpleButton {
        var up:Sprite = new Sprite();
        up.graphics.beginFill(0x333333);
        up.graphics.drawRect(0, 0, 100, 20);
        up.graphics.endFill();

        var tf:TextField = new TextField();
        tf.text = label;
        tf.textColor = 0xFFFFFF;
        tf.width = 100;
        tf.height = 20;
        tf.selectable = false;
        up.addChild(tf);

        // Same for over/down state (simplified)
        return new SimpleButton(up, up, up, up);
    }
}
}