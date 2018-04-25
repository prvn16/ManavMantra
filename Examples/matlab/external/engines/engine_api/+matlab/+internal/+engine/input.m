function varargout=input(varargin)
% matlab.internal.engine.input Raise an error if "input" is called by 
% Engine clients and MATLAB is launched by Engine clients without Desktop.
%
% This input.m is activated only if MATLAB is launched by Engine clients.
%
% If MATLAB is launched by Engine clients, it can be either hidden or 
% visible with Desktop.  If MATLAB Desktop is visible, the built-in input.m 
% is invoked; otherwise it errors out.
%
% If MATLAB is not launched by but connected by Engine clients, it should
% always call the built-in input.m so users can respond from the MATLAB
% command window.

% Copyright 2015 The MathWorks, Inc.

if usejava('desktop')
    [varargout{1:nargout}] = builtin('input', varargin{:});
else
    error(message('MATLAB:engineAPI:InputNotSupported'));
end
end

