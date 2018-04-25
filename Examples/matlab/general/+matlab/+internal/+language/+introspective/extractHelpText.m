function extractHelpText(inputFullPath, outputDir)
    [~, fileName] = fileparts(inputFullPath);

    if ~exist(inputFullPath, 'file')
        error(message('MATLAB:introspective:extractHelpText:FileNotFound'));
    end

    outputFile = fullfile(outputDir, [fileName '.m']);
    if isequal(outputFile, inputFullPath)
        error(message('MATLAB:introspective:extractHelpText:SameFile'));
    end

    if exist(outputFile, 'file')
        s = warning('off', 'MATLAB:DELETE:Permission');
        cleanup = onCleanup(@()warning(s));
        delete(outputFile);
        if exist(outputFile, 'file')
            error(message('MATLAB:introspective:extractHelpText:CannotDeleteFile'));            
        end
    end

    helpContainer = matlab.internal.language.introspective.containers.HelpContainerFactory.create(inputFullPath, 'onlyLocalHelp', true);
    helpContainer.exportToMFile(outputDir);
end

