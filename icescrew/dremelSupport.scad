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
	base(l0, r0, rBolt, rAxis, fixBase, angle, bAngle, depth, level, wall, scr);

dremel(0, l0);


//counterForce(10,20, 40);




module base(depth, r0, rBolt, rAxis, base, angle, bAngle, depth2, level, wall, scr)
{
	sz = sizes(r0, base, angle, bAngle, rAxis, rBolt, depth);

	w = sz[0]; 
	h = sz[1]; 
	dp = sz[2];
	dh = sz[3];


	bHeight = level - h/2;
	dx = bHeight;				// на сколько опустить вниз слоты? -- до дна
	dw = base*(1-cos(angle - bAngle)) - (rAxis - rBolt); // сколько отрезать с края

	surfOffset = wall + dp + 2*delta + depth2/2; // смещение до лицевой поверхности
	totalDepth = depth2 + depth + wall + 2*delta;

	rHole = (bHeight-wall)/3;

	// центр фиксирующего отверстия
	dxFix = rAxis + rBolt + dw ;
	dyFix = dh+base * sin(angle - bAngle);

	hDd = 1; 			// вынос головки болта, чтобы не сильно ослаблял держатель
	rotate = true; 	// вынести головку на другую опору
	tune = 0.5;  		// подгон положения шурупов между опорами
	

	translate([0, 0, -h/2])
	difference()
	{
		union()
		{
			// основание
			translate([-dw/2, wall/2 + depth/2 + delta, -bHeight/2])	
				cube ([w-dw, totalDepth , bHeight], true);

			// держатели осей
			translate([0, surfOffset, -dx])
			{
				translate([w/2 - dxFix, 0, 0])
					slot(dyFix + rBolt + rAxis + dx, dx, wall, depth + 2*delta, 2*rBolt + 2*rAxis, true, right = true);

				translate([-w/2 + 2*rAxis, 0, 0])
					slot(dh    + 2*rAxis + dx, dx, wall, depth + 2*delta, 4*rAxis, false, true);
			}
		}

		// ось
		translate([-w/2 + 2*rAxis,  surfOffset + delta/2, dh])
			rotate(90, [1, 0, 0])
				cylinder(r = rAxis, h = 2* wall + depth + 3*delta);

		// фиксирующий болт
		translate([w/2 - dxFix, surfOffset +delta/2 + (rotate ? 0 : hDd),  dyFix ])
			rotate(90, [1, 0, 0])
//				rotate(30)
					bolt(rBolt, 2* wall + depth + 3*delta + hDd, rotate);

		// крепление к основанию
		translate([-dw/2, depth/2+delta + tune/2, -bHeight-delta])
			screws(scr, bHeight/2+delta, bHeight, w-dw, totalDepth - wall +tune);	


		// сверлим полости
		for(i = [-1: 1])
			translate([i * (2*rHole + wall)- wall/4, surfOffset, -bHeight/2 - wall/3])
				rotate(90, [1, 0 ,0])
					rotate(180)
						repRapLogo(rHole, totalDepth, delta);

		// продольная полость
		translate([w/2 - dw, depth/2 + delta, -bHeight/2 - wall/3])
			rotate(90, [0, -1, 0])
				repRapLogo(rHole, w-dw, delta);
	}

//	color("red")
//	translate([0, -4, -10])
//		cube([mbase, 0.1, 0.1], true);

}

module screws(scr, scrH, H, l, w)
{
	dr = 1.2*scr[1];					//  подобрали отступ от кромок
	for (i=[-1, 1], j = [-1, 1])
		translate([ i *(l/2 - dr), j * (w/2 - dr), 0])
			screw(scr, scrH, H);
}

module slot(height, baseHeight, wall, l, width, rare = false, left = false, right = false)
{
	slot2(height, baseHeight, l + 2*wall, l, width);

	if (rare)
		rotate(180)
			translate([-width/2, 2*wall + l, baseHeight])			
				buttress(wall, width, height - baseHeight - width);
	if (left)
	{
		translate([0, -2*wall - l, baseHeight])			
				buttress(wall, 1.5*width, height - baseHeight, true);
		translate([0, -wall, baseHeight])			
				buttress(wall, 1.5*width, height - baseHeight, true);
	}
	if (right)
		rotate(180)
			translate([wall, 0, baseHeight])			
				buttress(wall, width, height - baseHeight - width, true);
}

module buttress(depth, width, height, inv = false)
{
	linear_extrude(height = height , center = false, convexity = 2, scale= inv ? [0,1] : [1, 0])
		square([width, depth]);
}

module slot2(H, h, L, l, w)
{
	translate([-w/2, -L, 0])
	difference()
	{	
		union()
		{
			cube([w, L, H-w/2]);
			translate([w/2, 0, H - w/2])
				rotate(90, [-1,0,0])
					cylinder(d = w, h = L);
		}
	
		translate([-delta/2, (L-l )/2, h])
			cube([w+delta, l, H-h+delta]);
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

module dremel(h, l0)
{
	sizes = [
	[-38],				// от первого значения нужна только координата
	[-32, 2.5, 2.5],	// фреза
	[0, 2, 2],			// ось фрезы
	[l0, 20, 20],		// шейка
	[25, 30, 30],		// тело за шейкой
	[40, 46, 43, true], // true -- переход с пред. значения конусом
	[55, 46, 43],
	[115, 46, 43]];

	color ("red")
	translate([0, l0/2, h])
		rotate(90, [-1, 0, 0])
			for (i = [1: len(sizes) -1])
			{
				translate([0, 0, -sizes[i][0]])
					cylinder(d1 = sizes[i][1], 
								d2 = sizes[i - (sizes[i][3] ? 1 : 0)][1], 
								h = sizes[i][0] - sizes[i-1][0]);
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