function tf = isPCTInstalled()
%     Copyright 2014 The MathWorks, Inc.

%Uses same logic as that found in parallel_function

persistent PCT_INSTALLED

if isempty(PCT_INSTALLED)
    % See if we have the correct code to try this
    PCT_INSTALLED = logical(exist('com.mathworks.toolbox.distcomp.pmode.SessionFactory', 'class')) && ...
        exist('distcompserialize', 'file') == 3; % 3 == MEX
end
tf = PCT_INSTALLED;
end

