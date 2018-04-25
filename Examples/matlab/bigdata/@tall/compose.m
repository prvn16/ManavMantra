function s = compose(format,varargin)
%COMPOSE Fill holes in string with formatted data.
%   S = COMPOSE(TXT)
%   S = COMPOSE(FORMAT,A)
%   S = COMPOSE(FORMAT,A1,...,AN)
%
%   For tall data A, FORMAT must be a non-tall string.
%
%   See also COMPOSE, TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin==1
    % Simply act element-wise
    format = tall.validateType(format, mfilename, {'string'}, 1);
    s = elementfun(@compose, format);
else
    % First input must be a non-tall string.
    tall.checkNotTall(upper(mfilename), 0, format);
    format = tall.validateType(format, mfilename, {'string'}, 1);
    
    % COMPOSE can consume multiple columns, so is slice-wise
    s = slicefun(@(varargin) compose(format,varargin{:}), varargin{:});
end
s = setKnownType(s, 'string');
end


