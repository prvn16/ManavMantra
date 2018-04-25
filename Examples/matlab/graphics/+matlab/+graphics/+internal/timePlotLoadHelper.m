function timePlotLoadHelper(ax)
% This is an undocumented function and may be removed in a future release.

% Copyright 2016-2017 The MathWorks, Inc.

% Swap in datetime or duration rulers as appropriate

% handle the case for hold on in 14b-16a and mixed numeric with time

% Make all non-time children invisible 
isTimeLine = isprop(ax.Children, 'XTimePlotData'); % Absence of X/YTimePlotData property as proxy of non-time line
set(ax.Children(~isTimeLine),'Visible','off'); 

% Grab handle for only the TimeLines for further processing
hTimeLines = ax.Children(isTimeLine);

% Keep only the lines corresponding to the same type as the last (winning) line
isDatetimeLine = false(length(hTimeLines),1);
for i = 1:length(hTimeLines)
    isDatetimeLine(i) = isdatetime(hTimeLines(i).XTimePlotData) || isdatetime(hTimeLines(i).YTimePlotData);
end

if isDatetimeLine(end) % Datetime line comes last, make all non-datetime lines invisible
    set(hTimeLines(~isDatetimeLine),'Visible','off');
    hTimeLines(~isDatetimeLine) = []; % no further processing on non-datetime lines
else % Duration line comes last, make all datetime lines invisible
    set(hTimeLines(isDatetimeLine),'Visible','off');
    hTimeLines( isDatetimeLine) = []; % no further process on datetime lines
end

isXTime = isdatetime(hTimeLines(1).XTimePlotData) || isduration(hTimeLines(1).XTimePlotData);
isYTime = isdatetime(hTimeLines(1).YTimePlotData) || isduration(hTimeLines(1).YTimePlotData);

% Invoke configureRuler to create, configure and attach time ruler in to
% axis corresponding to datetime or duration data
if isXTime
    matlab.graphics.internal.configureRuler(ax,'X',0,hTimeLines(1).XTimePlotData)
end

if isYTime
    matlab.graphics.internal.configureRuler(ax,'Y',1,hTimeLines(1).YTimePlotData)
end

% Copy time data into X/YData and remove X/YTimePlotData dynamic propery
for i = 1:length(hTimeLines)
    if isXTime
        % Copy time data into XData
        hTimeLines(i).XData = hTimeLines(i).XTimePlotData;
    end
    
    if isYTime
        % Copy time data into YData
        hTimeLines(i).YData = hTimeLines(i).YTimePlotData;
    end
    
    % Delete X/YTimePlotData dynamic properties
    delete(findprop(hTimeLines(i), 'XTimePlotData'));
    delete(findprop(hTimeLines(i), 'YTimePlotData'));
    
    % Remove the datacursor behavior object attached so this line
    hTimeLines(i).Behavior = rmfield(hTimeLines(i).Behavior, 'datacursor');
    
    % Remove customized MATLAB code generation in 14b-16a lines
    rmappdata(hTimeLines(i),'MCodeGeneration')
end
end
