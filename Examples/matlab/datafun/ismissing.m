function IA = ismissing(A,indicators)
%ISMISSING   Find missing entries
%   First argument must be numeric, datetime, duration, calendarDuration,
%   string, categorical, character array, cell array of character vectors,
%   a table, or a timetable.
%   Standard missing data is defined as:
%      NaN                   - for double and single floating-point arrays
%      NaN                   - for duration and calendarDuration arrays
%      NaT                   - for datetime arrays
%      <missing>             - for string arrays
%      <undefined>           - for categorical arrays
%      blank character [' '] - for character arrays
%      empty character {''}  - for cell arrays of character vectors
%
%   IA = ISMISSING(A) returns a logical array IA indicating the standard
%   missing values found in A. IA has the same size as A.
%
%   IA = ISMISSING(A,INDICATORS) uses the entries in INDICATORS to specify
%   which entries of A are treated as missing data. Use INDICATORS to find
%   non-standard missing values. If A is an array, INDICATORS must be a
%   vector. If A is a table, INDICATORS can also be a cell with entries of
%   different types.
%
%   Double entries in INDICATORS match double, single, integer, and logical
%   entries in A. Single, integer, and logical entries in INDICATORS match
%   single, integer, and logical entries in A, respectively.
%
%   String, character, and cell array of character vectors INDICATORS match
%   string entries in A. 
%
%   Character, duration, and datetime entries in INDICATORS match
%   character, duration, and datetime entries in A, respectively. 
%
%   String and character INDICATORS also match categorical entries in A.
%
%   You can include NaN, NaT, the missing string, the empty character '',
%   or '<undefined>' in INDICATORS to also find standard missing values.
%
%   Integers cannot store NaN, therefore you must include a special unused
%   integer value in INDICATORS to find missing integer data in A.
%
%   Examples:
%
%     % IA is TRUE for the entries of A that are NaN
%       A = [NaN 1 2 NaN NaN 3]
%       IA = ismissing(A)
%
%     % IA is TRUE for the entries of A that are missing strings
%       A = string({'Mercury','Gemini'}); A(5) = 'Apollo'
%       IA = ismissing(A)
%
%     % Find both standard (NaN and <undefined>) and non-standard
%     % (-99 and '--') missing entries in table T.
%     % Use the '' indicator to find the <undefined> categorical entry.
%       temperature = [21.1 21.5 NaN 23.1 25.7 24.1 25.3 NaN 24.1 25.5]';
%       windSpeed = [12.9 13.3 12.1 13.5 10.9 -99 -99 12.2 10.8 17.1]';
%       windDirection = categorical({'W' 'SW' 'SW' '' 'SW' 'S' ...
%                         'S' 'SW' 'SW' 'SW'})';
%       conditions = {'PTCLDY' '--' '--' 'PTCLDY' 'FAIR' 'CLEAR' ...
%                         'CLEAR' 'FAIR' 'PTCLDY' 'MOSUNNY'}';
%       T = table(temperature,windSpeed,windDirection,conditions)
%       IT = ismissing(T,{NaN -99 '' '--'})
%
%   See also FILLMISSING, RMMISSING, STANDARDIZEMISSING, ISNAN, ISNAT,
%            ISOUTLIER, ISLOCALMAX, ISLOCALMIN, ISCHANGE

%   Copyright 2012-2017 The MathWorks, Inc.

if nargin <= 1
    IA = matlab.internal.math.ismissingKernel(A);
else
    IA = matlab.internal.math.ismissingKernel(A,indicators,false);
end