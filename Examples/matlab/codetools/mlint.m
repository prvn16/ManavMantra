function [varargout] = mlint(varargin)
%MLINT is not recommended. Use CHECKCODE instead.

try
    [varargout{1:nargout}] = checkcode(varargin{:});
catch e
    throw(e);
end

end % function

