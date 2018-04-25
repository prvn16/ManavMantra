function string = getMessageString(identifier, varargin)
    
% Copyright 2015 The MathWorks, Inc.

if (nargin == 1)
    string = getString(message(sprintf('images:imageSegmenter:%s', identifier)));
elseif (nargin > 1)
    string = getString(message(sprintf('images:imageSegmenter:%s', identifier), varargin{:}));
end

end
