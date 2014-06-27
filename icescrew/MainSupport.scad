use <common.scad>

$fs=0.75;$fa=5;

MainAxeHeight = 35;
MainAxeDiameter = 6;
SupportThickness=10;
SupportRingDiameter=14;
BracketLength=11;

HolesDiameter = 5;

blt = stdScrew(1); // тип шурупа: 0 / 1 / 2

support(MainAxeHeight, MainAxeDiameter, SupportThickness, SupportRingDiameter, BracketLength, blt, -1.0);

module support(MainAxeHeight, AxeDiameter, SupportLength, SupportRingDiameter, BracketLength, blt, HolesOffset=0, Bearing = true)
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

if ( Bearing )
	{
	translate ([0,0,-0.01])
		bearing_inner ( od=AxeDiameter+4, id=AxeDiameter, height=SupportThickness+0.02 );
	}		
	
translate ([0,0,-0.01]) // Отверстие под ось
	cylinder (r=AxeDiameter/2, h=SupportLength+0.02);


translate ([-a*SQRT3/3+SupportRingDiameter/3,0,-0.01])
	rotate ([0,0,30])		
		cylinder (r=a*SQRT3/6,h=SupportLength+0.02,$fn=6); // Шестигранная выемка для экономии материала

if ( BracketLength )
	for ( Offset = [a/2+BracketLength/2+HolesOffset, -a/2-BracketLength/2-HolesOffset] ) // отверстия под шурупы
		{
		
		translate ([-MainAxeHeight-0.01, Offset,SupportLength/2])
		rotate ([0,90,0])
			screw ( blt, h=BaseThickness );
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
