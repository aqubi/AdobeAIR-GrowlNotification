
import growl.DisplayManager;

private var displayManager:DisplayManager = new DisplayManager();

[Embed(source='../icons/usa96.png')] 
protected var image:Class 


public function onWindowCompleted():void {
	//trace("idleThreshold:" + NativeApplication.nativeApplication.idleThreshold);
	//NativeApplication.nativeApplication.idleThreshold = 10;
}

public function showGrowl():void {
	displayManager.displayMessage(areaMessage.text, int(priority.selection.data), image);
}
