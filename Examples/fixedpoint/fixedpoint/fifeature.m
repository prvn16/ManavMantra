function flag = fifeature(featureStr,varargin)
% FIFEATURE Undocumented internal TMW command for feature diagnostics

%   Copyright 2007-2015 The MathWorks, Inc.
    
narginchk(1,2);

% Do something to load the fixed-point package without checking out a license.
numerictype();

if nargin == 1
    flag = feature(featureStr);
    return;
else % nargin == 2
    val = varargin{1};
    flag = feature(featureStr,val);
end
