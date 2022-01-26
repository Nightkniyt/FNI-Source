#if android
package;

//Thanks Daninnocent
import flixel.FlxG;
import flixel.FlxBasic;
import extension.webview.WebView;

using StringTools;

class WebViewPlayer extends FlxBasic
{
	public static var androidPath:String = 'file:///android_asset/assets/videos/';

        public var finishCallback:Void->Void = null;

	public function new(source:String)
	{
		super();

		WebView.onClose=onClose;
		WebView.onURLChanging=onURLChanging;

		WebView.open(androidPath + source + '.html', false, null, ['http://exitme(.*)']);
	}

	function onClose() {
		if (finishCallback != null)
		{
			finishCallback();
		}
	 }

	function onURLChanging(url:String) {
		if (url == 'http://exitme/') 
                        onClose();
	}
}
#end
