

$thick = 3;
$height = 30;
$w = 40;
$len = 350;
$dl = 1;

$hole = $w /2 - 2*$dl;

$inc = 20;

$fanThick = 15;
$hat = 60;

$base = $inc + $thick + $fanThick;
/*
#color("red")
    
    rotate(30, [1, 0, 0]) 
    translate([0, ($w + $dl)/2 + 10, 0])
    mem(); 
translate([$len/2, -$base, 0]) rotate(-90, [0, 1, 0]) side();
translate([-$len/2, -$base, 0]) rotate(-90, [0, 1, 0]) side();
translate([0, ($hat -$base) /2, $height + $thick /2]) top();
translate ([0, - $base/2, 0]) bottom();
/*/

mem();
translate([$len /2 + 2 * $thick, $thick, 0]) side();
mirror([0, 1, 0]) translate([$len /2 + 2* $thick, $thick, 0]) side();
translate([0, -$w -$hat, 0]) top();
translate([0, $w + $base, 0]) bottom();//*/




module side() {
   
    polygon([[0, $base], [0,0], [$height, 0], [$height, $base + $hat]]);    
}

module top() {
    square([$len + 2*$thick, $base + $hat], true);
}

module bottom() {
    square([$len + 2*$thick, $base], true);
}



module mem() {
    $w = 40;
    $ext = $dl+18;

    difference() // мембрана
    {
        square([$len, $w + $ext], true);
        translate([0, (-$ext + $dl) /2, 0]) {
        circle($hole);
        translate([$len /4 , 0, 0]) circle($hole);
        translate([-$len /4 , 0, 0]) circle($hole);}
    }
    //translate([0, (-$ext + $dl) / 2, 5.5]) cube([$w, $w, 10], true);
}

