function sfObj = getSFObjFromPath(sfPath)
% GETSFOBJFROMPATH  Helper utility to get the Stateflow object from the path

%    Copyright 2012 MathWorks, Inc.

sfObj = [];
try
    sfObj = get_param(sfPath,'Object');
catch e %#ok<NASGU>
    slashIdx = strfind(sfPath,'/');
    dotIdx = strfind(sfPath,'.');
    subPath = '';
    subName = '';
    
    if ~isempty(slashIdx)
        modelName = sfPath(1:slashIdx(1)-1);
    elseif ~isempty(dotIdx)
        modelName = sfPath(1:dotIdx(1)-1);
    end
    
    % The paths of stateflow objects could be something like
    % modelName/Chart/State.State1/SLfunction or
    % modelName/Chart/State.State1. The intention of the below logic is to
    % figure out on which character it should split the paths - '/' or '.'
    shouldUseSlashInsteadOfDot = ~isempty(dotIdx) && ~isempty(slashIdx) && (dotIdx(end) < slashIdx(end));
    
    if ~isempty(dotIdx) && ~shouldUseSlashInsteadOfDot
        try
            subPath = sfPath(1:dotIdx(end)-1);
            subName = sfPath(dotIdx(end)+1:end);
        catch e2
            rethrow(e2);
        end
    elseif ~isempty(slashIdx)
        try
            subPath = sfPath(1:slashIdx(end)-1);
            subName = sfPath(slashIdx(end)+1:end);
        catch e1
            rethrow(e1);
        end
    end
    
    % Streamed signal names may include ":self", ":leaf", etc.
    pos = strfind(subName, ':');
    if ~isempty(pos)
        subName = subName(1:pos-1);
    end
    
    if isempty(subPath)
        sfObj = [];
        return;
    end
    
    try
        modelObj = get_param(modelName, 'Object');
    catch
        % Model is not loaded, we will not be able to resolve the path.
        return;
    end
    % Find the stateflow object with the Name if not empty and then match
    % the path to identify the correct one.
    if(isempty(subName))
        % this is using the overloaded UDD find method and not the built-in
        % method
        sfObj = find(modelObj, '-isa', 'Stateflow.Object', 'Path', subPath); %#ok<GTARG>
    else
        % this is using the overloaded UDD find method and not the built-in
        % method
        obj = find(modelObj, '-isa', 'Stateflow.Object', 'Name', subName); %#ok<GTARG>
        for i = 1:numel(obj)
            if strcmp(obj(i).Path, subPath)
                sfObj = obj(i);
                break;
            else
                idx = find((obj(i).Path - subPath) > 0);
                % The paths returned by Stateflow objects and what FPT has
                % (via SDI) can differ by a '.' For example, Stateflow path
                % can be modelName/Chart/State/State1 while SDI can
                % represent the same path as modelName/Chart/State.State1 
                % We need to look for this character difference to see if there is a match
                if numel(idx) == 1 && strcmp(subPath(idx),'.')
                    sfObj = obj(i);
                    break;
                end
            end
        end
    end
end

%-----------------------------------------------------------------------------------

