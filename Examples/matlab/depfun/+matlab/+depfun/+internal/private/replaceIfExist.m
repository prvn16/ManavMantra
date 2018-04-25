function files = replaceIfExist(files, replacements)
    replacingFiles = ~strcmp(files, replacements);
    pos = find(replacingFiles);
    fileMustExist = replacements(replacingFiles);
    for k=1:numel(fileMustExist)
        if matlab.depfun.internal.cacheExist(fileMustExist{k},'file') == 2
            files{pos(k)} = replacements{pos(k)};
        end
    end
end
