function validateNonemptyText(input,varargin)
% This function is undocumented and may change in a future release.

% Copyright 2016 The MathWorks, Inc.

validateattributes(input,{'string','char'},{'nonempty','row'},'',varargin{:});
if ~isstring(input)
    return;
end

validateattributes(input,{'string'},{'scalar'},'',varargin{:});

if nargin > 1
    msgKeyPart = 'PropertyValue';
else
    msgKeyPart = 'Input';
end

if ismissing(input)
    error(message(['MATLAB:unittest:StringInputValidation:InvalidString' msgKeyPart 'MissingElement'],varargin{:}));
elseif strlength(input) == 0
    error(message(['MATLAB:unittest:StringInputValidation:InvalidString' msgKeyPart 'EmptyText'],varargin{:}));
end
end



