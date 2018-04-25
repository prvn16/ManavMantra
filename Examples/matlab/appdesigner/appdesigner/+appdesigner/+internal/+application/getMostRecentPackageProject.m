function mostRecentPrjFullFileName = getMostRecentPackageProject(mlappFullFileName, service)
    % Find most recent .prj file in the same directory as the .mlapp file,
    % which has the Main File field set to the specified mlapp file.

    [filePath, mlappFile, ext] = fileparts(mlappFullFileName);

    % Find all .prj files in the same directory as the .mlapp file
    % Returns struct array with name and datenum (double) fields

    prjFiles = dir(fullfile(filePath, '*.prj'));

    mostRecentPrjFullFileName = [];
    mostRecentPrjFileDatenum = 0;
    for file = prjFiles'
        if file.isdir
            continue;
        end
        try
            prjFullFileName = fullfile(filePath, file.name);
            if service.doesProjectContainMainFile(prjFullFileName, mlappFullFileName)
                if file.datenum > mostRecentPrjFileDatenum
                    mostRecentPrjFullFileName = fullfile(filePath, file.name);
                    mostRecentPrjFileDatenum = file.datenum;
                end
            end
        catch ex
            % Unknown error using packaging API -> return generic PackageError
            if isa(service, 'com.mathworks.toolbox.apps.services.AppsPackagingService')
                error(message('MATLAB:appdesigner:appdesigner:PackageAppFailed', mlappFullFileName));
            else
                error(message('MATLAB:appdesigner:appdesigner:CompileAppFailed', mlappFullFileName));
            end

        end
    end
end