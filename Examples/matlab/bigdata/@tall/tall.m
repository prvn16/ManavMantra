%tall Tall arrays and tables
%   T = TALL(DS) creates tall array T that represents the data contained
%   in datastore DS. If DS contains tabular data, then T is a tall table.
%   Otherwise, T is a tall cell array.
%
%   T = TALL(X) converts the in-memory array X into a tall array T.
%
%   Tall arrays are used to work with out-of-memory data. After creating a
%   datastore, you can create a tall array from the datastore. Tall arrays
%   let you work with large data sets the same as you would with normal
%   MATLAB arrays.
%
%   MATLAB does not perform most operations on tall arrays immediately.
%   These operations appear to execute quickly, because the actual
%   computation is deferred until the GATHER function is used on a
%   subsequent tall array. This delayed evaluation is important because
%   even using SIZE(X) on a tall array with a billion rows is not a quick
%   calculation.
%
%   As you work with tall arrays, MATLAB keeps track of all of the
%   operations to be carried out and optimizes the number of passes through
%   the data. The operations are performed when you explicitly request
%   output with GATHER. Thus, it is normal to work with unevaluated tall
%   arrays and request output only when you require it.
%
%   The GATHER function forces evaluation of all queued operations and
%   brings the resulting output back into memory. Since GATHER returns the
%   entire result in MATLAB, you should make sure that the result will fit
%   in memory. Calling GATHER on an unreduced tall array can cause MATLAB
%   to run out of memory. It is most useful to use GATHER on tall arrays
%   that are the result of a function that reduces the size of the tall
%   array, such as SUM, MIN, MEAN, and so on...
%
%   Tall arrays can be numeric, logical, datetime, duration,
%   calendarDuration, categorical, or strings. Some of the functions and
%   operations defined for tall arrays include:
%
%    Standard numeric functions: ABS, SIN, COS, EXP, LOG, ...
%         Summarizing functions: SUM, MIN, MAX, MEAN, STD, ...
%          Arithmetic operators: +, -, .*, ./
%             Logical operators: <, <=, >, >=, ==, ~=, ~
%                        String: STRREP, STRTRIM, STR2DOUBLE, ...
%                      Datetime: DATESHIFT, HOUR, YEAR, ...
%                   Categorical: ADDCATS, REORDERCATS, ...
%                 Visualization: HISTOGRAM, HISTOGRAM2
%
%   Likewise, some of the functions defined for tall tables and tall
%   timetables include the following tall methods:
%
%      HEIGHT - number of rows in the tall table or timetable
%       WIDTH - number of variables (columns) in the tall table or timetable
%       NUMEL - returns HEIGHT * WIDTH
%        SIZE - returns the size of the tall table or timetable
%     ISEMPTY - determine if tall table or timetable is empty
%     SUMMARY - displays summary information about the tall table
%
%   Functions specific to tall tables, tall timetables, and tall arrays
%   include the following tall methods:
%
%      GATHER - force evaluation and return an ordinary array
%        HEAD - return the first few rows as an ordinary array
%        TAIL - return the last few rows as an ordinary array
%    TOPKROWS - return top K rows of a tall table
%
%   The full list of operations supported for tall arrays can be accessed
%   with the command:
%
%     methods tall
%
%   Example:
%      % Create a datastore.
%      varnames = {'ArrDelay', 'DepDelay', 'Origin', 'Dest'};
%      ds = datastore('airlinesmall.csv', 'TreatAsMissing', 'NA', ...
%         'SelectedVariableNames', varnames);
%
%      % Create a tall table from the datastore.
%      tt = tall(ds)
%
%      % Extract a variable from the tall table. arrDelay is a 
%      % tall array. 
%      arrDelay = tt.ArrDelay
%
%      % Clean up NaN values in the tall array.
%      arrDelay(isnan(arrDelay)) = [];
%
%      % Calculate the range of arrDelay:
%      delayRange = [min(arrDelay), max(arrDelay)];
%
%      % Force evaluation of delayRange
%      localDelayRange = gather(delayRange)
%
%   See also: DATASTORE, TABLE, TIMETABLE, TALL/GATHER.

% Copyright 2015-2016 The MathWorks, Inc.
