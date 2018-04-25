function [B,I] = rmmissing(A,varargin)
%RMMISSING   Remove rows or columns with missing entries
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
%   B = RMMISSING(A) removes missing entries from a vector, or rows with
%   missing entries from a matrix or table.
%
%   B = RMMISSING(A,DIM) reduces the size of A along the dimension DIM.
%   DIM = 1 removes rows, and DIM = 2 removes columns with missing entries.
%   If A is a table, DIM = 2 removes table variables. By default, RMMISSING
%   reduces the size of A along its first non-singleton dimension: it
%   removes rows from matrices and tables.
%
%   B = RMMISSING(A,...,'MinNumMissing',N) removes rows (columns) that
%   contain at least N missing entries. N must be an integer. By default,
%   N = 1.
%
%   [B,I] = RMMISSING(A,...) also returns a logical row (column) vector I
%   indicating which rows (columns) of A were removed.
%
%   Arguments supported only for table inputs:
%
%   B = RMMISSING(A,...,'DataVariables',DV) removes rows according to
%   missing data in table variables DV. The default is all table variables
%   in A. DV must be a table variable name, a cell array of table variable
%   names, a vector of table variable indices, a logical vector, or a
%   function handle that returns a logical scalar (such as @isnumeric).
%
%   Examples:
%
%     % Remove NaN entries from a vector
%       a = [NaN 1 2 NaN NaN 3]
%       b = rmmissing(a)
%
%     % Remove only rows that contain at least 2 missing entries
%       A = [NaN(1,3); 13 1 -20; NaN(4,1) ones(4,2); -1 7 -10; NaN(1,3)]
%       B = rmmissing(A,'MinNumMissing',2)
%
%     % Remove table rows that contain standard missing data
%       v1 = {'AB'; ''; ''; 'XYZZ'; 'CDE'};
%       v2 = [NaN; -1; 8; 10; 4];
%       v3 = categorical({'yes'; '--'; 'yes'; 'no'; 'yes'},{'yes' 'no'});
%       T = table(v1,v2,v3)
%       U = rmmissing(T)
%
%     % Ignore rows with NaN entries when using sortrows
%       a = [ [20 10 NaN 30 -5]', [1:5]' ]
%       [b,ia] = rmmissing(a)
%       a(~ia,:) = sortrows(b)
%
%   See also ISMISSING, STANDARDIZEMISSING, FILLMISSING, ISNAN, ISNAT

%   Copyright 2015-2016 The MathWorks, Inc.

[A,AisTable,byrows,kount,dataVars,allVars] = parseInputs(A,varargin{:});

if ~AisTable
    I = ismissing(A);
    I = cumputeIndex(I,byrows,kount);
else
    if ~all(varfun(@ismatrix,A,'OutputFormat','uniform'))
        error(message('MATLAB:rmmissing:NDArrays'));
    end
    if byrows
        if allVars
            I = ismissing(A);
        else
            I = ismissing(A(:,dataVars));
        end
        I = cumputeIndex(I,byrows,kount);
        if isa(A,'timetable')
            % Also remove the rows that correspond to missing RowTimes
            I = I | ismissing(A.Properties.RowTimes);
        end
    else
        I = false(1,width(A));
        for vj = dataVars
            Ivj = ismissing(A(:,vj));
            I(vj) = cumputeIndex(Ivj,byrows,kount);
        end
    end
end
B = reduceSize(A,I,byrows);

%--------------------------------------------------------------------------
function I = cumputeIndex(I,byrows,kount)
if byrows
    I = sum(I,2) >= kount;
else
    I = sum(I,1) >= kount;
end 
end
%--------------------------------------------------------------------------
function B = reduceSize(A,I,byrows)
% Keep non-missing
if byrows
    B = A(~I,:);
else
    B = A(:,~I);
end
end
%--------------------------------------------------------------------------
function [A,AisTable,byrows,kount,dataVars,allVars]=parseInputs(A,varargin)
% Parse RMMISSING inputs
AisTable = matlab.internal.datatypes.istabular(A);
if ~isnumeric(A) && ~islogical(A) && ...
   ~ischar(A) && ~iscategorical(A) && ~iscellstr(A) && ~isstring(A) && ...
   ~isdatetime(A) && ~isduration(A) && ~iscalendarduration(A) && ...
   ~AisTable
    error(message('MATLAB:rmmissing:FirstInputInvalid'));
end
if ~ismatrix(A)
    error(message('MATLAB:rmmissing:NDArrays'));
end
% Defaults
kount = 1;
byrows = true;
allVars = true; % use all table variables
if ~AisTable
    if isrow(A) && ~isscalar(A)
        byrows = false;
    end
    dataVars = []; % not supported for arrays
else
    dataVars = 1:width(A);
end

if nargin > 1
    input2 = varargin{1};
    offsetNV = 1; % N-V pairs start at 3rd and 4th inputs
    if (ischar(input2) || (isstring(input2) && isscalar(input2))) && nargin > 2
        % rmmissing(A,'MinNumMissing',M)
        offsetNV = 0; % N-V pairs start at 2nd and 3rd inputs
    else
        % rmmissing(A,DIM,...)
        if (isnumeric(input2) || islogical(input2)) && isscalar(input2) 
            if input2 == 1
                byrows = true;
            elseif input2 == 2
                byrows = false;
            else
                error(message('MATLAB:rmmissing:DimensionInvalid'));
            end
        else
            error(message('MATLAB:rmmissing:DimensionInvalid'));
        end
    end
    % Parse N-V pairs
    if nargin > 2
        indNV = (1+offsetNV):numel(varargin);
        if rem(length(indNV),2) ~= 0
            error(message('MATLAB:rmmissing:NameValuePairs'));
        end
        for i = indNV(1:2:end)
            opt = varargin{i};
            if matlab.internal.math.checkInputName(opt,'MinNumMissing')
                kount = varargin{i+1};
                if (~isnumeric(kount) && ~islogical(kount)) || ~isscalar(kount) || ~isreal(kount) || fix(kount) ~= kount || ~(kount >= 0)
                    error(message('MATLAB:rmmissing:MinNumMissing'));
                end
            elseif matlab.internal.math.checkInputName(varargin{i},'DataVariables')
                allVars = false;
                if AisTable
                    dataVars = matlab.internal.math.checkDataVariables(A,varargin{i+1},'rmmissing');
                else
                    error(message('MATLAB:rmmissing:DataVariablesArray'));
                end
            else
                error(message('MATLAB:rmmissing:NameValueNames'));
            end
        end
    end
end
end % parseInputs
end % rmmissing