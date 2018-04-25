function doErrorLog(interactionFile, logFolder, message, taskNumber)
    fid = fopen(fullfile(logFolder, 'errors.txt'),'at+');
    fprintf(fid, '%s\n', '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    fprintf(fid, '%s\n',['Interaction: ' interactionFile]);
    if ~isempty(taskNumber)
        fprintf(fid, '%s\n',['  Task ' taskNumber]);
    end
    fprintf(fid, '%s\n', message);
    fclose(fid);

end

