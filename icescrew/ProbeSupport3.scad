$fs=0.75;$fa=5;

delta = 0.1;

MainAxeHeight = 35;
ProbeDiameter = 3;
SupportLength=40;
SpringLength=27;
SupportRingDiameter=10;
BracketLength=9;
BracketWidth=10;



//blt = 5;

blt = bPar(1); // тип шурупа: 0 / 1 / 2

difference ()
{
	union ()
	{
	support(MainAxeHeight, ProbeDiameter, BracketWidth, SupportRingDiameter, BracketLength, blt);
	translate ([0,0,SupportLength-BracketLength])
		support(MainAxeHeight, ProbeDiameter, BracketWidth, SupportRingDiameter, BracketLength, blt);
	translate ([0,0,BracketLength])
		support(MainAxeHeight, ProbeDiameter,SupportLength-2*BracketLength , SupportRingDiameter, 0, blt);
	}
translate ([0,0,(SupportLength-SpringLength)/2])
	cylinder (r=SupportRingDiameter/2+0.01, h=SpringLength); // Выемка под пружину
}

	
module support(MainAxeHeight, ProbeDiameter, SupportLength, SupportRingDiameter, BracketLength, blt)
{

SQRT3=sqrt(3);
BaseThickness=SupportRingDiameter/4;

a=(MainAxeHeight+SupportRingDiameter/4)*2/SQRT3; // сторона треугольника, являющегося основой.

difference ()
{
union ()
	{
	translate ([-MainAxeHeight, -a/2-BracketLength,0])
		cube ([BaseThickness,a+2*BracketLength,SupportLength]); // Нескошенное основание, включая "уши"
	translate ([-a*SQRT3/3+SupportRingDiameter/2,0,0])
			cylinder (r=a*SQRT3/3,h=SupportLength,$fn=3); // Основное тело

	cylinder (r=SupportRingDiameter/2,h=SupportLength); // Цилиндр, окружающий отверстие для щупа
	}
	
translate ([0,0,-0.01])
	cylinder (r=ProbeDiameter/2, h=SupportLength+0.02);


translate ([-a*SQRT3/3+SupportRingDiameter/3,0,-0.01])
	rotate ([0,0,30])		
		cylinder (r=a*SQRT3/6,h=SupportLength+0.02,$fn=6); // Шестигранная выемка для экономии материала

if ( BracketLength )
	for ( Offset = [a/2+BracketLength/2, -a/2-BracketLength/2] ) // отверстия под шурупы
		{
		
		translate ([-MainAxeHeight-0.01, Offset,SupportLength/2])
		rotate ([0,90,0])
			bolt ( blt, h=BaseThickness );
		}

}

}





module bearing_inner(od=10,id=6,height=10,thin=1,StartAngle=0,FinishAngle=324,Step=36){
  difference(){
    cylinder(r=od/2,h=height,$fn=60);
    for(a=[StartAngle:Step:FinishAngle]){
      rotate([0,0,a])
        translate([-thin/2,0,-1])
        cube([thin,height+2,height+2]);
    }
  }
  cylinder(r=id/2,h=height,$fn=60);
}

function bPar(type) = (type == 0 ? [3.62, 6.7] : 
							 (type == 1 ? [4.12, 7.84] : 
											  [4.36, 8.82] )) / 2;
function bPar2(r) = [r, 2.2 * r];	// до 2.2 для шурупов, до 1.9 для винтов


// 3.62 - 6.7
// 4.12 - 7.84
// 4.36 - 8.82
module bolt(param, h, hHead = -1)
{			
	hCone = param[1] < h ? param[1] : h;
	rCone = param[1] < h ? 0 : param[1] - h; 
	h2 = hHead > 0 ? hHead : h;

	cylinder(r = param[0], h = h);
	translate([0, 0, h-hCone])
		cylinder(r1 = rCone, r2 = param[1], h = hCone);	
	translate([0, 0 ,h - delta/10])				// delta/10 -- чтобы пересеклись конус и цилиндр
		cylinder(r = param[1], h = h2 + delta/10);
}
