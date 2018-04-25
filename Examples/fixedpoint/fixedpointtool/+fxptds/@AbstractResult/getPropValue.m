function val = getPropValue(this, prop)
% Gets the value of the property to display in the list view. This is a base class implementation of the ME interface.
%
%   Copyright 2012-2017 The MathWorks, Inc.

    val = [];
   if strcmp(prop,'Run')
       runObj = this.RunObject;
       if ~isempty(runObj)
           val = runObj.getRunName;
       end
   elseif strcmp(prop, 'RunID')
       val = this.RunObject.RunID;
   elseif strcmp(prop, 'SpecifiedDT')
       val = this.SpecifiedDT;
    elseif any(strcmp(prop, {'CompiledDT','SimDT'}))
        val = fxptds.Utils.getCompiledDTStringForResultCell(this);
   elseif strcmpi(prop,'OverflowWrap') || strcmpi(prop,'OvfWrap')
       ovfWrap = this.OverflowWrap;
       if this.PossibleOverflows
           % get the Overflow mode on the Simulink entity to decide if it
           % needs to be displayed as Wraps/Saturate
           if strcmpi(this.OverflowMode,'wrap')
               ovfWrap = sprintf('>=%d', this.PossibleOverflows);
           end
       end
       val = ovfWrap;
   elseif strcmpi(prop,'OverflowSaturation') || strcmpi(prop,'OvfSat')
       ovfSat = this.OverflowSaturation;
       if this.PossibleOverflows
           % get the Overflow mode on the Simulink entity to decide if it
           % needs to be displayed as Wraps/Saturate
           if strcmpi(this.OverflowMode, 'saturate')
               ovfSat = sprintf('>=%d', this.PossibleOverflows);
           end           
       end
       val = ovfSat;
   elseif strcmp(prop,'ProposedMin') || strcmp(prop,'RepresentableMin')
       val = this.RepresentableMin;
       if ~isempty(val)
           val = SimulinkFixedPoint.DataType.compactButAccurateNum2Str(val);
       end
    elseif strcmp(prop,'ProposedMax') || strcmp(prop,'RepresentableMax')
        val = this.RepresentableMax;
        if ~isempty(val)
            val = SimulinkFixedPoint.DataType.compactButAccurateNum2Str(val);
        end
    elseif strcmp(prop,'SimMin') || strcmp(prop,'SimMax') || strcmp(prop,'DesignMin') || strcmp(prop,'DesignMax')...
            || strcmp(prop,'DerivedMin') || strcmp(prop,'DerivedMax') || strcmp(prop,'CompiledDesignMin') || strcmp(prop,'CompiledDesignMax')
        val = this.(prop);
        % Use a compact display for any Min/Max value
        if ~isempty(val)
            val = SimulinkFixedPoint.DataType.compactButAccurateNum2Str(val);
        end
   elseif strcmp(prop, 'ProposedDT')       
       val = this.ProposedDT;
   elseif strcmp(prop,'Accept')
       if this.hasProposedDT
           val = this.Accept;
       else
           val = '';
       end
   elseif strcmp(prop, 'WholeNumber')
       if(this.WholeNumber)
           val = 'Yes';
       else
           val = 'No';
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


