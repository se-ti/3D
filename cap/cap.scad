delta = 0.1;
module base(l, w, l2, w2, h, d, d2 = 0, flat = true)
{	
	mkr = .01;	// цилиндр для базового элемента

	pts = [[d, d], 			 [l-d, d], 				[l-d, w2-d], 			[(l+l2) / 2-d, w2-d], 
			 [(l+l2)/2-d, w-d],[ (l-l2)/2+d, w-d], [ (l-l2)/2+d, w2-d], [d, w2-d]				];
	pathes = [[0, 1, 2, 3, 4, 5, 6, 7]];

	if (flat)
	{
		linear_extrude(height = h, center = true, convexity = 16, twist = 0, slices = 50)
		{
			minkowski()
			{
				polygon(points = pts, paths = pathes, convexity = 16);
				circle(d);
			}
		}
	}
	else 
	{
		minkowski()
		{
			linear_extrude(height = h - 2 * d2, center = true, convexity = 16, twist = 0, slices = 50)
				polygon( points = pts, paths = pathes, convexity = 16);

			intersection()
			{
				translate([0,0, -d2])
					cylinder( h = d2, r = d);
				minkowski()
				{
					cylinder(h = mkr, r = d - d2-mkr);
					sphere(d2-mkr, $fn = 50);
				}
			}
		}
	}
}

module cap(l, w, l2, w2, h, h2, s, z, d, d2)
{
	s2 = (s-dirt)*2; 

	lz = max (z, d-s, 0.3);
	cw = s*2;	// габариты стоек
	wd = w2 - 2 * (s + lz + dirt);

	union()
	{
		difference()
		{
			base(l, w, l2, w2, h + d2, d, d2, false);

			translate([s, s, s/2 + delta/2 - d2/2])
				base(l-s2, w-s2, l2-s2, w2-s2, h-s+delta, max (d-s, 0.3));
		}

		translate([s + lz, 		 s + lz + dirt, -h2/2 + 3*s/2 - d2 / 2])
			cube([cw, wd, h2]);

		translate([l- cw -s -lz, s + lz+ dirt, -h2/2 + 3*s/2 - d2 / 2])
			cube([cw, wd, h2]);
	}
}

$fn = 40;

dirt = 0.1; // запас на грязь

l = 41.2;		//внешние габариты
w = 23.4;
l2 = 32.1;		// по внутренним углам
w2 = 19.3;

h = 6.7;			// высота стенок 
h2 = 7.8;		// высота стоек
s = 1.2;	// толщина стенок
z = 2; 			// расстояние от стоек до стенок
d = (l - l2) /2 -1;	// радиус основных закруглений
d2 = 1;			// радиус вспомогательных закруглений


cap(l, w, l2, w2, h, h2, s, z, d, d2);