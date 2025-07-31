package kabam.rotmg.ProximityChat {
import flash.display.Sprite;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.ByteArray;

public class ProximityChat_UI_SoundVisualiser extends Sprite {

    // Microphone input reference
    private var micInput:ProximityChat_MicInput;

    // Visualization settings
    private var width2:Number = 180;
    private var height2:Number = 60;
    private var sensitivity:Number = 1.0;
    private var smoothing:Number = 0.8;

    // Colors
    private var backgroundColor:uint = 0x000000;
    private var waveColor:uint = 0x00FF00;

    // Data storage
    private var audioSamples:Array = [];
    private var smoothedSamples:Array = [];

    // Animation
    private var updateTimer:Timer;
    private var frameRate:Number = 30; // FPS

    // Activity monitoring
    private var currentLevel:Number = 0;

    // DEBUG: Add counters
    private var audioDataCount:int = 0;
    private var activityDataCount:int = 0;
    private var visualizationUpdateCount:int = 0;

    public function ProximityChat_UI_SoundVisualiser(micInput:ProximityChat_MicInput, w:Number = 180, h:Number = 60) {
        trace("DEBUG VIS: Constructor called with dimensions " + w + "x" + h);

        this.micInput = micInput;
        this.width2 = w;
        this.height2 = h;

        initializeVisualizer();
        setupMicrophoneConnection();
        startVisualization();

        trace("DEBUG VIS: Constructor completed");
    }

    /**
     * Initialize the visualizer
     */
    private function initializeVisualizer():void {
        trace("DEBUG VIS: initializeVisualizer() called");

        // Initialize data arrays
        for (var i:int = 0; i < 128; i++) {
            audioSamples.push(0);
            smoothedSamples.push(0);
        }
        trace("DEBUG VIS: Audio arrays initialized with 128 samples");

        // Draw initial background
        drawBackground();
        trace("DEBUG VIS: Initial background drawn");

        trace("DEBUG VIS: Visualizer initialized " + width2 + "x" + height2);
    }

    /**
     * Connect to microphone input events
     */
    private function setupMicrophoneConnection():void {
        trace("DEBUG VIS: setupMicrophoneConnection() called");

        if (micInput) {
            micInput.addEventListener(ProximityChat_MicInput.AUDIO_DATA_AVAILABLE, onAudioDataReceived);
            micInput.addEventListener(ProximityChat_MicInput.ACTIVITY_CHANGED, onActivityChanged);
            trace("DEBUG VIS: Event listeners added to micInput");
        } else {
            trace("DEBUG VIS: ERROR - micInput is null!");
        }
    }

    /**
     * Start the visualization timer
     */
    private function startVisualization():void {
        trace("DEBUG VIS: startVisualization() called");

        updateTimer = new Timer(1000 / frameRate);
        updateTimer.addEventListener(TimerEvent.TIMER, updateVisualization);
        updateTimer.start();

        trace("DEBUG VIS: Visualization timer started at " + frameRate + " FPS");
    }

    /**
     * Handle incoming audio data
     */
    private function onAudioDataReceived(event:*):void {
        audioDataCount++;
        trace("DEBUG VIS: onAudioDataReceived #" + audioDataCount + " called");

        var audioData:ByteArray = event.audioData;
        if (audioData) {
            trace("DEBUG VIS: Audio data received - " + audioData.length + " bytes");
            processAudioData(audioData);
        } else {
            trace("DEBUG VIS: ERROR - No audio data in event!");
        }
    }

    /**
     * Handle activity level changes
     */
    private function onActivityChanged(event:*):void {
        activityDataCount++;
        currentLevel = event.activityLevel / 100; // Normalize to 0-1

        trace("DEBUG VIS: onActivityChanged #" + activityDataCount + " - Level: " + event.activityLevel + " (normalized: " + currentLevel + ")");
    }

    /**
     * Process raw audio data into waveform data
     */
    private function processAudioData(data:ByteArray):void {
        trace("DEBUG VIS: processAudioData() called with " + data.length + " bytes");

        if (!data || data.length == 0) {
            trace("DEBUG VIS: No data to process");
            return;
        }

        data.position = 0;
        var sampleCount:int = Math.min(128, data.length / 4); // <-- Declare sampleCount here

        trace("DEBUG VIS: Processing " + sampleCount + " samples");

        for (var i:int = 0; i < sampleCount; i++) {
            if (data.bytesAvailable >= 4) {
                var sample:Number = data.readFloat();
                if (isNaN(sample) || Math.abs(sample) > 1.0) {
                    trace("Invalid sample at index", i, ":", sample);
                }
                audioSamples[i] = sample * sensitivity;
            }
        }

        trace("DEBUG VIS: Read " + sampleCount + " audio samples");
        applySmoothing(); // <-- Don't forget this
    }


    /**
     * Apply smoothing to waveform data
     */
    private function applySmoothing():void {
        trace("DEBUG VIS: applySmoothing() called");

        for (var i:int = 0; i < smoothedSamples.length; i++) {
            if (i < audioSamples.length) {
                smoothedSamples[i] = (smoothedSamples[i] * smoothing) + (audioSamples[i] * (1 - smoothing));
            }
        }

        // Check if we have any significant data
        var maxValue:Number = 0;
        for (var j:int = 0; j < smoothedSamples.length; j++) {
            maxValue = Math.max(maxValue, Math.abs(smoothedSamples[j]));
        }
        trace("DEBUG VIS: Smoothing applied - max value: " + maxValue);
    }

    /**
     * Update visualization display
     */
    private function updateVisualization(event:TimerEvent):void {
        visualizationUpdateCount++;

        // Only trace every 30 updates (once per second at 30fps)
        if (visualizationUpdateCount % 30 == 0) {
            trace("DEBUG VIS: updateVisualization #" + visualizationUpdateCount + " - audioData events: " + audioDataCount + ", activity events: " + activityDataCount);
        }

        drawBackground();
        drawWaveform();
    }

    /**
     * Draw background
     */
    private function drawBackground():void {
        graphics.clear();
        graphics.beginFill(backgroundColor);
        graphics.drawRect(0, 0, width2, height2);
        graphics.endFill();
    }

    /**
     * Draw waveform visualization
     */
    private function drawWaveform():void {
        graphics.lineStyle(2, waveColor);

        var centerY:Number = height2 / 2;
        var stepX:Number = width2 / smoothedSamples.length;

        graphics.moveTo(0, centerY);

        // Check if we have any data to draw
        var hasData:Boolean = false;
        for (var i:int = 0; i < smoothedSamples.length; i++) {
            if (Math.abs(smoothedSamples[i]) > 0.001) {
                hasData = true;
                break;
            }
        }

        if (visualizationUpdateCount % 30 == 0) {
            trace("DEBUG VIS: Drawing waveform - hasData: " + hasData);
        }

        for (var j:int = 0; j < smoothedSamples.length; j++) {
            var x:Number = j * stepX;
            var y:Number = centerY + (smoothedSamples[j] * centerY * 0.8);
            graphics.lineTo(x, y);
        }

        // Draw a test line to make sure graphics are working
        if (!hasData && visualizationUpdateCount < 5) {
            // Draw test pattern for first few frames
            graphics.lineStyle(1, 0xFF0000); // Red test line
            graphics.moveTo(0, centerY);
            graphics.lineTo(width2, centerY);
            trace("DEBUG VIS: Drew test line (no audio data yet)");
        }
    }

    /**
     * Set sensitivity (amplification factor)
     */
    public function setSensitivity(value:Number):void {
        sensitivity = Math.max(0.1, Math.min(5.0, value));
        trace("DEBUG VIS: Sensitivity set to " + sensitivity);
    }

    /**
     * Set smoothing factor (0 = no smoothing, 1 = maximum smoothing)
     */
    public function setSmoothing(value:Number):void {
        smoothing = Math.max(0, Math.min(0.95, value));
        trace("DEBUG VIS: Smoothing set to " + smoothing);
    }

    /**
     * Set colors
     */
    public function setColors(background:uint, wave:uint):void {
        backgroundColor = background;
        waveColor = wave;
        trace("DEBUG VIS: Colors set - background: 0x" + background.toString(16) + ", wave: 0x" + wave.toString(16));
    }

    /**
     * Set frame rate
     */
    public function setFrameRate(fps:Number):void {
        frameRate = Math.max(10, Math.min(60, fps));
        if (updateTimer) {
            updateTimer.delay = 1000 / frameRate;
        }
        trace("DEBUG VIS: Frame rate set to " + frameRate);
    }

    /**
     * Get current activity level
     */
    public function getCurrentLevel():Number {
        trace("DEBUG VIS: getCurrentLevel() returning " + currentLevel);
        return currentLevel;
    }

    /**
     * Dispose and clean up
     */
    public function dispose():void {
        trace("DEBUG VIS: dispose() called");

        if (updateTimer) {
            updateTimer.stop();
            updateTimer.removeEventListener(TimerEvent.TIMER, updateVisualization);
            updateTimer = null;
            trace("DEBUG VIS: Update timer disposed");
        }

        if (micInput) {
            micInput.removeEventListener(ProximityChat_MicInput.AUDIO_DATA_AVAILABLE, onAudioDataReceived);
            micInput.removeEventListener(ProximityChat_MicInput.ACTIVITY_CHANGED, onActivityChanged);
            trace("DEBUG VIS: MicInput event listeners removed");
        }

        audioSamples = null;
        smoothedSamples = null;

        trace("DEBUG VIS: Visualizer disposed");
    }

    // DEBUG: Add method to get current state
    public function getDebugInfo():String {
        return "AudioData events: " + audioDataCount +
                ", Activity events: " + activityDataCount +
                ", Visualization updates: " + visualizationUpdateCount +
                ", Current level: " + currentLevel;
    }
}
}