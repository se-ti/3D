delta = 0.1;
$fn = 100;


// параметры бормашины: захват д = 20 л = 8, от захвата до режущей кромки -- 32-54 мм, длина режущей кромки -- 6 мм, диаметр ~2,5

// размеры по сечениям от передней кромки
//смещение	      	0	25	55	115	130
//диаметр	высоте	20	30	46	46	
//	      ширине		20	30	43	43	



r= 15;
R = 20;
r0 = 20 / 2;	// радиус шейки бора 
l0 = 8;
h = 35;			// не обязательно делать на всю высоту

rBolt = 4;	// силовой винт
rBolt2 = 2; // фиксирующие винты

rAxis = 3; // каленая ось вращения


depth = 20;



mbase = 42;
head(r0 + 4*rBolt2, l0, r0, rBolt2, rAxis, mbase);
base(mbase, depth, r0, rBolt2, rAxis);





/*
intersection()
{
	union ()
	{
		support(r, R, r0, h, rBolt, rBolt2);
		
		translate([ 0, 0, h+3*delta])
			head(r, r0, rBolt2);
	}
	union()
	{
		translate([0, l0, h])
			cube([2*R, l0, 2*h], true);
		translate([0,0, (h-r0) /2])
		cube([2*R, 2*R, h-r0], true);
	}
}*/

bor(h, l0);



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

module base(mBase, depth, r0, rBolt, rAxis)
{
	angle = 30;
	translate([0, -l0-depth/2, 0])
	difference()
	{
		cube ([mBase + 2*(rBolt + rAxis), depth, 2*(r0 + rBolt + rAxis)], true);
		translate([-mBase/2, -delta/2 - depth/2, -mBase/2 * sin(angle)])
			rotate(90, [-1, 0, 0])
				cylinder(r = rAxis, h = depth + delta);

		translate([mBase/2 - mBase*(1- cos(angle)), -delta/2 - depth/2, mBase/2 * sin(angle)])
			rotate(90, [-1, 0, 0])
				cylinder(r = rBolt, h = depth + delta);
	}

	color("red")
	translate([0, -4, -10])
		cube([mbase, 0.1, 0.1], true);

}

module head(r, l, r0, rBolt2, rAxis, base)
{
	angle = 30;
	rAxis = 3;

	offset = r0 + 2*rBolt2;
	h = (r0 + rBolt2 + rAxis) * 2;
	w = max(2*r, base + 2*(rBolt2+ rAxis));

	difference()
	{
		cube([w, l, h], true);
		translate([-w/4 + delta/2, 0, 0])
			cube([w/2+ delta, l+ delta, 2*delta], true);	// 2*delta -- зазор на стяжку

		rotate(90, [1, 0, 0])
			translate([0, 0, -r -delta/2])  
				translate([0,0, - delta/2])
					cylinder(r = r0, h = 2*r + delta);

		translate([-offset, 0, -h/2 -delta/2])
			bolt(rBolt2, h+ delta);

		translate([-base/2, l0 /2 + delta/2, -r0])
			rotate(90, [1, 0, 0])
				tuner(base, rBolt2, rAxis, l0 + delta, angle);
	}
}


module tuner(r, rBolt, rAxis, h, angle)
{
	cylinder(r= rAxis, h = h);
	sector(r-rBolt, r+rBolt, h, angle);
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