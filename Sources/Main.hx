package;

import kha.graphics5.MipMapFilter;
import kha.graphics5.TextureFilter;
import kha.graphics5.TextureAddressing;
import kha.graphics4.TextureFormat;
import kha.Color;
import kha.Framebuffer;
import kha.Image;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
import kha.graphics4.CullMode;
import kha.graphics4.TextureUnit;
import kha.Shaders;
import kha.System;

class Main {
	private static var pipeline: PipelineState;
	private static var tpipeline: PipelineState;
	private static var vertices = new Array<VertexBuffer>();
	private static var tvertices:VertexBuffer;
	private static var indices = new Array<IndexBuffer>();
	private static var gridSize = 64;
	private static var numInsts = gridSize * gridSize;
	private static var step = 2 / gridSize;
	private static var tex: Image;
	private static var tex2: Image;
	private static var gridLen:ConstantLocation;
	private static var gridLen2:ConstantLocation;
	private static var texunit:TextureUnit;
	private static var texunit2:TextureUnit;
	private static var swapbuffer = true;

	public static function triangleGrid(which:Int):Void {
		var k = -1;
		var v = vertices[which].lock();
			for(j in 0...gridSize) {
				var j1 = j * -1.0 * step;
				for(i in 0...gridSize) {
					v.set(++k, i * step);v.set(++k, j1);
				}
			}
		vertices[which].unlock();
	}

	public static function fixedTriangleGrid(which:Int):Void {
		var s = step * 0.75;
		var v = vertices[which].lock();
			v.set(0,-1); v.set(1, 1); v.set(2, 0.5);
			v.set(3,-1); v.set(4, 1-s); v.set(5, 0.5);
			v.set(6,-1+s); v.set(7, 1-s); v.set(8, 0.5);
			v.set(9, -1); v.set(10, 1); v.set(11, 0.5);
			v.set(12, -1 + s); v.set(13, 1 - s); v.set(14, 0.5);
			v.set(15, -1 + s); v.set(16, 1); v.set(17, 0.5);
		vertices[which].unlock();
	}

	// public static function triangleIndices() {
	// 	var k = -1;
	// 	var ind = indices.lock();
	// 		for(j in 0...gridSize) {
	// 			var j1 = j * numLines;
	// 			for(i in 0...gridSize) {
	// 				// a quad
	// 				ind[++k] = j1 + i;
	// 				ind[++k] = j1 + i + numLines;
	// 				ind[++k] = j1 + i + 1 + numLines;
	// 				ind[++k] = j1 + i;
	// 				ind[++k] = j1 + i + 1 + numLines;
	// 				ind[++k] = j1 + i + 1;
	// 			}
	// 		}
	// 	indices.unlock();
	// }

	public static function fixedTriangleIndices():Void {
		var k = -1;
		var ind = indices[0].lock();
			ind[0] = 0; ind[1] = 1; ind[2] = 2;
			ind[3] = 3; ind[4] = 4; ind[5] = 5;
		indices[0].unlock();
	}

	// state texture pipeline
	public static function setupTextureRender():Void {

		var structure = new VertexStructure();
			structure.add("pos", VertexData.Float3);

		tpipeline = new PipelineState();
		tpipeline.inputLayout = [structure];
		tpipeline.vertexShader = Shaders.state_vert;
		tpipeline.fragmentShader = Shaders.state_frag;
		// pipeline.depthWrite = true;
		tpipeline.depthMode = CompareMode.Less;
		tpipeline.cullMode = CullMode.CounterClockwise;
		tpipeline.compile();

		tex2 = Image.createRenderTarget(gridSize, gridSize, TextureFormat.L8);
		texunit2 = tpipeline.getTextureUnit("tex");
		gridLen2 = tpipeline.getConstantLocation("gridLen");

		tvertices = new VertexBuffer(4, structure, Usage.StaticUsage);
		// fullscreen quad
		var v = tvertices.lock();
			v.set(0,-1.0); v.set(1,-1.0); v.set(2, 0.5);
			v.set(3, 1.0); v.set(4,-1.0); v.set(5, 0.5);
			v.set(6, 1.0); v.set(7, 1.0); v.set(8, 0.5);
			v.set(9,-1.0); v.set(10,1.0); v.set(11,0.5);
		tvertices.unlock();
		// indices in triangle fan
		indices[1] = new IndexBuffer(6, Usage.StaticUsage);
		var ind = indices[1].lock();
			ind[0] = 0; ind[1] = 1; ind[2] = 2;
			ind[3] = 0; ind[4] = 2; ind[5] = 3;
		indices[1].unlock();
	}
	
	public static function main(): Void {
		System.start({title: "Cellular Automaton for brian's brain", width: 800, height: 600}, function (_) {
			var structures = new Array<VertexStructure>();
			structures[0] = new VertexStructure();
			structures[0].add("pos", VertexData.Float3);
			// position structure, is different for each instance
			structures[1] = new VertexStructure();
			structures[1].add("trans", VertexData.Float2);
			
			pipeline = new PipelineState();
			pipeline.inputLayout = structures;
			pipeline.vertexShader = Shaders.shader_vert;
			pipeline.fragmentShader = Shaders.shader_frag;
			pipeline.depthWrite = false;
			pipeline.depthMode = CompareMode.Less;
			pipeline.cullMode = CullMode.Clockwise;
			pipeline.compile();

			tex = Image.createRenderTarget(gridSize, gridSize, TextureFormat.L8);
			gridLen = pipeline.getConstantLocation("gridLen");
			texunit = pipeline.getTextureUnit("tex");
			
			vertices[0] = new VertexBuffer(6, structures[0], Usage.StaticUsage);
			fixedTriangleGrid(0);
			// last parameter -> changed after every instance, use i higher number for repetitions.
			vertices[1] = new VertexBuffer(gridSize * gridSize,	structures[1], Usage.StaticUsage, 1);
			triangleGrid(1);
			
			indices[0] = new IndexBuffer(6, Usage.StaticUsage);
			fixedTriangleIndices();

			// initialise state in the first texture
			var mid = Std.int(gridSize / 2);
			var d1 = gridSize * mid + mid;
			var d2 = gridSize * (mid + 1) + mid;
			var bytes = tex.lock();
				bytes.fill(0, gridSize * gridSize, 0);
				bytes.set(d1, 2);
				bytes.set(d2, 2);
			tex.unlock();
			setupTextureRender();
			// start rendering.
			System.notifyOnFrames(render);
		});
	}
	
	private static function render(frames: Array<Framebuffer>): Void {
		var g = frames[0].g4;
		g.begin();
			g.clear(Color.Black);
			g.setPipeline(pipeline);
			g.setInt(gridLen, gridSize);
			g.setTexture(texunit, swapbuffer ? tex : tex2);
			g.setVertexBuffers(vertices);
			g.setIndexBuffer(indices[0]);
			g.drawIndexedVerticesInstanced(numInsts);
		g.end();
		var t = swapbuffer ? tex2.g4 : tex.g4;
		t.begin();
			t.setPipeline(tpipeline);
			t.setInt(gridLen2, gridSize);
			t.setTexture(texunit2, swapbuffer ? tex : tex2);
			t.setTextureParameters(texunit2, TextureAddressing.Clamp,
											TextureAddressing.Clamp,
											TextureFilter.PointFilter,
											TextureFilter.PointFilter,
											MipMapFilter.NoMipFilter);
			t.setVertexBuffer(tvertices);
			t.setIndexBuffer(indices[1]);
			t.drawIndexedVertices();
		t.end();
		swapbuffer = !swapbuffer;
	}
}
