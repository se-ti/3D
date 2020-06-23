// R1 R2 -- большой и малый радиусы внешнего конуса
// r1 r2 -- большой и малый радиусы внутреннего конуса
// H - высота кольца
// h - высота цилиндрической части

module ring(R1 = 6.6, R2 = 5.7, r1 = 5.25, r2 = 3.5, H = 2.9, h = 0.4)
{
    delta = 0.1;
    difference()
    {
        cylinder(H, R2, R1); 
        translate([0, 0, h])
            cylinder(H - h + delta, r2, r2 + (r1 - r2) * (H - h + delta) / (H - h));
        translate([0, 0, -delta / 2])
            cylinder(h + delta, r2, r2);
    }
}
$fn = 200;

ring();
