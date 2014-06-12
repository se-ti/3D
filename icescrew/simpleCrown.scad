// подшипник
// d=6 ?? 6
// D= 19.0
// h = 6;

delta = 0.1;


//antiTooth(7.65, 9.05 , 6.5);

R = 18.1 / 2;
r = (18.1 - 2.8 ) / 2;
h = 15;
th = 6.5;

$fn = 200;

simpleCrown(r, R, h, th, 1, true, true, false);

// внутренний / внешний радиусы, высота всей коронки, высота зуба, радиус сферы -- имитация резца, 'простота' -- имитировать резец, или обойтись
module simpleCrown(r, R, h, th, spR, simple, useHat, badIrbis = false)
{
	difference()
	{
		cylinder(r = R, h = h, $fn = 100);
		translate([0,0, -delta/2])
			cylinder(r = 2* r / 3, h = h + delta, $fn = 100);

		translate([0,0, h+ (useHat ? -2 : delta/8)])	
		union()
		{
			for (i = [0:3])
				rotate(90 *i, [0,0,1])
					if (simple)
						maTooth2(r, R, th, R-r, useHat, badIrbis);
					else
						minkowski()
						{
							antiTooth(r, R, th);
							sphere(r = spR, $fs=0.2, $fa=1);
						}
		}
	}
}




module maTooth(r, R, h, dx)
{
	difference()
	{
		antiTooth(r, R, h);
		ma(r, dx, h);
	}
}

module maTooth2(r, R, h, dx, useHat, irbis)
{
	hat = useHat ? 1 : 0;
//render()
	difference()
	{
		translate([0,0, -h])
			at2(R+delta, h, irbis);
		ma(r, dx, h+hat, hat);
	}
}

module ma(r, dx, h, hat= 0)
{
	translate([0,  0, hat - h - delta/2])
		scale([(r-dx) / r, 1, 1])
			cylinder(r = r, h = h + delta);
}

module at2(R, th, irbis)
{
	ga = 7; // угол атаки
	al = irbis ? atan(th / R) : 26.3; //25.8;	// угол задней поверхности
	vec = irbis ? [1, 0, 0] : [1, -1.5, 0];

	// вспомогательные величины
	tx = 4;
	tp = 1;
	td = 7;

//	intersection()
	{
//		cylinder(r=R, h= th);

		translate([0, -R, 0])
			difference()
			{
				translate([-0.2*R, 0, 0])
				cube([1.2*R, 1.2*R, th*1.5]);

				translate([0, 0, th])
					rotate(ga, [0, 1, 0])
						translate([-tx, -delta, -th/cos(ga)-tp])
							cube([tx, R+delta, th/cos(ga) +tp]);

				translate([-th * tan(ga), 0, 0])
			//	rotate(al2, [0,-1,0])
				//	translate([0,  0, 0])
						rotate(al, vec)
							translate([-0.3*R, -0.3*R,-td])
								 cube([2*R, 2*R, td]);
			}
	}

}

// зуб имеет высоту h, угол 90 гр, угол передней кромки (вид сверху) be, угол передней кромки (вид сбоку) ga
module antiTooth(r, R, h)
{
	be = 0; //22
	ga = 7;
/*
   [-R -h *tan(ga) , 0, -h]
	[-h*tan(ga), R*tan(be), R]
*/

	sibe = sin(be);
	cobe = cos(be);
	siga = sin(ga);
	coga = cos(ga);

//	rd = R - r + delta;

	compl = asin(R/r *sibe) - be ; // угол из центра на пересечение передней кромки и внутренней поверхности
	dr = R - r*cos(compl) + 8; // +4 -- запас, чтобы пересекались сектора соседних зубов.



   // S2 направляющих вектора
	// [- ctan(be), 1, 0]		
	// [  ctg(ga) , 0, 1]

//

 // 3*R и 2.1 -- подогнанные параметры :(

	polyhedron(points = [ [R, 0, 0], [3*R, -3*R, 0], [0, -R, 0], [-dr * tan(be) , -R + dr, 0],
								 [0 - h*tan(ga), -R, -h], [0 - h*tan(ga) - dr *tan(be), -R + dr, -h -dr*tan(be)*h/R+2.1]],

					faces = [ [0, 1, 2], [0, 2, 3], [1, 4, 2], [0,4,1], [0, 3, 5], [0, 5, 4], [2, 4, 3], [3, 4, 5] ],
					convexity = 4);
}