function out = urlfilter(varargin)
%URLFILTER  Scrape one or more numbers off of a web page
%   num = urlfilter(url, target) returns the first number that appears
%   after the target string.
%   num = urlfilter(url, target, numNumbers) returns a list of numbers that
%   appears after the target string.
%   num = urlfilter(url, target, numNumbers, direction) target is the
%   string that should appear right before the number in question. The
%   algorithm will continue grabbing numbers until numNumbers have been
%   grabbed or the end of the file has been reached.
%   direction is the direction, either "forward" or "backward" to search
%   from the target string. The default is "forward".
%
%   Numbers inside tag bodies (i.e. anything inside <..> angle braces) are
%   ignored.
%
%   Example:
%   url = 'https://www.mathworks.com/matlabcentral/trendy/Tutorial/trendco.html';
%   urlfilter(url,'Total Widgets')


% Copyright 2012-2017 The MathWorks, Inc.

runFromFolder = pwd;
finishup = onCleanup(@() cd(runFromFolder));

out = [];
% Check if the mltbx has been installed
try
    out = tsfcncallrouter('urlfilter', varargin);
catch err
    throwAsCaller(err);
end