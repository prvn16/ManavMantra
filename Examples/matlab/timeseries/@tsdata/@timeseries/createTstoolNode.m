function node = createTstoolNode(ts,h)
%CREATETSTOOLNODE Creates a node for the time series object in the tstool
%tree. 
%
%   CREATETSTOOLNODE(TS,H) where H is the parent node object. Information
%   from h is required to check against existing node with same name.

%   Author(s): Rajiv Singh
%   Copyright 2005-2011 The MathWorks, Inc.

node = [];

status = prepareTsDataforImport(ts);
if ~status
    return
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Time series object must have unique name in tstool
% check duplication
if localDoesNameExist(h,ts.tsValue.Name)
    % Duplicated, check if same handle handle
    % different but same name, ask if a name change is desired
    tmpname = ts.tsValue.Name;
    Namestr = sprintf(getString(message('MATLAB:tsdata:timeseries:createTstoolNode:TimeSeriesObjectDefined', ...
            tmpname)));
    while true
        answer = inputdlg(Namestr,getString(message('MATLAB:tsdata:timeseries:createTstoolNode:EnterUniqueName')));
        % comparing the given new name with all the nodes in tstool
        %return if Cancel button was pressed
        if isempty(answer)
            return;
        end
        tmpname = strtrim(cell2mat(answer));
        if isempty(tmpname)
            Namestr = getString(message('MATLAB:tsdata:timeseries:createTstoolNode:EmptyNamesNotAllowed'));
        else
            tmpname = strtrim(cell2mat(answer));
            %node = h.getChildren('Label',tmpname);
            if localDoesNameExist(h,tmpname)
                Namestr = sprintf(getString(message('MATLAB:tsdata:timeseries:createTstoolNode:TimeSeriesObjectDefined',tmpname)));
                continue;
            else
                ts.tsValue.name = tmpname;
                break;
            end %df ~isempty(node)
        end %df isempty(answer)
    end %while
end %df ~isempty(node) ..
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Create a @tsnode
node = tsguis.tsnode(ts);

% attach a listener to the leaf node, which would listen to the datachange
% event of the timeseries data object
node.Tslistener = handle.listener(node.Timeseries,'datachange',{@(e,d) node.updatePanel(d)});


%Attach a listener to the data object Name change property
node.DataNameChangeListener = handle.listener(node.Timeseries,...
    node.Timeseries.findprop('Name'),'PropertyPostSet',{@localUpdateNodeName, node});

%--------------------------------------------------------------------------
function localUpdateNodeName(~,~,node)

newName = node.Timeseries.Name; 
node.updateNodeNameCallback(newName);

%--------------------------------------------------------------------------
function Flag = localDoesNameExist(h,name)

nodes = h.getChildren('Label',name);
Flag = false;
if ~isempty(nodes)
    for k = 1:length(nodes)
        if strcmp(class(nodes(k)),'tsguis.tsnode')
            Flag = true;
            break;
        end
    end
end