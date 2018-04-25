function updateHelpPopup(topic)
%UPDATEHELPPOPUP Update HelpPopup Java component with a new help topic.
% 
%   This file is a helper function used by the HelpPopup Java component.  
%   It is unsupported and may change at any time without notice.

%   Copyright 2017 The MathWorks, Inc.
    
    if nargin
        topic = strrep(char(topic), '/', '.');
    else
        topic = '';
    end
    
    if ~com.mathworks.mlwidgets.help.HelpPopup.updateIfShowing(topic)
        helpPopup(topic);
    end
end