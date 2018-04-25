function result = extractFileReferencedAsString(file)
% Auto-detection of files referenced as strings in m-code.

    if ischar(file)
        file = { file };
    end
    
    result = struct([]);
    for k = 1:numel(file)
        % Extract file symbol referenced as strings in m-code.
        r = extractFileSymbolReferencedAsStr(file{k});

        if ~isempty(r)
            result = [result r]; %#ok
        end
    end
end
