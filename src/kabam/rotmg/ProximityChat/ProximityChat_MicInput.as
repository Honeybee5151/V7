package kabam.rotmg.ProximityChat {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.media.Microphone;

public class ProximityChat_MicInput extends EventDispatcher {
    private var mic:Microphone;

    public function ProximityChat_MicInput() {
        init();
    }

    private function init():void {
        var micNames:Array = Microphone.names;
        trace("Detected Microphones:");
        for (var i:int = 0; i < micNames.length; i++) {
            trace(i + ": " + micNames[i]);
        }

        mic = Microphone.getMicrophone();
        if (!mic) {
            trace("No microphone available.");
            return;
        }

        mic.addEventListener(StatusEvent.STATUS, onMicStatus);
        setupMic();
        dispatchEvent(new Event("MicInitialized"));
    }

    private function setupMic():void {
        mic.setLoopBack(false);
        mic.setUseEchoSuppression(true);
        mic.gain = 80;
        mic.rate = 11;
        mic.setSilenceLevel(5, 1000);
    }

    private function onMicStatus(evt:StatusEvent):void {
        if (evt.code == "Microphone.Unmuted") {
            trace("Microphone access granted");
        } else if (evt.code == "Microphone.Muted") {
            trace("Microphone access denied.");
        }
    }

    // ✅ THESE MUST BE PUBLIC
    public function getMic():Microphone {
        return mic;
    }

    public function getAvailableMicNames():Array {
        return Microphone.names;
    }

    public function switchToMic(index:int):void {
        var available:Array = Microphone.names;
        if (index >= 0 && index < available.length) {
            mic = Microphone.getMicrophone(index);
            if (mic) {
                setupMic();
                dispatchEvent(new Event("MicInitialized"));
            }
        }
    }
}
}