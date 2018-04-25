function openmltbx(filePath)
% OPENMLTBX - Called from UIOPEN for MLTBX filetype
%   Copyright 2014 - 2015 The MathWorks, Inc.

customToolboxManager = com.mathworks.toolboxmanagement.CustomToolboxManager;
customToolboxManager.installOnEDT(filePath);
end