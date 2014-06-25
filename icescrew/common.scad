delta = 0.1;
module nuts(alpha, dx, dy, bHeight)
{
	// нежно вписываем m3 в объем
	rotate(alpha)
		translate([0,0,-dx])
		rotate(90, [0, 1, 0])
			{
				translate([0, 0, dy])
					nutSlot(bh = bHeight);
				translate([0, 0, -dy])
					nutSlot(bh = bHeight);
			}
}

module nutSlot(d = 5.5, m = 3, h = 2.5, bh = 10)
{
	d2 = (d+delta) * 2 / sqrt(3);	// delta -- запас на грязь печати

	cylinder(d = d2, h = h, center = true, $fn = 6);
	translate([0,0, -bh/2])
		cylinder(d = m, h = bh, $fn = 50);

	translate([d2/4, 0, 0])
		cube([d2/2+ delta, d+delta, h], true);
}

