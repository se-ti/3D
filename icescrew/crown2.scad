delta = 0.1;	
use <common.scad>

$fn = 40;


r0 = 3;	// радиус вала
r = 5;	// внутренний радиус шаблона
R = 9;	// внешний радиус шаблона
H = 10.5; // высота всего шаблона
h = 2; // вынос втулки над базовой кромкой
th =6.5; // высота зуба
n = 4; 	// число зубьев
attack = 7; // угол атаки зуба
da = 5; // угол выноса ближней кромки
dh = 1; // высота выноса второй кромки


crown(r0, r, R, H, h, th, n, attack, da, dh);


module crown(r0, r, R, H, h, th, n, attack, da, dh)
{
	difference()
	{
		union()
		{
			intersection()
			{
				union()
				{
					semiCrown(r, (R+r) /2, th, n, attack, 0, dh);
					semiCrown((R+r)/2, R+ 2* delta, th, n, attack, da, 0);
				}
				cylinder (r = R, h = th + dh, $fn = $fn * n);
			}		
			body(r0, r, R, H, h, th, n);
		}
		
		nuts(55, 0.8, r0 + 2);	// подобрать для другого числа зубов
	}
}

// add -- продлить спираль вперед на такой угол
// dh -- поднять зубец на такую высоту
module semiCrown(r, R, h, n, attack, add = 0, dh = 0)
{
	dlh = h * add / (360 / n + attack);
	union()
	{
		for (i = [0: n-1])
			rotate (360/n*i)
	  			step(r, R, h + dlh, -360 / n - attack - add, -attack - add, $fn, dh );
	}
}

module body(r0, r, R, h, dh, th, n)
{	
	dx = 0.8;	// смещения гаек м3 в основании
	dy = 2;

	$fn = $fn * n;

	difference()
	{
		union()
		{
			translate([0, 0, -h + th])
				cylinder(r = R, h = h - th + delta / 4); // delta /4 -- чтобы чуть-чуть пересеклось
			cylinder(r = r + delta/2, h = th + dh);
		}

		translate([0, 0, -h + th  + -delta/2])
			cylinder(r = r0, h = h + delta + dh);
	}
}


module step(r, R, h, alpha, beta, n=$fn, dh, extra = 0)
{
	scale = (r + extra) 	/ r;
	union()
	{	
		for (i = [0: n-1])
		{
			render()
				main(r, R, h, alpha, beta, n, i, scale);
		}
		cover(r, R, h, alpha, beta, n, scale, dh);
		
		if (dh > 0)
				render()
			rotate(alpha - beta)
				cover2(r, R, h , n);
	}
}


module cover2(r, R, h, n)
{
	difference()
	{
		intersection()
		{
			cube([R, R, h]);
			scale([r/R, 1, 1])
				cylinder(r = R, h = h, $fn = $fn * n);
		}
		translate([0,0, -delta/2])
			cylinder (r= r, h = h +delta, $fn = $fn * n);
	}
}


// закрываем искажения на лицевой грани, когда криволинейную поверхность приблизили 2 треугольниками
module cover(r, R, h, alpha, beta, n, scale, dh = 0)
{
	d = 2 * 3.14 * (r + R) / 2 / 360 * abs(alpha) / n;	// толщина слоя в середине кольца
	p = max (abs((R - r)/2 * sin(beta)), dh*1.1);							// оценка искажений на граничном слое

	depth = ceil(p/d) < 1 ? 1 : ceil(p/d);
	echo (depth);

	at0 = alpha * (n-depth) / n;
	ab0 = (alpha - beta) * (n-depth) / n;
	h0 = h * (n-depth) / n;

	r0 = r * ( depth + scale * (n-depth)) / n;
	r1 = r * scale;

	R0 = R * ( depth + scale * (n-depth)) / n;
	R1 = R * scale;

	v0 = [(sin(at0) - sin(ab0)) * r0, (cos(at0) - cos(ab0)) *r0, h0];
	v1 = [(sin(alpha) - sin (alpha - beta))*r1, (cos(alpha) - cos(alpha - beta))*r1, h ];
	v2 = [(sin(alpha) - sin (alpha - beta))*R1, (cos(alpha) - cos(alpha - beta))*R1, h];
	v3 = [(sin(at0) - sin(ab0)) * R0, (cos(at0) - cos(ab0)) *R0, h0];

	a0 = [sin(ab0)*r0, cos(ab0)*r0, 0];
	a1 = [sin(alpha-beta)*r1, cos(alpha-beta)*r1, 0];
	a2 = [sin(alpha-beta)*R1, cos(alpha-beta)*R1, 0];
	a3 = [sin(ab0)*R0, cos(ab0)*R0, 0];

	m0 =  [a0, a1, a2, a3];
	vec = [v0, v1, v2, v3];

	m = round(n * (h+dh) / h);

	union() 
	{
		for (i = [0 : m-1])
			cov(m0 + vec * i / n, m0 + vec * (i+1) / n);
	}
}

module cov(m0, m1, i)
{
	fStrange([m1[0], m1[3], m0[3], m0[0]], [m1[1], m1[2], m0[2], m0[1]]);
}

module main(r, R, h, al, be, n, i, scale = 1)
{
	fStrange(
		face0(r, R, h, al, be, i/n,     scale),
		face0(r, R, h, al, be, (i+1)/n, scale));
}

// просто многогранник с согласующимися диагоналями, который можно лепить к самому себе без полостей
module strange(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, 
					x5, y5, z5, x6, y6, z6, x7, y7, z7, x8, y8, z8)
{
	points = [[x1, y1, z1], [x2, y2, z2], [x3, y3, z3], [x4, y4, z4], 
					[x5, y5, z5], [x6, y6, z6], [x7, y7, z7], [x8, y8, z8]];
	faces = [[0, 1, 2], [0, 2, 3], [0, 4, 5 ], [0, 5, 1], [1, 5, 6], [2, 1, 6], 
				[2, 6, 3], [3, 6, 7], [0, 3, 7], [0, 7, 4], [5, 4, 6], [4, 7, 6]];

	polyhedron(points = points, faces = faces, convexity = 4);
}


// радиус-вектор
function rVec(r, al, h) = [r*sin(al), r*cos(al), h];


function face(r, R, alt, alb, ht, hb) = 
	[rVec(r, alt, ht), rVec(R, alt, ht), 
	 rVec(R, alb, hb), rVec(r, alb, hb)];

function face0(r, R, h, al, be, iOn, scale = 1) = 
	face( r* (1 + (scale - 1) * iOn), 
			R* (1 + (scale - 1) * iOn), 
			al * iOn, 
			(al - be) * iOn, 
			h * iOn,
			0);

// просто многогранник с согласующимися диагоналями, который можно лепить к самому себе без полостей
// f1 и f2 -- массивы из 4 точек r-top R-top R-bot r-bot
module fStrange(f1, f2)
{
	points = [f1[0], f2[0], f2[1], f1[1],
					f1[3], f2[3], f2[2], f1[2]];
	faces = [[0, 1, 2], [0, 2, 3], [0, 4, 5 ], [0, 5, 1], [1, 5, 6], [2, 1, 6], 
				[2, 6, 3], [3, 6, 7], [0, 3, 7], [0, 7, 4], [5, 4, 6], [4, 7, 6]];

	polyhedron(points = points, faces = faces, convexity = 4);
}