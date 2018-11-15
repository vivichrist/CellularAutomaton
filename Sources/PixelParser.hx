package;

import haxe.io.StringInput;
import haxe.sys.io.*;
import kha.math.Vector2i;
import kha.Blob;

using StringTools;

class PixelParser
{
	public var pixels:Array<Vector2i> = [];

	public function new(file:Blob)
	{
		var str = new StringInput(file.toString());
		try
		{
			while (true)
			{
				var s = lineTokens(str);
				if (s[0].startsWith("#")) continue; // skip over comments
				// read primary floating point [0,1] x,y noralized coordinates
				var coords = s[0].split(",");
				var xcoord = Std.int(Main.gridSize * Std.parseFloat(coords[0]));
				var ycoord = Std.int(Main.gridSize * Std.parseFloat(coords[1]));
				for(ss in s.slice(1))
				{
					coords = ss.split(",");
					var xoffset = xcoord + Std.parseInt(coords[0]);
					var yoffset = ycoord + Std.parseInt(coords[1]);
					pixels.push(new Vector2i(xoffset, yoffset));
				}
			}
		}
		catch(ex:haxe.io.Eof) { }
		str.close();
	}

	// Parsing
	function lineTokens(input:StringInput):Array<String> {
		var line = input.readLine(); // eats one line
		line = StringTools.trim(line);
		var str = line.split(" ");
		return str;
	}
}