function connb = getBinaryConnectivityMatrix(connspec) %#codegen
%GETBINARYCONNECTIVITYMATRIX Return a binary N-D connectivity matrix
%  CONNB = images.internal.getBinaryConnectivityMatric(connspec) returns a
%  N-D binary connectivity matrix. Scalar specifications are connverted to
%  equivalent N-D logicals, vectors are cast into logicals.
%
%  Note: IPTCHECKCONN should be called first.
%
%  Example:
%        conn4 = images.internal.getBinaryConnectivityMatrix(4);
%
% See also: iptcheckconn

%   Copyright 2012 The MathWorks, Inc.


if isscalar(connspec)
    % scalar specification, expand to connectivity matrix.
    switch connspec
        case 1
            connb = true;
        case 4
            connb = logical(conndef(2,'min'));
        case 6
            connb = logical(conndef(3,'min'));
        case 8
            connb = logical(conndef(2,'max'));
        case 18
            connb = logical(conndef(3,'max'));
            connb(1,1,1) = 0;
            connb(1,3,1) = 0;
            connb(3,1,1) = 0;
            connb(3,3,1) = 0;
            connb(1,1,3) = 0;
            connb(1,3,3) = 0;
            connb(3,1,3) = 0;
            connb(3,3,3) = 0;
        case 26
            connb = logical(conndef(3,'max'));
        otherwise
            error(message('images:validate:badScalarConn',...
                'getBinaryConnectivityMatrix',...
                1,'connspec'));
    end
    
else
    % vector specification    
    connb = logical(connspec);
end