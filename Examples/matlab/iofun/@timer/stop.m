function stop(obj)
% STOP Stop timer(s).
%
%    STOP(OBJ) stops the timer, represented by the timer object, 
%    OBJ. If OBJ is an array of timer objects, STOP stops all of
%    the timers. Use the TIMER function to create a timer object. 
%
%    STOP sets the Running property of the timer object, OBJ,
%    to 'Off', halts further TimerFcn callbacks, and executes the 
%    StopFcn callback.
%
%    See also TIMER, TIMER/START.  

%    RDD 11-20-2001
%    Copyright 2001-2017 The MathWorks, Inc. 

len = length(obj);
inval = false;

% for each object...
for lcv = 1:len
    try
        if isvalid(obj(lcv)) && isJavaTimer(obj(lcv).getJobjects)
            obj(lcv).getJobjects.stop; % stop the timer
        else
            inval = true; % flag that an invalid timer object was found.
        end
    catch
    end
end

if inval % at least one OBJ object is invalid
    if (len==1) % if OBJ is singleton, invalid object is thrown as error
        error(message('MATLAB:timer:invalid'));
    else % if OBJ is an array, above invalid object(len) is thrown as warning
        state = warning('backtrace','off');
        warning(message('MATLAB:timer:someinvalid'));
        warning(state);
    end
end