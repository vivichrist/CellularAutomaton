package;

import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.graphics4.TextureFormat;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureAddressing;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Usage;
import kha.Color;
import kha.Image;
import kha.Shaders;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import gui.Gui;

class Main {
	private static var pipeline: PipelineState;
	private static var tpipeline: PipelineState;
	private static var vertices: VertexBuffer;
	private static var structure: VertexStructure;
	private static var indices: IndexBuffer;
	private static var texUnit: TextureUnit;
	private static var texUnit2: TextureUnit;
	private static var locationGS: ConstantLocation;
	private static var ping: Image;
	private static var pong: Image;
	private static var swap: Bool;
	private static var showMenu: Bool;
	private static var gridSize = 512;
	private static var width = 1024;
	private static var height = 1024;
	private static var tf = TextureFormat.L8;
	private static var zgui:Gui;
	public static var speed = 30;
	public static var taskt = 0;

	public static function initialiseState():Void {
		// initial read is ping, so pong is the render target
		swap = true;
		var texture = Image.create(gridSize, gridSize, tf);

		var mid = Std.int(gridSize / 2);
		var d1 = gridSize * mid + mid;
		var d2 = gridSize * (mid + 1) + mid;
		// two pixels set at the center, all else is zero
		// changing tf you should change the following too.
		var t = texture.lock();
			t.fill(0, gridSize * gridSize, 0);
			t.set(d1, 160);
			t.set(d2, 160);
		texture.unlock();
		// straight pass through writes texture -> ping
		var ipipeline = new PipelineState();
			ipipeline.inputLayout = [structure];
			ipipeline.vertexShader = Shaders.shader_vert;
			ipipeline.fragmentShader = Shaders.pass_frag;
			ipipeline.compile();
		var startex = tpipeline.getTextureUnit("tex");

		var p = ping.g4;
		p.begin();
			p.clear(Color.Black);
			p.setPipeline(ipipeline);
			p.setTexture(startex, texture);
			p.setTextureParameters(startex,
				TextureAddressing.Clamp, TextureAddressing.Clamp,
				TextureFilter.PointFilter, TextureFilter.PointFilter,
				MipMapFilter.NoMipFilter);
			p.setVertexBuffer(vertices);
			p.setIndexBuffer(indices);
			p.drawIndexedVertices();
		p.end();
		texture.unload();
	}
	// buffers for a full screen quad
	public static function createBuffers(structure:VertexStructure):Void {
		vertices = new VertexBuffer(4, structure, Usage.StaticUsage);
		var v = vertices.lock();
			v.set(0, -1); v.set(1, -1); v.set(2, 0.5);
			v.set(3,  1); v.set(4, -1); v.set(5, 0.5);
			v.set(6,  1); v.set(7,  1); v.set(8, 0.5);
			v.set(9, -1); v.set(10,  1); v.set(11, 0.5);
		vertices.unlock();
		
		indices = new IndexBuffer(6, Usage.StaticUsage);
		var i = indices.lock();
			i[0] = 0; i[1] = 1; i[2] = 2;
			i[3] = 0; i[4] = 2; i[5] = 3;
		indices.unlock();
	}

	public static function main(): Void {
		System.start({title: "Shader", width: width, height: height}, function (_) {
			showMenu = true;
			structure = new VertexStructure();
			structure.add("pos", VertexData.Float3);
			// main rendering pipeline
			pipeline = new PipelineState();
			pipeline.inputLayout = [structure];
			pipeline.vertexShader = Shaders.shader_vert;
			pipeline.fragmentShader = Shaders.shader_frag;
			pipeline.compile();
			// texture unit for main renderin
			texUnit = pipeline.getTextureUnit("tex");
			createBuffers(structure);
			// ping pong pipeline
			tpipeline = new PipelineState();
			tpipeline.inputLayout = [structure];
			tpipeline.vertexShader = Shaders.shader_vert;
			tpipeline.fragmentShader = Shaders.texture_frag;
			tpipeline.compile();

			locationGS = tpipeline.getConstantLocation("gridsize");
			// texture unit for pingpong.
			texUnit2 = tpipeline.getTextureUnit("tex");
			ping = Image.createRenderTarget(gridSize, gridSize, tf);
			pong = Image.createRenderTarget(gridSize, gridSize, tf);
			initialiseState();
			zgui = new Gui();

			System.notifyOnFrames(render);
			taskt = Scheduler.addTimeTask( update, 0, 1 / speed);
			Keyboard.get().notify(onKey, onKeyRelease, null);
		});
	}

	public static function onKey(key:KeyCode):Void {

	}

	public static function onKeyRelease(key:KeyCode) {
		switch (key) {
			case KeyCode.M :
			{
				showMenu = !showMenu;
			}
			case KeyCode.Up :
			{
				Scheduler.removeTimeTask(taskt);
				speed = (speed < 60) ? speed + 1 : speed;
				taskt = Scheduler.addTimeTask( update, 0, 1 / speed);
			}
			case KeyCode.Down :
			{
				Scheduler.removeTimeTask(taskt);
				speed = (speed > 1) ? speed - 1 : 1;
				taskt = Scheduler.addTimeTask( update, 0, 1 / speed);
			}
			case KeyCode.Escape :
			{
				Scheduler.removeTimeTask(taskt);
				System.removeFramesListener(render);
				System.stop();
			}
			default : {}
		}
	}
	
	private static function render(frames: Array<Framebuffer>): Void {
		var g = frames[0].g4;
		g.begin();
		g.clear(Color.Black);
		g.setPipeline(pipeline);
		// read from ping first
		g.setTexture(texUnit, swap ? ping : pong);
		g.setTextureParameters(texUnit,
			TextureAddressing.Clamp, TextureAddressing.Clamp,
			TextureFilter.PointFilter, TextureFilter.PointFilter,
			MipMapFilter.NoMipFilter);
		g.setVertexBuffer(vertices);
		g.setIndexBuffer(indices);
		g.drawIndexedVertices();
		g.end();

		if (showMenu) zgui.render(frames[0].g2);
	}
	public static function update():Void {
		// write to pong first
		var p = swap ? pong.g4 : ping.g4;
		p.begin();
			p.clear(Color.Black);
			p.setPipeline(tpipeline);
			p.setInt(locationGS, gridSize);
			// read from ping first
			p.setTexture(texUnit2, swap ? ping : pong);
			p.setTextureParameters(texUnit2,
				TextureAddressing.Clamp, TextureAddressing.Clamp,
				TextureFilter.PointFilter, TextureFilter.PointFilter,
				MipMapFilter.NoMipFilter);
			p.setVertexBuffer(vertices);
			p.setIndexBuffer(indices);
			p.drawIndexedVertices();
		p.end();
		swap = !swap;
	}
}
