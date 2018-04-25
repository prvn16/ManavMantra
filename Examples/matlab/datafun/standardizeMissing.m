function B = standardizeMissing(A,indicators,varargin)
%STANDARDIZEMISSING   Convert to standard missing data
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
%   B = STANDARDIZEMISSING(A,INDICATORS) converts entries in A to standard
%   missing values. INDICATORS specifies which values in A are not standard
%   missing values. If A is an array, INDICATORS must be a vector. If A is
%   a table, INDICATORS can also be a cell with entries of different types.
%
%   Double entries in INDICATORS match double, single, integer, and logical
%   entries in A. Single, integer, and logical entries in INDICATORS match
%   single, integer, and logical entries in A, respectively.
%
%   String, character, duration, and datetime entries in INDICATORS match
%   string, character, duration, and datetime entries in A, respectively.
%
%   String and character INDICATORS also match categorical entries in A.
%
%   STANDARDIZEMISSING cannot replace integer and logical entries in A with
%   NaN because integers and logicals cannot store NaN.
%
%   Arguments supported only for table inputs:
%
%   B = STANDARDIZEMISSING(A,INDICATORS,'DataVariables',DV) replaces values
%   only in the table variables specified by DV. The default is all table
%   variables in A. DV must be a table variable name, a cell array of table
%   variable names, a vector of table variable indices, a logical vector,
%   or a function handle that returns a logical scalar (such as
%   @isnumeric). Output table B has the same size as input table A.
%
%   Examples:
%
%     % Standardize missing entries in arrays
%       A = magic(5); A(1) = NaN; A([10 12 13]) = -99; A([3 21 24]) = 999
%       B = standardizeMissing(A,[-99 999])
%
%     % Standardize missing entries in tables
%       temperature = [21.1 21.5 -99 23.1 25.7 24.1 25.3 -99 24.1 25.5]';
%       windSpeed = [12.9 13.3 12.1 13.5 10.9 999 999 12.2 10.8 17.1]';
%       windDirection = categorical({'W' 'SW' 'SW' '' 'SW' 'S' ...
%                         'S' 'SW' 'SW' 'SW'})';
%       conditions = {'PTCLDY' 'N/A' 'N/A' 'PTCLDY' 'FAIR' 'CLEAR' ...
%                         'CLEAR' 'FAIR' 'PTCLDY' 'MOSUNNY'}';
%       T = table(temperature,windSpeed,windDirection,conditions)
%       U = standardizeMissing(T,{-99 999 'N/A'})
%
%   See also ISMISSING, RMMISSING, FILLMISSING, ISNAN, ISNAT, ISUNDEFINED

%   Copyright 2012-2016 The MathWorks, Inc.

if nargin <= 2
    B = matlab.internal.math.ismissingKernel(A,indicators,true);
else
    if ~matlab.internal.datatypes.istabular(A)
        error(message('MATLAB:standardizeMissing:DataVariablesArray'));
    end
    if rem(numel(varargin),2) ~= 0
        error(message('MATLAB:standardizeMissing:NameValuePairs'));
    end
    for i = 1:2:numel(varargin)
        if matlab.internal.math.checkInputName(varargin{i},'DataVariables')
            dataVars = matlab.internal.math.checkDataVariables(A,varargin{i+1},'standardizeMissing');
        else
            error(message('MATLAB:standardizeMissing:NameValueNames'));
        end
    end
    B = matlab.internal.math.ismissingKernel(A,indicators,true,dataVars);
end