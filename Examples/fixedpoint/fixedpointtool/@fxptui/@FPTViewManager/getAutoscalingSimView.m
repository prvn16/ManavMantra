function autoscaleSimMinMaxView = getAutoscalingSimView(this)

% Copyright 2014 The MathWorks, Inc.

autoscaleSimMinMaxProps = [DAStudio.MEViewProperty('Run'),DAStudio.MEViewProperty('CompiledDT'),...
    DAStudio.MEViewProperty('Accept'),DAStudio.MEViewProperty('ProposedDT'),...
    DAStudio.MEViewProperty('SpecifiedDT'),...
    DAStudio.MEViewProperty('SimMin'), DAStudio.MEViewProperty('SimMax'),...
    DAStudio.MEViewProperty('DesignMin'), DAStudio.MEViewProperty('DesignMax'), ...
    DAStudio.MEViewProperty('ProposedMin'),DAStudio.MEViewProperty('ProposedMax'),...
    DAStudio.MEViewProperty('OverflowWrap'), DAStudio.MEViewProperty('OverflowSaturation')];
name = fxptui.message('labelViewAutoscalingSimMinMax');
desc = fxptui.message('descViewAutoscalingSimMinMax');
autoscaleSimMinMaxView = DAStudio.MEView(name, desc);
autoscaleSimMinMaxView.Properties = autoscaleSimMinMaxProps;
autoscaleSimMinMaxView.SortName = 'Name';
autoscaleSimMinMaxView.SortOrder = 'Asc';
autoscaleSimMinMaxView.IsFactoryView = true;
this.addInternalName(autoscaleSimMinMaxView);

%------------------------------------------------------------------------