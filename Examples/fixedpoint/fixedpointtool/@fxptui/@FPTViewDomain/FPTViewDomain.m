function this = FPTViewDomain(viewManager, domainName)
%FPTVIEWDOMAIN Construct a FPTVIEWDOMAIN object
%   OUT = FPTVIEWDOMAIN(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

this = fxptui.FPTViewDomain;
% Name of this domain.
this.Name = domainName;
% Manager managing this domain.
this.ViewManager = viewManager;
% Current view for this domain.
this.ActiveView = [];
% [EOF]
