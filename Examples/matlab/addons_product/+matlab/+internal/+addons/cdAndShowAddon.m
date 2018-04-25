function cdAndShowAddon( addonIdentifier )
%CDANDSHOWADDON cd to last working folder and show Add-On detail page in Add-On
% Explorer

%   Copyright 2015 The MathWorks, Inc.

matlab.internal.language.introspective.showAddon(addonIdentifier);
s = settings;
lwf = s.matlab.addons.LastFolderPath.ActiveValue;
if (exist(lwf,'dir') == 7)
    cd(lwf);
end

end
