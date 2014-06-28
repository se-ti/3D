use <common.scad>

delta = 0.1;
$fn = 100;


// параметры бормашины: захват д = 20 л = 8, от захвата до режущей кромки -- 32-54 мм, длина режущей кромки -- 6 мм, диаметр ~2,5

r0 = 20 / 2;	// радиус шейки бора 
l0 = 8;			// толщина захвата
level = 35;			// не обязательно делать на всю высоту
wall = 5; 		// толщина держателей осей

rBolt = 2; // фиксирующие винты (М4)
rAxis = 3; // каленая ось вращения


depth = 20;	// глубина основания

base = 50; // радиус дуги высотной регулировки
angle = 30;	// угол дуги
bAngle = 8; // угол смещения

scr = stdScrew(1); // 0, 1, 2



fixBase = max(base, 2* (r0 +  (rBolt + rAxis)));

head(l0, r0, rBolt, rAxis, fixBase, angle, bAngle);

translate([0, -depth/2-l0/2 - delta, 0])
!	base(l0, r0, rBolt, rAxis, fixBase, angle, bAngle, depth, level, wall, scr);

bor(0, l0);

module base(depth, r0, rBolt, rAxis, base, angle, bAngle, depth2, level, wall, scr)
{
	sz = sizes(r0, base, angle, bAngle, rAxis, rBolt, depth);

	w = sz[0]; 
	h = sz[1]; 
	dp = sz[2];
	dh = sz[3];


	bHeight = level - h/2;
	dx = bHeight;				// на сколько опустить вниз слоты? -- до дна
	dw = base*(1-cos(angle - bAngle)); // сколько отрезать с края

	surfOffset = wall + dp + 2*delta + depth2/2; // смещение до лицевой поверхности

	rHole = (bHeight-wall)/3;

	// центр фиксирующего отверстия
	dxFix = 2*rBolt + dw;
	dyFix = dh+base * sin(angle - bAngle);

	hDd = 1; 			// вынос головки болта, чтобы не сильно ослаблял держатель
	rotate = false; 	// вынести головку на другую опору
	tune = 0.5;  		// подгон положения шурупов между опорами
	

	translate([0, 0, -h/2])
	difference()
	{
		union()
		{
			translate([-dw/2, wall/2 + depth/2 + delta, -bHeight/2])					// основание
				cube ([w-dw, depth2 + depth + wall + 2*delta , bHeight], true);

			translate([0, surfOffset, -dx])	// держатели осей
			{
				translate([w/2 - dxFix, 0, 0])
					slot2(dyFix + 2*rBolt + dx, dx, wall+depth + 2*delta, wall, 4*rBolt);

				translate([-w/2 + 2*rAxis, 0, 0])
					slot2(dh+dx + 2*rAxis, dx, wall+depth + 2*delta, wall, 4*rAxis);
			}
		}

		translate([-w/2 + 2*rAxis,  surfOffset + delta/2, dh])	// ось
			rotate(90, [1, 0, 0])
				cylinder(r = rAxis, h = 2* wall + depth + 3*delta);

		translate([w/2 - dxFix, surfOffset +delta/2 + (rotate ? 0 : hDd),  dyFix ])	// фиксирующий болт
			rotate(90, [1, 0, 0])
				rotate(30)
					bolt(rBolt, 2* wall + depth + 3*delta + hDd, rotate);

		// крепление к основанию
		translate([-dw/2, depth/2+delta + tune/2, -bHeight-delta])
			screws(scr, bHeight/2+delta, bHeight, w-dw, depth2 + depth + 2*delta+tune);	


		// сверлим полости
		for(i = [-1: 1])
			translate([i * (2*rHole + wall/2), surfOffset, -bHeight/2 - wall/3])
				rotate(90, [1, 0 ,0])
					rotate(90)
						repRapLogo(rHole, depth2 + depth + wall + 2*delta, delta);
	}

//	color("red")
//	translate([0, -4, -10])
//		cube([mbase, 0.1, 0.1], true);

}

module screws(scr, scrH, H, l, w)
{
	dr = 1.2*scr[1];
	for (i=[-1, 1], j = [-1, 1])
		translate([ i *(l/2 - dr), j * (w/2 - dr), 0])
			screw(scr, scrH, H);
}


module slot(wall, width, height, base, l)
{
	slot2(height, height + base, l + 2*wall, wall, width);
}

module slot2(H, h, L, l, w)
{
	translate([-w/2, -L-l, 0])
	difference()
	{	
		union()
		{
		cube([w, L+l, H-w/2]);
		translate([w/2, 0, H - w/2])
		rotate(90, [-1,0,0])
			cylinder(d = w, h = L+l);
		}
	
		translate([-delta/2, l, h])
			cube([w+delta, L-l, H-h+delta]);
	}
}


