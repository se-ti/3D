$fn = 100;
delta = 0.01;

ext = 0.5;    // запас на точность измерений
thick = 25; 

topWidth = 22.5;
width = topWidth + ext; // раствор по верхней кромке
dw = 1.5;
w2 = width + dw;  // раствор по нижней кромке
peakX = 17;         // точка излома
dh = 1.5;           // высоты изломов
dh2 = 0.5;

peak = peakX + 1.0 * ext*peakX/width;

height = 15; // высота раствора
wall = 3;
hand = 12;  // высота "ручки"
r = 2;      // радиус кривизны сопряжений


invCosAl = sqrt(peak * peak + dh*dh) / peak;



linear_extrude(height = thick) {    
    translate([wall, 0])
        difference() {
            offset(wall)
                polygon([[0, 0], [0, height], [peak, height + dh], [width, height + dh - dh2], [w2, 0], [w2, 0]]);
            polygon([[0, -delta], [0, height], [peak, height + dh], [width, height + dh - dh2], [w2, 0], [w2, -delta]]);  
            translate([-wall - delta / 2, -wall - delta])
              square([w2 + 2 * wall + delta, wall + delta]);
        }
        
    translate([0, height])
    difference() {
        polygon([[0, 0], [0, hand + wall], [wall + 2*r, hand + wall], [wall + 2 * r, dh * 2 * r / peak]]);
        
        translate([wall, wall * invCosAl])        
            offset(r = r)        
                offset(r = -r)
                    polygon([[0, 0], [0, hand + r], [peak, hand + r], [peak, dh]]);
    }
}