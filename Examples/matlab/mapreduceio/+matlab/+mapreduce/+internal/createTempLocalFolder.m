function basePath = createTempLocalFolder()
while (true)
    basePath = tempname;

    % We use this syntax as the only way to atomically detect
    % whether a folder already exists is to catch the warning
    % that is generated.
    [status, message, messageID] = mkdir(basePath);
    if ~status
        error(messageID, message);
    elseif isempty(messageID)
        return;
    end
end
