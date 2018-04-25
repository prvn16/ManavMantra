function h = ufi(varargin)
%UFI     Unsigned fixed-point numeric object
%
%   Syntax:
%     a = ufi
%     a = ufi(v)
%     a = ufi(v, w)
%     a = ufi(v, w, f)
%     a = ufi(v, w, slope, bias)
%     a = ufi(v, w, slopeadjustmentfactor, fixedexponent, bias)
%
%   Description:
%     ufi is the default constructor and returns an unsigned fixed-point object
%     with no value, 16-bit word length, and 15-bit fraction length.
%
%     ufi(v) returns an unsigned fixed-point object with value v, 16-bit
%     word length, and best-precision fraction length. Best-precision
%     is when the fraction length is set automatically to accommodate the
%     value v for the given word length.
%
%     ufi(v,w) returns an unsigned fixed-point object with value v, word length w,
%     and best-precision fraction length.
%
%     ufi(v,w,f) returns an unsigned fixed-point object with value v, word length w,
%     and fraction length f.
%
%     ufi(v,w,slope,bias) returns an unsigned fixed-point object with value v,
%     word length w, slope, and bias.
%
%     ufi(v,w,slopeadjustmentfactor,fixedexponent,bias) returns an unsigned
%     fixed-point object with value v, word length w, slopeadjustmentfactor,
%     fixedexponent, and bias.
%
%     The fi object returned by this function does not have a local fimath object;
%     it always associates with the global fimath.
%
%   See also FI, SFI, FIMATH, FIPREF, NUMERICTYPE, QUANTIZER, SAVEFIPREF, GLOBALFIMATH, <a href="matlab:help embedded.fi.isfimathlocal">isfimathlocal</a> 
%            FIXEDPOINT, FORMAT, FISCALINGDEMO

%   Copyright 2008-2015 The MathWorks, Inc.

narginchk(0,5);
for idx = 1:length(varargin)
    if ~isnumeric(varargin{idx})
        error(message('fixed:fi:InvalidInputNotNumeric'));
    end
end
if nargin == 0
    varargin{1} = [];
end
varargin = [varargin(1),0,varargin(2:end)];

% Only do this if the embedded package has not been loaded already.
if isempty(findpackage('embedded'))
    initializeEmbeddedUnused = fi(0,'DataType','Double'); %#ok also do not want to check out a license - just load the embedded package
end

h = fi(varargin{:});
% If varargin{1} is a fi then this is a copy constructor
% If varargin{1} has a local fimath, then we need to set h'd fimath to an []
if isfi(varargin{1}) && (isfimathlocal(varargin{1}) || isfloat(varargin{1}))
    h.fimath = [];
end

%--------------------------------------------------------------------------
