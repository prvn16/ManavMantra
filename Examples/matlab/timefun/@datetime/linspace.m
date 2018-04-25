function c = linspace(a,b,n)
%LINSPACE Create equally-spaced sequence of datetimes.
%   C = LINSPACE(A,B) generates a row vector of 100 equally-spaced datetimes
%   between A and B. A and B are scalar datetimes. A or B can also be a datetime
%   string.
%  
%   C = LINSPACE(A,B,N) generates N points between A and B. For N = 1, LINSPACE
%   returns B.

%   Copyright 2014 The MathWorks, Inc.

if nargin < 3, n = 100; end

[aData,bData,c] = datetime.compareUtil(a,b);

if ~isscalar(aData) || ~isscalar(bData) || ~isscalar(n)
    error(message('MATLAB:datetime:linspace:NonScalarInputs'));
end

cData = matlab.internal.datetime.datetimeAdd(...
    aData,linspace(0,matlab.internal.datetime.datetimeSubtract(bData,aData),n));
cData(end) = bData;
c.data = cData;
