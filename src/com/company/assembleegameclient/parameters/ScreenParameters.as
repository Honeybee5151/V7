package com.company.assembleegameclient.parameters {

import flash.display.DisplayObject;


public class ScreenParameters {


    public static function positionRelations(asset:DisplayObject):Object {
        return {xPercent: asset.x /  WebMain.sWidth, yPercent: asset.y / WebMain.sHeight}

    }

    public static function resizeAsset(asset:DisplayObject):void{
        asset.scaleX = (WebMain.sWidth / 800)
        asset.scaleY = (WebMain.sHeight / 600)
        var scale:Number = Math.min(asset.scaleX, asset.scaleY); // Keeps aspect ratio

        asset.scaleX = scale;
        asset.scaleY = scale;

    }


    public static function newPosition(pos:Object, asset:DisplayObject):void {
        asset.x = WebMain.sWidth * pos.xPercent;
        asset.y = WebMain.sHeight * pos.yPercent;
    }
    public static function execute(asset:DisplayObject, pos:Object): void{

        if (!asset || !pos) return;
        resizeAsset(asset);
        newPosition(pos, asset);
        trace("screenapramaters execute has executed")



    }
}

}
