function this = FPTViewManager()
%FPTVIEWMANAGER Construct a FPTVIEWMANAGER object
%   OUT = FPTVIEWMANAGER(ARGS) <long description>

%   Copyright 2010-2014 The MathWorks, Inc.

this = fxptui.FPTViewManager;
this.PrefFileName = [prefdir filesep 'fixedpointtoolviews.mat'];
this.initializeFactoryMap;
this.ActiveDomainName = 'Other';
% This is default domain.
this.Domains = fxptui.FPTViewDomain(this, 'Other');
this.SuggestionMode = 'auto';

% [EOF]
