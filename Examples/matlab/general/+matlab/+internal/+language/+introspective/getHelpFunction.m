function helpFunction = getHelpFunction(extension)
    helpFunction = ['help' extension 'File'];
    if isempty(which(helpFunction))
        helpFunction = '';
    end
end