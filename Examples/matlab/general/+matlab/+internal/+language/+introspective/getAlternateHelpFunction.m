function [alternateHelpFunction, hasMFileForHelp, targetExtension] = getAlternateHelpFunction(fullPath)
    [~, ~, targetExtension] = fileparts(fullPath);
    hasMFileForHelp = ~isempty(regexpi(targetExtension, '^\.[mp]$', 'once'));
    if ~hasMFileForHelp
        alternateHelpFunction = matlab.internal.language.introspective.getHelpFunction(targetExtension);
    else
        alternateHelpFunction = '';
    end
end

