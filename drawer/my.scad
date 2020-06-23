//use <ring.scad>

simple = true;
useRing = false;

// для красоты визуализации, чтобы исчезали грани нулевой толщины
delta = 0.01; // 0.1 или 0
d2 = delta / 2;

module inner()
{		
    wh = 10;
    h = 9.3;
    
	difference()
	{
		translate([h/2, 0, 0])
			cube([h, wh, wh], center=true);

// основной паз
        depth = 6;
		translate([h - (depth-delta) / 2, 0, 0])
			cube([depth+delta, wh+delta, 3.5], center=true);


// 4 необязательных выемки
		if (!simple)
		{
            dx = 2.3 + 3.5 + d2;
            dz = 3 + 1 + d2;
            vec = [7 + delta, 2.4, 2 + delta];
            
			translate([dx, -1.1 - 1.2, dz])
				cube(vec, center=true);
			translate([dx,  1.1 + 1.2, dz])
				cube(vec, center=true);
	
			translate([dx, -1.1 - 1.2, -dz])
				cube(vec, center=true);
			translate([dx,  1.1 + 1.2, -dz])
				cube(vec, center=true);
		}
	}
}

module outer()
{
	sz = 7;
	szBase = 6.9; // квадрат, вставляющийся в направляющую
    baseH = 1.5;
	r = 3.4;

    H = 5;    	// высота полуоси с замком
    ri = 1.8; 	// радиус вн. отверстия в оси		// 2   // правки от 4.11
	dpt = 3.5;	// глубина прорези					// 3.2
	union()
	{
		translate([-baseH/2, 0, 0])
			cube([baseH, szBase, szBase], center = true);
		translate([-baseH, 0, 0])
			rotate(a = 90, v = [0, -1, 0])
				intersection()
                {
					difference()
					{	
						union()		// ось с замком
						{
							cylinder(h = 5, r = r);
							translate([0, 0, 3.3])
								cylinder(h = 1.7, r1 = 4.1, r2 = r);
						}

						translate([0, 0, 0.4])							// глухое отверстие в "оси"
							cylinder(h = 4.6 + delta, r = ri);		
						translate([0, 0, H - dpt/2 + d2])					// прорезь
							cube([1.3, 2 * r + delta, dpt + delta], center = true);
					}
					translate([0, 0, H/2 + d2])
						cube([sz, 2 * r, H + delta], center = true);
				}
	}
}

$fn = 200;

H = 2.9;
h = 0.4;
r2 = 3.5; 
rotate(a = 90, v = [0, 1, 0])
rotate(a = 90, v = [1, 0, 0])
	union()
	{
		inner();
		outer();
		if (useRing)
		{			
			rotate(a = 90, v = [0, 1, 0])
				translate([0, 0, -1.5 - H - delta])
					ring(h = h); 
		}
	}
