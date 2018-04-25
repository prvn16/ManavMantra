function idx = getChildOrder(kids)
%getChildOrder  Get the child order which satisfies dependencies
%
%  Return the order in which to generate code so that all possible variable
%  dependencies between the peers are satisfied.

% Copyright 2012 The MathWorks, Inc.

NumKids = numel(kids);
idx = 1:NumKids;

if NumKids==0
    return
end

% Gather the list of all required and provided variables for each child
% block
Req = cell(1, NumKids);
Prov = cell(1, NumKids);
for n = idx
    [ThisReq, ThisProv] = getVariableUsage(kids(n));   
    
    % Convert all variables to the "active variable" to enable simple
    % equality testing and to ensure we get most up-to-date information on
    % the type of argument
    ThisReq = localConvertToActive(ThisReq);
    ThisProv = localConvertToActive(ThisProv);
    
    if ~isempty(ThisReq)
        % Remove requirements that are not someone's output - these are
        % either not parameters and will become hard-coded strings, or will
        % become parameters of the function.  
        outputs = get(ThisReq, {'IsOutputArgument'});
        ThisReq = ThisReq([outputs{:}]);
    end
    
    % Convert all variables to the "active variable" to enable simple
    % equality testing
    Req{n} = ThisReq;
    Prov{n} = ThisProv;
end

% Filter out requirements that cannot be satisfied because no block at this
% level provides them - for example a reference to a figure handle.  We
% want to do the best we can to satisfy dependencies that can be fixed and
% these unknown requirements interfere with this.
Req = cellfun(@(r) intersect(r, [Prov{:}]), Req, 'UniformOutput', false);

% Go through the required and provided lists, and check for
% unsatisfied dependencies that we can fix by reordering.
idx = zeros(1, NumKids);
Nextidx = 1;
Taken = false(size(idx));
CurrentProvided = [];

AnyDone = true;
while AnyDone && ~all(Taken)
    AnyDone = false;
    for n = 1:NumKids
        if ~Taken(n) ...
            && (isempty(Req{n}) || all(ismember(Req{n}, CurrentProvided)))
            
            AnyDone = true;
            
            % Take this one as the next item
            Taken(n) = true;
            idx(Nextidx) = n;
            Nextidx = Nextidx+1;
            
            if ~isempty(Prov{n})
                % Add the new provided items to those available.
                CurrentProvided = [CurrentProvided Prov{n}];
                
                % Now we have provided more variables, we need to start
                % at the beginning again to see if we have satisfied
                % new requirements
                break
            end
        end
    end
end

if ~all(Taken)
    % We have traversed the list and not found anything more we can add.
    % This means that there is a cycle in the requirement graph.  The
    % remaining items will be left in their current order and done at the
    % end.
    idx(Nextidx:end) = find(~Taken);
end


function hArgs = localConvertToActive(hArgs)
if ~isempty(hArgs)
    % Convert arguments to their "Active" handle
    ActiveVar = get(hArgs, {'ActiveVariable'});
    HasActiveVar = ~cellfun('isempty', ActiveVar);
    ActiveVar = [ActiveVar{:}];
    hArgs(HasActiveVar) = ActiveVar;
end
