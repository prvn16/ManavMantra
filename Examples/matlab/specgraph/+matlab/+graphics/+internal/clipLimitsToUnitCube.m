function newmat = clipLimitsToUnitCube(mat)
%CLIPLIMITSTOUNITCUBE Clip limits to 0-1 cube
%   Given a 3x2 matrix representing limits or a line segment, clip them to
%   fit in a unit cube.  In other words, imagine a line segment going
%   through a unit cube (xlim = [0,1], ylim = [0,1] and zlim = [0,1]).
%   Return the vertices which are on the boundary of this cube, the
%   intersection between the line segment and the cube. 

x = mat(1,:);
y = mat(2,:);
z = mat(3,:);

[x,y,z] = clipatminzero(x,y,z);
[x,y,z] = clipatmaxone(x,y,z);
[y,x,z] = clipatminzero(y,x,z);
[y,x,z] = clipatmaxone(y,x,z);
[z,x,y] = clipatminzero(z,x,y);
[z,x,y] = clipatmaxone(z,x,y);

newmat = [x;y;z];
    
function [newx, newy, newz] = clipatminzero(x,y,z)
newx = x;
newy = y;
newz = z;

if min(x) > 0
    return;
end

if x(1) < x(2)
    ind1 = 1;
    ind2 = 2;
else
    ind1 = 2;
    ind2 = 1;
end

rat = -x(ind1)/(x(ind2)- x(ind1));
newx(ind1) = 0;
newy(ind1) = y(ind1)+rat*(y(ind2)-y(ind1));
newz(ind1) = z(ind1)+rat*(z(ind2)-z(ind1));


function [newx, newy, newz] = clipatmaxone(x,y,z)
newx = x;
newy = y;
newz = z;

if max(x) < 1
    return;
end

if x(1) < x(2)
    ind1 = 1;
    ind2 = 2;
else
    ind1 = 2;
    ind2 = 1;
end

rat = (x(ind2)-1)/(x(ind2)-x(ind1));
newx(ind2) = 1;
newy(ind2) = y(ind2) - rat*(y(ind2) - y(ind1));
newz(ind2) = z(ind2) - rat*(z(ind2) - z(ind1));



