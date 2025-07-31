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

    // DEBUG: Add counters
    private var sampleDataCount:int = 0;
    private var activityCount:int = 0;

    // Events
    public static const MIC_INITIALIZED:String = "micInitialized";
    public static const MIC_ERROR:String = "micError";
    public static const AUDIO_DATA_AVAILABLE:String = "audioDataAvailable";
    public static const ACTIVITY_CHANGED:String = "activityChanged";

    public function ProximityChat_MicInput() {
        super();
        trace("DEBUG: ProximityChat_MicInput constructor called");
        audioBuffer = new ByteArray();
        audioBuffer.endian = Endian.LITTLE_ENDIAN;
        initializeMicrophone();
    }

    /**
     * Initialize the default system microphone
     */
    private function initializeMicrophone():void {
        trace("DEBUG: initializeMicrophone() called");
        try {
            // Get the default microphone (uses Windows default)
            microphone = Microphone.getMicrophone();
            trace("DEBUG: Microphone.getMicrophone() returned: " + microphone);

            if (microphone != null) {
                trace("DEBUG: Microphone found, calling setupMicrophone()");
                setupMicrophone();
            } else {
                trace("DEBUG: No microphone found!");
                dispatchEvent(new Event(MIC_ERROR));
            }
        } catch (error:Error) {
            trace("DEBUG: Error in initializeMicrophone - " + error.message);
            dispatchEvent(new Event(MIC_ERROR));
        }
    }

    /**
     * Configure microphone settings
     */
    private function setupMicrophone():void {
        trace("DEBUG: setupMicrophone() called");

        // Set microphone properties
        microphone.rate = sampleRate / 1000; // Convert to kHz (44.1 kHz = 44)
        microphone.gain = gain;
        microphone.setSilenceLevel(silenceLevel, silenceTimeout);

        trace("DEBUG: Microphone settings - Rate: " + microphone.rate + ", Gain: " + microphone.gain);
        trace("DEBUG: Microphone name: " + microphone.name);
        trace("DEBUG: Microphone muted: " + microphone.muted);

        // Enable enhanced microphone (reduces echo and noise)
        if (microphone.hasOwnProperty("enhancedMicrophone")) {
            microphone["enhancedMicrophone"] = true;
            trace("DEBUG: Enhanced microphone enabled");
        }

        // Add event listeners
        microphone.addEventListener(ActivityEvent.ACTIVITY, onMicrophoneActivity);
        microphone.addEventListener(StatusEvent.STATUS, onMicrophoneStatus);
        trace("DEBUG: Event listeners added");

        isInitialized = true;
        trace("DEBUG: Microphone initialized successfully, dispatching MIC_INITIALIZED");
        dispatchEvent(new Event(MIC_INITIALIZED));
    }

    /**
     * Start recording from microphone
     */
    public function startRecording():void {
        trace("DEBUG: startRecording() called - isInitialized: " + isInitialized + ", isRecording: " + isRecording);

        if (!isInitialized || isRecording) {
            trace("DEBUG: Cannot start recording - not initialized or already recording");
            return;
        }

        try {
            // Clear the audio buffer
            audioBuffer.clear();
            trace("DEBUG: Audio buffer cleared");

            // Set up microphone for recording
            microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
            trace("DEBUG: SampleDataEvent listener added");

            isRecording = true;
            trace("DEBUG: Recording started successfully");

        } catch (error:Error) {
            trace("DEBUG: Error starting recording - " + error.message);
            dispatchEvent(new Event(MIC_ERROR));
        }
    }

    /**
     * Stop recording from microphone
     */
    public function stopRecording():void {
        trace("DEBUG: stopRecording() called");
        if (!isRecording) return;

        try {
            microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
            isRecording = false;
            trace("DEBUG: Recording stopped");

        } catch (error:Error) {
            trace("DEBUG: Error stopping recording - " + error.message);
        }
    }

    /**
     * Handle microphone sample data
     */
    private function onSampleData(event:SampleDataEvent):void {
        var freshSamples:ByteArray = new ByteArray();
        freshSamples.endian = Endian.LITTLE_ENDIAN;
        event.data.readBytes(freshSamples);

        var audioEvent:ProximityChat_AudioDataEvent = new ProximityChat_AudioDataEvent(
                AUDIO_DATA_AVAILABLE,
                freshSamples
        );
        dispatchEvent(audioEvent);
    }

    /**
     * Handle microphone activity changes
     */
    private function onMicrophoneActivity(event:ActivityEvent):void {
        activityCount++;
        isActive = event.activating;
        activityLevel = microphone.activityLevel;

        trace("DEBUG: Activity #" + activityCount + " - Active: " + isActive + ", Level: " + activityLevel);

        var activityEvent:ProximityChat_ActivityEvent = new ProximityChat_ActivityEvent(
                ACTIVITY_CHANGED,
                isActive,
                activityLevel
        );
        trace("DEBUG: Dispatching ACTIVITY_CHANGED event");
        dispatchEvent(activityEvent);
    }

    /**
     * Handle microphone status changes (permissions, etc.)
     */
    private function onMicrophoneStatus(event:StatusEvent):void {
        trace("DEBUG: Status event - Code: " + event.code + ", Level: " + event.level);

        if (event.code == "Microphone.Unmuted") {
            trace("DEBUG: Microphone access granted");
        } else if (event.code == "Microphone.Muted") {
            trace("DEBUG: Microphone access denied");
            dispatchEvent(new Event(MIC_ERROR));
        }
    }

    /**
     * Get current audio data from buffer
     */
    public function getAudioData():ByteArray {
        trace("DEBUG: getAudioData() called - buffer length: " + audioBuffer.length);

        var data:ByteArray = new ByteArray();
        data.endian = Endian.LITTLE_ENDIAN;

        if (audioBuffer.length > 0) {
            audioBuffer.position = 0;
            audioBuffer.readBytes(data, 0, audioBuffer.length);
            audioBuffer.clear(); // Clear buffer after reading
            trace("DEBUG: Returned " + data.length + " bytes of audio data");
        } else {
            trace("DEBUG: No audio data in buffer");
        }

        return data;
    }

    /**
     * Get current microphone activity level (0-100)
     */
    public function getActivityLevel():Number {
        var level:Number = microphone ? microphone.activityLevel : 0;
        trace("DEBUG: getActivityLevel() returning: " + level);
        return level;
    }

    /**
     * Check if microphone is currently active
     */
    public function get microphoneActive():Boolean {
        trace("DEBUG: microphoneActive getter returning: " + isActive);
        return isActive;
    }

    /**
     * Check if recording is in progress
     */
    public function get recording():Boolean {
        trace("DEBUG: recording getter returning: " + isRecording);
        return isRecording;
    }

    /**
     * Get microphone name
     */
    public function get microphoneName():String {
        var name:String = microphone ? microphone.name : "No microphone";
        trace("DEBUG: microphoneName getter returning: " + name);
        return name;
    }

    /**
     * Set microphone gain (0-100)
     */
    public function setGain(value:Number):void {
        trace("DEBUG: setGain(" + value + ") called");
        gain = Math.max(0, Math.min(100, value));
        if (microphone) {
            microphone.gain = gain;
            trace("DEBUG: Microphone gain set to: " + microphone.gain);
        }
    }

    /**
     * Get current microphone gain
     */
    public function getGain():Number {
        trace("DEBUG: getGain() returning: " + gain);
        return gain;
    }

    /**
     * Set silence detection level (0-100)
     */
    public function setSilenceLevel(level:Number, timeout:int = -1):void {
        trace("DEBUG: setSilenceLevel(" + level + ", " + timeout + ") called");
        silenceLevel = Math.max(0, Math.min(100, level));
        silenceTimeout = timeout;

        if (microphone) {
            microphone.setSilenceLevel(silenceLevel, silenceTimeout);
            trace("DEBUG: Microphone silence level set");
        }
    }

    /**
     * Clean up and release microphone
     */
    public function dispose():void {
        trace("DEBUG: dispose() called");
        stopRecording();

        if (microphone) {
            microphone.removeEventListener(ActivityEvent.ACTIVITY, onMicrophoneActivity);
            microphone.removeEventListener(StatusEvent.STATUS, onMicrophoneStatus);
            microphone = null;
            trace("DEBUG: Microphone disposed");
        }

        if (audioBuffer) {
            audioBuffer.clear();
            audioBuffer = null;
            trace("DEBUG: Audio buffer disposed");
        }

        isInitialized = false;
        trace("DEBUG: ProximityChat_MicInput disposed");
    }

    // DEBUG: Add method to check current state
    public function getDebugInfo():String {
        return "Initialized: " + isInitialized +
                ", Recording: " + isRecording +
                ", Active: " + isActive +
                ", Level: " + activityLevel +
                ", SampleData events: " + sampleDataCount +
                ", Activity events: " + activityCount;
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