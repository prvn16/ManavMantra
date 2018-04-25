function y = quantizefi(x, varargin)
% QUANTIZEFI(x, ...) Quantize x (undocumented internal function).

% Copyright 2011-2012 The MathWorks, Inc.

%#codegen

if ~isempty(coder.target)
    eml_prefer_const(varargin);
end

% -------------------------------------------------------------------
% If x is floating point, just pass x through to output unchanged.
% Otherwise, call documented QUANTIZE function or method.
% -------------------------------------------------------------------
if isfloat(x)
    % MATLAB builtin double/single, or
    % FI double/single Data Type Override
    y = x;
else
    % Caller syntax: y = quantizefi(x,Ty,rm,om)
    % Caller syntax: y = quantizefi(x,s,wl,fl,rm,om)
    y = quantize(x, varargin{:});
end
