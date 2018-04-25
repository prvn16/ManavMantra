function envobj = reqenv(varargin)

persistent storedenv

if nargin == 0
    if isempty(storedenv)
        storedenv = matlab.depfun.internal.UserEnvironment;
    end
else
    validateattributes(varargin{1},{'matlab.depfun.internal.Environment'},{})
    storedenv = varargin{1};
end

% I'd prefer to query nargout here and only pass an output when needed, but
% quick and dirty speed tests show it slows it down considerably
envobj = storedenv;