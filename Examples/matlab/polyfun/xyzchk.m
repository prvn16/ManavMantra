function [msg,x,y,z,out5,out6] = xyzchk(arg1,arg2,arg3,arg4,arg5)
%XYZCHK Check arguments to 3-D data routines.
%   [MSG,X,Y,Z,C] = XYZCHK(Z), or
%   [MSG,X,Y,Z,C] = XYZCHK(Z,C), or
%   [MSG,X,Y,Z,C] = XYZCHK(X,Y,Z), or
%   [MSG,X,Y,Z,C] = XYZCHK(X,Y,Z,C), or
%   [MSG,X,Y,Z,XI,YI] = XYZCHK(X,Y,Z,XI,YI) checks the input arguments
%   and returns either an error structure in MSG or valid X,Y,Z (and
%   XI,YI) data.

%   Copyright 1984-2011 The MathWorks, Inc.

narginchk(1,6);

msg.message = 0;
msg.identifier = 0;
msg = msg(zeros(0,1));

out5 = []; out6 = [];
if nargin==1, % xyzchk(z)
    z = arg1;
    if ischar(z) || (isstring(z) && isscalar(z))
        msg(1).identifier = 'MATLAB:xyzchk:nonNumericInput';
        msg(1).message = getString(message(msg(1).identifier));
        
        return
    end
    [m,n] = size(z);
    [x,y] = meshgrid(1:n,1:m);
    out5 = z; % Default color matrix
    return
    
elseif nargin==2, % xyzchk(z,c)
    z = arg1; c = arg2;
    [m,n] = size(z);
    [x,y] = meshgrid(1:n,1:m);
    if ~isequal(size(z),size(c)),
        msg(1).identifier = 'MATLAB:xyzchk:CAndZSizeMismatch'; 
        msg(1).message = getString(message(msg(1).identifier));
        
        return
    end
    out5 = c;
    return
    
elseif nargin>=3, % xyzchk(x,y,z,...)
    x = arg1; y = arg2; z = arg3;
    [m,n] = size(z);
    if ~isvector(z), % z is a matrix
        % Convert x,y to row and column matrices if necessary.
        if isvector(x) && isvector(y),
            [x,y] = meshgrid(x,y);
            if size(x,2)~=n && size(y,1)~=m,
                msg(1).identifier = 'MATLAB:xyzchk:lengthXAndYDoNotMatchSizeZ';
                msg(1).message = getString(message(msg(1).identifier));
                return
            elseif size(x,2)~=n,
                msg(1).identifier = 'MATLAB:xyzchk:lengthXDoesNotMatchNumColumnsZ';
                msg(1).message = getString(message(msg(1).identifier));
                return
            elseif size(y,1)~=m,
                msg(1).identifier = 'MATLAB:xyzchk:lengthYDoesNotMatchNumRowsZ';
                msg(1).message = getString(message(msg(1).identifier));
                return
            end
        elseif isvector(x) || isvector(y),
            msg(1).identifier = 'MATLAB:xyzchk:XAndYShapeMismatch';
            msg(1).message = getString(message(msg(1).identifier));
            return
        else
            if ~isequal(size(x),size(y),size(z)),
                msg(1).identifier = 'MATLAB:xyzchk:XYAndZSizeMismatch';
                msg(1).message = getString(message(msg(1).identifier));
                return
            end
        end
    else % z is a vector
        if ~isvector(x) || ~isvector(y),
            msg(1).identifier = 'MATLAB:xyzchk:XYAndZShapeMismatch'; 
            msg(1).message = getString(message(msg(1).identifier));
            return
        elseif (length(x)~=length(z) || length(y)~=length(z)) && ...
                ~((length(x)==size(z,2)) && (length(y)==size(z,1)))
            msg(1).identifier = 'MATLAB:xyzchk:XYAndZLengthMismatch'; 
            msg(1).message = getString(message(msg(1).identifier));
            return
        end
    end
end

if nargin==4, % xyzchk(x,y,z,c)
    c = arg4;
    if ~isequal(size(z),size(c))
        msg(1).identifier = 'MATLAB:xyzchk:CAndZSizeMismatch'; 
        msg(1).message = getString(message(msg(1).identifier));
        return
    end
    out5 = c;
    return
end

if nargin==5, % xyzchk(x,y,z,xi,yi)
    xi = arg4; yi = arg5;
    
    if automesh(xi,yi),
        [xi,yi] = meshgrid(xi,yi);
    elseif ~isequal(size(xi),size(yi)),
        msg(1).identifier = 'MATLAB:xyzchk:XIAndYISizeMismatch';
        msg(1).message = getString(message(msg(1).identifier));
    end
    out5 = xi; out6 = yi;
end

function tf = isvector(x)
%ISVECTOR True if x has only one non-singleton dimension.
tf = (length(x) == numel(x));


