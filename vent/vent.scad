

$thick = 3;
$w = 30;
$len = 350;
$dl = 1;

$hole = $w /2 - 2*$dl;

$inc = 20;

$fanThick = 15;
$hat = 50;

$base = $inc + $thick + $fanThick;

/*#color("red")translate([0, 0, ($w + $dl)/2])  rotate(90, [1, 0, 0]) mem(); 
translate([$len/2, -$base, 0]) rotate(-90, [0, 1, 0]) side();
translate([-$len/2, -$base, 0]) rotate(-90, [0, 1, 0]) side();
translate([0, ($hat -$base) /2, $w + $dl+ $thick /2]) top();
translate ([0, - $base/2, 0]) bottom();*/

mem();
translate([$len /2 + 2 * $thick, $thick, 0]) side();
mirror([0, 1, 0]) translate([$len /2 + 2* $thick, $thick, 0]) side();
translate([0, -$w -$hat, 0]) top();
translate([0, $w + $base, 0]) bottom();




module side() {
   
    polygon([[0, $base], [0,0], [$w+$dl, 0], [$w+$dl, $base + $hat]]);    
}

module top() {
    square([$len + 2*$thick, $base + $hat], true);
}

module bottom() {
    square([$len + 2*$thick, $base], true);
}



module mem() {
    difference() // мембрана
    {
        square([$len, $w + $dl], true);
        circle($hole);
        translate([$len /4 , 0, 0]) circle($hole);
        translate([-$len /4 , 0, 0]) circle($hole);
    }
}

