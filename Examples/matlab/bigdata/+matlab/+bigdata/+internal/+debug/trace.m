function ds = trace(location, varargin)
% Annotate execution of a tall array to generate a trace of execution
% stored on disk.
%
% Syntax:
%   matlab.bigdata.internal.debug.trace(LOCATION) enables trace logging,
%   with all log output stored at the given location. LOCATION can be a
%   local path or a URL.
%
%   matlab.bigdata.internal.debug.trace('off') disables trace logging.
%
%   matlab.bigdata.internal.debug.trace('info') returns a datastore to all
%   of the trace log entries.
%
%   matlab.bigdata.internal.debug.trace(..,'KeepData',K) controls how much
%   of the input/output to keep. This can be:
%    * 'All' for the entirety of input/output.
%    * 'Slice' for a single slice per chunk of input/output. This is the
%    default.
%    * 'None' for no slices per chunk of input/output.
%
% This will generate a timetable of the event entries stored across several
% MAT or SEQ files. Use datastore to read these into MATLAB.
%
% This can be used for all tall array execution environments.

%   Copyright 2017 The MathWorks, Inc.

persistent LOGGER_OBJECT

if isequal(location, 'info')
    assert(~isempty(LOGGER_OBJECT), 'Trace logger is not active.');
    ds = datastore([LOGGER_OBJECT.OutputFolder, '/*/*']);
    return;
end

delete(LOGGER_OBJECT);
LOGGER_OBJECT = [];
mlock;

if ~isequal(location, 'off')
    LOGGER_OBJECT = matlab.bigdata.internal.debug.TraceLogger(location, varargin{:});
end
