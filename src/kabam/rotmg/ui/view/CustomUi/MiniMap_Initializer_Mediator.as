package kabam.rotmg.ui.view.CustomUi {
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.view.CustomUi.MiniMap_Initializer;
import kabam.rotmg.ui.view.CustomUi.MiniMap_Initializer_Signal;

import robotlegs.bender.bundles.mvcs.Mediator;

public class MiniMap_Initializer_Mediator extends Mediator {

    [Inject]
    public var view:MiniMap_Initializer;

    [Inject]
    public var hudModel:HUDModel;

    [Inject]
    public var initSignal:MiniMap_Initializer_Signal;

    override public function initialize():void {
        this.initSignal.addOnce(onInit); // 👈 only run once
    }

    private function onInit():void {
        if (hudModel && hudModel.gameSprite && hudModel.gameSprite.map) {
            view.initialize(hudModel.gameSprite.map);
        } else {
            trace("[MiniMapInitializerMediator] ERROR: gameSprite or map is null");
        }
    }
}
}