package com.company.assembleegameclient.parameters {

import flash.display.DisplayObject;


public class ScreenParameters {
    private static var defaultWidth:uint = 800;
    private static var defaultHeight:uint = 600;



    public static function positionRelations(asset:DisplayObject):Object {
        return {xPercent: asset.x /  800 , yPercent: asset.y / 600 }

    }

    public static function resizeAsset(asset:DisplayObject):void{
        asset.scaleX = (asset.stage.stageWidth / defaultWidth)
        asset.scaleY = (asset.stage.stageHeight / defaultHeight)

        var scale:Number = Math.min(asset.scaleX, asset.scaleY);
        asset.scaleY = scale
        asset.scaleX = scale

    }



    public static function newPosition(pos:Object, asset:DisplayObject):void {
        const w:Number = asset.stage.stageWidth;
        const h:Number = asset.stage.stageHeight;

        // same scale you used in resizeAsset()
        const scale:Number = Math.min(w / 800, h / 600);

        const scaledDesignW:Number = 800 * scale;
        const marginX:Number       = (w - scaledDesignW) * 0.5;   // 0 when window ≤ 4:3

        asset.x = marginX + scaledDesignW * pos.xPercent;
        asset.y = h * pos.yPercent;   // y was already correct
    }
    public static function execute(asset:DisplayObject, pos:Object): void {

        if (!asset || !pos) {


        }
        else {

            resizeAsset(asset);
            newPosition(pos, asset);

        }




    }



}

}
