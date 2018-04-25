function category = getSupportCategoryForBaseCode(baseCode)
%CATEGORY = getSupportCategoryForBaseCode(BASECODE) is an internal utility
%function to return the supportcategory value of a support package
%identified by BASECODE.
% 
% BASECODE is a basecode string identifying the support package
% 
% CATEGORY is a string that identifies whether the support package is a
% "hardware" support package or "software" support package
% 
% This function is used by AddOn Manager to determine whether to label a
% support package as "Hardware Support Package" or "Feature" for all other
% types

% Copyright 2016 MathWorks Inc.
validateattributes(baseCode, {'char'}, {'nonempty'});
% Check to see if spInfo is available via the support package MCOS plugin.
% If the support package does not have a MCOS plugin, spInfo will be empty.
spInfo = matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(baseCode);
if isempty(spInfo)
    % The default value is hardware
    category = 'hardware';
else
    % Get the "supportcategory" value returned via the support package MCOS
    % plugin
    category =  spInfo.SupportCategory;
end

end