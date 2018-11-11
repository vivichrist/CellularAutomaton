package gui;

import haxe.io.StringInput;
import zui.Zui;
import zui.Id;
import zui.Ext;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.Scheduler;

class Gui {
	// zui vars
	private var ui:Zui;
	private var hdl:Dynamic;
	// app state
	private var speed:Dynamic;
	public var starts:Array<kha.math.Vector2>;
	// parsing vars
	private var config:StringInput;
	private var loaded = false;

	public function new() {
		var theme = {
			FONT_SIZE: 13,
			ELEMENT_W: 100,
			ELEMENT_H: 22,
			ELEMENT_OFFSET: 2,
			ARROW_SIZE: 5,
			BUTTON_H: 17,
			CHECK_SIZE: 15,
			CHECK_SELECT_SIZE: 8,
			SCROLL_W: 8,
			TEXT_OFFSET: 8,
			TAB_W: 12,
			LINE_STRENGTH: 1,
			FLASH_SPEED: 0.5,
			TOOLTIP_DELAY: 1.0,
			FILL_WINDOW_BG: false,
			FILL_BUTTON_BG: true,
			FILL_ACCENT_BG: false,

			WINDOW_BG_COL: 0xff202020,
			WINDOW_TINT_COL: 0xaaffffff,
			ACCENT_COL: 0xff404040,
			ACCENT_HOVER_COL: 0xff505050,
			ACCENT_SELECT_COL: 0xff666666,
			PANEL_BG_COL: 0xff000000,
			PANEL_TEXT_COL: 0xffffffff,
			BUTTON_COL: 0xff2b2b2b,
			BUTTON_TEXT_COL: 0xffffffff,
			BUTTON_HOVER_COL: 0xff3b3b3b,
			BUTTON_PRESSED_COL: 0xff1b1b1b,
			TEXT_COL: 0xffffffff,
			LABEL_COL: 0xffaaaaaa,
			ARROW_COL: 0xffcac9c7,
			SEPARATOR_COL: 0xff262626,
		};

		Assets.loadEverything(function() {
			ui = new Zui({font: Assets.fonts.DejaVuSans, theme: theme});
			loaded = true;
		});
		hdl = Id.handle({text: "/home"}); // Set initial path
		speed = Id.handle({value: Main.speed});
	}

	function readLine():Array<String> {
		var line = config.readLine();
		line = StringTools.trim(line);
		var str = line.split(" ");
		return str;
	}

	public function render(g:Graphics):Void {
		if (!loaded) return;
		ui.begin(g);
		if (ui.window(Id.handle(), 10, 10, 400, 800, true)) {
			var htab = Id.handle();
			if (ui.tab(htab, "Open File")) {
				if (ui.panel(Id.handle({selected: true}), "File Browser")) {
					
					ui.row([1/2, 1/2]);
					ui.button("Cancel");
					if (ui.button("Load")) {
						trace(hdl.text);
					}
					
					hdl.text = ui.textInput(hdl, "Path");
					Ext.fileBrowser(ui, hdl);
				}
			}
			if (ui.tab(htab, "Options")) {
				if (ui.panel(Id.handle({selected: true}), "Display Options")) {
					ui.row([1/2, 1/2]);
					var b = ui.button("Update");
					if (speed.value + 1 == Main.speed || speed.value - 1 == Main.speed)
						speed.value = Main.speed;
					var f = ui.slider(speed, "FPS", 1, 60, false, 1);
					if (b) {
						Scheduler.removeTimeTask(Main.taskt);
						Main.speed = Std.int(f);
						Main.taskt = Scheduler.addTimeTask( Main.update, 0, 1 / Main.speed);
					}
					if (ui.isHovered) ui.tooltip("Framerates/Animation Speed");
				}
			}
		}
		ui.end();
	}
}