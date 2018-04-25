function bdata = datetimeDiff(adata,varargin)

%   Copyright 2014-2015 The MathWorks, Inc.

if nargin < 2
    diff_adata = diff(adata);
else
    diff_adata = diff(adata,varargin{:});
end
bdata = real(matlab.internal.datetime.datetimeAdd(real(diff_adata),imag(diff_adata)));
