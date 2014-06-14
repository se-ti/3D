//гривель 360
/*
толщина стенки 1.4
внешний диаметр 18,1
высота зуба 6.4

смещение зуба -- 1 мм (угол атаки)

*/

delta = 0.1;

R = 18.1 / 2;
r = 5;// (18.1 - 2.8 ) / 2;
th = 6.5;
h = 10;

$fn = 200;
crown(r, R, th, 4, 7, 0, fn= 400);

translate([0,0,-h+th])
difference()
{
	cylinder(r= R, h =h -th);
	translate([0,0,-delta/2])
		cylinder(r=r, h = h -th +delta);
}



// мин / макс радиусы, высота зуба, число зубьев, 
// угол между вертикалью и передней кромкой, 
// угол между направлением на ось и передней кромкой
//"чистота"
module crown(r, R, th, n, attack, rare, fn = 300) 
{
	step = 2; // макс. глубина пазов для щупа
	difference()
	{
		intersection()
		{
			union()
			{
				for (i = [0 : n-1])   
					rotate(360 / n * i,  [0, 0, 1])
						tooth(R, R-step, th, 360 / n + attack , attack, rare, fn);
			}
			cylinder(r = R, h = th, $fn = fn);
		}

		translate([0, 0, -delta/2])
			cylinder(r = r, h= th+delta, $fn= fn);
	}
}


module tooth(r, r2, h, segment, attack, rare, fn)
{
	difference()
	{
		shape(r, h, rare, (segment - attack), -segment, fn);
	translate([0,0, -delta/2])
			difference()
			{
				rotate(segment-attack, [0, 0, 1])

					shape(r+delta, h+delta, rare, segment - attack , -attack , fn);

				rotate(segment, [0, 0, 1])
					scale([1, 2 * r2/(r+r2), 1])
						cylinder(r = (r+r2) /2, h= h + delta, $fn=fn);
			}
	}
}

module shape(r, h, rare, segm, tw, fn = 300)
{
	pts = [[0, 0], [0, - r*tan(rare)], [r, 0], [r, 2*r], [r * cos(segm), r * sin(segm)]];
	pth = [[0, 1, 2, 3, 4]];

	linear_extrude(height = h, center = false, convexity = 4, twist = tw, slices = fn, $fn=fn)
		polygon(points = pts, pathes = pth, convexity = 4);
}