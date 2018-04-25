function obj = getSettingsRoot()
    mlock;
    persistent settingsRoot

    if isempty(settingsRoot)
       settingsRoot = matlab.internal.createAndInitSettingsRoot();
    end

    obj = settingsRoot;
end