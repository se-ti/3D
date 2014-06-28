delta = 0.1;
$fn = 100;


// параметры бормашины: захват д = 20 л = 8, от захвата до режущей кромки -- 32-54 мм, длина режущей кромки -- 6 мм, диаметр ~2,5

// размеры по сечениям от передней кромки
//смещение	      	0	25	55	115	130
//диаметр	высоте	20	30	46	46	
//	      ширине		20	30	43	43	




r0 = 20 / 2;	// радиус шейки бора 
l0 = 8;			// толщина захвата
level = 35;			// не обязательно делать на всю высоту

rBolt2 = 2; // фиксирующие винты (m4)
rAxis = 3; // каленая ось вращения


depth = 20;	// глубина основания

mbase = 46; // радиус дуги высотной регулировки
angle = 30;	// угол дуги
bAngle = 8; // угол смещения




head(l0, r0, rBolt2, rAxis, mbase, angle, bAngle);
base(l0, r0, rBolt2, rAxis, mbase, angle, bAngle, depth);

bor(0, l0);

//dx = 3;
//translate([10, -depth/2 +l0/2 + dx+delta, 0])
	//slot(4*rAxis, depth, 2*r0 + 2*(rBolt2 + rAxis), rBolt2, 6, l0 + 2*delta, dx);

//translate([-15, -depth/2 +l0/2 + dx+delta, - r0 - rBolt2 - rAxis + 2*rAxis])
	//slot(4*rAxis, depth, 4* rAxis, rAxis, 6, l0 + 2*delta, dx);



module base(depth, r0, rBolt, rAxis, base, angle, bAngle, depth2)
{
	sz = size(r0, base, angle, bAngle, rAxis, rBolt, depth);

	w = sz[0]; 
	h = sz[1]; 
	dp = sz[2];
	dh = sz[3];


	wall = 5;
	bHeight = level - h/2;
	dx = bHeight;


	translate([0, -depth/2-depth2/2 - delta, 0])
	difference()
	{
		union()
		{
			translate([0,0, -bHeight/2-h/2])
				cube ([w, depth2, bHeight], true);

			translate([0, wall + dp + 2*delta + depth2/2, -dx-h/2])
			{
				translate([w/2 - 2*rBolt - base*(1-cos(angle - bAngle)), 0, 0])
					slot2(h+dx, dx, wall+depth + 2*delta, wall, 4*rBolt);

				translate([-w/2 + 2*rAxis, 0, 0])
					slot2(dh+dx + 2*rAxis, dx, wall+depth + 2*delta, wall, 4*rAxis);
			}
		}

		translate([-w/2 + 2*rAxis, -delta/2 - depth/2, -h/2 + dh])
			rotate(90, [-1, 0, 0])
				cylinder(r = rAxis, h = 10*depth + delta);

		translate([w/2 - 2*rBolt - base*(1-cos(angle - bAngle)), -delta/2 - depth/2, h/2 -2*rBolt])
			rotate(90, [-1, 0, 0])
				cylinder(r = rBolt, h = 10*depth + delta);
	}

//	color("red")
//	translate([0, -4, -10])
//		cube([mbase, 0.1, 0.1], true);

}



module slot2(H, h, L, l, w)
{
	rotate(180)
	translate([-w/2, 0, 0])
	{	
		cube([w, l, H]);
		cube([w, L, h]);
		translate([0,L,0])
			cube([w, l, H]);
	}
}

module slot(l, w, h, r, dh, wdt, dx)
{
	difference()
	{
		cube([l, w, h], true);
		
		translate([0, w/2-wdt/2 - dx, h/2-(h-dh) /2 + delta/2])
			cube([l + delta, wdt, h-dh + delta], true);

		rotate(90, [1,0,0])
			translate([0, +h/2 -2*r, -delta/2 - w/2])
				cylinder(r = r, h = w+delta);
	}
}


function size(r0, base, angle, bAngle, rAxis, rBolt, depth ) = 
	[
		max(2*(r0 + 2*rAxis + 2*rBolt), base + 2 * (rAxis + rBolt)), // длина
      max(2*(r0 + rBolt + rAxis), 4*rBolt + base*(sin(bAngle) + sin(angle-bAngle))),// высота
		max(depth, 4*rBolt),							// толщина
		base * sin(bAngle) + 2*rBolt				// смещение оси вверх 
	];


module head(l, r0, rBolt2, rAxis, base, angle, bAngle)
{
	sz = size(r0, base, angle, bAngle, rAxis, rBolt2, l);

	w = sz[0]; 
	h = sz[1]; 
	dp = sz[2];
	dh = sz[3];

	offset = r0 + 2*rBolt2;

	difference()
	{
		cube([w, dp, h], true);
		translate([-w/4 + delta/2, 0, 0])
			cube([w/2+ delta, dp + delta, 2*delta], true);	// 2*delta -- зазор на стяжку

		rotate(90, [1, 0, 0])
			translate([0, 0, -dp/2 -delta/2])  
				cylinder(r = r0, h = dp + delta);

		translate([-offset, 0, -h/2 -delta/2])
			bolt(rBolt2, h+ delta);

		translate([-w/2 + 2*rAxis, dp /2 + delta/2, -h/2 + dh])
			rotate(90, [1, 0, 0])				
				tuner(base, rBolt2, rAxis, dp + delta, angle, bAngle);
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


module bor(h, l0)
{
	l = 32;

	color ("red")
	translate([0, l0/2, h])
		rotate(90, [-1, 0, 0])
		{
			//  бор и головка
			cylinder(r= 1, h = l);
			translate([0,0,l])
				cylinder(d = 2.5, h = 6);
	
			translate([0,0,-l0])			// шейка
				cylinder(d = 20, h = l0);
			translate([0,0, - 25])			// тело за шейкой
				cylinder(d = 30, h = 25 - l0);
			translate([0,0, - 55])			// тело за шейкой
				cylinder(d = 36, h = 55 - 25 );
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