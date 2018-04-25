function start(obj)
%START Start timer(s) running.
%
%    START(OBJ) starts the timer running, represented by the timer
%    object, OBJ. If OBJ is an array of timer objects, START starts
%    all the timers. Use the TIMER function to create a timer object.
%
%    START sets the Running property of the timer object, OBJ, to 'On',
%    initiates TimerFcn callbacks, and executes the StartFcn callback.
%
%    The timer stops running when one of the following conditions apply:
%     - The number of TimerFcn callbacks executed equals the number
%       specified by the TasksToExecute property.
%     - The STOP(OBJ) command is issued.
%     - An error occurs while executing a TimerFcn callback.
%
%    See also TIMER, TIMER/STOP.

%    RDD 11-20-2001
%    Copyright 2001-2017 The MathWorks, Inc.

try
    len = length(obj);
    javaTimerArray = obj.getJobjects;
    err = false;
    alreadyRunning = false;
    
    for lcv = 1:len % foreach object in OBJ array
        if (javaTimerArray(lcv).isRunning == 1) % if timer already running, flag as error/warning
            alreadyRunning = true;
        else
            try
                javaTimerArray(lcv).start; % start the timer
            catch exception
                err = true; % flag as error/warning needing to be thrown at end
            end
        end
    end
    
    if (len==1) % if OBJ is singleton, above problems are thrown as errors
        if alreadyRunning
            error(message('MATLAB:timer:alreadystarted'));
        elseif err % throw actual error
            throw(fixexception(exception));
        end
    else % if OBJ is an array, above problems are thrown as warnings
        if alreadyRunning
            state = warning('backtrace','off');
            warning(message('MATLAB:timer:alreadystarted'));
            warning(state);
        elseif err
            state = warning('backtrace','off');
            warning(message('MATLAB:timer:errorinobjectarray'));
            warning(state);
        end
    end
    
catch ME
    if ~all(isvalid(obj))
        if len==1
            error(message('MATLAB:timer:invalid'));
        else
            error(message('MATLAB:timer:someinvalid'));
        end
    else
        rethrow(ME);
    end
end