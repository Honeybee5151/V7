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

    public function ProximityChat_UI_SoundVisualiser(micInput:ProximityChat_MicInput, w:Number = 180, h:Number = 60) {
        this.micInput = micInput;
        this.width2 = w;
        this.height2 = h;

        initializeVisualizer();
        setupMicrophoneConnection();
        startVisualization();
    }

    /**
     * Initialize the visualizer
     */
    private function initializeVisualizer():void {
        // Initialize data arrays
        for (var i:int = 0; i < 128; i++) {
            audioSamples.push(0);
            smoothedSamples.push(0);
        }

        // Draw initial background
        drawBackground();

        trace("ProximityChat_UI_SoundVisualiser: Initialized " + width2 + "x" + height2);
    }

    /**
     * Connect to microphone input events
     */
    private function setupMicrophoneConnection():void {
        if (micInput) {
            micInput.addEventListener(ProximityChat_MicInput.AUDIO_DATA_AVAILABLE, onAudioDataReceived);
            micInput.addEventListener(ProximityChat_MicInput.ACTIVITY_CHANGED, onActivityChanged);
            trace("ProximityChat_UI_SoundVisualiser: Connected to microphone input");
        }
    }

    /**
     * Start the visualization timer
     */
    private function startVisualization():void {
        updateTimer = new Timer(1000 / frameRate);
        updateTimer.addEventListener(TimerEvent.TIMER, updateVisualization);
        updateTimer.start();
    }

    /**
     * Handle incoming audio data
     */
    private function onAudioDataReceived(event:*):void {
        var audioData:ByteArray = event.audioData;
        processAudioData(audioData);
    }

    /**
     * Handle activity level changes
     */
    private function onActivityChanged(event:*):void {
        currentLevel = event.activityLevel / 100; // Normalize to 0-1
    }

    /**
     * Process raw audio data into waveform data
     */
    private function processAudioData(data:ByteArray):void {
        if (!data || data.length == 0) return;

        data.position = 0;
        var sampleCount:int = Math.min(128, data.length / 4); // 4 bytes per float

        // Read audio samples
        for (var i:int = 0; i < sampleCount; i++) {
            if (data.bytesAvailable >= 4) {
                var sample:Number = data.readFloat();
                audioSamples[i] = sample * sensitivity;
            }
        }

        // Apply smoothing
        applySmoothing();
    }

    /**
     * Apply smoothing to waveform data
     */
    private function applySmoothing():void {
        for (var i:int = 0; i < smoothedSamples.length; i++) {
            if (i < audioSamples.length) {
                smoothedSamples[i] = (smoothedSamples[i] * smoothing) + (audioSamples[i] * (1 - smoothing));
            }
        }
    }

    /**
     * Update visualization display
     */
    private function updateVisualization(event:TimerEvent):void {
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

        for (var i:int = 0; i < smoothedSamples.length; i++) {
            var x:Number = i * stepX;
            var y:Number = centerY + (smoothedSamples[i] * centerY * 0.8);
            graphics.lineTo(x, y);
        }
    }

    /**
     * Set sensitivity (amplification factor)
     */
    public function setSensitivity(value:Number):void {
        sensitivity = Math.max(0.1, Math.min(5.0, value));
    }

    /**
     * Set smoothing factor (0 = no smoothing, 1 = maximum smoothing)
     */
    public function setSmoothing(value:Number):void {
        smoothing = Math.max(0, Math.min(0.95, value));
    }

    /**
     * Set colors
     */
    public function setColors(background:uint, wave:uint):void {
        backgroundColor = background;
        waveColor = wave;
    }

    /**
     * Set frame rate
     */
    public function setFrameRate(fps:Number):void {
        frameRate = Math.max(10, Math.min(60, fps));
        if (updateTimer) {
            updateTimer.delay = 1000 / frameRate;
        }
    }

    /**
     * Get current activity level
     */
    public function getCurrentLevel():Number {
        return currentLevel;
    }

    /**
     * Dispose and clean up
     */
    public function dispose():void {
        if (updateTimer) {
            updateTimer.stop();
            updateTimer.removeEventListener(TimerEvent.TIMER, updateVisualization);
            updateTimer = null;
        }

        if (micInput) {
            micInput.removeEventListener(ProximityChat_MicInput.AUDIO_DATA_AVAILABLE, onAudioDataReceived);
            micInput.removeEventListener(ProximityChat_MicInput.ACTIVITY_CHANGED, onActivityChanged);
        }

        audioSamples = null;
        smoothedSamples = null;

        trace("ProximityChat_UI_SoundVisualiser: Disposed");
    }
}
}
