function visible = isSupportPackageVisible(baseCode)
%VISIBLE = isSupportPackageVisible(BASECODE) is an internal utility
%function to indicate whether the support package identified by BASECODE is
%hidden or not.
%
% BASECODE is a basecode string identifying the support package
% 
% VISIBLE is a boolean flag to indicate whether support package is hidden
% or not.
% 
% This function is used by AddOn Manager to determine whether to list an
% installed support package or not based on the legacy "Visible" flag in
% the support_package_registry.xml file.
% 
% If SSI is enabled, this function will return TRUE unconditionally for all
% support packages as the "Visible" attribute is a legacy attribute. 
%
% If SSI is NOT enabled, this function uses the support package's MCOS
% plugin to inspect the "Visible" field in the support_package_registry.xml
% file. If no such plugin is found, the default visibility is true.

% Copyright 2016 MathWorks Inc.

validateattributes(baseCode, {'char'}, {'nonempty'});
if com.mathworks.supportsoftwareinstaller.services.ServiceUtilities.isSsiMode()
   visible = true;
   return;
end

spInfo = matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(baseCode);
if isempty(spInfo)
    % If the SP does not have a plugin, default visibility to true
    visible = true;
else
    visible = spInfo.Visible;
end


end