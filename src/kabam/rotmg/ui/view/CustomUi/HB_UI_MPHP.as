package kabam.rotmg.ui.view.CustomUi {
import flash.display.Shape;
import flash.display.Sprite;
import com.company.assembleegameclient.objects.Player;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.Event;


public class HB_UI_MPHP extends Sprite {
    private var HPBAR:Shape= new Shape();
    private var HPBARBG:Shape= new Shape();
    private var MPBAR:Shape= new Shape();
    private var MPBARBG:Shape= new Shape();
    private var trackedPlayer:Player;
    private var hpText:TextField = new TextField();
    private var mpText:TextField = new TextField();
    private var textFormat:TextFormat = new TextFormat();

    public function HB_UI_MPHP() {
        createHPBAR();
        addChild(HPBARBG);
        addChild(HPBAR);
        createMPBAR();
        addChild(MPBARBG);
        addChild(MPBAR);
        textFormat.size = 12;
        textFormat.color = 0xFFFFFF;
        textFormat.bold = true;
        textFormat.align = "center";

        hpText.defaultTextFormat = textFormat;
        hpText.width = 80;
        hpText.height = 30;
        hpText.x = 260;
        hpText.y = 570;
        hpText.selectable = false;
        addChild(hpText);

        mpText.defaultTextFormat = textFormat;
        mpText.width = 80;
        mpText.height = 30;
        mpText.x = 460;
        mpText.y = 570;
        mpText.selectable = false;
        addChild(mpText);
    }

private function createHPBAR():void{
    HPBARBG.graphics.beginFill(0xB01030); // Red fill
    HPBARBG.graphics.drawRect(0, 0, 80, 30); // x, y, width, height
    HPBARBG.graphics.endFill();
    HPBARBG.x = 260
    HPBARBG.y = 570

    HPBAR.graphics.beginFill(0xdc143c); // Red fill
    HPBAR.graphics.drawRect(0, 0, 80, 30); // x, y, width, height
    HPBAR.graphics.endFill();
    HPBAR.x = 260
    HPBAR.y = 570




}

    private function createMPBAR():void {
        MPBARBG.graphics.beginFill(0x334FAB); // Red fill
        MPBARBG.graphics.drawRect(0, 0, 80, 30); // x, y, width, height
        MPBARBG.graphics.endFill();
        MPBARBG.x = 460
        MPBARBG.y = 570

        MPBAR.graphics.beginFill(0x4169e1); // Red fill
        MPBAR.graphics.drawRect(0, 0, 80, 30); // x, y, width, height
        MPBAR.graphics.endFill();
        MPBAR.x = 460
        MPBAR.y = 570



    }

private function maintainBARS(player:Player):void{

        var mpRatio:Number = player.mp_ / player.maxMP_;
        if (mpRatio < 0) mpRatio = 0;
        if (mpRatio > 1) mpRatio = 1;

        MPBAR.graphics.clear();
        MPBAR.graphics.beginFill(0x4169e1);
        MPBAR.graphics.drawRect(0, 0, 80 * mpRatio, 30); // Scale width
        MPBAR.graphics.endFill();

    mpText.text = player.mp_ + " / " + player.maxMP_;
    var hpRatio:Number = player.hp_ / player.maxHP_;
    if (hpRatio < 0) hpRatio = 0;
    if (hpRatio > 1) hpRatio = 1;

    HPBAR.graphics.clear();
    HPBAR.graphics.beginFill(0xdc143c);
    HPBAR.graphics.drawRect(0, 0, 80 * hpRatio, 30); // Scale width
    HPBAR.graphics.endFill();
    hpText.text = player.hp_ + " / " + player.maxHP_;


}
public function frameBARS(e:Event):void {
    if (trackedPlayer != null) {
        maintainBARS(trackedPlayer);
    }
}



    public function startUpdating(player:Player):void {
        this.trackedPlayer = player;
        addEventListener(Event.ENTER_FRAME, frameBARS);

    }

    public function stopUpdating():void {
        removeEventListener(Event.ENTER_FRAME, frameBARS);

    }



}


}
