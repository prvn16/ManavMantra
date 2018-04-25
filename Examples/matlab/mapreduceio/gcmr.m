function mr = gcmr(varargin)
%GCMR Get the current mapreduce execution environment.
%
%   mr = gcmr returns the current mapreduce execution environment. If a
%   mapreduce execution environment does not already exist, this will create
%   the default mapreduce execution environment.
%
%   mr = gcmr('nocreate') returns the current mapreduce execution
%   environment if it exists, otherwise it will return empty.
%
%   The current mapreduce execution environment can be set using the
%   MAPREDUCER function. This will be used by the MAPREDUCE function if no
%   explicit execution environment is provided to it.
%
%   See also mapreduce, mapreducer.

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.mapreduce.internal.MapReducerManager;

narginchk(0,1);

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end
if nargin == 1
    validatestring(varargin{1}, {'nocreate'}, mfilename, '', 1);
end

mr = getCurrent(MapReducerManager.getCurrentManager());
if isempty(mr) && (nargin == 0)
    mr = mapreducer();
end
