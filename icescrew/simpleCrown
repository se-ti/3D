

delta = 0.1;


//antiTooth(7.65, 9.05 , 6.5);

R = 18.1 / 2;
r = (18.1 - 2.8 ) / 2;
h = 15;
th = 6.5;

//$fn = 100;

simpleCrown(r, R, h, th, 1, false);
%simpleCrown(r, R, h, th, 1, true);

// внутренний / внешний радиусы, высота всей коронки, высота зуба, радиус сферы -- имитация резца, 'простота' -- имитировать резец, или обойтись
module simpleCrown(r, R, h, th, spR, simple)
{
	difference()
	{
		cylinder(r = R, h = h, $fn = 100);
		translate([0,0, -delta/2])
			cylinder(r = r, h = h + delta, $fn = 100);

		translate([0,0, h + delta /8])
		union()
		{
			for (i = [0:3])
				rotate(90 *i, [0,0,1])
					if (simple)
						antiTooth(r, R, th);
					else
						minkowski()
						{
							antiTooth(r, R, th);
							sphere(r = spR, $fs=0.2, $fa=1);
						}
		}
	}
}


// зуб имеет высоту h, угол 90 гр, угол передней кромки (вид сверху) be, угол передней кромки (вид сбоку) ga
module antiTooth(r, R, h)
{
	be = 22;
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
	dr = R - r*cos(compl) + 4; // +4 -- запас, чтобы пересекались сектора соседних зубов.



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