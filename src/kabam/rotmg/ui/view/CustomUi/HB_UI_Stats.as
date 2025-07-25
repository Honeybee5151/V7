package kabam.rotmg.ui.view.CustomUi {

    import com.company.assembleegameclient.objects.Player;
    import flash.display.Shape;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.Event;
    import flash.display.Sprite;
    import com.company.assembleegameclient.objects.Player;
    import flash.text.TextFieldAutoSize;
import flash.utils.Timer;
import flash.events.TimerEvent;




    public class HB_UI_Stats extends Sprite {
        private var ShowStatsTextField:TextField = new TextField();
        private var currentLVLTextField:TextField = new TextField();
        public var xpBar:Shape = new Shape();
        public var xpBarBase:Shape = new Shape();
        private var statsTimer:Timer;
        private var currentPlayer:Player;


        public function HB_UI_Stats() {
            this.visible = false;
            addChild(currentLVLTextField);
            addChild(ShowStatsTextField);
            addChild(xpBarBase);
            addChild(xpBar);


        }

        public function ShowStats(player:Player):void {
            var format:TextFormat = new TextFormat();
            var lifePotsToMax:uint = ((player.maxHPMax_ - player.maxHP_) / 5)
            var manaPotsToMax:uint = ((player.maxMPMax_ - player.maxMP_) / 5)
            format.bold = true;
            format.size = 14; // optional
            format.font = "Arial"; // optional
            ShowStatsTextField.defaultTextFormat = format;
            ShowStatsTextField.x = 350
            ShowStatsTextField.y = 400
            ShowStatsTextField.height = 100
            ShowStatsTextField.width = 0
            ShowStatsTextField.multiline = true;   // permits multiple rows
            ShowStatsTextField.wordWrap = false;
            ShowStatsTextField.selectable = false;  // ❶ stops text highlighting / caret
            ShowStatsTextField.mouseEnabled = false;// no wrapping → width expands; set true if you want wrapping
            ShowStatsTextField.autoSize = TextFieldAutoSize.LEFT;

            ShowStatsTextField.htmlText =
                    "<font color='#be39cf'>Attack: </font>" + player.attack_ + " " + (player.attack_ - player.attackBoost_) + "/" + player.attackMax_ + "<br>" +
                    "<font color='#d7741c'>Dexterity: </font>" + player.dexterity_ + " " + (player.dexterity_ - player.dexterityBoost_) + "/" + player.dexterityMax_ + "<br>" +
                    "<font color='#2bce6a'>Speed: </font>" + player.speed_ + " " + (player.speed_ - player.speedBoost_) + "/" + player.speedMax_ + "<br>" +
                    "<font color='#454545'>Defense: </font>" + player.defense_ + " " + (player.defense_ - player.defenseBoost_) + "/" + player.defenseMax_ + "<br>" +
                    "<font color='#357dea'>Wisdom: </font>" + player.wisdom_ + " " + (player.wisdom_ - player.wisdomBoost_) + "/" + player.wisdomMax_ + "<br>" +
                    "<font color='#af0108'>Vitality: </font>" + player.vitality_ + " " + (player.vitality_ - player.vitalityBoost_) + "/" + player.vitalityMax_ + "<br>" +
                    "<font color='#2fccd2'>HP left: </font>" + lifePotsToMax + "<br>" +
                    "<font color='#d9ba46'>MP left: </font>" + manaPotsToMax;


        }

        public function ShowXP(player:Player):void {

            var xpPercent:Number = player.exp_ / player.nextLevelExp_;
            xpPercent = Math.max(0, Math.min(1, xpPercent)); // clamp between 0 and 1

            var maxBarWidth:Number = 94.85;
            var fillWidth:Number = maxBarWidth * xpPercent;
            xpBarBase.graphics.clear();
            xpBarBase.graphics.beginFill(0x00cc00); // Example color
            xpBarBase.graphics.drawRect(0, 0, 94.85, 8); // Height is 16 in your case
            xpBarBase.graphics.endFill();
            xpBarBase.x = 350
            xpBarBase.y = 392

            xpBar.graphics.clear();
            xpBar.graphics.beginFill(0x008000); // Example color
            xpBar.graphics.drawRect(0, 0, fillWidth, 8); // Height is 16 in your case
            xpBar.graphics.endFill();
            xpBar.x = 350
            xpBar.y = 392
            if (player.level_ == 20) {
                xpBar.graphics.clear();
                xpBar.graphics.beginFill(0xffa500);
                xpBar.graphics.drawRect(0, 0, 94.85, 8);
                xpBar.graphics.endFill();
            }


        }

        public function currentLVL(player:Player):void {
            var format:TextFormat = new TextFormat();
            format.bold = true;
            format.size = 14; // optional
            format.font = "Arial"; // optional


            currentLVLTextField.defaultTextFormat = format;
            currentLVLTextField.x = 378
            currentLVLTextField.y = 370

            currentLVLTextField.multiline = true;   // permits multiple rows
            currentLVLTextField.selectable = false;  // ❶ stops text highlighting / caret
            currentLVLTextField.mouseEnabled = false;
            currentLVLTextField.wordWrap = false;     // no wrapping → width expands; set true if you want wrapping
            currentLVLTextField.autoSize = TextFieldAutoSize.LEFT;
            currentLVLTextField.htmlText = "LVL " + player.level_;
            currentLVLTextField.setTextFormat(format);

// Center text horizontally over the bar

            if (player.level_ == 20) {
                currentLVLTextField.htmlText = "FAME " + player.fame_;
                currentLVLTextField.setTextFormat(format);

// Center text horizontally over the bar

            }
        }

            private function onStatsTimer(e:TimerEvent):void {
                if (currentPlayer) {
                    refreshShowStats(currentPlayer);
                }
            }

            public function refreshShowStats(player:Player):void {
                ShowXP(player);
                ShowStats(player);
                currentLVL(player);
            }

            public function startStatsTimer(player:Player):void {
                currentPlayer = player;
                if (!statsTimer) {
                    statsTimer = new Timer(100); // 100 ms interval
                    statsTimer.addEventListener(TimerEvent.TIMER, onStatsTimer);
                    statsTimer.start();
                }
            }

            public function stopStatsTimer():void {
                if (statsTimer) {
                    statsTimer.stop();
                    statsTimer.removeEventListener(TimerEvent.TIMER, onStatsTimer);
                    statsTimer = null;
                }
                currentPlayer = null;
            }


        }



}

