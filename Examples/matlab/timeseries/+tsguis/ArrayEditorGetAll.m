function [nameVal,eventVector,currentTimeStr] = ArrayEditorGetAll(thisTs)

% Copyright 2006-2017 The MathWorks, Inc.

import java.util.*;

%% Get name
nameVal = thisTs.Name;

%% Create events Vecotr
eventVector = Vector;
if ~isempty(thisTs.Events)
    eventDataJavaArray = workspacefunc('getshortvalueobjectsj',...
        get(thisTs.Events,{'EventData'}));
end
for k=1:length(thisTs.Events)
    rowVector = Vector;
    rowVector.addElement(thisTs.Events(k).Name);
    rowVector.addElement(eventDataJavaArray(k));
    if isempty(thisTs.Events(k).StartDate)
        rowVector.addElement(thisTs.Events(k).Time);
    else
        rowVector.addElement(java.lang.String(thisTs.Events(k).getTimeStr));
    end
    eventVector.addElement(rowVector);
end

%% Get current time string
currentTimeStr = getTimeStr(thisTs.TimeInfo);