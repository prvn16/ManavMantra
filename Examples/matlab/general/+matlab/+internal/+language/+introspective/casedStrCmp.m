function result = casedStrCmp(isCaseSensitive, string1, string2)
    if isCaseSensitive
        result = strcmp(string1, string2);
    else
        result = strcmpi(string1, string2);
    end
end

