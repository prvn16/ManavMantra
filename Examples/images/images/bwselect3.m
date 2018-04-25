function varargout = bwselect3(varargin)
%BWSELECT3 Select objects in binary image.
%   J = BWSELECT3(V,C,R,P,N) returns a binary volume containing the objects
%   that overlap the pixel location (R,C,P), wherein R,C and P stand for row,
%   column and plane index respectively. R,C and P can be scalars or equal-length
%   vectors. If R, C and P are vectors, J contains the set of objects overlapping
%   with any of the pixels (R(k),C(k),P(k)). N (optional) can be
%   either 6,18 or 26(the default) , where 6 specifies 6-connected objects
%   (Face-Face), 18 specifies 18-connected objects (Face-Face and Edge-Edge)
%   and 26 specifies 26-connected objects (Face-Face, Edge-Edge and Vertex-Vertex).
%   Objects are connected sets of "on" pixels (i.e., having value of 1).
%
%   [J,IDX] = BWSELECT3(...) returns the linear indices of the pixels belonging
%   to the selected objects.
%
%   J = BWSELECT3(X,Y,Z,V,Xi,Yi,Zi,N) uses the vectors X,Y and Z to establish
%   a non default spatial coordinate system for V. Xi, Yi and Zi are scalars 
%   or equal-length vectors that specify locations in this coordinate system.
%
%   [X,Y,Z,J,IDX,Xi,Yi,Zi] = BWSELECT3(...) returns the XData, YData and ZData
%   in X,Y and Z; the output volume in J; linear indices of the pixels belonging
%   to the selected objects in IDX; and the specified spatial coordinates Xi,Yi and Zi.
%
%
%   Class Support
%   ------------- 
%   The input volume V can be logical or any numeric type and 
%   must be 3-D and nonsparse.  The output volume J is logical.
%
%   Example
%   -------
%
%   load mristack;
%   V = mristack;
%   C = [126 87 11];
%   R = [34 120 20];
%   P = [20 2 12];
%   J = bwselect3(V,C,R,P);
%
%   See also IMFILL, BWLABEL, GRAYCONNECTED, REGIONFILL, ROIPOLY.

%   Copyright 2016-2017 The MathWorks, Inc.

[xdata,ydata,zdata,BW,xi,yi,zi,r,c,p,n] = ...
    ParseInputs(varargin{:});

seed_indices = sub2ind(size(BW), r(:), c(:),p(:));
BW2 = imfill(~BW, seed_indices, n);
BW2 = BW2 & BW;

switch nargout
case 0
    % BWSELECT3(...)
    varargout{1} = BW2;
    
case 1
    % BW2 = BWSELECT3(...)
    
    varargout{1} = BW2;
    
case 2 
    % [BW2,IDX] = BWSELECT3(...)
    
    varargout{1} = BW2;
    varargout{2} = find(BW2);
    
otherwise
    % [X,Y,Z,BW2,...] = BWSELECT3(...)
    
    varargout{1} = xdata;
    varargout{2} = ydata;
    varargout{3} = zdata;
    varargout{4} = BW2;
    
    if (nargout >= 5)
        % [X,Y,Z,BW2,IDX,...] = BWSELECT3(...)
        varargout{5} = find(BW2);
    end
    
    if (nargout >= 6)
        % [X,Y,Z,BW2,IDX,Xi,...] = BWSELECT3(...)
        varargout{6} = xi;
    end
    
    if (nargout >= 7)
        % [X,Y,Z,BW2,IDX,Xi,Yi,...] = BWSELECT3(...)
        varargout{7} = yi;
    end
    
    if (nargout == 8)
        % [X,Y,Z,BW2,IDX,Xi,Yi,Zi] = BWSELECT3(...)
        varargout{8} = zi;
    end
    
end

%%%
%%% Subfunction ParseInputs
%%%
function [xdata,ydata,zdata,BW,xi,yi,zi,r,c,p,style] = ParseInputs(varargin)

narginchk(4,8);
VolPos = 1;
NPos = 5;

if nargin == 4 || nargin == 5
    
    inpPar = inputParser;
    inpPar.addRequired('V', @validateVolume);
    inpPar.addRequired('C', @validateCRP);
    inpPar.addRequired('R', @validateCRP);
    inpPar.addRequired('P', @validateCRP);
    inpPar.addOptional('N',26, @validateConn);
    
    inpPar.parse(varargin{:});
    res = inpPar.Results;
    
    [xdata,ydata,zdata,BW,xi,yi,zi,r,c,p,style] = assignResult(res);
    
elseif nargin == 7 || nargin == 8
    
    inpPar = inputParser;
    inpPar.addRequired('X', @validateIdx);
    inpPar.addRequired('Y', @validateIdx);
    inpPar.addRequired('Z', @validateIdx);
    inpPar.addRequired('V', @validateVolume);
    inpPar.addRequired('Xi', @validateIdx);
    inpPar.addRequired('Yi', @validateIdx);
    inpPar.addRequired('Zi', @validateIdx);
    inpPar.addOptional('N',26, @validateConn);
    
    VolPos = 4;
    NPos = 8;
    inpPar.parse(varargin{:});
    res = inpPar.Results;
    
    [xdata,ydata,zdata,BW,xi,yi,zi,r,c,p,style] = assignResult(res);
    
end

if ~islogical(BW)
    BW = BW ~= 0;
end


badPix = find((r < 1) | (r > size(BW,1)) | ...
              (c < 1) | (c > size(BW,2)) | ...
              (p < 1) | (p > size(BW,3)));
if (~isempty(badPix))
    warning(message('images:bwselect:outOfRange')); % Using the same OutOfRange warning from bwselect function
    r(badPix) = [];
    c(badPix) = [];
    p(badPix) = [];
end 

function [xdata,ydata,zdata,BW,xi,yi,zi,r,c,p,style] = assignResult(res)

BW = res.V;
style = res.N;

if length(fieldnames(res)) == 8
    xdata = res.X;
    ydata = res.Y;
    zdata = res.Z;
    xi = res.Xi;
    yi = res.Yi;
    zi = res.Zi;
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    p = round(axes2pix(size(BW,3), zdata, zi));
    
elseif length(fieldnames(res)) == 5
    
    xdata = [1 size(BW,2)];
    ydata = [1 size(BW,1)];
    zdata = [1 size(BW,3)];
    xi = res.C;
    yi = res.R;
    zi = res.P;
    r = round(yi);
    c = round(xi);
    p = round(zi);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = validateVolume(V)

validateattributes(V,{'logical' 'numeric'},{'ndims',3, 'real' , 'nonsparse'}, ...
                  mfilename, 'V');
flag = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = validateCRP(inp)

validateattributes(inp,{'numeric'},{'real','nonsparse','integer'}, mfilename);

flag = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = validateIdx(inp)

validateattributes(inp,{'numeric'},{'real','nonsparse'}, mfilename);

flag = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = validateConn(N)

validateattributes(N, {'numeric'}, {'scalar'}, mfilename, 'N');
if ~((N == 6 ) || (N == 18) || (N == 26))
     error(message('images:bwselect:bad3DScalarConn',mfilename));
end
flag=true;

