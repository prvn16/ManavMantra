function htmlOut = mlintrptCurrentFolder
    configFile = com.mathworks.widgets.text.mcode.MLintPrefsUtils.getActiveConfiguration().getFile().getAbsolutePath();
    configFileCorrectFormat = char(com.mathworks.util.StringUtils.quoteSingleQuotes(configFile));
    if com.mathworks.matlab.api.explorer.MatlabPlatformUtil.isMatlabOnline
        % We set equal to an output variable htmlOut so we can return this value
        % to the consumer in the MATLAB worker, and also since setting no
        % output argument results in a MATLAB Swing desktop web window being generated
        htmlOut = mlintrpt(cd, 'dir', configFileCorrectFormat);
    else
        mlintrpt(cd, 'dir', configFileCorrectFormat);
    end
end