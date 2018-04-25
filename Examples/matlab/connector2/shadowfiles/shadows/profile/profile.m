function varargout=profile(varargin)
%PROFILE Profile execution time for function
%   PROFILE ON starts the profiler and clears previously recorded
%   profile statistics.
%
%   PROFILE takes the following options:
%
%      -TIMER CLOCK
%         This option specifies the type of time to be used in profiling.
%         If CLOCK is 'cpu' (the default), then compute time is measured.
%         If CLOCK is 'real', then wall-clock time is measured.  For
%         example, the function PAUSE will have very small cpu time, but
%         real time that accounts for the actual time paused.
%
%      -HISTORY
%         If this option is specified, MATLAB records the exact
%         sequence of function calls so that a function call
%         history report can be generated.  NOTE: MATLAB will
%         not record more than 1000000 function entry and exit events
%         (see -HISTORYSIZE below).  However, MATLAB will continue
%         recording other profiling statistics after this limit has
%         been reached.
%
%      -NOHISTORY
%         If this option is specified, MATLAB will disable history
%         recording.  All other profiler statistics will continue
%         to be collected.
%
%      -HISTORYSIZE SIZE
%         This option specifies the length of the function call history
%         buffer.  The default is 1000000.
%
%      Options may appear either before or after ON in the same command,
%      but they may not be changed if the profiler has been started in a
%      previous command and has not yet been stopped.
%
%   PROFILE OFF stops the profiler.
%
%   PROFILE RESUME restarts the profiler without clearing
%   previously recorded function statistics.
%
%   PROFILE CLEAR clears all recorded profile statistics.
%
%   S = PROFILE('STATUS') returns a structure containing
%   information about the current profiler state.  S contains
%   these fields:
%
%       ProfilerStatus   -- 'on' or 'off'
%       DetailLevel      -- 'mmex'
%       Timer            -- 'cpu' or 'real'
%       HistoryTracking  -- 'on' or 'off'
%       HistorySize      -- 1000000 (default)
%
%   STATS = PROFILE('INFO') stops the profiler and returns
%   a structure containing the current profiler statistics.
%   STATS contains these fields:
%
%       FunctionTable    -- structure array containing stats
%                           about each called function
%       FunctionHistory  -- function call history table
%       ClockPrecision   -- precision of profiler time
%                           measurement
%       ClockSpeed       -- Estimated clock speed of the cpu (or 0)
%       Name             -- name of the profiler (i.e. MATLAB)
%
%   The FunctionTable array is the most important part of the STATS
%   structure. Its fields are:
%
%       FunctionName     -- function name, includes subfunction references
%       FileName         -- file name is a fully qualified path
%       Type             -- MATLAB function, MEX-function
%       NumCalls         -- number of times this function was called
%       TotalTime        -- total time spent in this function
%       Children         -- FunctionTable indices to child functions
%       Parents          -- FunctionTable indices to parent functions
%       ExecutedLines    -- array detailing line-by-line details (see below)
%       IsRecursive      -- is this function recursive? boolean value
%       PartialData      -- did this function change during profiling?
%                           boolean value
%
%   The ExecutedLines array has several columns. Column 1 is the line
%   number that executed. If a line was not executed, it does not appear in
%   this matrix. Column 2 is the number of times that line was executed,
%   and Column 3 is the total spent on that line. Note: The sum of Column 3
%   does not necessarily add up to the function's TotalTime.
%
%   If you want to save the results of your profiler session to disk, use
%   the PROFSAVE command.
%
%   Examples:
%
%       profile on
%       plot(magic(35))
%       profsave(profile('info'),'profile_results')
%
%       profile on -history
%       plot(magic(4));
%       p = profile('info');
%       for n = 1:size(p.FunctionHistory,2)
%           if p.FunctionHistory(1,n)==0
%               str = 'entering function: ';
%           else
%               str = ' exiting function: ';
%           end
%           disp([str p.FunctionTable(p.FunctionHistory(2,n)).FunctionName]);
%       end
%
%   See also PROFSAVE, PROFVIEW.

%   Copyright 1984-2011 The MathWorks, Inc.

if nargin == 1 && isstr(varargin{1}) && strcmp(varargin{1}, 'viewer')
    nse = connector.internal.argumentNotSupportedError(varargin{1});
    nse.throwAsCaller;

else

    % disable shadow warnings
    warningState = warning('off', 'MATLAB:dispatcher:nameConflict');
	originalDir = cd(fullfile(matlabroot, 'toolbox','matlab','codetools'));

    % on function exit, run cleanup
    c = onCleanup(@()cleanup(originalDir, warningState));

    % run the regular pause command
    if nargout > 0
        varargout = {profile(varargin{:})};
    else
        profile(varargin{:});
    end

end

end

function cleanup(originalDir, warningState)
    cd(originalDir);
    warning(warningState);
end
