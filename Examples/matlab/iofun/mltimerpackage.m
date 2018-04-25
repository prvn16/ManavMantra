function output = mltimerpackage(option, tobj)

% Copyright 2004-2017 The MathWorks, Inc.

% Policy:
% DO NOT ASSUME that all returned timers are valid.
% 1. Executes the GetList/Add/Delete/Count options.
% 2. Guarantees that the timers that were invalid before the call to this
% function will be removed before returning from this function.
% 3. Timers that become invalid during the execution of this function may
% also be deleted but the removal is not guaranteed.

persistent state
if isempty(state), state = initPackage(); end
mlock;

init_state = state.sentinal;
try
    if ~state.sentinal && ~isempty(state.toAdd)
        state.sentinal = true;
        [state.list, state.toAdd] = addToList(state.list,state.toAdd);
        state.sentinal = false;
    end
    
    if strcmpi(option,'GetList')
        state.list = state.list(isvalid(state.list));
        output = state.list(isvalid(state.list));
    elseif strcmpi(option, 'Add')
        state.toAdd = [state.toAdd; tobj(:)];
        if ~state.sentinal % Another instance of mltimerpackage is running, don't add these yet, wait
            state.sentinal = true;
            [state.list, state.toAdd] = addToList(state.list,state.toAdd);
            state.sentinal = false;
        end
    elseif strcmpi(option, 'Delete')
        if ~state.sentinal % If there are elements to be removed, get them next time
            state.sentinal = true;
            % Use a temp list since this function can be interuppted by a callback
            % which can remove or add elements from the list.
            state.list = remove(state.list,tobj);
            state.sentinal = false;
        end
    elseif strcmpi(option, 'Count')
        state.list = state.list(isvalid(state.list));
        output = length(state.list)+length(state.toAdd);
    else
        if (ischar(option))
            error(message('MATLAB:mltimerpackage:UnknownFirstArg'));
        else
            error(message('MATLAB:mltimerpackage:IllegalFirstArg'));
        end
    end
catch ME
    state.sentinal = init_state;
    rethrow(ME)
end

end

function state = initPackage()
state.toAdd = [];
jobj = handle(com.mathworks.timer.TimerTask);
jobj.Name = 'timer-root';
state.list = timer(jobj);
state.sentinal = false;
end

function list = remove(list,tobj)
[~,heq] = eq(list,tobj);
list = list(~heq & isvalid(list));
end
            
function [list,toAdd] = addToList(list,toAdd)
len = length(toAdd);
for i = len:-1:1
    if isa(toAdd(i),'timer')
        list(end+1) = toAdd(i); %#ok<AGROW>
    end
end
toAdd = [];
end