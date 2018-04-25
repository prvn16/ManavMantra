function factoryView = getFactoryView(this)
%GETFACTORYVIEW Get the factoryView for this domain

%   Copyright 2010 The MathWorks, Inc.


factoryView = this.ViewManager.getView(fxptui.message('labelViewSimulation'));

% [EOF]
