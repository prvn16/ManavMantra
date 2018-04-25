function this  = hdfpanel(hImportPanel)
%HDFPANEL Construct an hdfpanel.
%
%   Function arguments
%   ------------------
%   HIMPORTPANEL: the HG parent of this panel.

%   Copyright 2004-2013 The MathWorks, Inc.

    this = hdftool.hdfpanel;
    hdfPanelConstruct(this, hImportPanel);

end
