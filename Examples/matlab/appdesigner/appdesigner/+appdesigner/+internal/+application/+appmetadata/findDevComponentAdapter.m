function metaClasses = findDevComponentAdapter()
%FINDDEVCOMPONENTMETACLASSES find component adapters registered
% in the App Designer Design Environment but still under development

% find the registered component adapter classes that are in
% the 'appdesigner.internal.componentadapter' package and extend
% from 'appdesigner.internal.componentadapterapi.DevComponentAdapter'.
% The list returned contains metaclasses of the adapters

%   Copyright 2017 The MathWorks, Inc.

    metaClasses = internal.findSubClasses( ...
        'appdesigner.internal.componentadapter', ...
        'appdesigner.internal.componentadapterapi.DevComponentAdapter', ...
        true);
end

