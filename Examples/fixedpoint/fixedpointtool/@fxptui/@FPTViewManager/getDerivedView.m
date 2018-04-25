function derivedMinMaxView = getDerivedView(this)

% Copyright 2014 The MathWorks, Inc.

derivedProps = [DAStudio.MEViewProperty('Run'),DAStudio.MEViewProperty('CompiledDT'),...
                DAStudio.MEViewProperty('CompiledDesignMin'), DAStudio.MEViewProperty('CompiledDesignMax'), ...
                DAStudio.MEViewProperty('DerivedMin'), DAStudio.MEViewProperty('DerivedMax'), ...
               ];
derivedMinMaxView = DAStudio.MEView(fxptui.message('labelViewDerivedMinMax'),...
                                    fxptui.message('descViewDerivedMinMax'));
derivedMinMaxView.Properties = derivedProps;
derivedMinMaxView.SortName = 'Name';
derivedMinMaxView.SortOrder = 'Asc';
derivedMinMaxView.IsFactoryView = true;
this.addInternalName(derivedMinMaxView);

%--------------------------------------------------------