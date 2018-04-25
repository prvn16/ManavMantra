function node = createTstoolNode(ts,h)
%CREATETSTOOLNODE
%
% CREATETSTOOLNODE(TSC,H) creates a node for the tscollection object TSC to
% be inserted in the tstool's tree viewer. H is the parent node (@tsparent).
% Info from h is required to check against existing node with same name.

%   Copyright 2004-2017 The MathWorks, Inc.

node = [];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Tscollection object must have unique name in tstool
% check duplication
if localDoesNameExist(h,ts.TsValue.Name)
    % Duplicated, check if same handle handle
    % different but same name, ask if a name change is desired
    tmpname = ts.TsValue.name;
    Namestr = sprintf(getString(message('MATLAB:tsdata:tscollection:createTstoolNode:TscollectionObjectAlreadyDefined', ...
        tmpname)));
    while true
        answer = inputdlg(Namestr,getString(message('MATLAB:tsdata:tscollection:createTstoolNode:EnterUniqueName')));
        % Comparing the given new name with all the nodes in tstool.
        % Return if Cancel button was pressed
        if isempty(answer)
            return;
        end
        tmpname = strtrim(cell2mat(answer));
        if isempty(tmpname)
            Namestr = getString(message('MATLAB:tsdata:tscollection:createTstoolNode:EmptyNamesNotAllowed'));
        else
            tmpname = strtrim(cell2mat(answer));
            if localDoesNameExist(h,tmpname)
                Namestr = sprintf(getString(message('MATLAB:tsdata:tscollection:createTstoolNode:TimeSeriesObjectAlreadyDefined',tmpname)));
                continue;
            else
                ts.TsValue.Name = tmpname;
                break;
            end %df ~isempty(node)
        end %df isempty(answer)
    end %while
end %df ~isempty(node) ..
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Create a @tscollectionNode
node = tsguis.tscollectionNode(ts);

% now add children nodes (@timeseries members of tscollection)
Members = ts.TsValue.gettimeseriesnames;

for k = 1:length(Members)
    if ~ts.TsValue.(Members{k}).IsTimeFirst
        ts.TsValue.(Members{k}) = transpose(ts.TsValue.(Members{k}));
    end
    thisdataobj = tsdata.timeseries;
    thisdataobj.tsValue = ts.TsValue.(Members{k});
    thisdataobj.Name = Members{k};
    childnode = createTstoolNode(thisdataobj,node);
    if ~isempty(childnode)
        childnode = node.addNode(childnode); %#ok<NASGU>
    else
        % An error happened duing the node creation process; do not add the
        % node and also update the tscollection to not contain the
        % corresponding member anymore:
        ts.removets(thisdataobj.Name);
    end
end %end for Members

% Attach a listener at tscollectionNode to the tscollection data change
% event ('datachange'), which would listen to the members-list or
% time vector change event of the tscollection.
node.TsCollListener = event.listener(node.Tscollection,'datachange',@(e,d) node.update(d));

node.DataNameChangeListener = event.listener(node.Tscollection,...
    node.Tscollection.findprop('Name'),'PropertyPostSet',@(e,d) localUpdateNodeName(e,d,node));

%--------------------------------------------------------------------------
function localUpdateNodeName(~,~,node)

newName = node.Tscollection.Name;
node.updateNodeNameCallback(newName);

%--------------------------------------------------------------------------
function Flag = localDoesNameExist(h,name)

nodes = h.getChildren('Label',name);
Flag = false;
if ~isempty(nodes)
    for k = 1:length(nodes)
        if strcmp(class(nodes(k)),'tsguis.tscollectionNode')
            Flag = true;
            break;
        end
    end
end