function enableSignalLoggingForSUD(me)
% ENABLESIGNALLOGGINGFORSUD Turns on the signal logging for the inputs and
% outputs of the system selected for conversion. It will only turn on the
% signals that aren't logged in the system.

% Copyright 2014 The MathWorks, Inc.

blkObj = me.SystemUnderDesign;
modelNode = me.getTopNode;
conversionNode = me.ConversionNode;
if ~isempty(conversionNode)
    % Enable signal logging at the top model
    modelNode.enableSignalLog;
    
    if isa(conversionNode, 'fxptui.ModelNode')
        conversionNode.setLogging('On', 'ALL', 1);
    else
        % Set up signal logging for input & output of the SUD.
        outports = get_param(blkObj.PortHandles.Outport, 'Object');
        inports = get_param(blkObj.PortHandles.Inport, 'Object');
        
        for i = 1:numel(outports)
            port = outports(i);
            if(iscell(port));
                port = port{:};
            end
            if ~strcmpi(port.DataLogging,'on')
                me.LoggedOutportSignals = [me.LoggedOutportSignals, port.Handle];
                port.DataLogging = 'on';
            end
        end
        
        for i = 1:numel(inports)
            port = inports(i);
            if(iscell(port));
                port = port{:};
            end
            lineSegment = get_param(port.Line,'Object');
            upstreamOutputPort = get_param(lineSegment.SrcPortHandle,'Object');
            if ~strcmpi(upstreamOutputPort.DataLogging,'on')
                me.LoggedInportSignals = [me.LoggedInportSignals, upstreamOutputPort.Handle];
                upstreamOutputPort.DataLogging = 'on';
            end
        end
    end
end

%----------------------------------------------------------------------------
% [EOF]

