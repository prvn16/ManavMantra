function varargout = evalc(tryVal,catchVal) %#ok<INUSD>
%EVALC for Java strings.
%
%   See also EVALC. 

%   Copyright 1984-2011 The MathWorks, Inc. 

tryVal = fromOpaque(tryVal); %#ok<NASGU>

if nargin==2
    % The catch-argument to evalin is evaluated in the current workspace, hence the need for the
    % embedded evalin in the third argument below.
    [varargout{1:nargout}] = evalc('evalin(''caller'', tryVal);', 'evalin(''caller'', fromOpaque(catchVal));');
else
    [varargout{1:nargout}] = evalc('evalin(''caller'', tryVal);');
end

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error(message('MATLAB:evalc:CannotConvertClass', class( x )));
end
