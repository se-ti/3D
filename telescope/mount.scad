
debug = true;

delta = 0.01;

width = 65;
height = 150;
thick = 6;
wall = 4;
rWnd = 10;
wndX = 10;
wndY = 0;

shiftY = 13;

$fn = 50;

oH = 30;
or = 30/2;  // ocular radius


// m3
rbolt = 1.5 + 0.1;
rboltHead = 5.5 / 2 + delta + 0.1;
rbHeadThick = 2;

k = 2 / sqrt(3);


/* p smart
72.05x150.10x7.45 мм

185px x 380
(25;20) (48;20) центры объективов, размер: 20х20



65-110 + 131-152 -- боковые клавиши
*/


//nutSet(30, 6, 9, 10, 4);
body();

mirror([0, 0, 1])
translate([wall + rboltHead + 14, or + wall + rbolt + rboltHead * k - shiftY, 1]) {
    rotate(180, [0, 0, 1])
        half();
    half();
}



module body() {
    slide = 5;
    minLen = 2 * (or + wall + rbolt);   

    difference() {
        union() {
            cube([width + wall, height + wall, thick + wall]);
            translate([0, -shiftY, 0])
            cube([width + wall, shiftY, wall]);
        }
        
        translate([wall, wall, wall])
            cube([width + delta, height + delta, thick+delta]);
         
        translate([rbolt + rWnd + 2*rboltHead, wall + rWnd, wall / 2]) // window
            minkowski() {
                cube([rWnd, rWnd, wall], true);
                translate([0, 0, -delta/2])
                    cylinder(r = 5, h = delta);
                //cylinder(r = rWnd, h = wall + delta);
            }
        
        translate([rbolt + rboltHead + rbolt, rboltHead * k -shiftY /*+ wall*/, 0])
            rotate(90, [0, 0, 1])
                pair(slide, rbolt, rboltHead, wall + thick, wall + thick - 2, minLen);
        
        translate([rbolt + 3*rboltHead + rbolt + rWnd*2, rboltHead * k -shiftY /*+ wall-2*/ , 0])
            rotate(90, [0, 0, 1])
                pair(slide, rbolt, rboltHead, wall + thick, wall + thick - 2, minLen);
    }
    
    if (debug)    // объективы    
        color("red")
            translate([wall, wall, wall])
                objectif(or + 1);        
}



module half() {
    ex = 10;
    ey = 3*rbolt;
    
    halfY = or + wall + ey;
    
    
    difference() {
        union() {
            difference() {
                translate([0, -halfY, 0])
                    cube([or+wall+ ex, 2 * halfY, wall]);
                
                translate([2*rbolt, -rbolt + halfY - 2* rbolt, -delta/2])
                    semiSet(or + wall + ex - 4*rbolt, rbolt, wall +delta);
                
                translate([2*rbolt, -rbolt - halfY + 2* rbolt, -delta/2])
                    semiSet(or + wall + ex - 4*rbolt, rbolt, wall + delta);
            }
            cylinder(h = oH, r = or + wall);
        }
        translate([0, 0, -delta/2])
            cylinder(h = oH + delta, r = or);
        
        translate([-or-wall, - halfY -delta/2, -delta/2])
            cube([or+wall+delta + 0.5, 2*halfY + delta , oH + delta]);
    }

    if (debug)
        cylinder(r = 0.1, h = oH); // axis
}



module pair (len0, r0, r2, thick, thick2, dX) {
    nutSet(len0, r0, r2, thick, thick2);
    
    translate ([dX, 0, 0])
        nutSet(len0, r0, r2, thick, thick2);
}



module nutSet(len, r0, r2, thick, thick2) {
    semiSet(len, r0, thick);
    translate([0, r0-r2, thick-thick2])
        semiSet(len, r2, thick2, true);
        
}

module semiSet(len, r, thick, bolt = false) {
    cube([len, 2*r, thick]);
    
    r2 = bolt ? r * 2 / sqrt(3) : r; 
    fn = bolt ? 6 : $fn;
    
    translate([0, r, 0])
        cylinder(r=r2, h=thick, $fn = fn);
    translate([len, r, 0])
        cylinder(r=r2, h=thick, $fn = fn);
}

module objectif(rLense) {
    k = 150.1 / 380;
    k = 72.05 / 185;
    
    r0 = 10 * k;
    //r0 = rLense;
    
    hull() {
        translate([25*k, 20*k, 0])
            cylinder(r = r0, h = 2);
        translate([48*k, 20*k, 0])
            cylinder(r = r0, h = 2);
    }
}
