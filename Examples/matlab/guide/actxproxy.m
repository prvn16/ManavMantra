function activex = actxproxy(hObject)
% ACTXPROXY Support function for GUIDE. Create ActiveX controls in a GUI. 
  
% Copyright 2002-2017 The MathWorks, Inc.

activex=[];

hObject = handle(hObject);
if ishandle(hObject)
    set(hObject,'Visible','off');
    fig = get(hObject, 'Parent');
    if isempty(fig)
        return
    end
    filename = get(fig,'FileName');
    if isempty(filename)
        appdata = getappdata(fig,'GUIDEOptions');
        if ~isempty(appdata) && isfield(appdata,'lastSavedFile')
            filename = appdata.('lastSavedFile');
        end
    end
    [p,fname,e]=fileparts(filename);
    
    % Its possible that the location to the fig file is wrong because the 
    % user moved the fig file without doing save or saveas (see g1549632). 
    % If the fig file doesn't exist, assume the path to the fig file and
    % thus the path to the activex control is the one returned by which.
    if ~exist(filename)
        figFile = which([fname e]);
        p = fileparts(figFile);
    end

    if ~ispc
        errordlg(getString(message('MATLAB:guide:actxproxy:RequireWindowsPlatform')), fname, 'modal');    
        delete hObject;
        return;
    end
    
    if ishandle(hObject) && isappdata(hObject, 'Control')
        control = getappdata(hObject, 'Control');
        currentPosition = getpixelposition(hObject);
        % create activex control
        try
            data = guidata(fig);
            
            if isappdata(0, genvarname(['OpenGuiWhenRunning_', fname])) && ~isfield(data,'keepactivexposition')
                % This is coming from running a GUIDE GUI
                [activex, container] = actxcontrol(control.ProgID, getpixelposition(hObject), fig);
                set(container,'units',get(hObject,'units'));
            else
                % This is coming from loading a GUI in GUIDE
                activex = actxcontrol(control.ProgID, getpixelposition(hObject), fig);
            end
        catch me
            delete(hObject);
            errordlg(me.message, getString(message('MATLAB:guide:actxproxy:ErrorDialogTitle')));    
            return;
        end
        
        control.Runtime = 1;
        control.Instance = activex;
        setappdata(hObject, 'Control', control);
        
        activex.addproperty('Peer');
        activex.Peer = hObject;
        
        %restore activex to its design time states
        if ~isempty(control.Serialize)
            try
                 load(activex, fullfile(p, control.Serialize));
                 %for some active control(e.g. calendar), it needs move
                 %twice for right display. 
                 activex.move(currentPosition+1,true); 
                 activex.move(currentPosition); 
            catch me
                errordlg(sprintf('%s',getString(message('MATLAB:guide:actxproxy:FailToRestoreActiveX', me.message, control.Name, control.Serialize))), fname, 'modal');
            end
        end
        
        %register event listeners only in FIG/MATLAB file mode
        options = getappdata(fig,'GUIDEOptions');
        if options.mfile 
            callbacks = control.Callbacks;
            command = {};
            for i=1:length(callbacks)
                command={command{:} callbacks{i} fname};
            end
            registerevent(activex, reshape(command, 2,i)');         
        end
    end
end

