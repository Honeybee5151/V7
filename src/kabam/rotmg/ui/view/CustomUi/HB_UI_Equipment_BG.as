package kabam.rotmg.ui.view.CustomUi {
import flash.display.Shape;
import flash.display.Sprite;


public class HB_UI_Equipment_BG extends Sprite{

    private var perfectSquare:Shape = new Shape;
    public function HB_UI_Equipment_BG() {

    }
    public function drawPerfectSquares():void {
        perfectSquares();
        addChild(perfectSquare);
    }
    private function perfectSquares():void {
        for (var i:int = 0; i < 4; i++) {
            var perfectSquare:Shape = new Shape();
            perfectSquare.graphics.clear(); // just in case it was drawn before
            perfectSquare.graphics.beginFill(0x454545); // dark gray fill
            perfectSquare.graphics.drawRect(0, 0, 30, 30); // draw at (0, 0)
            perfectSquare.graphics.endFill();

            perfectSquare.x = 340 - 260 + (i * 30); // space them out horizontally
            perfectSquare.y = 570 - 555;

            addChild(perfectSquare);
        }
    }





}
}
