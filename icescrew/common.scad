delta = 0.1;
module nuts(alpha, dx, dy)
{
	// нежно вписываем m3 в объем
	rotate(alpha)
		translate([0,0,-dx])
		rotate(90, [0, 1, 0])
			{
				translate([0, 0, dy])
					nutSlot();
				translate([0, 0, -dy])
					nutSlot();
			}
}

module nutSlot(d = 5.5, m = 3, h = 2.5)
{
	th = 10;
	d2 = d * 2 / sqrt(3);

	cylinder(d = d2, h = h, center = true, $fn = 6);
	translate([0,0, -th/2])
		cylinder(d = m, h = 10, $fn = 50);

	translate([d2/4, 0, 0])
		cube([d2/2+ delta, d, h], true);
}

