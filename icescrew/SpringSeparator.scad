$fs=0.75;$fa=5;

MainAxeDiameter = 6;
SeparatorLength = 35;
SeparatorExternalDiamater = 10-0.3;


difference ()
	{
	cylinder ( r = SeparatorExternalDiamater/2, h=SeparatorLength );
	translate ([0,0,-0.01])
	cylinder ( r = MainAxeDiameter/2, , h=SeparatorLength + 0.02 );
	}