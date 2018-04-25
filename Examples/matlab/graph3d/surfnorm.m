function [nxout,nyout,nzout] = surfnorm(varargin)
%SURFNORM Surface normals.
%   [Nx,Ny,Nz] = SURFNORM(X,Y,Z) returns the components of the 3-D 
%   surface normal for the surface with components (X,Y,Z).  The 
%   normal is normalized to length 1.
%
%   [Nx,Ny,Nz] = SURFNORM(Z) returns the surface normal components
%   for the surface Z.
%
%   Without lefthand arguments, SURFNORM(X,Y,Z) or SURFNORM(Z) 
%   plots the surface with the normals emanating from it.
%
%   SURFNORM(AX,...) plots into AX instead of GCA.
%
%   SURFNORM(...,'PropertyName',PropertyValue,...) can be used to set
%   the value of the specified surface property.  Multiple property
%   values can be set with a single statement.
%
%   The surface normals returned are based on a bicubic fit of
%   the data.  Use SURFNORM(X',Y',Z') to reverse the direction
%   of the normals.

%   Clay M. Thompson  1-15-91
%   Revised 8-5-91, 9-17-91 by cmt.
%   Copyright 1984-2017 The MathWorks, Inc.

[cax,args] = axescheck(varargin{:});
[reg, prop]=parseparams(args);
nargs=length(reg);

if nargs < 1
  error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargs > 3
  error(message('MATLAB:narginchk:tooManyInputs'));
end

if rem(length(prop),2)~=0
   error(message('MATLAB:surfnorm:PropertyValuePairsExpected'))
end

if nargs==1
   x=reg{1};
   z = x;
   [m,n] = size(z);
   [x,y] = meshgrid(1:n,1:m);
elseif nargs==2
   error(message('MATLAB:surfnorm:InvalidMatrixInput'));
elseif nargs==3
   [x,y,z]=deal(reg{1:3});
end

[m,n] = size(x);
if ~isequal(size(y),[m,n])
    error(message('MATLAB:surfnorm:InvalidInput')); 
end
if ~isequal(size(z),[m,n])
    error(message('MATLAB:surfnorm:IncorrectInput')); 
end
if any([m n]<3), error(message('MATLAB:surfnorm:InvalidZValue')); end

stencil1 = [1 0 -1]/2;
stencil2 =  [-1;0;1]/2;

if nargout==0 % If plotting, then scale to match plot aspect ratio.
   % Determine plot scaling factors for a cube-like plot domain.
   if isempty(cax)
       cax = gca;
   end
   nextPlot = cax.NextPlot;
   surf(cax,args{:});
   a = [get(cax,'xlim') get(cax,'ylim') get(cax,'zlim')];
   Sx = a(2)-a(1);
   Sy = a(4)-a(3);
   Sz = a(6)-a(5);
   scale = max([Sx,Sy,Sz]);
   Sx = Sx/scale; Sy = Sy/scale; Sz = Sz/scale;
   
   % Scale surface
   xx = x/Sx; yy = y/Sy; zz = z/Sz;
else
   xx = x; yy = y; zz = z;
end

% Expand x,y,z so interpolation is valid at the boundaries.
xx = [3*xx(1,:)-3*xx(2,:)+xx(3,:);xx;3*xx(m,:)-3*xx(m-1,:)+xx(m-2,:)];
xx = [3*xx(:,1)-3*xx(:,2)+xx(:,3),xx,3*xx(:,n)-3*xx(:,n-1)+xx(:,n-2)];
yy = [3*yy(1,:)-3*yy(2,:)+yy(3,:);yy;3*yy(m,:)-3*yy(m-1,:)+yy(m-2,:)];
yy = [3*yy(:,1)-3*yy(:,2)+yy(:,3),yy,3*yy(:,n)-3*yy(:,n-1)+yy(:,n-2)];
zz = [3*zz(1,:)-3*zz(2,:)+zz(3,:);zz;3*zz(m,:)-3*zz(m-1,:)+zz(m-2,:)];
zz = [3*zz(:,1)-3*zz(:,2)+zz(:,3),zz,3*zz(:,n)-3*zz(:,n-1)+zz(:,n-2)];

rows = 2:m+1; cols = 2:n+1;
ax = filter2(stencil1,xx); ax = ax(rows,cols);
ay = filter2(stencil1,yy); ay = ay(rows,cols);
az = filter2(stencil1,zz); az = az(rows,cols);

bx = filter2(stencil2,xx); bx = bx(rows,cols);
by = filter2(stencil2,yy); by = by(rows,cols);
bz = filter2(stencil2,zz); bz = bz(rows,cols);

% Perform cross product to get normals
nx = -(ay.*bz - az.*by);
ny = -(az.*bx - ax.*bz);
nz = -(ax.*by - ay.*bx);

if nargout==0
    % Set the length of the surface normals
    mag = sqrt(nx.*nx+ny.*ny+nz.*nz)*(10/scale);
    d = find(mag==0); mag(d) = eps*ones(size(d));
    nx = nx ./mag;
    ny = ny ./mag;
    nz = nz ./mag;
    
    % Normal vector points
    xc = x; yc = y; zc = z;
    
    % Set NextPlot to 'add' so that the line is added to the existing axes.
    % 'surf' calls 'newplot', so the Figure's NextPlot property will
    % already be set to 'add' at this point.
    cax.NextPlot = 'add';
    
    % use nan trick here
    xp = [xc(:) Sx*nx(:)+xc(:) nan([numel(xc) 1])]';
    yp = [yc(:) Sy*ny(:)+yc(:) nan([numel(xc) 1])]';
    zp = [zc(:) Sz*nz(:)+zc(:) nan([numel(xc) 1])]';
    
    plot3(xp(:),yp(:),zp(:),'r-','parent',cax)
    
    % Restore the original value for NextPlot.
    cax.NextPlot = nextPlot;
    return
end

% Normalize the length of the surface normals to 1.
mag = sqrt(nx.*nx+ny.*ny+nz.*nz);
d = find(mag==0); mag(d) = eps*ones(size(d));
nxout = nx ./mag;
nyout = ny ./mag;
nzout = nz ./mag;

