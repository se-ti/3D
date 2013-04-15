irb = "screws/irbis.stl";
grivel = "screws/grivel.stl";


/*translate([0, 28, 0])
	import(grivel);
translate([28, 28, 0])
	import(grivel);
*/

import(irb);
translate([27, 0, 0])
	import(irb);


