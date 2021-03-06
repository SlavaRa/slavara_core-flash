package slavara.as3.game.starling.managers {
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	import slavara.as3.core.debug.Assert;
	import slavara.as3.core.enums.BaseEnum;
	import slavara.as3.core.utils.Validate;
	import slavara.as3.game.starling.gui.GUIItem;
	import slavara.as3.game.starling.gui.windows.BaseWindow;
	import slavara.as3.game.starling.utils.StarlingDisplayUtils;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	
	/**
	 * @author SlavaRa
	 * XXX: возможно необходимо сделать универсальный менеджер, данная реализация была сделана на скорую руку,
	 * и не расчитана на отображение нескольких окон одновременно, а также формирование какой-либо очереди.
	 * Окно которое должно открыть, закроет открытые.
	 * Алерт имеет высший приоритет, обычно закрывает сам себя.
	 */
	public class WindowsManager {
		
		public static const manager:WindowsManager = new WindowsManager();
		
		public static function setup(enum2window:Dictionary, container:DisplayObjectContainer):WindowsManager {
			return manager.setup(enum2window, container);
		}
		
		public static function getBy(id:BaseEnum):BaseWindow { return manager.getBy(id); }
		
		public static function alertIsOpened():Boolean { return manager.alertIsOpened(); }
		
		public static function alert(id:BaseEnum):BaseWindow { return manager.alert(id); }
		
		public static function closeAlert():void { manager._alert.close(); }
		
		public static function show(id:BaseEnum):BaseWindow { return manager.show(id) }
		
		public static function close(window:BaseWindow):void { manager.close(window); }
		
		public static function closeAll():void { manager.closeAll(); }
		
		public function WindowsManager() {
			super();
			
			CONFIG::debug
			{
				if (Validate.isNotNull(manager)) {
					throw new Error("Singleton, use WindowsManager.manager");
				}
			}
			
			initialize();
		}
		
		//TODO: change 2 add
		public function setup(enum2window:Dictionary, container:DisplayObjectContainer):WindowsManager {
			CONFIG::debug
			{
				Assert.isNull(enum2window, "enum2window");
				Assert.isNull(container, "container");
			}
			
			if (Validate.isNull(_enum2window)) {
				_enum2window = enum2window;
				_container = container;
				configureContainers();
				buildWindows();
			}
			return this;
		}
		
		public function alertIsOpened():Boolean {
			return Validate.isNotNull(_alert);
		}
		
		public function alert(uri:BaseEnum):BaseWindow {
			CONFIG::debug
			{
				Assert.isNull(uri, "uri");
			}
			
			if (canNotOpenWindowOrAlert(uri)) {
				return null;
			}
			
			const alert:BaseWindow = BaseWindow(_enum2window[uri]);
			alert.onClosed.addOnce(onAlertClosed);
			StarlingDisplayUtils.addChildTo(alert.view, _containerAlert);
			_alert = alert.open();
			return _alert;
		}
		
		public function has(uri:BaseEnum):Boolean {
			return Boolean(_enum2window[uri]);
		}
		
		public function getBy(enum:BaseEnum):BaseWindow {
			return _enum2window[enum] as BaseWindow;
		}
		
		public function show(uri:BaseEnum):BaseWindow {
			CONFIG::debug
			{
				Assert.isNull(uri, "uri");
			}
			
			if (canNotOpenWindowOrAlert(uri)) {
				return null;
			}
			
			const window:BaseWindow = BaseWindow(_enum2window[uri]);
			_queue.push(window);
			close(_openedWindow);
			return window;
		}
		
		public function close(window:BaseWindow):void {
			if(Validate.isNotNull(window)) {
				window.close();
			} else {
				onCurWindowClosed();
			}
		}
		
		public function closeAll():void {
			if (Validate.isNotNull(_alert)) {
				_alert.close();
			}
			_queue.length = 0;
			close(openedWindow);
		}
		
		private var _enum2window:Dictionary;
		private var _container:DisplayObjectContainer;
		private var _containerDialogWindows:DisplayObjectContainer;
		private var _containerAlert:DisplayObjectContainer;
		private var _queue:Vector.<BaseWindow>;
		private var _openedWindow:BaseWindow;
		private var _alert:BaseWindow;
		private var _onWindowOpen:Signal;
		private var _onWindowClosed:Signal;
		
		private function initialize():void {
			_containerDialogWindows = new Sprite();
			_containerAlert = new Sprite();
			_queue = new <BaseWindow>[];
			_onWindowOpen = new Signal();
			_onWindowClosed = new Signal();
		}
		
		private function configureContainers():void {
			_container.addChild(_containerDialogWindows);
			_container.addChild(_containerAlert);
		}
		
		private function buildWindows():void {
			for (var uri:* in _enum2window) {
				GUIItem(_enum2window[uri]).build();
			}
		}
		
		private function onCurWindowClosed(window:BaseWindow = null):void {
			if (window) {
				Starling.current.juggler.remove(_openedWindow);
				StarlingDisplayUtils.removeChildFrom(window.view, _containerDialogWindows);
			}
			
			_openedWindow = null;
			_onWindowClosed.dispatch();
			
			if (Validate.collectionIsNullOrEmpty(_queue)) {
				return;
			}
			
			window = _queue.shift();
			window.onClosed.addOnce(onCurWindowClosed);
			StarlingDisplayUtils.addChildTo(window.view, _containerDialogWindows);
			_openedWindow = window.open();
			_onWindowOpen.dispatch();
			Starling.current.juggler.add(_openedWindow);
		}
		
		private function onAlertClosed(window:BaseWindow):void {
			StarlingDisplayUtils.removeChildFrom(window.view, _containerAlert);
			_alert = null;
		}
		
		private function canNotOpenWindowOrAlert(uri:BaseEnum):Boolean {
			return alertIsOpened() && !has(uri);
		}
		
		public function get containerDialogWindows():DisplayObjectContainer {
			return _containerDialogWindows;
		}
		
		public function get containerAlert():DisplayObjectContainer {
			return _containerAlert;
		}
		
		public function get openedWindow():BaseWindow {
			return _openedWindow;
		}
		
		public function get onWindowOpen():Signal {
			return _onWindowOpen;
		}
		
		public function get onWindowClosed():Signal {
			return _onWindowClosed;
		}
		
	}
}