function displayHelp(hp)
    if ~hp.suppressDisplay
        if ~isempty(hp.helpStr)
            disp(hp.helpStr);
        elseif ~isempty(hp.topic)
            fcnInfo = matlab.internal.language.registry.findUnlicensedFunctions(hp.topic);
            if isempty(fcnInfo)
                disp(getString(message('MATLAB:helpUtils:displayHelp:TopicNotFound', hp.topic)));
                if hp.wantHyperlinks
                    disp(getString(message('MATLAB:helpUtils:displayHelp:SearchMessageWithLinks', helpUtils.makeDualCommand('docsearch', hp.topic))));
                else
                    disp(getString(message('MATLAB:helpUtils:displayHelp:SearchMessageNoLinks')));
                end
            elseif fcnInfo.NumProducts == 1
                disp(getString(message('MATLAB:ErrorRecovery:UnlicensedFunctionInSingleProduct', hp.topic, fcnInfo.ProductLinks)))
            else
                disp(getString(message('MATLAB:ErrorRecovery:UnlicensedFunctionInMultipleProducts', hp.topic, fcnInfo.ProductLinks)))
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
