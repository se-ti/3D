
debug = true;

delta = 0.01;

width = 65;
height = 118;
thick = 7;
wall = 4;
rWnd = 10;

btnDepth = wall + delta; // кнопочки надо нажимать руками

shift = 12;
shiftX = 14;

$fn = 50;

// ocular mount
oH = 20;
or = 30/2;  // ocular radius
ex = 6;
oey = 7;


// m3 // 0.1 -- запас на точность печати
rbolt = 1.5 + 0.1;
rboltHead = 5.5 / 2 + 0.1;
rbHeadThick = 2.2;



/* p smart
72.05x150.10x7.45 мм

185px x 380
(25;20) (48;20) центры объективов, размер: 20х20

65-110 + 131-152 -- боковые клавиши


iphone 
67.10x138.30x7.10
325x671

(68x31)

34x34
echo (kMod * 65);
echo (kMod * 152);

echo (iMod* 68);
echo (iMod* 31);
*/

kMod = 150.1 / 380;
kMod = 72.05 / 185;

iMod = 138.3 / 671;


body();

if (debug)
mirror([0, 0, 1])
translate([or + wall + rboltHead + 2 * rbolt - shiftX + oey +7, 
           or + wall + rboltHead - rbolt     - shift  + ex -6,       1]) 
{
    rotate([0, 0, 90])
        half();
    rotate([0, 0, 270])
        half();
}
else {
    mntY2 = (or + wall + oey + 3 * rbolt);
    translate([width + wall + 10, mntY2 - shift, 0])
        half();
    translate([width + wall + 10, 3*mntY2 - shift + 5, 0])
        half();
}



module body() {
    slide = 8;
    minLen = 2 * (or + wall + rbolt + oey);
    
    extX = 6;
    extY = 4;
    
    kWave = 0.6;
    rWave = 4;

    difference() {
        union() {
            cube([width + wall, height + wall, thick + wall]);
            translate([-shiftX, -shift, 0])
            cube([width + wall + shiftX, height + wall + shift, wall]);
        }
        
        translate([wall, wall, wall])
            cube([width + delta, height + delta, thick+delta]);
         
        translate([wall + kMod * 48-1.5, wall + kMod * 20, wall / 2]) // window
            minkowski() {
                cube([extX, extY, wall], true);
                translate([0, 0, -delta/2])
                    cylinder(r = or + 1, h = delta + 1.5*wall);
            }

        translate([wall - btnDepth, wall + kMod * 56, wall])       // side buttons
            cube([btnDepth + delta, kMod*(160 - 56), thick + delta]);
            
        translate([rbolt + rboltHead - shiftX, rboltHead -shift, -delta/2])            // nut holes
            pair(slide, rbolt, rboltHead, wall + thick + delta, thick + rbHeadThick  + delta/2, minLen);
            
        translate([rbolt + rboltHead - shiftX, rboltHead -shift + or + wall + ex, -delta/2])
            pair(slide, rbolt, rboltHead, wall + thick + delta, thick + rbHeadThick + delta/2, minLen);
            
        translate([-shiftX, wall + 2* or + extY, -delta/2]) {   // extra area
            wave(rWave, shiftX, wall + delta, kWave);
            translate([0, 2*rWave, ])
                cube([shiftX, height + wall - 2 * rWave,  wall + delta]);
        }
        
        
        for (i = [0: 4])
            translate([width + wall, wall + 2* or + extY + i * (4 + 4*rWave), -delta/2])
                mirror([1, 0, 0])
                    wave(rWave, i % 2 == 0 ? 12: 8, wall + delta, kWave);
    }

    
    if (debug)
        translate([wall + kMod * 48, wall + kMod * 20, wall / 2]) // window axis
            cylinder(r = 0.2, h = 10);
    
    if (debug)
        translate([wall + kMod * 48-1, wall + kMod * 20, wall / 2]) // window
            cube([extX+ 2, extY + 2, wall], true);
    
    if (debug)    // объективы    
        color("red")
            translate([wall, wall, wall])
                objectif(or + 1, kMod);        
    
    if (debug)    // объективы    
        color("red")
            translate([wall, wall, wall])
                objectifI(or + 1, iMod); 
}



module half() {
    ey = 3*rbolt + oey;   
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

module objectif(rLense, kMod) {   
    r0 = 10 * kMod;
    //r0 = rLense;
    r0 = 0.2;
    
    hull() {
        translate([25*kMod, 20*kMod, 0])
            cylinder(r = r0, h = 2);
        translate([48*kMod, 20*kMod, 0])
            cylinder(r = r0, h = 2);
    }
}

module objectifI(rLense, kMod) {
    r0 = 0.2;
    translate([68*kMod, 31*kMod, 0])
        cylinder(r = r0, h = 2);
}

module wave(r, length, h, k = 0.4) {
   
    dx = length - 2*r *k;
    translate([r *k+dx, 2*r, 0])
        scale([k, 1, 1])
            cylinder(r = r, h = h);
    translate([0, r, 0])
        cube([r*k + dx, 2*r, h]);
    
    difference() {
        cube([r*k, r, h]);
        translate([r*k, 0, 0])
            scale([k, 1, 1])
            cylinder(r = r, h = h);
    }
    
    translate([0, 3*r, 0])
    difference() {
        cube([r*k, r, h]);
        translate([r*k, r, 0])
            scale([k, 1, 1])
            cylinder(r = r, h = h);
    }
    
}
