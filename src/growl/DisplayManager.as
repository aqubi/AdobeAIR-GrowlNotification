package growl {
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import mx.events.AIREvent;
	import mx.core.Window;
	
	/** Growlerの画面を制御するManager */
	public class DisplayManager extends EventDispatcher {
		public static const LIFE_TICK:String = "lifeTick";
		
		private var lifeTicks:uint = 0;
		private var lifeTimer:Timer = new Timer(1000);
		private const gutter:int = 8;
		
		public function DisplayManager():void {
			installEventListeners();
		}
		
		/** イベントリスナーを登録する */
		private function installEventListeners():void {
			NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE, onIdle);
			NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT, onPresence);
			lifeTimer.addEventListener(TimerEvent.TIMER, addTick);
			lifeTimer.start();
		}
		
		/** メッセージを表示する */
		public function displayMessage(message:String, priority:int, image:Class):void {
			var growler:Growler = new Growler();
			growler.init(message, priority, image, this);
			
			growler.addEventListener(AIREvent.WINDOW_COMPLETE, function (event:Event):void {
				var position:Point = findSpotForMessage(growler.nativeWindow.width, growler.nativeWindow.height);
				growler.nativeWindow.x = position.x;
				growler.nativeWindow.y = position.y;
				growler.visible = true;
			}); 
			
			growler.open();
		}
		
		
		/** コンピュータがアイドル状態の場合は、メッセージを削除しない */
		private function onIdle(event:Event):void{
			pauseExpiration();
			trace("Idling.");
		}
		
		/** 戻ったら、ウィンドウの期限切れタイマーを再開する */
		private function onPresence(event:Event):void{
			resumeExpiration();
			trace("Resuming.");
		}
		
		/** 生存チェックを停止する */
		public function pauseExpiration():void {
			lifeTimer.stop();
		}
		
		/** 生存チェックを再開する */
		public function resumeExpiration():void {
			lifeTimer.start();
		}
		
		/** 1秒経ったタイミングで登録リスナーにイベントを発火 */
		private function addTick(event:Event):void {
			lifeTicks++;
			var tickEvent:Event = new Event(LIFE_TICK, false, false);
			dispatchEvent(tickEvent);
		}
		
		/** 表示する位置を探す */
		private function findSpotForMessage(width:int, height:int):Point {
			var spot:Point = new Point();
			
			var startX:int = Screen.mainScreen.bounds.width - width - gutter;
			var startY:int = Screen.mainScreen.bounds.height - height - gutter;
			
			for (var x:int = startX; x > 0; x -= (width + gutter)) {
				for(var y:int = startY; y > 0; y -= (height + gutter)){
					//trace("x=" + x + ", y=" + y);
					var testRect:Rectangle = new Rectangle(x, y, width + gutter, height + gutter);
					var interWindow:NativeWindow = getIntersectsWindow(testRect);
					if (interWindow != null) {
						y = interWindow.bounds.y;
					} else {
						spot.x = x;
						spot.y = y;
						return spot;
					}
				}
			}
			return spot;
		}
		
		/** 表示エリアにカブっているかチェック */
		private function isOccupied(testRect:Rectangle):Boolean {
			var occupied:Boolean = false;
			for each (var window:NativeWindow in NativeApplication.nativeApplication.openedWindows){
				occupied = occupied || window.bounds.intersects(testRect);
			}
			return occupied;
		}
		
		/** 表示エリアにカブっているかチェック */
		private function getIntersectsWindow(testRect:Rectangle):NativeWindow {
			for each (var window:NativeWindow in NativeApplication.nativeApplication.openedWindows){
				if (window.bounds.intersects(testRect)) {
					return window;
				}
			}
			return null;
		}
	}
}