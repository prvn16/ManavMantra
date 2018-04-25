function setTickFormat(ruler, val)
% This function is undocumented and may change in a future release.

%   Copyright 2015-2016 The MathWorks, Inc.

% If the ruler input is empty, there is nothing to do.
if isempty(ruler)
    return
end

% Make sure that the format string provided is actually a character vector
% or scalar string.
if ~(ischar(val) || (isstring(val) && isscalar(val)))
    invalidFormatError(ruler(1));
end

data = lookupOneStyle(val);

% Set the format on each ruler
for r = ruler(:)'
    setFormat(r, data)
end

end

function setFormat(r, data)

fmt = [data.prefix data.format data.suffix];

if strcmp(data.exponentMode, 'auto')
    if isprop(r,'ExponentMode')
        r.ExponentMode = 'auto';
    end
elseif ~isempty(data.exponent)
    r.Exponent = data.exponent;
end

r.TickLabelMode = 'auto';
if data.auto
    if isa(r,'matlab.graphics.axis.decorator.NumericRuler')
        % NumericRuler has TickLabelFormatMode, but it doesn't do anything,
        % so just set the TickLabelFormat to the default for NumericRuler.
        r.TickLabelFormat = '%g';
    elseif isprop(r, 'TickLabelFormatMode')
        r.TickLabelFormatMode = 'auto';
    else
        invalidFormatError(r);
    end
else
    r.TickLabelFormat = fmt;
end

end

function data = lookupOneStyle(style)

data.prefix = '';
data.suffix = '';
data.format = '';
data.exponent = [];
data.exponentMode = '';
data.auto = false;

switch style
    case 'auto'
        data.exponentMode = 'auto';
        data.auto = true;
    case 'percentage'
        data.prefix = '';
        data.format = '%g';
        data.suffix = '%%';
        data.exponentMode = 'auto';
    case 'degrees'
        data.prefix = '';
        data.format = '%g';
        data.suffix = '\x00B0';
        data.exponentMode = 'auto';
    case 'usd'
        data = setCurrency(data, '$', '%,.2f');
    case 'eur'
        data = setCurrency(data, '\x20AC', '%,.2f');
    case 'gbp'
        data = setCurrency(data, '\x00A3', '%,.2f');
    case 'jpy'
        data = setCurrency(data, '\x00A5', '%,d');
    otherwise
        data.format = char(style);
end

end

function data = setCurrency(data, prefix, fmt)

data.prefix = prefix;
data.format = fmt;
data.exponent = 0;
data.exponentMode = 'manual';

end

function invalidFormatError(ruler)
    switch class(ruler)
        case 'matlab.graphics.axis.decorator.DatetimeRuler'
            throwAsCaller(MException(message('MATLAB:rulerFunctions:InvalidDatetimeFormat')));
        case 'matlab.graphics.axis.decorator.DurationRuler'
            throwAsCaller(MException(message('MATLAB:rulerFunctions:InvalidDurationFormat')));
        otherwise
            throwAsCaller(MException(message('MATLAB:rulerFunctions:InvalidNumericFormat')));
    end
end
