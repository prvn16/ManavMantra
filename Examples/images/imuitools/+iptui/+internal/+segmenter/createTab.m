function hTab = createTab(tabGroup, resourceKeyword, varargin)
    
    % Copyright 2015-2017 The MathWorks, Inc.

if (nargin == 2)
    hTab = tabGroup.addTab(...
        iptui.internal.segmenter.getMessageString(resourceKeyword));
else
    hTab = matlab.ui.internal.toolstrip.Tab(...
        iptui.internal.segmenter.getMessageString(resourceKeyword));
    tabGroup.add(hTab, varargin{:});
end

end