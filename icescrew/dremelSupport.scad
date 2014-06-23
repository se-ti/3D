delta = 0.1;
$fn = 100;


// параметры бормашины: захват д = 20 л = 8, от захвата до режущей кромки -- 32-54 мм, длина режущей кромки -- 6 мм, диаметр ~2,5


r= 15;
R = 20;
r0 = 20 / 2;	// радиус шейки бора 
l0 = 8;
h = 35;			// не обязательно делать на всю высоту

rBolt = 4;	// силовой винт
rBolt2 = 2; // фиксирующие винты


intersection()
{
	union ()
	{
		support(r, R, r0, h, rBolt, rBolt2);
		
		translate([0 /*R + r*/, 0, h+3*delta])
			head(r, r0, rBolt2);
	}
	union()
	{
		translate([0, l0, h])
			cube([2*R, l0, 2*h], true);
		translate([0,0, (h-r0) /2])
		cube([2*R, 2*R, h-r0], true);
	}
}

bor(h, l0);



module bor(h, l0)
{

	l = 32;

	color ("red")
	translate([0, l0/2, h])
		rotate(90, [-1, 0, 0])
		{
			cylinder(r= 1, h = l);
			translate([0,0,l])
				cylinder(d = 2.5, h = 6);
		}
}

module head(r, r0, rBolt2)
{

	offset = (r0 + r)/2 ;

	difference()
	{
		cylinder(r = r, h = min(r, r0 * 1.5));
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
		{
			cylinder(r = rBolt, h = h - r0 + delta);
			translate([0, 0, h-r0 - rBolt])
				cylinder(r = 2*rBolt, h = 2*rBolt);
		}
		//	bolt(rBolt, h-r0, true, rBolt + r0);

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