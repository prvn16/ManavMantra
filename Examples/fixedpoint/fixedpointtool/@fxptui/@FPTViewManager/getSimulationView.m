function simMinMaxView = getSimulationView(this)

% Copyright 2014 The MathWorks, Inc.

simulationProps = [DAStudio.MEViewProperty('Run'),DAStudio.MEViewProperty('CompiledDT'),...
    DAStudio.MEViewProperty('SpecifiedDT'),...
    DAStudio.MEViewProperty('SimMin'), DAStudio.MEViewProperty('SimMax'), ...
    DAStudio.MEViewProperty('DesignMin'), DAStudio.MEViewProperty('DesignMax'), ...
    DAStudio.MEViewProperty('OverflowWrap'), DAStudio.MEViewProperty('OverflowSaturation')];
simMinMaxView = DAStudio.MEView(fxptui.message('labelViewSimulation'),...
                                fxptui.message('descViewSimulation'));
simMinMaxView.Properties = simulationProps;
simMinMaxView.SortName = 'Name';
simMinMaxView.SortOrder = 'Asc';
simMinMaxView.IsFactoryView = true;
this.addInternalName(simMinMaxView);
%--------------------------------------------------------