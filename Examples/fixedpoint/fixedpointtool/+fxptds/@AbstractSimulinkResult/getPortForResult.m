function port = getPortForResult(this)
% GETPORTFORRESULT Returns the associated port on the block for the result.

% Copyright 2012-2017 The MathWorks, Inc.

port = [];
if ~isempty(this.UniqueIdentifier)
    owner = this.UniqueIdentifier.getObject;
    if ~isempty(owner) && isa(owner,'Simulink.Block')
        outports = get_param(owner.PortHandles.Outport, 'Object');
        
        %if there is only one outport, return it
        if(numel(outports) == 1)
            port = outports;
        else
            for idx = 1:numel(outports)
                port = outports(idx);
                if(iscell(port)); port = port{:}; end
                if(isequal(port.PortNumber, str2double(this.getElementName)))
                    break;
                end
            end
        end
    end
end
