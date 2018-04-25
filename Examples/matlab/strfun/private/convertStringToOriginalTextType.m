function outputValue = convertStringToOriginalTextType(outputValue, originalInput)

    if ischar(originalInput)
        if ismissing(outputValue)
            outputValue = '';
        else
            outputValue = char(outputValue);
        end
    elseif iscell(originalInput)
        outputValue = cellstr(outputValue);
    end
end

