//гривель 360
/*
толщина стенки 1.4
внешний диаметр 18,1
высота зуба 6.4

смещение зуба -- 1 мм (угол атаки)

*/

/*minkowski()
{
	//cube([5, 10, 15]);
!	crown(9, 11, 7, 4, 7, fn= 40);
	sphere(r=1, $fa=2, $fs=0.2 );
}
/**/

delta = 0.1;

R = 18.1 / 2;
r = 5;// (18.1 - 2.8 ) / 2;
th = 6.5;
h = 15;

crown(r, R, h, th, 4, 20, fn= 200);


// мин / макс радиусы, высота зуба, число зубьев, угол между вертикалью и передней кромкой, "чистота"
module crown(r, R, h, th, n, attack, fn = 300) 
{
	difference()
	{
		intersection()
		{
			union()
			{
				for (i = [0 : n-1])   
					rotate(360 / n * i,  [0, 0, 1])
						tooth(R, th, 360 / n + attack, attack, fn, R-3);
			}
			cylinder(r = R, h = th, $fn = fn);
		}

		translate([0, 0, -delta/2])
			cylinder(r = r, h= h+delta, $fn= fn);
	}
}


module tooth(r, h, segment, attack, fn, r2)
{
	difference()
	{
		shape(r, h, segment - attack, -segment, fn);
		translate([0,0, -delta/2])
			difference()
			{
				rotate(segment-attack, [0, 0, 1])
					shape(r+delta, h+delta, segment - attack+delta, -attack, fn);

				rotate(segment, [0, 0, 1])
					scale([1, 2 * r2/(r+r2), 1])
						cylinder(r = (r+r2) /2, h= h + delta, $fn=fn);
			}
	}
}

module shape(r, h, segm, tw, fn = 300)
{
	pts = [[0, 0], [r, 0], [r, 2*r], [r * cos(segm), r * sin(segm)]];
	pth = [[0, 1, 2, 3]];

	linear_extrude(height = h, center = false, convexity = 16, twist = tw, slices = 100)
		polygon(points = pts, pathes = pth, convexity = 4);
}