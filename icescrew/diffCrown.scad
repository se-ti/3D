use <common.scad>

delta = 0.1;
$fn = 25;


r0 = 3;	// радиус вала
rb = 1.5; // радиус фрезы / щупа
r = 8;	// внутренний радиус шаблона
R = 12;	// внешний радиус шаблона
H = 14; // высота всего шаблона
h = 2; // вынос втулки над базовой кромкой
th =6.5; // высота зуба
n = 4; 	// число зубьев
attack = 7; // угол атаки зуба
da = 5; // угол выноса ближней кромки
dh = 1; // высота выноса второй кромки
probeH = 2; // толщина головки щупа


crown(r0, rb, r, R, H, h, th, n, attack, da, dh, probeH);


module crown(r0, rb, r, R, H, h, th, n, attack, da, dh, probeH)
{
	// cложное вычисление углов, не спрашивайте как
	al = 90 - attack;
	dth = th-rb;

	l = 2 * 3.14 * R / n;
	l1 = l - rb + dth * tan(attack);

	sq = sqrt(dth * dth + l1 * l1);

	ga = acos(dth / sq);
	gabe = acos (-rb / sq);
	be = gabe - ga;
//	echo (gabe, ga, be); // !!! удачно попали в квадранты !

	d1 = rb / sin(be);
	d2 = rb / sin(al);

	x = l - d1 - d2;
	TH = l * dth / x;

	fn = $fn * n;
	echo(TH);

	difference()
	{
		translate([0,0, -H + th + h - rb /2])
		{
			difference()
			{
				cylinder(r= R, h = H, $fn = fn);
				translate([0, 0, -delta/2])
					cylinder(r = r0, h = H + delta, $fn = fn);
			}
		}

		union()
		{
			for (i = [0: n-1])
				rotate(360/n * i)
					tooth(r, R, TH, 360/n+attack, attack, rb, $fn, da, dh);
			
		}

		nuts(42, 3.05, r0+2, 2*R);	// 2*R вынос с большим запасом
	}

	// проверка попадания по высоте
/*	
	color ("red")
		translate([0, -R-2*delta, -rb])
			cube([0.1, 0.1, th]);
*/	
}

module tooth(r, R, th, angle, attack, rb, n, da, dh, probeH)
{
	// смещаем границу ближней и дальней зон наружу, следим, чтобы щуп всегда влез во внутреннюю щону

	rMid = max(r + (R-r) * 2 /3, r+probeH + 2*delta); // 2*delta -- запас на грязь
	// затылок
	for (i = [0: n])
		rotate(angle/n * i)
			translate([0,0, th/n*i])
				bor((r*(n-i) + rMid * i) / n, rb);

	// дальняя часть вертикали
	for (i = [0: n])
		rotate(attack/n * i)
			translate([0,0, (th+dh)/n*i])
				bor(r, rb, rMid - r);  //(R-r)/2

	// ближняя часть вертикали
	for (i = [0: n])
		rotate((attack+da)/n * i)
			translate([0,0, th/n*i])
				bor(rMid -delta, rb);
	
	// горизонталь
	for (i = [0: n])
		rotate(attack +(angle - 2* attack)/n * i)
			translate([0,0, th])	// должно быть + dh, но хватает и так
				bor(r, rb);
}


module bor(dx, rb=1.5, h=10)
{
	translate([dx, 0, 0])
	{
		rotate(90, [0, 1, 0])
			cylinder(r = rb, h = h);
		cube([h, 1, 5]);				// просто высекаем лишнее, отследить на больших углах атаки / малых диаметрах
	}
}