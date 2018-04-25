function H = defaultObjectArray(varargin)
%

% Takes a size (following the syntax of REPMAT) and returns an array of 
% default objects.

    H = repmat(internalArrayUtil.DefaultObject, varargin{:});
end
