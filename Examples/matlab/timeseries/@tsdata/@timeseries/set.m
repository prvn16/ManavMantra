function set(h,varargin)

% Copyright 2006 The MathWorks, Inc.

for k=1:floor((nargin-1)/2)
    if ~strcmpi(varargin{2*k-1},'tsvalue')
        h.tsValue = set(h.tsValue,varargin{2*k-1},varargin{2*k});
    else
        h.tsValue = varargin{2*k};
    end
end




