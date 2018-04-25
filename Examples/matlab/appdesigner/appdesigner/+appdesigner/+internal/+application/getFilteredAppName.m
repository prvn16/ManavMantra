function result = getFilteredAppName(name)
% filter out the invalid charactors in the app name.
% the filter rule is from:
% matlab/java/src/com/mathworks/deployment/widgets/validation/NameFormatRule.java 
    invalidChars = '<>\\\\/?*:|\" ';
    if isempty(name)
        result = '';
    else
        result = ''; 
        for i = 1:length(name)
            if ~contains(invalidChars,name(i)) && isASCII(name(i))
                result = [result name(i)];
            end
        end
    end
    result = strtrim(result);
end

function value = isASCII(char)

value = (double(char) < 128);

end
