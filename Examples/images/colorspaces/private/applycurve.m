function out = applycurve(in, curve, inverse, method)
%APPLYCURVE processes vector data through a function
%   OUT = APPLYCURVE(IN, CURVE, INVERSE, METHOD) remaps the input 
%   vector IN through a tag of curveType or parametricCurveType 
%   to compute the output vector OUT.  The tag is defined by 
%   CURVE, which is a uint8 or uint16 vector for curveType or a
%   structure, of specific form, for parametricCurveType.  
%   INVERSE is an optional argument, defaulting to zero, for 
%   selecting between forward or inverse evaluation of the function:
%   non-zero values imply the inverse.  METHOD is a string specifying
%   the method of interpolation for interp1; the default is 'linear'.

%   Copyright 2005-2015 The MathWorks, Inc.
%      Poe
%   Original author:  Robert Poe 10/15/05

validateattributes(in, {'double'}, ...
             {'real', 'vector', 'nonsparse', 'finite'}, ...
                 'applycurve', 'IN', 1);

if nargin < 3
    isfwd = true;
else
    isfwd = (inverse == 0);
end

if nargin < 4
    method = 'linear';
end

% Clip input to [0, 1]
in = min(max(in, 0.0), 1.0);

% Detect parametricCurveType and evaluate
if isstruct(curve)
    if isfield(curve, 'FunctionType')
        funtype = curve.FunctionType;
    else
        error(message('images:applycurve:noParametricCurveTypeFunction'))
    end
    if isfield(curve, 'Params') && isa(curve.Params, 'double')
        params = curve.Params;
    else
        error(message('images:applycurve:noParametricCurveTypeParams'))
    end
    out = applyparametric(in, funtype, isfwd, params);

% Handle curveType
else    
    if isa(curve, 'uint8')
        scale = 255.0;
    elseif isa(curve, 'uint16')
        scale = 65535.0;
    else
        error(message('images:applycurve:invalidDataType'))
    end
    clength = length(curve);
    if clength > 1                            % 1D LUT
        % Rescale LUT to [0, 1]
        lut1d = double(curve) / scale;
        samples = linspace(0.0, 1.0, clength)';
        if isfwd
        % Evaluate in forward direction
            out = interp1(samples, lut1d, in, method);
        else
        % Make inverse LUT monotonic for backward direction
            [Xi, Yi] = monotonicize(lut1d, samples);
            out = interp1(Xi, Yi, in, method);
        end
    elseif scale == 65535.0                   % power law
        if isfwd
            gamma = double(curve) / 256.0;
        else
            if curve == 0
                gamma = 1.0;
            else
                gamma = 256.0 / double(curve);
            end
        end
        out = in .^ gamma;
    else
        error(message('images:applycurve:numLutEntries'));
    end
end

% Clip output to [0, 1]
out = max(min(out, 1.0), 0.0);

%-----------------------------------------------
function [xout, yout] = monotonicize(xin,  yin)

% Remove non-monotonic values from XIN, along with
% corresponding rows from YIN, copying the remaining
% rows into XOUT and YOUT, respectively.

if ~isvector(xin) || length(xin) < 2
    error(message('images:applygraytrc_inv:BadInputXi'))
end

nin = length(xin);
xin = reshape(xin, nin, 1); % make column vector

if size(yin, 1) ~= nin
    error(message('images:applygraytrc_inv:BadInputYi'))
end

% Determine overall polarity of XIN
% Flip rows, if necessary, to make it an increasing sequence
fliprows = xin(nin) < xin(1);
if fliprows
    xin = flip(xin, 1);
    yin = flip(yin, 1);
end

xout = [];
yout = [];

% Find start of first increasing sequence
iin = 1;
while iin < nin && xin(iin + 1, 1) <= xin(iin, 1)
    iin = iin + 1;
end
igood = iin;

% Keep this row and move on
iout = 1;
xout(iout, 1) = xin(igood, 1);
yout(iout, :) = yin(igood, :);

iin = iin + 1;
while iin <= nin
  % Save rows only when increasing
    if xin(iin, 1) > xin(igood, 1)
        igood = iin;
        iout = iout + 1;
        xout(iout, 1) = xin(igood, 1); %#ok<AGROW>
        yout(iout, :) = yin(igood, :); %#ok<AGROW>
    end
    iin = iin + 1;
end

% Flip output arrays, if inputs were flipped
if fliprows
    xout = flip(xout, 1);
    yout = flip(yout, 1);
end
