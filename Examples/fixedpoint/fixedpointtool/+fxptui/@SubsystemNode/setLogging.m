function setLogging(this, state, scope, depth)
% SETLOGGING set signal logging to STATE for all blocks in the
%selected subsystem having SCOPE and DEPTH

%STATE = 'on' or 'off', SCOPE = 'OUTPORT', 'NAMED', 'UNNAMED', 'ALL' or
%'NONE', DEPTH = 1 or Inf.
%Examples:
%h.setlogging('on', 'NAMED', Inf), turns signal logging on all named
%signals from this system down
%h.setlogging('on', 'ALL', 1), turns signal logging on all signals in this
%system
%h.setlogging('off', 'UNNAMED', Inf), turns signal logging off all unnamed
%signals in this system

% Copyright 2013-2015 The MathWorks, Inc.

    narginchk(4,4);
    %if scope = OUTPORT set outport logging and return
    if(strcmp('OUTPORT', scope))
        this.setLoggingOnOutports(state);
        return;
    end
    %set logging on first level hierarchical children recursively. if DEPTH=Inf
    %set logging from here down.
    if depth == Inf
        %get the tree nodes belonging to H
        hchildren = this.getHierarchicalChildren;
        %for each node belonging to H call SETLOGGING on it
        for idx = 1:numel(hchildren)
            subsys = hchildren(idx);
            subsys.setLogging(state, scope, depth);
        end
    end
    %always set logging on H DEPTH=1
    if(~this.isParentLinked && ~this.DAObject.isLinked)
        locSetLogging(this, state, scope);
    end
end
%--------------------------------------------------------------------------
function locSetLogging(this, state, scope)
    blks = find(this.DAObject, '-depth', 1, '-isa', 'Simulink.Block'); %#ok<GTARG>
    for blksIdx = 1:numel(blks)
        blk = blks(blksIdx);
        if(~isLoggable(this, blk)); 
            continue;
        end
        ports = blk.PortHandles.Outport;
        for portsIdx = 1:numel(ports)
            outport = get_param(ports(portsIdx), 'Object');
            switch scope
              case 'NAMED'
                %skip unnamed signals
                if(~isNamedSignal(outport))
                    continue;
                end
              case 'UNNAMED'
                %skip named signals
                if(isNamedSignal(outport))
                    continue;
                end
              otherwise
                %log all signals
            end
            outport.DataLogging = state;
        end
    end
end
%--------------------------------------------------------------------------
function b = isNamedSignal(p)
    b = ...
        (strcmpi('SignalName', p.DataLoggingNameMode) && ~isempty(p.Name)) || ...
        (strcmpi('Custom', p.DataLoggingNameMode) && ~isempty(p.DataLoggingName));
end
%--------------------------------------------------------------------------
function b = isLoggable(this,blk)
% These are blocks that can cause the signal logging mechanism to error
% out. 
    b = ...
        ~isequal(this.DAObject, blk) && ...
        ~isa(blk, 'Simulink.Mux') && ...
        ~isa(blk,'Simulink.FrameConversion') && ...
        ~strcmpi(blk.MaskType,'Frame Status Conversion') && ... 
        ~strcmpi(blk.MaskType,'Signal From workspace') && ...
        ~strcmpi(blk.MaskType, 'DSP Constant') && ...
        ~strcmpi(blk.MaskType, 'Enabled And Triggered Subsystem') && ...
        ~strcmpi(blk.MaskType, 'Function-Call Subsystem') && ...
        ~strcmpi(blk.MaskType, 'Triggered Subsystem') && ...
        ~strcmpi(blk.MaskType, 'Enabled Subsystem') && ...
        ~strcmpi(blk.MaskType, 'Triggered Delay Line') && ...
        ~strcmpi(blk.MaskType, 'Fast Block LMS Filter') && ...
        ~strcmpi(blk.MaskType, 'RLS filter') && ...
        ~strcmpi(blk.MaskType, 'Overlap-Add FFT Filter') && ...
        ~strcmpi(blk.MaskType, 'Convert 1-D to 2-D') && ...
        ~strcmpi(blk.MaskType, 'Convert 2-D to 1-D') && ...
        ~strcmpi(blk.MaskType, 'Detrend') && ...
        ~strcmpi(blk.MaskType, 'Event-Count Comparator');  
end
