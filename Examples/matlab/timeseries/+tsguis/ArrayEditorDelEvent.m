function thisTs = ArrayEditorDelEvent(thisTs,rows)

% Copyright 2006-2017 The MathWorks, Inc.

%% Deletes an event from a timeseries. Called from the Variable Editor.
e = thisTs.Events;
e(rows+1) = [];
thisTs.Events = e;