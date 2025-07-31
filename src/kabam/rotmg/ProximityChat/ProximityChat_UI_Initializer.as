package kabam.rotmg.ProximityChat {
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;

public class ProximityChat_UI_Initializer extends Sprite {
    private var visualiser:ProximityChat_UI_SoundVisualiser;
    private var micInput:ProximityChat_MicInput;
    private var debugTimer:Timer;

    public function ProximityChat_UI_Initializer() {
        trace("DEBUG MAIN: ProximityChat_UI_Initializer constructor called");

        // Create microphone input
        micInput = new ProximityChat_MicInput();

        // ADD EVENT LISTENERS IMMEDIATELY AFTER CREATING MIC INPUT
        micInput.addEventListener(ProximityChat_MicInput.MIC_INITIALIZED, onMicReady);
        micInput.addEventListener(ProximityChat_MicInput.MIC_ERROR, onMicError);
        micInput.addEventListener(ProximityChat_MicInput.ACTIVITY_CHANGED, onMicActivity);

        // Check if already initialized and start recording manually
        if (micInput.recording == false && isInitialized()) {
            trace("DEBUG MAIN: Microphone already initialized, starting recording");
            micInput.startRecording();
        }

        // Create visualizer
        visualiser = new ProximityChat_UI_SoundVisualiser(micInput, 200, 80);

        // Add to display list
        addChild(visualiser);

        // Position it
        visualiser.x = 10;
        visualiser.y = 10;

        // Set up debug timer
        debugTimer = new Timer(5000);
        debugTimer.addEventListener(TimerEvent.TIMER, onDebugTimer);
        debugTimer.start();

        trace("DEBUG MAIN: Constructor completed");
    }

    private function isInitialized():Boolean {
        // Check if mic input has a valid microphone
        return micInput.microphoneName != "No microphone";
    }

    private function onMicReady(e:Event):void {
        trace("DEBUG MAIN: Microphone ready - " + micInput.microphoneName);
        micInput.startRecording();
        trace("DEBUG MAIN: Recording started");
    }

    private function onMicError(e:Event):void {
        trace("DEBUG MAIN: Microphone error!");
    }

    private function onMicActivity(e:*):void {
        trace("DEBUG MAIN: Activity - " + e.isActive + " Level: " + e.activityLevel);
    }

    private function onDebugTimer(e:TimerEvent):void {
        trace("=== DEBUG STATUS ===");
        trace("MicInput: " + micInput.getDebugInfo());
        trace("Visualizer: " + visualiser.getDebugInfo());

        // Force start recording if not started
        if (!micInput.recording) {
            trace("DEBUG MAIN: Recording not started, forcing start");
            micInput.startRecording();
        }

        trace("===================");
    }
}
}