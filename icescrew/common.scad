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


// возвращают вектор: радиус тела шурупа - радиус головки
function stdScrew(type) = (type == 0 ? [3.62, 6.7] : 
						 		  (type == 1 ? [4.12, 7.84] : 
													[4.36, 8.82] )) / 2;
function screwParam(r) = [r, 2.2 * r];	// до 2.2 для шурупов, до 1.9 для винтов
function boltParam(r)  = [r, 1.9 * r];	


// 3.62 - 6.7
// 4.12 - 7.84
// 4.36 - 8.82

// гнездо под шуруп 
// param -- вектор радиусов тело / головка шурупа
// h -- высота от кончика до верха головки
// hHead -- высота выреза над головкой
module screw(param, h, hHead = -1)
{			
	hCone = param[1] < h ? param[1] : h;
	rCone = param[1] < h ? 0 : param[1] - h; 
	h2 = hHead > 0 ? hHead : h;

	cylinder(r = param[0], h = h);
	translate([0, 0, h-hCone])
		cylinder(r1 = rCone, r2 = param[1], h = hCone);	
	translate([0, 0 ,h - delta/10])				// delta/10 -- чтобы пересеклись конус и цилиндр
		cylinder(r = param[1], h = h2 + delta/10);
}