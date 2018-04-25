function wait(obj)
%WAIT Wait until the timer stops running.
%
%    WAIT(OBJ) blocks the MATLAB command line and waits until the
%    timer, represented by the timer object OBJ, stops running. 
%    When a timer stops running, the value of the timer object's
%    Running property changes from 'On' to 'Off'.
%
%    If OBJ is an array of timer objects, WAIT blocks the MATLAB
%    command line until all the timers have stopped running.
%
%    If the timer is not running, WAIT returns immediately.
%
%    See also TIMER/START, TIMER/STOP.
%

%    Copyright 2001-2017 The MathWorks, Inc.

if ~all(isvalid(obj))
    error(message('MATLAB:timer:invalid'));
end

len = length(obj);

% foreach object, check end-times for naturally never-ending timers
for lcv = 1:len
    try 
        t = endtime(obj(lcv).getJobjects); % estimate soonest end time
    catch exception
        throw(fixexception(exception));
    end
    % check if timer is never-ending
    if ~isfinite(t)
        error(message('MATLAB:timer:infinitetimer'));
    end
end

% wait for the end of each timer.
for lcv = 1:len
    if strcmp(get(obj(lcv).getJobjects,'ExecutionMode'),'singleShot')
        time = 0.01;
    else
        time = get(obj(lcv).getJobjects,'Period');
        if (time<0.01)
            time = 0.01;
        end    
    end
    
    while obj(lcv).getJobjects.isRunning
        pause(time);
    end
end

return;


function time = endtime(obj)
% if singleShot, can't determine endtime
if strcmp(get(obj,'ExecutionMode'),'singleShot')
    time = 0.01;
else
    rate = get(obj,'Period');
    repeat = get(obj,'TasksToExecute');
    task = get(obj,'TasksExecuted');
    time = (repeat-task-1)*rate;
    % forces a minimum wait of 10ms. 
    if (time<0.01)
        time = 0.01;
    end
end

