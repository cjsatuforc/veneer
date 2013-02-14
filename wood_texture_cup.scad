sides = 100;
diameter = 100;
height = 30;
layer_height = 0.3;
thread_thickness = 0.4;
walls = 2;
radius = diameter/2;

echo("Length: ", PI*diameter);
echo("Height: ", height/layer_height);
//echo("Square Height: ", PI*diameter/layer_height);

difference() {
	cylinder(r=radius, h=height, $fn=sides);
	translate([0, 0, -1]) {
		cylinder(r=radius-(thread_thickness*walls), h=height+2, $fn=sides);
	}
}