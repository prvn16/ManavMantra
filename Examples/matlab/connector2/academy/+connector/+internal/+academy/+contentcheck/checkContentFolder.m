function checkContentFolder(contentFolder, startFolder, logFolder)
    %checkContentFolder('<pathtocontent>','<pathtocontent>\folder\of\interest'
    
    connector.internal.Worker.start;
    
    %Ensure no trailing \ in contentFolder
    if contentFolder(end) == filesep
        contentFolder(end) = '';
    end
    
    %Assume whole content folder if startFolder not specified
    if nargin < 2 || isempty(startFolder)
        startFolder = contentFolder;
    end   
    
    if nargin < 3 || isempty(logFolder)
        logFolder = tempdir;
    end
    
    %Check folders recursively
    checkFolder(startFolder, contentFolder, logFolder);
    
    %Display results
    disp(['Done!  Logs in:  ' logFolder]);
    
    connector.internal.Worker.stop;
end

function checkFolder(folder, contentFolder, logFolder)
    %Depth-first search!
    d = dir(folder);
    for i = 3:numel(d)  %3:end so we can ignore . and ..
        if d(i).isdir
            checkFolder(fullfile(d(i).folder,d(i).name), contentFolder, logFolder);
        end
    end
    
    %Process interaction files in this folder
    d = dir(fullfile(folder,'*interaction*.json'));
    for i = 1:numel(d)
        try
            connector.internal.academy.contentcheck.checkInteraction(fullfile(d(i).folder,d(i).name), contentFolder, logFolder);
        catch MExc
            disp(MExc)
            doLog(['Failed checking interaction: ' fullfile(d(i).folder,d(i).name)], logFolder);
            doErrorLog(fullfile(d(i).folder,d(i).name), logFolder, ['    ' MExc.message], '');
        end
    end
end