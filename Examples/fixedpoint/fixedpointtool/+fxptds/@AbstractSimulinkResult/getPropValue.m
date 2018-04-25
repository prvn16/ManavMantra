function val = getPropValue(this, prop)
% GETPROPVALUE Implements a ME interface to return the value to be displayed
% for a give property

% Copyright 2012-2014 The MathWorks, Inc.

val = getPropValue@fxptds.AbstractResult(this, prop);
if isempty(val) && ~strcmp(prop,'Run') && ~isempty(findprop(this,prop))
    if strcmp(prop,'SignalName')
        if isempty(this.SignalName); val = ''; return; end;
        if all(cellfun(@isempty,this.SignalName,'uniformoutput',true));val = ''; return; end;
        val = this.SignalName{1};
        for i = 2:length(this.SignalName)
            if ~isempty(this.SignalName{i})
                val = sprintf('%s,%s',val,this.SignalName{i});
            end
        end
        return;
    elseif strcmp(prop,'LogSignal')
        if ~this.hasOutput
            val = [];
        else
            val = this.LogSignal;
        end
    elseif strcmp(prop,'Accept')
        % val should already have the correct value from the base class call
    else
        val = this.(prop);
        if ~isempty(val) && (~isempty(regexp(prop,'\w.*Min$','once')) || ~isempty(regexp(prop,'\w.*Max$','once')))
            val = SimulinkFixedPoint.DataType.compactButAccurateNum2Str(val);
        end
    end
    
    % Convert [] value to an empty string for proper display.
    if isempty(val)
        val = '';
        return;
    end
    
    % Convert numerics and logicals to a string for display.
    if isnumeric(val)
        val = num2str(val);
    elseif islogical(val)
        if val
            val = 'On';
        else
            val = 'Off';
        end
    end
end
