use <common.scad>

delta = 0.1;
$fn = 50;

h = 35;	// высота до оси щупа
r = 1.5;	// радиус щупа

l = 50;	// длина опоры
lSpring = 35; // длина пружины
rs = 2.5;// радиус пружины

wall = 1.5;	// толщина стенки после вычитания
hs = 5;			// толщина опоры под головкой шурупа

//blt = bPar2(2.5); // 2.5 -- радиус тела шурупа
blt = stdScrew(0); // тип шурупа: 0 / 1 / 2



probeSupport(h, l, r, lSpring, rs, wall, hs, blt);



module probeSupport(h, l, r, lSpring, rs, wall, hs, blt)
{
	useSidePlates = false;

	dh = 2 * (max(wall + r, rs)); // настолько сместится ось щупа
	rc = (h+dh)  * 2/3; 
   dhr = (dh+rs)* 2/3;
	dhSupp = dh / 2;

	suppW  = (blt[1] + wall) * 2;

	offset = rc*sqrt(3)/2 - hs/2 - blt[1] - .3; // непонятно, откуда взялось 0.3

	rotate(-90, [0,1,0])
	translate([rc/2, 0, 0])
	difference()
	{
		recursiveHole(rc, l, wall)				// рекурсивное вырезание полостей
			makeRound(rc, dhSupp, l)
				cylinder(r = rc, h = l, $fn = 3);
		
//		hole((rc/2 - wall)/sqrt(3) * 2, l); // основная пустота - 6-гранник
//		repRapLogo(rc/2 - wall, l, delta);			// 						 RepRap logo

		translate([rc-dh, 0, -delta/2])		// щуп
			cylinder(r = r, h = l + delta);

		translate([rc-dh, 0, (l-lSpring)/2])	// пружина
			cylinder(r = rs, h = lSpring);

		translate([rc-dhr+ delta/2, 0, (l-lSpring)/2])					// место пружины
			cylinder(r = dhr + delta, h = lSpring, $fn = 3);


		if (! useSidePlates)
			rotate(90, [1, 0, 0])	// места крепления
				rotate(90, [0, 1, 0])
				{
					translate([0 , blt[1] + wall, - rc/2])
						bp2(blt, hs, offset, delta, h);
					translate([0 , l- blt[1] - wall, - rc/2])
						bp2(blt, hs, offset, delta, h);
				}
		
	}

// крепление лапами
	coef = 1.4; // экспериментально подобранная константа -- разлет лап
	if (useSidePlates)
	rotate(90)
	{
		translate([0, suppW/2, 0])
			basePlate(rc* sqrt(3) + coef*suppW, suppW, hs, blt);
		translate([0, l-suppW/2, 0])
			basePlate(rc* sqrt(3) + coef*suppW , suppW, hs, blt);
	}

// контроль высоты
//	color("red")
//		cube([0.2, 0.1, h]);

}

// срезаем угол треугольника alpha = 0 / 120 / 240 определяет какой именно
module makeRound(rc, dh, l, alpha = 0)
{
	difference()
	{
		children();
		rotate(alpha)
			translate([rc-dh+ delta/2, 0, -delta/2])					// скосы под скругления
				cylinder(r = dh + delta, h = l+ delta, $fn = 3);
	}
	rotate(alpha)
		translate([rc-2*dh, 0, 0])
			cylinder(r = dh, h = l);
}


module recursiveHole(r, l, wall, p)
{
	rn = r/2 - wall;						// диаметр текущей полости
	rRec = (r - rn) * 2 / 3;			// размер остатка

	dx = (rn + rRec / 2) * sin(30);	//
	dy = (rn + rRec / 2) * cos(30);

	difference()
	{
		if (rRec > max (2* wall, .1))
		{
			translate([-dx, dy, 0])
				recursiveHole(rRec, l, wall)
					translate([0, -2*dy, 0])
						recursiveHole(rRec, l, wall)
							translate([dx, dy, 0])
								children();			
		}
		else
			children();
		repRapLogo(rn, l, delta);
	}
}

module hole(r, l)
{
	rotate(30)
		translate([0, 0, -delta/2])
			cylinder(r = r, h = l + delta, $fn = 6);
}


module basePlate(l, w, h, param)
{
	offset = l/2 - w/2 ;
	difference()
	{
		translate([0,0,h/2])
			cube([l, w, h], true);
		bp2(param, h, offset, delta, delta);
	}
}

module bp2(param, h, offset, dlt=0, hHead)
{
	translate([offset, 0, -dlt])
		screw(param, h + dlt, hHead);
	translate([-offset, 0, -dlt])
		screw(param, h + dlt, hHead);
}