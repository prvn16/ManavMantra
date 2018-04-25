function dataEditCallback(varNames,varargin)

% Called from java to perform various operations on linked brushed data on
% named variables in the current workspace. Note that this methods does not
% trigger a workspace event, so it's up the caller to notify any
% workspace listeners.

% Copyright 2008-2011 The MathWorks, Inc.

% Parse pv-pairs
action = '';
args = {};
workspaceevent = false;
for k=1:2:length(varargin)
    switch varargin{k}
        case 'action'
            action = varargin{k+1};
        case 'arguments'
            args = varargin{k+1};
        case 'workspaceevent'
            workspaceevent = varargin{k+1};
    end
end


[mfile,fcnname] = datamanager.getWorkspace(1);

% Find which variables are timeseries objects and set their BeingBuilt
% property if data is being removed or actions undone.
tsNames = {};
varNames = unique(varNames);
isTimeSeries = false(length(varNames),1);
for k=1:length(varNames)
    dotPos = strfind(varNames{k},'.');
    if ~isempty(dotPos)
        varName = varNames{k};
        varClassName = evalin('caller',['class(' varName(1:dotPos-1) ');']);
        isTimeSeries(k) = strcmp(varClassName,'timeseries') || ...
            strcmp(varClassName,'Simulink.Timeseries');
        if ~strcmp(action,'replace') && isTimeSeries(k)
            tsNames = [tsNames; {varName(1:dotPos-1)}]; %#ok<AGROW>
            if workspaceevent
                h = datamanager.LinkplotManager.getInstance();
                h.LinkListener.executeFromDataSource([tsNames{k} '.BeingBuilt = true;'],[]);   
            else    
                evalin('caller',[tsNames{k} '.BeingBuilt = true;']);
            end
        end
    end 
end

brushMgr = datamanager.BrushManager.getInstance();
cmd = '';
switch action
    case 'undo'
        % Undo non-timeseries actions        
        for k=1:length(varNames)        
           cmd = [cmd varNames{k} ' = getfield(datamanager.BrushManager.getInstance().UndoData,''' strrep(varNames{k},'.','_') ''');']; %#ok<AGROW>
        end 
        if workspaceevent
            h = datamanager.LinkplotManager.getInstance();
            h.LinkListener.executeFromDataSource(cmd,[]);
        else
            evalin('caller',cmd);
        end
        
        % Restore brushing
        for k=1:length(varNames)
            brushMgr.setBrushingProp(varNames{k},mfile,fcnname,'I',brushMgr.UndoData.Brushing.(strrep(varNames{k},'.','_')));
        end
        
        % Restore timeseries BeingBuilt property
        if workspaceevent
            h = datamanager.LinkplotManager.getInstance();
            for k=1:length(tsNames)
                h.LinkListener.executeFromDataSource([tsNames{k} '.BeingBuilt = false;'],[]);
            end   
        else
            for k=1:length(tsNames)
                evalin('caller',[tsNames{k} '.BeingBuilt = false;']);
            end
        end
    case 'remove'
        keepflag = args{1};
        
        % Remove points
        for k=1:length(varNames)
            I = brushMgr.getBrushingProp(varNames{k},mfile,fcnname,'I');
            if keepflag
                if isvector(I)
                    cmd = [cmd varNames{k} '(~datamanager.getBrushingProp(''' varNames{k} ''',''' mfile ''',''' fcnname ''',''I'')) = [];']; %#ok<AGROW>
                else
                    cmd = [cmd varNames{k} '(~any(datamanager.getBrushingProp(''' varNames{k} ''',''' mfile ''',''' fcnname ''',''I''),2),:) = [];']; %#ok<AGROW>
                end
            else
                if isvector(I)
                    cmd = [cmd varNames{k} '(datamanager.getBrushingProp(''' varNames{k} ''',''' mfile ''',''' fcnname ''',''I'')) = [];']; %#ok<AGROW>
                else
                    cmd = [cmd varNames{k} '(any(datamanager.getBrushingProp(''' varNames{k} ''',''' mfile ''',''' fcnname ''',''I''),2),:) = [];']; %#ok<AGROW>
                end
            end
        end
        
        if workspaceevent           
            h = datamanager.LinkplotManager.getInstance();
            h.LinkListener.executeFromDataSource(cmd,[]); 
        else
            evalin('caller',cmd);
        end
        % Restore timeseries BeingBuilt property
        for k=1:length(tsNames)
            evalin('caller',[tsNames{k} '.BeingBuilt = false;']);
        end
    case 'replace'
        if isempty(args) 
            newValue = datamanager.replacedlg;
        else
            newValue = args{1};
        end 
        if isempty(newValue)
            return
        end
        % Replace points
        for k=1:length(varNames)
            if ~isTimeSeries(k) || isempty(strfind(lower(varNames{k}),'.time'))
                I = brushMgr.getBrushingProp(varNames{k},mfile,fcnname,'I');
                if isvector(I)
                    cmd = [cmd varNames{k} '(datamanager.getBrushingProp(''' varNames{k} ''',''' mfile ''',''' fcnname ''',''I'')) = ' num2str(newValue,12) ';']; %#ok<AGROW>
                else
                    cmd = [cmd varNames{k} '(any(datamanager.getBrushingProp(''' varNames{k} ''',''' mfile ''',''' fcnname ''',''I''),2),:) = ' num2str(newValue,12) ';']; %#ok<AGROW>
                end
            end
        end
        if workspaceevent
            h = datamanager.LinkplotManager.getInstance();
            h.LinkListener.executeFromDataSource(cmd,[]);
        else
            evalin('caller',cmd);
        end
end