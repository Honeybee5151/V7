package kabam.rotmg.ProximityChat {
import flash.media.Microphone;
import flash.media.SoundTransform;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.events.ActivityEvent;
import flash.events.StatusEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.Endian;
import flash.events.TimerEvent;

public class ProximityChat_MicInput extends EventDispatcher {

    // Microphone instance
    private var microphone:Microphone;

    // Audio data storage
    private var audioBuffer:ByteArray;
    private var isRecording:Boolean = false;
    private var isInitialized:Boolean = false;

    // Settings
    private var sampleRate:int = 44100; // CD quality
    private var gain:Number = 50; // Microphone gain (0-100)
    private var silenceLevel:Number = 0; // Silence detection threshold
    private var silenceTimeout:int = -1; // Never timeout

    // Activity monitoring
    private var activityLevel:Number = 0;
    private var isActive:Boolean = false;

    // Events
    public static const MIC_INITIALIZED:String = "micInitialized";
    public static const MIC_ERROR:String = "micError";
    public static const AUDIO_DATA_AVAILABLE:String = "audioDataAvailable";
    public static const ACTIVITY_CHANGED:String = "activityChanged";

    public function ProximityChat_MicInput() {
        super();
        audioBuffer = new ByteArray();
        audioBuffer.endian = Endian.LITTLE_ENDIAN;
        initializeMicrophone();
    }

    /**
     * Initialize the default system microphone
     */
    private function initializeMicrophone():void {
        try {
            // Get the default microphone (uses Windows default)
            microphone = Microphone.getMicrophone();

            if (microphone != null) {
                setupMicrophone();
            } else {
                dispatchEvent(new Event(MIC_ERROR));
                trace("ProximityChat_MicInput: No microphone found");
            }
        } catch (error:Error) {
            dispatchEvent(new Event(MIC_ERROR));
            trace("ProximityChat_MicInput: Error initializing microphone - " + error.message);
        }
    }

    /**
     * Configure microphone settings
     */
    private function setupMicrophone():void {
        // Set microphone properties
        microphone.rate = sampleRate / 1000; // Convert to kHz (44.1 kHz = 44)
        microphone.gain = gain;
        microphone.setSilenceLevel(silenceLevel, silenceTimeout);

        // Enable enhanced microphone (reduces echo and noise)
        if (microphone.hasOwnProperty("enhancedMicrophone")) {
            microphone["enhancedMicrophone"] = true;
        }

        // Add event listeners
        microphone.addEventListener(ActivityEvent.ACTIVITY, onMicrophoneActivity);
        microphone.addEventListener(StatusEvent.STATUS, onMicrophoneStatus);

        isInitialized = true;
        dispatchEvent(new Event(MIC_INITIALIZED));
        trace("ProximityChat_MicInput: Microphone initialized - " + microphone.name);
    }

    /**
     * Start recording from microphone
     */
    public function startRecording():void {
        if (!isInitialized || isRecording) return;

        try {
            // Clear the audio buffer
            audioBuffer.clear();

            // Set up microphone for recording
            microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);

            isRecording = true;
            trace("ProximityChat_MicInput: Recording started");

        } catch (error:Error) {
            trace("ProximityChat_MicInput: Error starting recording - " + error.message);
            dispatchEvent(new Event(MIC_ERROR));
        }
    }

    /**
     * Stop recording from microphone
     */
    public function stopRecording():void {
        if (!isRecording) return;

        try {
            microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
            isRecording = false;
            trace("ProximityChat_MicInput: Recording stopped");

        } catch (error:Error) {
            trace("ProximityChat_MicInput: Error stopping recording - " + error.message);
        }
    }

    /**
     * Handle microphone sample data
     */
    private function onSampleData(event:SampleDataEvent):void {
        // Read available audio data
        var samples:ByteArray = event.data;

        if (samples.bytesAvailable > 0) {
            // Copy data to our buffer
            samples.readBytes(audioBuffer, audioBuffer.length, samples.bytesAvailable);

            // Dispatch event with audio data
            var audioEvent:ProximityChat_AudioDataEvent = new ProximityChat_AudioDataEvent(
                    AUDIO_DATA_AVAILABLE,
                    audioBuffer
            );
            dispatchEvent(audioEvent);
        }
    }

    /**
     * Handle microphone activity changes
     */
    private function onMicrophoneActivity(event:ActivityEvent):void {
        isActive = event.activating;
        activityLevel = microphone.activityLevel;

        var activityEvent:ProximityChat_ActivityEvent = new ProximityChat_ActivityEvent(
                ACTIVITY_CHANGED,
                isActive,
                activityLevel
        );
        dispatchEvent(activityEvent);

        trace("ProximityChat_MicInput: Activity - " + (isActive ? "Active" : "Inactive") +
                " Level: " + activityLevel);
    }

    /**
     * Handle microphone status changes (permissions, etc.)
     */
    private function onMicrophoneStatus(event:StatusEvent):void {
        trace("ProximityChat_MicInput: Status - " + event.code + ": " + event.level);

        if (event.code == "Microphone.Unmuted") {
            trace("ProximityChat_MicInput: Microphone access granted");
        } else if (event.code == "Microphone.Muted") {
            trace("ProximityChat_MicInput: Microphone access denied");
            dispatchEvent(new Event(MIC_ERROR));
        }
    }

    /**
     * Get current audio data from buffer
     */
    public function getAudioData():ByteArray {
        var data:ByteArray = new ByteArray();
        data.endian = Endian.LITTLE_ENDIAN;

        if (audioBuffer.length > 0) {
            audioBuffer.position = 0;
            audioBuffer.readBytes(data, 0, audioBuffer.length);
            audioBuffer.clear(); // Clear buffer after reading
        }

        return data;
    }

    /**
     * Get current microphone activity level (0-100)
     */
    public function getActivityLevel():Number {
        return microphone ? microphone.activityLevel : 0;
    }

    /**
     * Check if microphone is currently active
     */
    public function get microphoneActive():Boolean {
        return isActive;
    }

    /**
     * Check if recording is in progress
     */
    public function get recording():Boolean {
        return isRecording;
    }

    /**
     * Get microphone name
     */
    public function get microphoneName():String {
        return microphone ? microphone.name : "No microphone";
    }

    /**
     * Set microphone gain (0-100)
     */
    public function setGain(value:Number):void {
        gain = Math.max(0, Math.min(100, value));
        if (microphone) {
            microphone.gain = gain;
        }
    }

    /**
     * Get current microphone gain
     */
    public function getGain():Number {
        return gain;
    }

    /**
     * Set silence detection level (0-100)
     */
    public function setSilenceLevel(level:Number, timeout:int = -1):void {
        silenceLevel = Math.max(0, Math.min(100, level));
        silenceTimeout = timeout;

        if (microphone) {
            microphone.setSilenceLevel(silenceLevel, silenceTimeout);
        }
    }

    /**
     * Clean up and release microphone
     */
    public function dispose():void {
        stopRecording();

        if (microphone) {
            microphone.removeEventListener(ActivityEvent.ACTIVITY, onMicrophoneActivity);
            microphone.removeEventListener(StatusEvent.STATUS, onMicrophoneStatus);
            microphone = null;
        }

        if (audioBuffer) {
            audioBuffer.clear();
            audioBuffer = null;
        }

        isInitialized = false;
        trace("ProximityChat_MicInput: Disposed");
    }
}
}

// Custom event class for audio data
import flash.events.Event;
import flash.utils.ByteArray;

class ProximityChat_AudioDataEvent extends Event {
    public var audioData:ByteArray;

    public function ProximityChat_AudioDataEvent(type:String, data:ByteArray) {
        super(type, false, false);
        this.audioData = data;
    }

    public override function clone():Event {
        return new ProximityChat_AudioDataEvent(type, audioData);
    }
}

// Custom event class for activity changes
class ProximityChat_ActivityEvent extends Event {
    public var isActive:Boolean;
    public var activityLevel:Number;

    public function ProximityChat_ActivityEvent(type:String, active:Boolean, level:Number) {
        super(type, false, false);
        this.isActive = active;
        this.activityLevel = level;
    }

    public override function clone():Event {
        return new ProximityChat_ActivityEvent(type, isActive, activityLevel);
    }
}
