package kabam.rotmg.ProximityChat {
import flash.display.Sprite;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.setTimeout;

public class ProximityChat_UI_Initializer extends Sprite {
    private var micInput:ProximityChat_MicInput;
    private var visualiser:ProximityChat_UI_SoundVisualiser;
    private var micIndex:int = 0;
    private var micLabel:TextField;

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
        micInput = new ProximityChat_MicInput();
        micInput.addEventListener("MicInitialized", onMicReady);

        // Optional: background box to ensure visibility
        graphics.beginFill(0x111111, 0.7);
        graphics.drawRect(0, 0, 220, 80);
        graphics.endFill();
    }

    private function onMicReady(e:Event):void {
        if (visualiser && contains(visualiser)) removeChild(visualiser);

        visualiser = new ProximityChat_UI_SoundVisualiser(micInput.getMic());
        visualiser.y = 60;
        addChild(visualiser);

        updateMicLabel();
        showSwitchMicButton();
    }

    private function updateMicLabel():void {
        if (micLabel && contains(micLabel)) removeChild(micLabel);

        micLabel = new TextField();
        micLabel.name = "micLabel";
        micLabel.text = "Mic: " + micInput.getMic().name;
        micLabel.textColor = 0xFFFFFF;
        micLabel.x = 10;
        micLabel.y = 10;
        micLabel.width = 200;
        micLabel.height = 20;
        micLabel.selectable = false;
        addChild(micLabel);
    }

    private function showSwitchMicButton():void {
        var btn:SimpleButton = new SimpleButton();
        btn.upState = makeButtonState("Switch Mic");
        btn.overState = makeButtonState("Switch Mic");
        btn.downState = makeButtonState("Switching...");
        btn.hitTestState = btn.upState;
        btn.x = 10;
        btn.y = 30;
        addChild(btn);

        btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            micIndex++;
            var mics:Array = micInput.getAvailableMicNames();
            if (micIndex >= mics.length) micIndex = 0;
            micInput.switchToMic(micIndex);
        });

        micInput.addEventListener("MicInitialized", function(e:Event):void {
            updateMicLabel();
            if (visualiser && contains(visualiser)) removeChild(visualiser);
            visualiser = new ProximityChat_UI_SoundVisualiser(micInput.getMic());
            visualiser.y = 60;
            addChild(visualiser);
        });
    }

    private function makeButtonState(label:String):Sprite {
        var state:Sprite = new Sprite();
        state.graphics.beginFill(0x333333);
        state.graphics.drawRect(0, 0, 100, 20);
        state.graphics.endFill();

        var tf:TextField = new TextField();
        tf.text = label;
        tf.textColor = 0xFFFFFF;
        tf.width = 100;
        tf.height = 20;
        tf.selectable = false;
        state.addChild(tf);

        return state;
    }
}
}