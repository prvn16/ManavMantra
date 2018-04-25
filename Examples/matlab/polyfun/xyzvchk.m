function [msg,x,y,z,v,xi,yi,zi] = xyzvchk(arg1,arg2,arg3,arg4,arg5,arg6,arg7)
%XYZVCHK Check arguments to 3-D volume data routines.
%   [MSG,X,Y,Z,V,XI,YI,ZI] = XYZVCHK(X,Y,Z,V,XI,YI,ZI), checks the
%   input arguments and returns either an error structure in MSG or
%   valid X,Y,Z,V (and XI,YI,ZI) data.

%   Copyright 1984-2011 The MathWorks, Inc.

narginchk(7,7);

x = [];
y = [];
z = [];
v = [];
xi = [];
yi = [];
zi = [];

msg.message = '';
msg.identifier = '';
msg = msg(zeros(0,1));

if nargin>4, % xyzchk(x,y,z,v,...)
    x = arg1; y = arg2; z = arg3; v = arg4;
    if ndims(v)~=3
        msg(1).identifier = 'MATLAB:xyzvchk:VNot3D'; 
        msg(1).message = getString(message(msg(1).identifier));
        return
    end
    siz = size(v);
    if ~isvector(v), % v is not a vector or scalar
        % Convert x,y,z to row, column, and page matrices if necessary.
        if isvector(x) && isvector(y) && isvector(z),
            [x,y,z] = meshgrid(x,y,z);
            if ~isequal([size(y,1) size(x,2) size(z,3)],siz),
                msg(1).identifier = 'MATLAB:xyzvchk:lengthXYAndZDoNotMatchSizeV'; 
                msg(1).message = getString(message(msg(1).identifier));
                return
            end
        elseif isvector(x) || isvector(y) || isvector(z),
            msg(1).identifier = 'MATLAB:xyzvchk:XYAndZShapeMismatch'; 
            msg(1).message = getString(message(msg(1).identifier));
            return
        else
            if ~isequal(size(x),size(y),size(z),siz),
                msg(1).identifier = 'MATLAB:xyzvchk:XYZAndVSizeMismatch';
                msg(1).message = getString(message(msg(1).identifier));
                return
            end
        end
    elseif isvector(v) % v is a vector
        if ~isvector(x) || ~isvector(y) || ~isvector(z),
            msg(1).identifier = 'MATLAB:xyzvchk:XYZAndVShapeMismatch'; 
            msg(1).message = getString(message(msg(1).identifier));
            return
        elseif ~isequal(length(x),length(y),length(z),length(v)),
            msg(1).identifier = 'MATLAB:xyzvchk:XYZAndVLengthMismatch'; 
            msg(1).message = getString(message(msg(1).identifier));
            return
        end
    end
end

if nargin==7, % xyzchk(x,y,z,v,xi,yi,zi)
    xi = arg5; yi = arg6; zi = arg7;
    
    % If xi,yi and zi don't all have the same orientation, then
    % build xi,yi,zi arrays.
    if automesh(xi,yi,zi)
        [xi,yi,zi] = meshgrid(xi,yi,zi);
    elseif ~isequal(size(xi),size(yi),size(zi)),
        msg(1).identifier = 'MATLAB:xyzvchk:XIYIAndZISizeMismatch'; 
        msg(1).message = getString(message(msg(1).identifier));
    end
end

function tf = isvector(x)
%ISVECTOR True if x has only one non-singleton dimension.
tf = (sum(size(x)~=1) <= 1);

