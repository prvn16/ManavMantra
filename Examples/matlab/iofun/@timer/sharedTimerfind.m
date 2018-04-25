function output = sharedTimerfind(timerObject, varargin)

if isa(timerObject, 'timer')
    % Check to see if the given object is all invalid
    if all(~isvalid(timerObject))
        output = []; % Return empty if all input timer handles are invalid
        return;
    end
    jobjs = timerObject.getJobjects;
    % set the remaining 
    findparam = varargin(1:end);
    idxsIntoTimerObject = 1:numel(jobjs);
else
    error(message('MATLAB:timer:invalid'));
end

% call find on the java objects
% filter invalid java timer & find ('find' overloaded built-in in TimerTask)
if ~isempty(findparam)
    done = false;
    while(~done)
        try
            jobjsFound = find(jobjs(isJavaTimer(jobjs)),findparam);
            idxsIntoTimerObject = false(size(jobjsFound));
            for i = 1:numel(jobjsFound)
                idxsIntoTimerObject(jobjs == jobjsFound(i)) = true;
            end
            done = true;
        catch ME
            % can only error in find, if find errored, then return to top.
            if(~strcmp(ME.identifier,'MATLAB:class:InvalidHandle'))
                throw(ME);
            end
        end
    end
end

% if nothing found, return empty set, otherwise return the timer object.
if (isempty(jobjs))
    output = [];
else
    output = timerObject(idxsIntoTimerObject);
end

