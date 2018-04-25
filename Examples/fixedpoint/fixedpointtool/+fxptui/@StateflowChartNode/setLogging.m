function setLogging(this, state, scope, depth)
% SETLOGGING Turn on signal logging on the system

% Copyright 2013 MathWorks, Inc

    if(strcmp(scope, 'OUTPORT'))
        this.setLoggingOnOutports(state);
        return;
    end
    
    if strcmp(scope, 'All') || strcmp(scope, 'NAMED') || strcmp(scope, 'UNNAMED')
        ch = this.getHierarchicalChildren;
        for i = 1:length(ch)
            if isa(ch(i).DAObject,'Simulink.SubSystem')
                % If the child is a simulink subsystem, turn on logging in that system first.
                ch(i).setLogging(state,scope,1);
            end
            hch = ch(i).getHierarchicalChildren;
            for k = 1:length(hch)
                if isa(hch(k).DAObject,'Simulink.SubSystem')
                    hch(k).setLogging(state,scope,depth);
                end
            end
        end
    end
    
    % All stateflow signals are named. So, if you are enabling logging of unnamed signals,
    % skip this part.
    if ~strcmp(scope,'UNNAMED')
        blk = fxptui.getPath(this.DAObject.getFullName);
        sigprops = get_param(blk, 'AvailSigsInstanceProps');
        for idx = 1:numel(sigprops.Signals)
            sigprops.Signals(idx).LogSignal = strcmpi('On', state);
        end
        set_param(blk, 'AvailSigsInstanceProps', sigprops);
    end
end
