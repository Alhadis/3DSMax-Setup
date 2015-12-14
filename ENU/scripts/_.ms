obj	=	$Line001;
clearListener();

v1	=	getKnotPoint obj 1 1;
v2	=	getKnotPoint obj 1 2;


--	X Rotation
/*
x	=	if(v1.x > 0) then v2.x - v1.x else v1.x - v2.x;
y	=	if(v1.y > 0) then v2.y - v1.y else v1.y - v2.y;
*/

x	=	v2.x - v1.x;
y	=	v2.y - v1.y;

rot	=	atan (y / x);

if(rot < 0) then rot = abs(rot) else -(rot);