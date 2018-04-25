function setupWorkDir(workDir)
    % Create the directory if it doesn't exist.
    if ~folderExists(workDir)
        mkdir(workDir)
    end
end

function tf = folderExists(f)
    tf = numel(dir(f)) > 1;
end