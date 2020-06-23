
module mKernel(R, r, part = 0)
{
	mkr = 0.001;

	translate([0, 0, -mkr/2])
	intersection()
	{
		if (R == r)
			sphere(r = R, $fn = max($fn, 20));
		else
			minkowski()
			{
				cylinder(h = mkr, r = R-r-mkr);
				sphere(r = r-mkr, $fn = max($fn, 20));
			}
		if (part != 0)
			translate([0,0, (part-1) * r])
				cylinder(h = 2*r, r = R);
	}
}


//module thread(R, r, h, angle)
//{
//	intersection()
//	{
//		translate([0, -(R+delta) * sin(angle/2),0])
//			cube([R + delta, 2*(R+delta) * sin(angle/2), h]); // первое приближение
//		difference()
//		{
//			cylinder(h, r = R + delta);
//			translate([0,0,-delta/2])
//				cylinder(h+delta, r = r);
//		}
//	}		
//}


// имитация резьбы. работает лишь на небольших углах
module fthread(R, r, h, angle, step)
{
	mcr = 0.01;
 	mkr = .05;

	th = step * angle / 360;
	sq2 = (R-r) * sqrt(2)/2;
		
	minkowski()
	{
		// тоненький виточек
		rotate(angle /2, [0, 0, -1])	
			linear_extrude(height = th, center = false, convexity = 10, twist = -angle, slices = 30)
				translate([R-mcr, -mcr/2])
					square([mcr, mcr]);
		
		// типа профиль резьбы
		rotate(90, [1, 0, 0])
			linear_extrude(height = mkr, center = true, convexity = 10, twist = 0, slices = 10)
				polygon(points = [[0, 0], [0, h - mcr + sq2], [r-R - mcr, h - mcr + sq2], [r-R - mcr, sq2 - mcr]], 
							paths = [[0, 1, 2, 3]], 
							convexity = 6);
	}		
}

module threads(n, R, r, h, step, angle)
{
	intersection()
	{	
		for(i = [0: n-1])
			rotate(360 / n * i, [0,0,1])
				translate([0,0, i*step/n])
					fthread(R, r, h, angle, step);
	
		difference()
		{
			cylinder(h + step, r = R + delta, $fn = altFn);
			translate([0,0,-delta/2])
				cylinder(h + step +delta, r = r, $fn = altFn);
		}
	}
}

module holes(R, rh, h, n)
{
	intersection()
	{
		for(i = [0: n-1])
			rotate(360 / n * i, [0,0,1])
				translate([R, 0, 0])
					cylinder(h, r = rh, $fn = altFn);
		
		cylinder(h, r = R, $fn = altFn);
	}
}

module cones(r, n, Rc, rc, H, mR, mr)
{
	for (i = [0 : n-1])
		rotate(i * 360 / n, [0,0,1] )	
			translate([r, 0, H / 7])
				minkowski()
				{
					scale([1, 2.5, 1])
						cylinder(r1 = rc, r2 = Rc, h = H * 6 / 7);
					mKernel(mR, mr, -1);
				}
}

module screwCap(r0, h, st, tst, R, H, n, addThread = false, debug = true)
{
	r = r0 + 0.12; // допуск на ошибки измерений и т.п.

	s = R-r;	// столщина стенки
	mR = 1;	// кривизна боков / дна
	mr = 1;

	nc = 6;	// число конусов
	Rc = 1.1;// радиусы конусов
	rc = 0.4;

	rH = r/2; // радиус вырезов в дне ~r/2 4
	nH = 3; // количество вырезов

	angle = 35; // сектор резьбы
	th = 3.5; 		// высота основной части сектора

	union()
	{
		difference()
		{
			if (debug)
				union()
				{
					cylinder(r=R, H, $fn = altFn);
					cones(R, nc, Rc, rc, H, mR, mr);
				}
			else					// очень долго считает :(
				translate([0, 0, mr])
					union()
					{
						minkowski()
						{
							cylinder(r = R-mR, H-mr, $fn = altFn);
							mKernel(mR, mr, -1);
						}
						cones(R-mR, nc, Rc, rc, H-mr, mR, mr);
					}
	
			translate([0, 0, s])
				cylinder(H-s + delta, r=r, $fn = altFn);
			translate([0, 0, -delta/2])
				holes(r, rH, s+delta, nH);
		}

		if (addThread)		
			translate ([0, 0, max(tst, (H - st - s)/2) + s])
				threads(n, r + delta, r - h, th, st, angle); // чтобы точно вклеился
	}
}

module arrayCap(arr, at = false, debug = true)
{
	screwCap(arr[0]/2, arr[0]/2 - arr[1]/2, arr[2], arr[3], arr[4]/2, arr[5], n, at, debug);
}

delta = 0.1;

r = 8.5; // внешний радиус по резьбе
R = 10;	// внешний радиус колпачка
h = 1.5;	// высота резьбы
H = 20;	// высота колпачка

n = 3;	// число секторов с резьбой
st = 10;	// шаг резьбы
tst = 9; //


$fn = 20;
altFn = max($fn, 50); // $fn для крупных деталей


//screwCap(r, h, st, R, H, n, true, true);

arrayCap(types[3], true, false);


types = [
// D 		-диаметр по резьбе
// d 		- диаметр ствола
// st 	- шаг резьбы
// tst	- начало резьбы от кончика
// Dcap 	- диаметр основной части 
// H		- высота колпачка

//[D,  d, 	 st,tst,	Dcap, H],
[18, 	 16, 	 10, 	7,	20.5, 22],  // 0 Ирбис
[17.8, 16, 	 6, 	3,	20.5, 22],	// 1 Недоирбис
[21.1, 17.6, 6, 	9,	24,	23],	// 2 Ушба
[20.1, 17.2, 6.55, 8,24, 	23],	// 3 Гривель 360
[19.8, 17.4, 6.55, 8,24, 	23],	// 4 Simond
[22, 	 20.8, 6, 	7, 25.5,	23],	// 5 фирновый Шестминцев
[20, 	 17.8, 6, 	7, 23,	23]	// 6 Шестминцев - 20

//[, , , , ],	//
];
