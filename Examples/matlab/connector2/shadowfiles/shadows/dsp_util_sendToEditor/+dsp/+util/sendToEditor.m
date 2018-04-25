function sendToEditor(code, smartIndent)
    % This part is taken from the edit.m file 
    % ----------------------------------------------------------------------------
    import com.mathworks.matlabserver.workercommon.client.*;
    clientServiceRegistryFacade = ClientServiceRegistryFactory.getClientServiceRegistryFacade();
    editorService = clientServiceRegistryFacade.getEditorService();

    basename = 'untitled';
    ext = '.m';

    name = [basename ext];
    i = 1;
    while exist(name,'file') && i < 100
        name = [basename int2str(i) ext];
        i = i+1;
    end

    if exist(name,'file')
        error(message('MATLAB:connector:Platform:NoAvailableUntitledName'));
    end
    fullname = fullfile(pwd, name);
    % ----------------------------------------------------------------------------
    
    % Write code to a file
    fileID = fopen(fullname,'w');
    fwrite(fileID,code);
    fclose(fileID);
    
    % Open file
    editorService.createOrOpenFile(fullname);
end