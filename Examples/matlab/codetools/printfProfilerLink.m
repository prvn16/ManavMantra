function output = printfProfilerLink(cmd, text, varargin)
%PRINTFPROFILERLINK Print a profiler html link string from a command,
%text and variable length input which is the argument to the command

% Copyright 2016 The MathWorks, Inc.

    output = sprintf(['<a href="matlab: ' cmd '">' text '</a>'], varargin{:});
end