function sizes(r0, base, angle, bAngle, rAxis, rBolt, depth ) = 
	[
		max(2*(r0 + 2*rAxis + 2*rBolt), base + 2 * (rAxis + rBolt)), // длина
      max(2*(r0 + rBolt + rAxis), max(base * sin(bAngle) + 2*rBolt, 2*rAxis) + 2*rBolt+ base*sin(angle-bAngle)),// высота
		max(depth, 4*rBolt),							// толщина
		max(base * sin(bAngle) + 2*rBolt, 2*rAxis)				// смещение оси вверх 
	];


module head(l, r0, rBolt, rAxis, base, angle, bAngle)
{
	sz = sizes(r0, base, angle, bAngle, rAxis, rBolt, l);

	w = sz[0]; 
	h = sz[1]; 
	dp = sz[2];
	dh = sz[3];

	offset = r0 + 2*rBolt;
	dw = base*(1-min(cos(angle - bAngle), cos(bAngle)));

	difference()
	{
		cube([w, dp, h], true);
		translate([-w/4 + delta/2, 0, 0])
			cube([w/2+ delta, dp + delta, 2*delta], true);	// 2*delta -- зазор на стяжку

		rotate(90, [1, 0, 0])
			translate([0, 0, -dp/2 -delta/2])  
				cylinder(r = r0, h = dp + delta);

		translate([-offset, 0, -h/2 -delta/2])	// стяжка
			bolt(rBolt, h+ delta);
		translate([max(offset, w/2 - 5*rBolt - dw ), 0, -h/2 -delta/2])	// регулировка
			bolt(rBolt, h+ delta);

		translate([-w/2 + 2*rAxis, dp /2 + delta/2, -h/2 + dh])
			rotate(90, [1, 0, 0])				
				tuner(base, rBolt, rAxis, dp + delta, angle, bAngle);

		for (i =[1, -1], j = [1, -1])
			assign(dr = (i == 1) ? rBolt : rAxis, 
					 rot = 90 * (1-i) + 45 *(1-i*j))		// страшная формула для подбора углов
				translate([i * (w/2-dr), 0 , j*(h/2 - dr)])
					rotate(rot , [0, 1, 0])
						corner4(2 * dr, dp + delta);
	}
}


module tuner(r, rBolt, rAxis, h, angle, bAngle)
{
	rotate(-bAngle)
	{
		cylinder(r= rAxis, h = h);
		sector(r-rBolt, r+rBolt, h, angle);
	}
}


module corner4(r, h)
{
	difference()
	{
		translate(-delta/2, 0, -delta/2)
			cube([r+delta, h, r+delta], true);
		translate([-r/2, -h/2-delta/2, -r/2])
			rotate(90, [-1, 0, 0])
				cylinder(r = r, h = h+delta);		
	}
}

module sector(r, R, h, angle)
{
	fn = 100;


	pts = [[0, 0], [R, 0], [R, 2*R], [R * cos(angle), R * sin(angle)]];
	pth = [[0, 1, 2, 3]];

	dr = (R+r)/2;

	linear_extrude(height = h, center = false, convexity = 4, twist = 0, slices = fn)
	{
		union()
		{
			difference()	// сектор
			{
				intersection()
				{
					polygon(points = pts, pathes = pth, convexity = 4);
					circle(r=R, $fn = 4*fn);
				}
				circle(r=r, $fn = 4*fn);
			}

			//  скругления с концов
			translate([dr, 0, 0])
				circle(r = (R-r)/2, $fn = fn);
			translate([dr * cos(angle), dr * sin(angle), 0])
				circle(r = (R-r)/2, $fn = fn);
		}
	}

}


// размеры по сечениям от передней кромки
//смещение	      	0	25	55	115	130
//диаметр	высоте	20	30	46	46	
//	      ширине		20	30	43	43	

module bor(h, l0)
{
	l = 32;

	color ("red")
	translate([0, l0/2, h])
		rotate(90, [-1, 0, 0])
		{
			//  фреза и ось
			cylinder(r= 1, h = l);
			translate([0,0,l])
				cylinder(d = 2.5, h = 6);
	
			translate([0,0,-l0])			// шейка
				cylinder(d = 20, h = l0);
			translate([0,0, - 25])			// тело за шейкой
				cylinder(d = 30, h = 25 - l0);
			translate([0,0, - 55])			// и еще дальше
				cylinder(d = 36, h = 55 - 25 );
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