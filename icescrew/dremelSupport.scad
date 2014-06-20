delta = 0.1;
$fn = 100;


r= 20;
R = 30;
r0 = 25 / 2;	// радиус шейки бора 
h = 35;

rBolt = 4;	// силовой винт
rBolt2 = 2; // фиксирующие винты


support(r, R, r0, h, rBolt, rBolt2);

translate([R + r, 0, 0])
	head(r, r0, rBolt2);



module head(r, r0, rBolt2)
{

	offset = (r0 + r)/2 ;

	difference()
	{
		cylinder(r = r, h = r);
		rotate(90, [1, 0, 0])
			translate([0, -2*delta, -r -delta/2])  // 2*delta -- зазор на стяжку
				translate([0,0, - delta/2])
					cylinder(r = r0, h = 2*r + delta);

		translate([offset, 0, -delta/2])
			cylinder(r= rBolt2, r+delta);
		translate([-offset, 0, -delta/2])
			cylinder(r= rBolt2, r+delta);
	}
}


module support(r, R, r0, h, rBolt, rBolt2)
{
	offset = (r0 + r)/2 ;

	difference()
	{
		cylinder(r1 = R, r2 = r, h = h);
		translate([0, 0, h])
			rotate(90, [1, 0, 0])
				translate([0, 0, -R])
					cylinder(r = r0, h = 2*R);
		

		translate([0,0, -delta/2])		// основной винт
			bolt(rBolt, h-r0, true, rBolt + r0);

		translate([offset, 0, -delta/2])
			bolt(rBolt2, h+delta);
		translate([-offset, 0, -delta/2])
			bolt(rBolt2, h+delta);
	}
}

module bolt(r, h, rot = false, head = -1)
{
	h2 = head > 0 ? head : 1.5*r;
	rHead = r * 1.9; 				// проверить!!!

	cylinder(r = r, h = h);
	translate([0,0, rot ? h - 1.5*r : 0])
		cylinder(r = rHead, h = h2, $fn = 6);
}