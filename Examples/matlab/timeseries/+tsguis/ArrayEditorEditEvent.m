function thisTs = ArrayEditorEditEvent(thisTs,row,col,newValue)

% Copyright 2006-2017 The MathWorks, Inc.

%% Get objects
e = thisTs.Events(row+1);
if col==1 % EventData
    try
        if ischar(newValue)
            evaluatedValue = evalin('base',newValue);
        else
            evaluatedValue = newValue;
        end
    catch
        return;
    end
elseif col==2 % Time
    if isempty(e.StartDate)
        if ischar(newValue)
            evaluatedValue = evalin('base',newValue);
        else
            evaluatedValue = newValue;
        end
    else % Check that newValue is a valid date
        junk = datenum(newValue);
    end
end

switch col
    case 0 % Name
        thisTs.Events(row+1).Name = newValue;
    case 1 % EventData
        thisTs.Events(row+1).EventData = evaluatedValue;
    case 2 % Time
        if isempty(thisTs.Events(row+1).StartDate)
            thisTs.Events(row+1).Time = evaluatedValue;
            thisTs.Events(row+1).StartDate = '';
        else
            thisTs.Events(row+1).Time = 0;
            thisTs.Events(row+1).StartDate = newValue;
        end
end