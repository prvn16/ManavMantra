%ADDTODATE Add a quantity to a date field.
%   R = ADDTODATE(D,N,T) will add a quantity N to date field T of date 
%   number D, and return the new date number R. 
%
%   INPUT PARAMETERS:
%   D:  double scalar, defining the date number (see DATENUM for definition)
%   N:  double scalar <= 1e16, defining the integer-valued quantity to add to N
%   T:  char vector, defining the date field to add to (see NOTE 1).
%
%   RETURN PARAMETERS:
%   R:  double scalar, returning the new date number.
%
%   NOTE 1: valid values are:
%       'year', 'month', 'day', 'hour', 'minute', 'second', 'millisecond'
%   
%   Examples: R = ADDTODATE(now,20,'day') will add 20 days to the current
%   date and time and return the result in R.
%
%   R = ADDTODATE(DATENUM('20.01.2002','dd.mm.yyyy'),20,'day') will add 20
%   days to the date 20 January 2002, which is first converted to a date
%   number by the nested call to DATENUM, and return the result in R.
%
%   R = DATEVEC(ADDTODATE(now,20,'day')) will add 20 days to the current
%   date and time, convert the result to a date vector, returned in R.
%
%   See also DATENUM, DATEVEC, DATESTR.

%   Copyright 2002-2012 The MathWorks, Inc.

%==============================================================================
function R = addtodate(dtNumber,additionalQuantity,dateField)

% initialise variables
validfields = {'year','month','day', 'hour', 'minute', 'second', 'millisecond'};

% check number of input arguments
if nargin < 3
    error(message('MATLAB:addtodate:Nargin'));
end
% validate input arguments
if ~isnumeric(dtNumber) || ~isscalar(dtNumber)
    error(message('MATLAB:addtodate:InputDate'));
end
if ~isa(dtNumber, 'double')
    dtNumber = double(dtNumber);
end

if ~isnumeric(additionalQuantity) || ~isscalar(additionalQuantity) || abs(additionalQuantity) > 1e16
    error(message('MATLAB:addtodate:InputQuantity'));
end
if ~ischar(dateField)
    error(message('MATLAB:addtodate:InputDateField'));
end

if (floor(additionalQuantity) ~= additionalQuantity)
    warning(message('MATLAB:addtodate:NonIntegerValue', sprintf( '%f', additionalQuantity ), fix( additionalQuantity )));
    additionalQuantity = fix(additionalQuantity);
end
if ~isa(additionalQuantity, 'double')
    additionalQuantity = double(additionalQuantity);
end

% find matching datefield
dateFieldIdx = find(strncmpi(validfields,dateField,length(dateField)), 1);
if isempty(dateFieldIdx)
    error(message('MATLAB:addtodate:DateField', dateField, sprintf('%s ', validfields{:})));
else
    maxInt = 2073600000; % greatest multiple of millisec/day less than 2^31
    if abs(additionalQuantity) > maxInt
        remBy = [1 1 1 24 1440 86400 86400000]; remBy = remBy(dateFieldIdx);
        dayFrac = dtNumber - floor(dtNumber);
        dtNumber = dtNumber - dayFrac;
        quantityDayFrac = rem(additionalQuantity,remBy);
        additionalQuantity = additionalQuantity - quantityDayFrac;
        delta = maxInt * sign(additionalQuantity);
        for i = 1:fix(additionalQuantity/delta)
            %ICU library interface only deals with int32. Thus we need to loop.
            dtNumber = addtodatemx(dtNumber,delta,dateFieldIdx);
        end
        additionalQuantity = rem(additionalQuantity,maxInt) + quantityDayFrac;
        dtNumber = dtNumber + dayFrac;
    end
    R = addtodatemx(dtNumber,additionalQuantity,dateFieldIdx);
end
