$fn = 100;
delta = 0.1;

r0 = 3;	// радиус вала
r = 5;	// внутренний радиус вала
R = 9;	// внешний радиус шаблона
H = 10; // высота всего шаблона
h = 2; // вынос втулки над базовой кромкой
th =6.5; // высота зуба
n = 4; 	// число зубьев
attack = 7; // угол атаки зуба
da = 5; // угол выноса ближней кромки
dh = 1; // высота выноса второй кромки


crown(r0, r, R, H, h, th, n, attack, da, dh);


module crown(r0, r, R, H, h, th, n, attack, da, dh)
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
			render()
				main(r, R, h, alpha, beta, n, i, scale);
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
				cylinder(r = R, h = h);
		}
		translate([0,0, -delta/2])
			cylinder (r= r, h = h +delta);
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
			cov(m0 + vec * i / n, m0 + vec * (i+1) / n, i);
	}
}

module cov(m0, m1, i)
{
	 strange(m1[0][0], m1[0][1], m1[0][2],m1[1][0], m1[1][1], m1[1][2], m1[2][0], m1[2][1], m1[2][2], m1[3][0], m1[3][1], m1[3][2], 
				m0[0][0], m0[0][1], m0[0][2],m0[1][0], m0[1][1], m0[1][2], m0[2][0], m0[2][1], m0[2][2], m0[3][0], m0[3][1], m0[3][2]);
}

module main(r, R, h, al, be, n, i, scale = 1)
{
	h0 = h * i / n;
	h1 = h * (i+1) / n;

	r0 = r * ( n - i + scale* i) / n;
	r1 = r * (n - i - 1 + scale* (i + 1)) / n;

	R0 = R * ( n - i + scale* i) / n;
	R1 = R * (n - i - 1 + scale* (i + 1)) / n;
	

	at0 = al * i / n;
	at1 = al * (i+1) / n;

	ab0 = (al - be) * i / n;
	ab1 = (al - be) * (i+1) / n;

	strange(r0*sin(at0), r0*cos(at0), h0, r1*sin(at1), r1*cos(at1), h1, R1*sin(at1), R1*cos(at1), h1, R0*sin(at0), R0*cos(at0),h0,
				r0*sin(ab0), r0*cos(ab0), 0,	r1*sin(ab1), r1*cos(ab1), 0,	R1*sin(ab1), R1*cos(ab1), 0,	R0*sin(ab0), R0*cos(ab0), 0);
}

// просто многогранник с согласующимися диагоналями, который можно лепить к самому себе без полостей
module strange(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, 
					x5, y5, z5, x6, y6, z6, x7, y7, z7, x8, y8, z8)
{
	points = [[x1, y1, z1], [x2, y2, z2], [x3, y3, z3], [x4, y4, z4], 
					[x5, y5, z5], [x6, y6, z6], [x7, y7, z7], [x8, y8, z8]];
	faces = [[0, 1, 2], [0, 2, 3], [0, 4, 5 ], [0, 5, 1], [1, 5, 6], [2, 1, 6], 
				[2, 6, 3], [3, 6, 7], [0, 3, 7], [0, 7, 4], [5, 4, 6], [4, 7, 6]];

	polyhedron(points = points, faces = faces, confexity = 4);

}