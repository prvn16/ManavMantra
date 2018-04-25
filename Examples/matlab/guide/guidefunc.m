function varargout = guidefunc(action, varargin)
%GUIDEFUNC Support function for GUIDE. Support layout and GUI FIG-file.

%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,inf);
try

    switch action,

        case 'activateFigure'
            varargout = layoutActivate(varargin{:});

        case 'activexControl'
            varargout = getActiveXControlList(varargin{:});

        case 'activexSelect'
            varargout = selectActiveXControl;

        case 'applicationOptions'
            fig = varargin{1};
            guideopts(fig, 'edit');

        case 'configNewGobject'
            varargout = configNewGobject(varargin{:});

        case 'changeparent'
            varargout = changeparent(varargin{:});

        case 'copy'
            varargout = copyGobject(varargin{:});

        case 'deleteFigure'
            varargout = deleteFigure(varargin{:});

        case 'deleteGObject'
            varargout = deleteGobject(varargin{:});

        case 'duplicate'
            varargout = duplicateGobject(varargin{:});

        case 'editCallback'
            varargout = editCallback(varargin{:});

        case 'export'
            varargout = layoutExport(varargin{:});
            
        case 'exportAppDesigner'
            varargout = layoutExportAppDesigner(varargin{:});

        case 'getProperties'
            varargout = getProperties(varargin{:});

        case 'helpGettingStarted'
             helpview([docroot '/matlab/helptargets.map'], 'guide_getting_started');
            
        case 'helpLayingOutGUIs'
            helpview([docroot '/matlab/helptargets.map'], 'gui_layout');

        case 'helpProgrammingGUIs'
             helpview([docroot '/matlab/helptargets.map'], 'guide_programming');
            
         case 'helpExampleGUIs'
             helpview([docroot '/matlab/helptargets.map'], 'application_techniques');

         case 'helpOnlineDemos'
             web('http://blogs.mathworks.com/videos/category/gui-or-guide/','-browser');

        case 'move'
            varargout = moveGobject(varargin{:});

        case 'moveToFront'
            moveGobjectOrder(varargin{:},'top');

        case 'moveToBack'
            moveGobjectOrder(varargin{:},'bottom');

        case 'moveForward'
            moveGobjectOrder(varargin{:},'up');

        case 'moveBackward'
            moveGobjectOrder(varargin{:},'down');

        case 'moveNForward'
            varargout = moveGobjectForward(varargin{:});

        case 'moveNBackward'
            varargout = moveGobjectBackward(varargin{:});

        case 'newGObject'
            varargout = createNewGobject(varargin{:});

        case 'newFigure'
            varargout = createNewFigure(varargin{:});

        case 'newLayout'
            varargout = createNewLayout(varargin{:});

        case 'okToProceed'
            varargout = {okToProceed(varargin{:})};

        case 'openFigure'
            varargout = openFigure(varargin{:});

        case 'openCallbackEditor'
            varargout = openCallbackEditor(varargin{:});

        case 'preload'
            preloadFigure(varargin{:});

        case 'prepareProxy'
            varargout = prepareProxy(varargin{:});

        case 'readFigure'
            varargout = readSavedFigure(varargin{:});

        case 'resizeFigure'
            varargout = resizeFigure(varargin{:});

        case 'save'
            varargout = layoutSave(varargin{:});

        case 'saveAs'
            varargout = layoutSaveAs(varargin{:});

        case 'setProperties'
            varargout = setProperties(varargin{:});

        case 'snapshotFigure'
            varargout = snapshotFigure(varargin{:});

        case 'showPropertyPage'
            varargout = showPropertyPage(varargin{:});

        case 'showErrorDialog'
            varargout = showErrorDialog(varargin{:});

        case 'syncWithObjects'
            varargout = syncWithObjects(varargin{:});

        case 'GUIDE2ToolInterface'
            varargout = guide2tool(action, varargin{:});

        case 'updateChildrenPosition'
            varargout = updateChildrenPosition(varargin{:});

        case 'initLastValidTag'
            varargout = initLastValidTag(varargin{:});

        case 'updateTag'
            varargout = updateTag(varargin{:});

        case 'setOption'
            varargout = setOption(varargin{:});
    end

catch me
    % initialize varargout to something useful
    
    for i=1:nargout
        varargout{i} = []; 
    end
    
    % show error dialog
    showErrorDialog(me ,'Unhandled internal error in guidefunc');    
end



% ****************************************************************************
% create new GObjects with default properties or with given properties,
% If no property is given, it is the first time creation. Otherwise, it if
% creation from undo/redo
% ****************************************************************************
function out = createNewGobject(varargin)

items = length(varargin)/8;
allhandles = [];

for i=1:items
    past = 1+(i-1)*8;
    parent = varargin{past};
    if ischar(parent)
        parent = allhandles(str2num(parent));
    end
    parent = double(parent);

    if (strcmp(varargin{past+1},'uicontrol'))
        vin = {parent varargin{past+1:past+7}};
        if strcmpi(varargin{past+4},'table')
            h = createUitable(vin{:});
        else
            h = createUicontrol(vin{:});
        end

    elseif (strcmp(varargin{past+1},'axes'))
        vin = {parent varargin{past+1:past+7}};
        h = createAxes(vin{:});
    elseif (strcmp(varargin{past+1},'uipanel'))
        vin = {parent varargin{past+1:past+7}};
        h = createContainer(vin{:});
    else
        vin = {parent varargin{past+1:past+7}};
        control = createExternalControl(vin{:});
        h = get(control,'Peer');
    end

    % initialize the last known valid tag
    initLastValidTag(h);

    % local handle list for finding parent in undo/redo
    allhandles(end+1) = h;

    % store double handle on Java side
    h = handle(h);
    out{(i-1)*6+1} = h;
    if ~isExternalControl(h)
        out{(i-1)*6+2} = requestJavaAdapter(h);
        out{(i-1)*6+3} = out{(i-1)*6+2};
    else
        out{(i-1)*6+2} = requestJavaAdapter(get(h,'Peer'));
        out{(i-1)*6+3} = requestJavaAdapter(h);
    end
    [out{(i-1)*6+4}, out{(i-1)*6+5}] = getProperty(h);
    out{(i-1)*6+6} = guidemfile('getCallbackProperties', h);
    varargin{past+2}.updateProxy(out{(i-1)*6+3});
end


% ****************************************************************************
% create a new figure for Guide. Return the figure, its UDD adapter, initial
% properties, and initial position.
% ****************************************************************************
function out = createNewFigure(varargin)

layout_ed = varargin{1};
fig = newGuideFig(layout_ed);

out{1} = true;
out{2} = fig;
out{3} = requestJavaAdapter(fig);
[out{4}, out{5}] = getProperty(fig);
out{6} = guidemfile('getCallbackProperties', fig);
out{7} = localGetPixelPos(fig);
[out{8}, out{9}] = guideopts(fig);


% ****************************************************************************
% call 'guide' to open the LayoutNewDialog to get the user input to created
% a new layout from template
% ****************************************************************************
function out = createNewLayout(varargin)

out = {};

fig = varargin{1};
layout_ed = getappdata(fig, 'GUIDELayoutEditor');
filename =guidetemplate(layout_ed.getFrame);


if ~isequal(filename, 0)
    guide(filename);
end

% ****************************************************************************
% update parent change
% ****************************************************************************
function out = changeparent(varargin)

out={};

objs = varargin{1};
parents = varargin{2};
holder =[];
for i=1:length(objs)
    children =[];
    if ishghandle(objs{i},'uicontainer')
        % this is workaround a figure bug where Java peer is not created
        % if the new parent is a hidden figure
        if isempty(holder)
            holder = uipanel(getParentFigure(objs{i}));
        end
        children = get(objs{i},'Children');
        if ~isempty(children)
            set(children,'Parent',holder)
        end
    end

    set(objs{i},'Parent',parents{i});
    if ~isempty(children)
        set(children,'Parent',double(objs{i}));
    end
end

if ~isempty(holder)
    delete(holder);
end


% ****************************************************************************
% Make a copy of the given object
% ****************************************************************************
function out = copyGobject(varargin)

copyContents = varargin{1};
copyBuffer = varargin{2};

% close all force deletes GUIDE figure
if isempty(copyBuffer) || ~ishghandle(copyBuffer)
    copyBuffer = newGuideFig;
else
    deleteInDesignTime(get(copyBuffer,'children'));
    %delete(get(copyBuffer,'children'));
end

newList = [];
for i=1:length(copyContents)
    keeppos = 0;  % for normalized units
    if strcmpi(get(copyContents{i},'units'), 'normalized')
        keeppos=1;
    end
    if keeppos
        mypos = localGetPixelPos(copyContents{i});
    end
    if isExternalControl(copyContents{i})
        newList(end+1) = copyExternalControl(copyContents{i}, copyBuffer);
    else
        newList(end+1)=makeCopyInParent(copyContents{i}, copyBuffer);
    end
    if keeppos
        localSetPixelPos(newList(end),mypos);
    end
end
newList = handle(newList);

out{1} = num2cell(newList);
out{2} = copyBuffer;

% ****************************************************************************
% Delete graphics objects
% ****************************************************************************
function out = deleteGobject(varargin)

items = length(varargin);

for i=1:items
    h= varargin{i};

    if ishandle(h)
        [out{i*2-1}, out{i*2}] = getProperty(h);

        if isExternalControl(h)
            delete(get(h,'Peer'));
        end
        deleteInDesignTime(h);
    %    delete(h);
    end
end


% ****************************************************************************
% Delete figure
% ****************************************************************************
function out = deleteFigure(varargin)

fig = varargin{1};

deleteInDesignTime(fig);
out = {};

% ****************************************************************************
% Delete HG object(s) without triggering the DeleteFcn
% ****************************************************************************
function deleteInDesignTime(objs)

if ~isempty(objs)
    for i=1:length(objs)
        if ishghandle(objs(i))
            all = findall(objs(i));
            for j=1:length(all)
                try 
                    set(all(j),'DeleteFcn', []);
                catch e
                end
            end

            delete(objs(i));
        end
    end
end

% ****************************************************************************
% Adjust the offset used in Paste or Duplicate
% ****************************************************************************
function offset = getPasteDuplicateOffset(varargin)

originals = varargin{1};
parents = varargin{2};
% minus is needed because offset is the delta from top-left but HG has
% bottom-left coordinates
offset = [varargin{3}(1) -varargin{3}(2) 0 0];
type = varargin{4};

% get the dimension of the copy
pos =[];
for i=1:length(originals)
    pos =[pos; localGetPixelPos(originals{i})];
end
leftmost = min(pos(:,1));
rightmost = max(pos(:,1) + pos(:,3));
topmost = max(pos(:,2) + pos(:,4));
bottommost = min(pos(:,2));

if strcmpi(type, 'paste')
    % adjust offset so that the new copy will appear from the offset
    % position of its parent
    parentpos = localGetPixelPos(parents(1));

    offset(1) = offset(1) - leftmost;
    offset(2) = offset(2) + (parentpos(4) - topmost);
else
    oldparent = get(originals{1},'Parent');
    newparent = parents(1);
    parentpos = localGetPixelPos(newparent);

    if (oldparent ~= newparent)
        oldparentpos = localGetPixelPos(oldparent);
        while (~strcmp(get(oldparent,'type'),'figure'))
            oldparent = get(oldparent,'Parent');
            oldparentpos = oldparentpos + localGetPixelPos(oldparent);
        end
        newparentpos = localGetPixelPos(newparent);
        while (~strcmp(get(newparent,'type'),'figure'))
            newparent = get(newparent,'Parent');
            newparentpos = newparentpos + localGetPixelPos(newparent);
        end
        offset(1) = offset(1) + (oldparentpos(1) - newparentpos(1));
        offset(2) = offset(2) + (oldparentpos(2) - newparentpos(2));
    end
end

%make sure the copy does not go out of bounds
if (offset(1)+ rightmost) > parentpos(3)
    offset(1) = parentpos(3) - rightmost;
    if offset(1)+ leftmost<0
        offset(1) = -leftmost;
    end
end
if (offset(2)+ bottommost) < 0
    offset(2) = -bottommost;
    if offset(2) + topmost > parentpos(4)
        offset(2) = parentpos(4) - topmost;
    end
end


% ****************************************************************************
% Make a copy of the given object and add to the figure
% This function is called by both Paste and Duplicate
% ****************************************************************************
function out = duplicateGobject(varargin)

originals = varargin{1};
parents = varargin{2};
fig = getParentFigure(parents(1));
offset = getPasteDuplicateOffset(varargin{:});

% new uicontrols are created here. For external controls, the duplication
% is not done until the real controls get a change to create in createExternalControl

% dups = copyobj(originals{:}, parents);
origs = [];
dups = [];
tops = [];
filter.includeParent =1;
for i=1:length(originals)
    keeppos = 0;    % for normalized units
    if strcmpi(get(originals{i},'units'), 'normalized')
        keeppos = 1;
    end
    if keeppos
        mypos = localGetPixelPos(originals{i});
    end
    if isExternalControl(originals{i})
        origs(end+1) = originals{i};
        tops(end+1) = copyExternalControl(originals{i}, parents);
        dups(end+1) = tops(end);
    else
        origs = [origs; guidemfile('findAllChildFromHere', originals{i}, filter)];

        tops(end+1)=makeCopyInParent(originals{i}, parents);

        thisdups = guidemfile('findAllChildFromHere',tops(end), filter);
        dups = [dups;thisdups];
        for i=1:length(thisdups)
            set(thisdups(i), 'tag', nextTag(thisdups(i)));
        end
    end
    if keeppos
        localSetPixelPos(tops(end), mypos);
    end
end
dups = handle(dups);

% update the callback properties of duplicated objects
guidemfile('chooseCopyCallbacks',fig, origs, dups);

% new external controls are created in localScanChildren
[out{1:5}] = localScanChildren(handle(tops), offset, filter);
out{6}=ismember(cell2mat(out{1}), tops);
markDirty(fig);


% ****************************************************************************
% Add callback stub to the mfile and open it in proper editor: M Editor or
% Inspector
% ****************************************************************************
function out = editCallback(varargin)

out = {};

fig = varargin{1};
hndls = varargin{2};
whichCb = varargin{3};

options = guideopts(fig);
if options.mfile && options.callbacks
    setappdata(fig, 'RefreshCallback', {hndls,whichCb});
    [success, istemp] = saveBeforeAction(fig, 'editcallback');
    if isappdata(fig, 'RefreshCallback')
        rmappdata(fig, 'RefreshCallback');
    end

    if success
        % scroll to it:
        guidemfile('scrollToCBSubfunction', fig,hndls{end}, whichCb);
    end
else
    % If not in mfile mode, go to this callback in the inspector,
    % and highlight it:
    com.mathworks.mlservices.MLInspectorServices.activateInspector;
    com.mathworks.mlservices.MLInspectorServices.selectProperty(whichCb);
end


% ****************************************************************************
% utility for searching up the instance hierarchy for the figure ancestor
% ****************************************************************************
function fig = getParentFigure(h)

while ~isempty(h) && ~strcmp(get(h,'type'),'figure')
    h = get(h,'parent');
end
fig = h;

% ****************************************************************************
% get the status of the figure and/or m files related to a layout. Return as a
% structure cover: existence, dirty, writable?
% ****************************************************************************
function status = getGuiStatus(varargin)

fig = varargin{1};
layout_ed = getappdata(fig, 'GUIDELayoutEditor');
options = guideopts(fig);

if nargin>1
    figfilename = varargin{2};
else
    figfilename = get(fig,'filename');
end

% check figure file
figure.file      = true;
figure.saved     = false;
figure.exist     = false;
figure.dirty     = false;
figure.writable  = false;

if layout_ed.isDirty
    figure.dirty =true;
end
if ~isempty(figfilename)
    figure.saved =true;
    if exist(figfilename)
        figure.exist = true;
    end

    figure.writable = iswritable(figfilename);
end

% check m file
mfile.file     = false;
mfile.saved    = false;
mfile.exist    = false;
mfile.dirty    = false;
mfile.writable = false;

if options.mfile
    mfile.file = true;
    if ~isempty(figfilename)
        [p,f,e]= fileparts(figfilename);
        mfilename = fullfile(p,[f,'.m']);
        if  guidemfile('isMFileDirty',figfilename)
            mfile.dirty = true;
        end
        if exist(mfilename)
            mfile.exist = true;
            mfile.saved = true;
        end

        mfile.writable = iswritable(mfilename);
    end
end

status.figure = figure;
status.mfile  = mfile;

% ****************************************************************************
%
% ****************************************************************************
function out = syncWithObjects(varargin)

handles = varargin{1};
hnumber = varargin{2};
for i=1:hnumber
    if ishandle(handles{i})
        [properties{1}, properties{2}]  = getProperty(handle(handles{i}));
        out{3*i-2} = properties{1};
        out{3*i-1} = properties{2};
        out{3*i} = guidemfile('getCallbackProperties', handle(handles{i}));
    else
        out{3*i-2} = [];
        out{3*i-1} = [];
        out{3*i} = [];
    end
end



% ****************************************************************************
% get the properties of given graphical objects
% ****************************************************************************
function out = getProperties(varargin)

handles = varargin{1};
hnumber = varargin{2};
for i=1:hnumber
    if ishandle(handles{i})
        [out{2*i-1}, out{2*i}] = getProperty(handles{i});
    else
        out{2*i-1} = [];
        out{2*i} = [];
    end
end

% ****************************************************************************
% 
% ****************************************************************************
function restoredata = beforeSaveGuideFig(fig)
restoredata.Metadata = removePropertyMetaData(fig);

% tables = findobj(allchild(fig),'type','uitable');
% handles = [];
% tabledata ={};
% for i=1:length(tables)
%     %set the proper data on table according to its design time format
%     data = get(tables(i),'Data');
%     handles(end+1) = tables(i);
%     tabledata{i}= data;
%     format = get(tables(i),'ColumnFormat');
%     rowName = get(tables(i),'RowName');
%     colName = get(tables(i),'ColumnName');
%     eRow = size(data,1);
%     if ~isempty(rowName) && ~isequal('numbered', rowName)
%         eRow = max(eRow, length(rowName));
%     end
%     eCol = size(data,2);
%     if ~isempty(colName) && ~isequal('numbered', colName)
%         eCol = max(eCol, length(colName));
%     end
% 
%     % update the data in range
%     newdata=cell(eRow,eCol);
%     for j=1:eCol
%         value ='';
%         if ~isempty(format) && length(format)>=j
%             switch char(format{j})
%               case 'char'
%                 value ='';
%               case 'number'
%                 value =[];
%               case 'logical'
%                 value =false;
%             end           
%         end
%         for k=1:eRow
%             newdata{k,j} = value;
%         end
%     end
%     % add data back
%     if ~isequal(getInitialUitableData(tables(i)), data)
%         newdata{1:size(data,1), 1:size(data,2)} = data;
%     end
%     set(tables(i),'Data', newdata);    
% end
% if ~isempty(handles)
%     restoredata.Tabledata = {handles, tabledata};
% end


% ****************************************************************************
% 
% ****************************************************************************
function afterSaveGuideFig(fig, restoredata)

if isfield(restoredata, 'Metadata')
    restorePropertyMetaData(restoredata.Metadata);
end
% if isfield(restoredata,'Tabledata')
%     handles = restoredata.Tabledata{1};
%     tabledata=restoredata.Tabledata{2};
%     for i=1:length(handles)
%         set(handles(i), 'Data', tabledata{i});
%     end
% end



% ****************************************************************************
% return the special name we keep extra property info
% ****************************************************************************
function name = getPropertyMetaDataName()
name = 'PropertyMetaData';

% ****************************************************************************
% 
% ****************************************************************************
function metadataList = removePropertyMetaData(obj)
children=allchild(obj);
metadataList ={};
handles = [];
metadata ={};
for i=1:length(children)
    if isappdata(children(i),getPropertyMetaDataName())
        handles(end+1) = children(i);
        metadata{end+1}= getappdata(children(i),getPropertyMetaDataName());
        
        rmappdata(children(i),getPropertyMetaDataName());
    end
end
if ~isempty(handles)
    metadataList = {handles, metadata};
end

% ****************************************************************************
% 
% ****************************************************************************
function restorePropertyMetaData(metadataList)
if ~isempty(metadataList)
    handles = metadataList{1};
    metadata = metadataList{2};
    for i=1:length(handles)
        setappdata(handles(i), getPropertyMetaDataName(), metadata{i});
    end
end


% ****************************************************************************
% 
% ****************************************************************************
function metadata = getPropertyMetaData(obj)
metadata=[];
if ishghandle(obj, 'uitable')
    if ~isappdata(obj, getPropertyMetaDataName())
        names = {'DataPropertyDimension',...
                 'DataPropertyConditionedDimension',...
                 'DataPropertySource',...
                 'BackgroundColorPropertyDimension'};
        data =get(double(obj),'Data');     
        source = 'DataDefault';
        initialdata = getInitialUitableData(obj);
        % here is where we convert old initial table data to the new one
        if isequal(data,getOldInitialUitableData(obj))
            set(double(obj),'Data', initialdata);
            drawnow;
        end
        if ~isequal(data,initialdata) 
            source = 'DataExisting';
        end
        values ={size(data),...
                 getDataPropertyConditionedDimension(obj),...
                 source,...
                 size(get(double(obj),'BackgroundColor'))};
        metadata={names, values};     
    else
        metadata = getappdata(obj, getPropertyMetaDataName());
    end
end

% ****************************************************************************
% 
% ****************************************************************************
function data = getOldInitialUitableData(table)

data = {[],[];[],[];[],[];[],[]};

% ****************************************************************************
% 
% ****************************************************************************
function data = getInitialUitableData(table)

data = generateDefaultTableData(table, [4, 2]);

% ****************************************************************************
% 
% ****************************************************************************
function data = generateDefaultTableData(table, size)
format = get(table,'ColumnFormat');
eCol = size(2);
eRow = size(1);

data=cell(eRow,eCol);
for j=1:eCol
    value ='';
    if ~isempty(format) && length(format)>=j
        switch char(format{j})
          case 'char'
            value ='';
          case {'numeric','short', 'long','short e','long e', 'short g','long g','short eng','long eng','bank','+','rat'}
            value =[];
          case 'logical'
            value =false;
        end           
    end
    for k=1:eRow
        data{k,j} = value;
    end
end

% ****************************************************************************
% 
% ****************************************************************************
function setPropertyMetaData(obj, fields, values, metadata)
obj = double(obj);
mnames = metadata{1};
mvalues= metadata{2};
if ishghandle(obj, 'uitable')
    try
        index=find(ismember(mnames,'BackgroundColorPropertyDimension'));
        if ~isempty(index)
            index1 = find(ismember(fields,'BackgroundColor'));
            if ~isempty(index1)
                set(obj, 'BackgroundColor', reshape(values{index1}, mvalues{index}));        
            end
        end

        index = find(ismember(mnames, 'DataPropertySource'), 1);
        if ~isempty(index)
            if isequal(mvalues{index},'DataExisting')
                index=find(ismember(mnames,'DataPropertyConditionedDimension'));
                if ~isempty(index)
                    index1 = find(ismember(fields,'Data'), 1);
                    if ~isempty(index1)
                        % reshape to the right size
                        set(obj, 'Data', reshape(get(obj,'Data'), mvalues{index}(1), []));        
                    end
                end
            elseif isequal(mvalues{index},'DataDefault')
                set(obj,'Data',getInitialUitableData(obj));
            elseif evalin('base', ['exist(''' mvalues{index},''',''var'')'])
                set(obj,'Data',evalin('base',mvalues{index}));
            end
            % update data dimension
            index=find(ismember(mnames,'DataPropertyDimension'));
            if ~isempty(index) 
                mvalues{index} = size(get(obj,'Data'));
            end
            % condition the data value so that the editable cells will work
            % properly in the runtime
            conditionTableData(obj);
            % update conditioned data dimension
            index=find(ismember(mnames,'DataPropertyConditionedDimension'));
            if ~isempty(index) 
                mvalues{index} = size(get(obj,'Data'));
            end
        end
    catch
    end
end
%set it last in case it is changed above
setappdata(obj, getPropertyMetaDataName(), {mnames,mvalues});

% ****************************************************************************
% 
% ****************************************************************************
function dataSize = getDataPropertyConditionedDimension(table)
data = get(table,'Data');
rowName = get(table,'RowName');
colName = get(table,'ColumnName');
% find how many rows there are in the table according to the API spec
if ~isequal('numbered', rowName)
    eRow = max([size(data,1) length(rowName)]);
else
    eRow = size(data,1);
end
% find how many columns there are in the table according to the API spec
if ~isequal('numbered', colName)    
    eCol = max([size(data,2) length(colName)]);
else
    eCol = size(data,2);
end
dataSize = [eRow, eCol];

% ****************************************************************************
% 
% ****************************************************************************
function conditionTableData(table)
dataSize = getDataPropertyConditionedDimension(table);
eRow = dataSize(1);
eCol = dataSize(2);

% update the data in range
data = get(table,'Data');
% change data only if there is the need that we need to append data
if eRow>size(data,1) || eCol>size(data,2) 
    newdata = generateDefaultTableData(table ,[eRow,eCol]);

    % add data back in case it is set by the user from workspace variable
    if ~isequal(getInitialUitableData(table), data)
        for j=1:size(data,1)
            for k=1:size(data,2)
                if iscell(data)
                    newdata{j,k} = data{j,k};
                else
                    newdata{j,k} = data(j,k);
                end
            end
        end
        %newdata{1:size(data,1), 1:size(data,2)} = data;
    end
    set(table,'Data', newdata);    
end

% ****************************************************************************
% get the properties of a graphical object
% ****************************************************************************
function [name, value] = getProperty(obj)

% For External control, the callback properties are added as instance
% properties on its uicontrol peer.

if ~isExternalControl(obj)
    properties = get(obj);
    if isfield(properties,'FileName')
        properties = rmfield(properties,'FileName');
    end
    % long[] not working from Java
    % side through jmi
     fnames = fieldnames(properties);
     for k=1:length(fnames)
         try
             if isequal(class(get(obj, fnames{k})),'uint64')
                 properties = rmfield(properties,fnames{k});
             end
         catch e
         end
     end    
    name = fieldnames(properties);

    try
        value = get(obj,name)';
    catch
        tempName = name;
        value ={};
        name  ={};

        for i=1:length(tempName)
            try
                %Set 'name{end+1}' must after set 'value{end+1}'. Since if
                %there is an exception when "get(obj,char(tempName{i}))",
                %'name{end+1}'won't be set.
                value{end+1} = get(obj,char(tempName{i}));
                name{end+1} = tempName {i};
            catch
            end
        end
    end
    
    % the data we pass to the Java side loses dimension information
    % for example, a 3X3 cell will become a 9x1 Object[]. We need to
    % keep that information in another way
    if ~isempty(getPropertyMetaData(obj))
        name{end+1} = getPropertyMetaDataName();
        value{end+1} = getPropertyMetaData(obj);    
    end
else
    % get the callback properties on peer
    obj=handle(obj);
    callbacks = guidemfile('getCallbackProperties', obj);

    % get the real properties of external control
    % some of the ActiveX controls will produce error when try to get its
    % property list and certain property value. Use Try-Catch temporarily
    properties=[];
    try
        properties = get(obj.Peer);
    catch
    end
    name = {};
    tempName = {};
    value ={};
    if (~isempty(properties))
        tempName = fieldnames(properties);
    end
    for i=1:length(tempName)
        try
            %Set 'name{end+1}' must after set 'value{end+1}'. Since if
            %there is an exception when "get(obj,char(tempName{i}))",
            %'name{end+1}'won't be set.
            value{end+1} = get(obj.Peer,char(tempName{i}));
            name{end+1} = tempName{i};
        catch
        end
    end
    % Tag property is also needed for undo/redo
    name = {name{:} 'Tag'}';
    value ={value{:} get(obj,'Tag')}';

    % callback properties are always saved at the end, This order is
    % important in setProperty.
    if ~isempty(callbacks)
        group1 = get(obj, callbacks)';
        name = {name{:} callbacks{:}}';
        value ={value{:} group1{:}}';
    end
end

% ****************************************************************************
% Check to see whether the correct m file can be found in MATLAB path
% popup PathUpdateDialog if cannot
% ****************************************************************************
function success = handleMfilePath(mfilename, frame)
import com.mathworks.mlwidgets.dialog.PathUpdateDialog;

success = 1;

[pname,fcn,ext] = fileparts(mfilename);

% see what MATLAB find
mfiles = which(fcn, '-all');

flag = 0;
where = pwd;

if isempty(mfiles)
    flag =1;
else
    [p,f,e]= fileparts(mfiles{1});

    if ispc
        if ~strcmpi(mfilename, mfiles{1})
            if ~strcmpi(p,where)
                flag = 2;
            else
                flag =3;
            end
        end
    else
        if ~strcmp(mfilename, mfiles{1})
            if ~strcmp(p,where)
                flag = 2;
            else
                flag =3;
            end
        end
    end
end

if (flag>0)
    if flag==1
        filename = mfilename;
        mdbFlag = PathUpdateDialog.FILE_NOT_ON_PATH;
    elseif flag==2
        filename = mfiles{1};
        mdbFlag = PathUpdateDialog.FILE_SHADOWED_BY_TBX;
    else
        filename = mfiles{1};
        mdbFlag = PathUpdateDialog.FILE_SHADOWED_BY_PWD;
    end

    dialog = PathUpdateDialog(frame, getDialogTitle(), filename, PathUpdateDialog.MSG_TO_ACTIVATE, mdbFlag);

    selection= dialog.showDialog;

    if selection == PathUpdateDialog.CHOICE_CANCEL
        success = 0;
        return;
    else
        if selection == PathUpdateDialog.CHOICE_CHANGEPATH
            cd(pname);
        else
            path(pname, path);
        end
    end
end


% ****************************************************************************
% Activate the figure in layout
% ****************************************************************************
function out = layoutActivate(varargin)

out = {};

fig = varargin{1};
oldName = get(fig,'FileName');

% First: save layout if needed before activation
[success, istemp]= saveBeforeAction(fig, 'activate');
if ~success  return; end

% gui options may have been changed in saveBeforeAction for template
% get updated options here
options = guideopts(fig);
layout_ed = getappdata(fig, 'GUIDELayoutEditor');

% May did a save as above thus fig file may have changed
filename = get(fig, 'filename');
[pname, fcn, ext] = fileparts(filename);
mfilename = fullfile(pname, [fcn, '.m']);

% Second: check and change MATLAB path so that correct mfile can be found
% check whether need to add path to find the correct mfile
status = getGuiStatus(fig);
if status.mfile.file
    frame = layout_ed.getFrame;
    if ~handleMfilePath(mfilename,frame);
        return;
    end
end

%Third: ready to activate now. Involved files are saved or do not need to save
options.active_h = unique(options.active_h(ishandle(options.active_h)));
if options.singleton && options.mfile
    % if we're in singleton mode, make sure to delete all
    % other copies so that the MFile actually creates a new
    % copy instead of raising the last one:
    delete(options.active_h);
    options.active_h = [];
end

% if we're in MFile mode, and we've got the MFile, then
% activate by calling the MFile (for highest fidelity)
if options.mfile && ~istemp
    % keep track of the new figure handle
    figs_before = allchild(0);

    % run the GUI
    feval(fcn);

    % capture the new handle (if any), by comparing the root's
    % list of children before and after calling the MFile.
    % Don't assume the MFile returns the figure handle, because
    % users might change that!
    options.active_h = [options.active_h setdiff(allchild(0), figs_before)];
else
    % because ActiveX controls are saved in individual files at this time,
    % instead of saving in FIG file, need to change directory.
    current = pwd;
    cd(pname);
    new_fig = hgload(filename);
    cd(current);
   
    %workaround for CreateFcn not called to create ActiveX
    peers=findobj(findall(allchild(new_fig)),'type','uicontrol','style','text');    
    for i=1:length(peers)
        if isappdata(peers(i),'Control')
            actxproxy(peers(i));
        end
    end
    
    options.active_h(end + 1) = new_fig;
    % If we're in "companion mfile" mode, and we activate
    % before having done a SAVE, many of our callbacks will
    % have strings that error out.  Just clear out those
    % callbacks in the "activated" figure:
    % PS - I don't think we need this anymore, as we now
    % force a save upon the first activate.
    if options.mfile && istemp
        guidemfile('loseAutoCallbacks', new_fig);
    end
end

if istemp
    delete([pname, filesep, fcn, '*.*']);
    set(fig,'filename', oldName);
end

guideopts(fig, options);


% ****************************************************************************
% Save layout as figure/m file
% ****************************************************************************
function out = layoutSave(varargin)
import com.mathworks.mwswing.MJOptionPane;
import com.mathworks.toolbox.matlab.guide.serialization.MfileOverwriteDialog;

out{1} = 0;

fig = varargin{1};
if nargin > 1
    filename = varargin{2};
else
    filename = get(fig, 'filename');
end
if isempty(filename)
    % Do saveAs if has not saved
    out{1} = guidefunc('saveAs',fig);
    return;
end

layout_ed = getappdata(fig, 'GUIDELayoutEditor');
frame = layout_ed.getFrame;

[p, f, e, ErrMsg] = checkValidFilename(filename, getString(message('MATLAB:guide:guidefunc:GuiFileExtension')), false);

% Correct filename
if isempty(p)
   p = pwd;
end
filename = fullfile(p, [f, e]);

if ~isempty(ErrMsg)
    edtMethod('showMessageDialog', 'com.mathworks.mwswing.MJOptionPane', ...
        frame, ErrMsg, getDialogTitle(), MJOptionPane.ERROR_MESSAGE);
    return;
end

% Get the status of all files involved in saving. Do checking before
% do save to ensure that saving is necessary and will be successful
status = getGuiStatus(fig, filename);

opts = guideopts(fig);
if isappdata(0, 'templateFile')
    source = get(fig, 'filename');
else
    if isfield(opts, 'lastFilename')
        source = opts.lastFilename;
    else
        source = get(fig, 'filename');
    end
end
target = filename;

% First, if saving to itself and all files existing and not dirty, return.
% Otherwise, if file(s) is missing, regenerate if needed. If dirty save.
% If clean but from adding of callback, still save.
% If it is from opening template, handle it here.
needsave = 1;
isoverwrite = 0;
if ispc
    isoverwrite = strcmpi(target, source);
else
    isoverwrite = strcmp(target, source);
end
if isoverwrite
    if isappdata(0, 'templateFile')
        savetemplate = getappdata(0,'templateFileSave');
        srcfigfile = getappdata(0,'templateFile');
        [sp, sfile ,se] = fileparts(srcfigfile);
        srcmfile = fullfile(sp, [sfile, '.m']);

        rmappdata(0,'templateFile');
        rmappdata(0,'templateFileSave');

        % set flag to indicate template mode. This is used when this
        % template GUI is saved the very first time. For template save
        % mode, it is now. For template no-save mode, it is the time when
        % the GUI is saved. This flag is used in updateFile in guidemfile
        s = guideopts(fig);
        if isfield(s, 'lastSavedFile')
            s = rmfield(s, 'lastSavedFile');
        end
        s.template = srcfigfile;
        guideopts(fig, s);

        if ~savetemplate
            needsave =0;

            % update all used callbacks to AUTOMATIC so that they appear
            % correctly in Inspector
            guidemfile('renameCallbacks', findall(fig),  sfile);

            % set name to be untitled
            set(fig, 'Name', 'Untitled');

            % delete temporary files
            tempfigfile= get(fig,'FileName');
            [tp, tfile ,te] = fileparts(tempfigfile);
            tempmfile = fullfile(tp, [tfile, '.m']);
            delete(tempfigfile);
            delete(tempmfile);
        end

        % change filename to empty. For template no-save, this will prevent
        % it from being added to MRU list. For template save, this will be
        % reset later
        set(fig,'FileName','');

    elseif ~status.figure.exist || (status.mfile.file && ~status.mfile.exist)
        % regenerate FIG and/or MATLAB file
        if status.mfile.file
            % reset existing callbacks to AUTOMATIC, only those
            % callback properties whose value is generated by GUIDE
            % already will be changed here.
            [p, file ,e] = fileparts(source);
            list = [fig;findall(fig)];
            list =handle(list);
            
            guidemfile('resetAutoCallback', list, file);            
        end
    else
        if isempty(getappdata(fig, 'RefreshCallback')) && ~status.figure.dirty ...
                && (status.mfile.file && ~status.mfile.dirty)
            needsave = 0;
        end
    end
else
    % if save to different file but target figure file is the figure file
    % of one of the GUIs opened in GUIDE, show dialog and return
    match = com.mathworks.toolbox.matlab.guide.LayoutEditor.isGUIOpen(target);
    if match
        needsave = 0;
        edtMethod('showMessageDialog', 'com.mathworks.mwswing.MJOptionPane', ...
            frame, sprintf('%s',getString(message('MATLAB:guide:guidefunc:CannotSaveToOpenGui', target))), getDialogTitle(), MJOptionPane.ERROR_MESSAGE);
    end
end
if ~needsave
    return;
end

% Second, if saving to different file and target exists, ask for
% confirmation. Only m file is checked at this time because
% confirmation for overwriting figure file is done in uiputfile
% presently. These two can be combined here if uiputfile can offer the
% choice to turn the checking off
[p, f, e] = fileparts(filename);
mfilename= fullfile(p,[f, '.m']);
if ~isoverwrite
    flist = '';
    found=0;
    if status.mfile.file && status.mfile.exist
        flist = [flist, mfilename, getNewLineCharacter()];
        found = found+1;
    end
    if found
        wish = edtMethod('showOverwriteDialog', ...
            'com.mathworks.toolbox.matlab.guide.serialization.MfileOverwriteDialog', ...
            frame, flist);

        if wish == MJOptionPane.YES_OPTION
            % discard the callbacks in the target m file
            if status.mfile.file
                delete(mfilename);
            end
        elseif wish == MJOptionPane.CANCEL_OPTION
            return;
        end
    end
end

% Third, check to see whether we have the write permission of all the files
% If not, give user the chance to save to another file.
flist = '';
found = 0;

fnames=[];
if ~status.figure.writable
    flist = [flist, filename, getNewLineCharacter()];
    found = found+1;
    fnames{end+1}= filename;
end
if status.mfile.file && ~status.mfile.writable
    flist = [flist, mfilename,getNewLineCharacter()];
    found = found+1;
    fnames{end+1}= mfilename;
end
if found
    % If they don't exist, and they are not writable, then the name is
    % invalid
    if ~status.mfile.exist && ~status.figure.exist
        if found==1
            errmessage = sprintf('%s',getString(message('MATLAB:guide:guidefunc:InvalidFilename', flist)));
        else
            errmessage = sprintf('%s',getString(message('MATLAB:guide:guidefunc:InvalidFilenames', flist)));
        end
        edtMethod('showMessageDialog', 'com.mathworks.mwswing.MJOptionPane', ...
            frame, errmessage, getDialogTitle(), MJOptionPane.ERROR_MESSAGE);
        return;
    end

    % Otherwise they are real files which are marked read-only
    wish = edtMethod('showSaveReadOnly', ...
            'com.mathworks.toolbox.matlab.guide.serialization.MfileOverwriteDialog', ...
            frame, found, flist);

    if wish == MJOptionPane.YES_OPTION
        out{1}=guidefunc('saveAs',fig);
        return;
    elseif wish == MJOptionPane.NO_OPTION
        % pressed overwrite
        fclist = '';
        found =0;
        for i=1:length(fnames)
            fname = fnames{i};
            com.mathworks.util.NativeJava.changeFileAttribute(fname, 'w');
            if ~iswritable(fname)
                fclist = [fclist, fname,getNewLineCharacter()];
                found = found+1;
            end
        end
        if found==1
            errmessage = sprintf('%s',getString(message('MATLAB:guide:guidefunc:ErrorWritingFile', fclist)));
        else
            errmessage = sprintf('%s',getString(message('MATLAB:guide:guidefunc:ErrorWritingFiles', fclist)));
        end
        if found
            edtMethod('showMessageDialog', 'com.mathworks.mwswing.MJOptionPane', ...
                frame, errmessage, getDialogTitle(), MJOptionPane.ERROR_MESSAGE);
            return;
        end
    else
        % pressed cancel
        return;
    end
end


% Update callback in edit callback case for auto callback generation
if ~isempty(getappdata(fig, 'RefreshCallback'))
    % From editCallback. Change to AUTOMATIC so that the callback can be
    % generated during next save
    data = getappdata(fig, 'RefreshCallback');
    rmappdata(fig, 'RefreshCallback');
 
    if ~isempty(data)
        hndls = data{1};
        whichCb= data{2};
        for i=1:length(hndls)
            obj = hndls{i};
            if guidemfile('isAutoGeneratedCallback',hndls{i}, whichCb, source)
                if guidemfile('isAutoGeneratedCallbackHG1',hndls{i}, whichCb, source)
                    % Do not throw warning, do not set to automatic.
                else
                    guidemfile('setAutoCallback',obj, whichCb);
                end
            elseif guidemfile('isManagedButtonGroupCallback',hndls{i}, whichCb, source)
                  helpdlg(sprintf('%s',getString(message('MATLAB:guide:guidefunc:ButtonGroupManagedCallback', get(get(obj,'Parent'),'Tag'),whichCb, get(obj,'Tag')))), getDialogTitle());
            else
                if isequal(questdlg(...
                        sprintf('%s',getString(message('MATLAB:guide:guidefunc:ModifiedAutoCallback', whichCb, whichCb))), ... % This call to message catalog requires two input args in addition to the id
                        getDialogTitle(), ...
                        getString(message('MATLAB:guide:guidefunc:QuestdlgYesButtonText')), ...
                        getString(message('MATLAB:guide:guidefunc:QuestdlgNoButtonText')), ...
                        getString(message('MATLAB:guide:guidefunc:QuestdlgNoButtonText'))), ...
                        getString(message('MATLAB:guide:guidefunc:QuestdlgYesButtonText')))
                    guidemfile('setAutoCallback',obj, whichCb);
                end
            end
        end
    end
end
     
%remove from appdata to prevent it from being saved in figure
if ~isempty(getappdata(fig, 'RefreshCallback'))
    rmappdata(fig, 'RefreshCallback');
end


opts = guideopts(fig);
% Need to set the name if we haven't saved before, or if we have and the
% name was the same as the previous filename
needSetName = ~isfield(opts, 'lastFilename');
if isfield(opts, 'lastFilename')
   [lastP, lastF, lastE] = fileparts(opts.lastFilename);
   needSetName = strcmpi(lastF, get(fig, 'Name'));
end
if needSetName
    set(fig, 'Name', f);
end

% Fourth, it is OK to save
% This is the only place that Guide layout is saved to its figure and mfile
restoreData = beforeSaveGuideFig(fig);
saveGuideFig(fig, filename);
afterSaveGuideFig(fig, restoreData);

% update layout if not saving to temp file from layoutActivate
if isempty(getappdata(fig, 'ActivateTemp'))
    layout_ed.setDirty(0);
    layout_ed.writeCompleted(java.lang.String(filename));
end

out{1} =1;


% ****************************************************************************
% Save layout as figure/m file
% ****************************************************************************
function out = layoutSaveAs(varargin)

out{1} = 0;

fig = varargin{1};

% regenerate FIG and/or MATLAB file if needed
[success, istemp] = saveBeforeAction(fig, 'saveas');

if success
    layout_ed = getappdata(fig, 'GUIDELayoutEditor');
    default_name = get(fig,'filename');
    [oldp, oldf, olde] = fileparts(default_name);
    if isempty(default_name)
        default_name = [char(layout_ed.getRuntimeName) getString(message('MATLAB:guide:guidefunc:GuiFileExtension'))];
    else
        % this is needed in case the extension has capital letters on
        % Windows
        default_name = fullfile(oldp, [oldf, getString(message('MATLAB:guide:guidefunc:GuiFileExtension'))]);
    end

    % get user input of destination file name
    [figfile, filterindex] = getOutputFilename(fig, default_name,getString(message('MATLAB:guide:SaveAsDialogTitle')), char(layout_ed.getRuntimeName));

    % save layout
    if (~isempty(figfile))
        out{1}= guidefunc('save',fig,figfile);
    end
end

% ****************************************************************************
% Save layout in other format than the latest one. Choices are:
%   1. M only format.
% ****************************************************************************
function out = layoutExport(varargin)

out{1} = 0;

% save layout if needed
fig = varargin{1};
status = getGuiStatus(fig);

[success, istemp] = saveBeforeAction(fig, 'export');

if success && ~istemp
    filename = get(fig, 'filename');
    options = guideopts(fig);
    [path, infilename, ext] = fileparts(filename);

    addguimain = 1;

    exeindex = -1;
    title = getString(message('MATLAB:guide:guidefunc:ExportGuiDialogTitle'));
    filter = {'*.m',  getString(message('MATLAB:guide:guidefunc:SingleExportedFileDescription'))};
    %     if exist('mcc','file') == 3
    %         filter = [filter; {'*.exe',  'Standalone EXE (*.exe)'}];
    %         exeindex = length(filter);
    %     end

    % get destination file name
    [exportmfile, filterindex] = getOutputFilename(fig, filter, title, [infilename '_export.m']);

    % user pressed Cancel if file name is empty
    if ~isempty(exportmfile)
        % form temp m file name if user selected exporting to EXE
        if filterindex == exeindex
            exefile = exportmfile;
            [p,f,e]= fileparts(exportmfile);
            exportmfile = fullfile(p, [f '.m']);
        end

        if options.mfile
            % m file and figure file exist
            [p,f,e]= fileparts(filename);
            mfilename = fullfile(p,[f,'.m']);

            % may be used to control whether the exported m file includes
            % gui_main. It is added all the time now.
            addguimain = 1;

            % check to see whether the user selected to export the GUI to the
            % same m file the GUI is using.
            if ispc
                same = strcmpi(mfilename, exportmfile);
            else
                same = strcmp(mfilename, exportmfile);
            end

            % if not same, delete the target m file, make a copy of the m file
            % of this GUI
            if ~same
                if exist(exportmfile)
                    delete(exportmfile);
                end
                [status,msg] = copyfile(mfilename, exportmfile, 'writable');
                fileattrib(exportmfile, '+w');
                if status == 0
                     error(message('MATLAB:guide:ExportWriteFailed', msg));
                end
            end

            % replace old filename with new filename
            [path, outfilename, ext] = fileparts(exportmfile);

            guidemfile('replaceMfileStrings',exportmfile, infilename ,outfilename);

            % These options only work for FIG/M mode
            if options.release>=13
                choices.createFigureInvisible=1;
            end
            choices.appendToFile=1;
            choices.addHeaderComment=0;
            choices.renameCallbacks=1;
            choices.functionPrefix = getExportHeader(fig, exportmfile);
            choices.functionSuffix = getExportFooter(fig);
        end

        % These options work for both FIG only and FIG/M modes
        choices.absorbGUIDEOptions=1;
        choices.limitForMatFile=256;
        choices.excludedPropertyList = getExclusionPropertyList;
        choices.showMessageForMATFile = 1;

        % save exportmfilename in application data that is used to support
        % ActiveX
        myoptions = 'GUIDEOptions';
        myfield = 'lastSavedFile';
        options = getappdata(fig, myoptions);
        needrestore = 0;
        if ~isempty(options)
            if isfield(options, myfield)
                needrestore =1;
                oldvalue = options.(myfield);
                options.(myfield) = exportmfile;
                setappdata(fig, myoptions, options);
            end
        end

        % Add layout code
        tools = [];
        if isappdata(fig,'tools')
            tools = getappdata(fig,'tools');
            rmappdata(fig,'tools');
        end
        printdmfile(fig, exportmfile, choices);
        if ~isempty(tools)
            setappdata(fig,'tools', tools);
        end

        % restore application data
        if needrestore
            options.(myfield) = oldvalue;
            setappdata(fig, myoptions, options);
        end

        % update function handle array in the initialization code.
        updateGuiHeader(fig, exportmfile);

        % insert gui_main after replaceMfileString to prevent multiple
        % replacement and after printdmfile so that checking for layoutFcn
        % returns true.
        if addguimain
            insertGuiMain(exportmfile);
        end

        if filterindex == 1
            editorObj = matlab.desktop.editor.openDocument(exportmfile);
            editorObj.reload;
        elseif filterindex == exeindex
            % user requested stand alone exe
            [filepath, filename, ext] = fileparts(exportmfile);

            current =pwd;
            % create output directory for generated c and h files
            outdir = fullfile(filepath,[filename '_files']);
            if ~exist(fullfile(filepath,[filename '_files']),'dir')
                [status, msg] = mkdir(filepath,[filename '_files']);
                if status == 0
                    error(message('MATLAB:guide:CannotMakeDirectory', msg));
                end
            end

            checkthis = sprintf('%s',getString(message('MATLAB:guide:guidefunc:SolutionForStandaloneRunningError', exportmfile)));
            try
                % have to change directory, mcc is not working properly
                % under our situation: if export to another directory other
                % than the pwd, three directories are involved.
                cd(filepath);
                % run the compiler
                feval('mcc','-B','sgl','-I',[filepath filesep], '-o',['..' filesep filename], '-d',outdir,filename);
                cd(current);

                % if succeed, the generated EXE may not fully work, if the
                % GUI m code calling some MATLAB function hidden in a string, that
                % function will not be detected and thus compiled by mcc
                msgbox(sprintf('%s',getString(message('MATLAB:guide:guidefunc:RunningSuccessfullyGeneratedStandalone', exefile,checkthis))), getDialogTitle(),'help');
            catch
                cd(current);
                errordlg(sprintf('%s',getString(message('MATLAB:guide:guidefunc:RunningUnsuccessfullyGeneratedStandalone',exefile, checkthis))), getDialogTitle());
            end
        end
    end
end

function out = layoutExportAppDesigner(varargin)
    % Launches GUIDE to App Designer migration add-on if it is installed.
    % Otherwise prompts the user to install it.

if appdesservices.internal.appmigration.isGUIDEAppMigrationAddonInstalled()
    fig = varargin{1};
    
    if ischar(fig) || isStringScalar(fig)
        % Fig is a full file path to a figure to be converted.
        % Launch the migration tool.
        appmigration.internal.convertGUIDEApp(fig);
    else
        % Fig is a handle to the GUIDE editor fig
        
        % Attempt/prompt to save before continuing
        [success, istemp] = saveBeforeAction(fig, 'export');
        
        if (success && ~istemp)
            % Save was successful. Launch the migration tool.
            filename = get(fig, 'filename');
            appmigration.internal.convertGUIDEApp(filename);
        end
    end
else
    % Add-on is not installed and so propmpt the user to install it.
    title = getDialogTitle();
    appdesservices.internal.appmigration.showGetAppMigrationAddonDialog(title);
end

% Return 0 to signify no errors.
out{1} = 0;

% ****************************************************************************
% Only insert @mfilename_LayoutFcn at this time
% ****************************************************************************
function updated = updateGuiHeader(fighandle, mfilename)

updated = 0;

[fpath, fname, fext]= fileparts(mfilename);
contents = fileread(mfilename);

% set correct gui_LayoutFcn
NL = getNewLineCharacter();
signature = '''gui_LayoutFcn''';
head = strfind(contents, signature);
tail = [];
if ~isempty(head)
    % search for the line end
    for i=(head(1)+length(signature)):length(contents)
        if contents(i) == NL
            tail = i;
            break;
        end
    end
end

if ~isempty(head) && ~isempty(tail)
    new_contents = [contents(1:head(1)-1), ...
        '''gui_LayoutFcn'',  @', fname,'_LayoutFcn, ...', ...
        contents(tail:end)];
    % don't use 'wt', it puts too many CR's in.
    fid=fopen(mfilename, 'w');
    if fid > 0
        fprintf(fid, '%s', new_contents);
        fclose(fid);
        updated =1;
    end
end



% ****************************************************************************
% Insert gui_main.m script file into the given M file if that file uses it
% ****************************************************************************
function inserted = insertGuiMain(mfilename)

inserted = 0;

% insert gui_mainfcn so we have a single file
main = 'gui_mainfcn';
[fpath, fname, fext]= fileparts(mfilename);
contents = fileread(mfilename);

% insert guimainfcn at the end of the mfilename if it is called
where = strfind(contents, main);

% if we found the gui_main call, replace it
if ~isempty(where)
    NL = getNewLineCharacter();

    % read gui_main from file
    guimain = fileread(which(main));

    % remove comments from guimain
    guimain = removeComments(guimain);

    % rename 'UNTILED' in guimainfcn to the export file name
    guimain = guidemfile('stringReplace', guimain, 'UNTITLED', upper(fname), 'strict', 'comment');

    % add together
    new_contents = [contents, NL, NL, ...
        '% --- Handles default GUIDE GUI creation and callback dispatch', NL, ...
        guimain, NL];

    % don't use 'wt', it puts too many CR's in.
    fid=fopen(mfilename, 'w');
    if fid > 0
        fprintf(fid, '%s', new_contents);
        fclose(fid);
        insertes =1;
    end
end


% ****************************************************************************
% replace all the occurrences of the given string in m file with a new string
% and open and/or bring it to front in m file editor (Deprecated)
%       filename: the m file whose contents will be changed
%       sourcestring: the string to search for in m file
%       targetstring: the string replacing sourcestring
%
%       policy: 'strict' or 'loose'. Used to do string-match. Default is 'loose'.
%
%       scope: 'comment', 'function', 'code', or 'all'. Indicates where to look
%               for sourcestring. 'comment' will only replace string in comments,
%               'function' replacing string in function definition, 'code'
%               replacing string in real code. 'all' looks everywhere.
%               Default is 'all'.
% ****************************************************************************
function replaceMfileString(filename, sourcestring, targetstring, policy, scope)

if nargin < 4
    policy ='loose';
end

if nargin < 5
    scope ='all';
end

if exist(filename)
    [path, file,ext] = fileparts(filename);
    if strcmp(ext,'.m')
        mcode = fileread(filename);

        % replace old filename with new name
        mcode = guidemfile('stringReplace', mcode, sourcestring, targetstring, policy, scope);

        % update version string
        mcode = guidemfile('updateVersionString', targetstring, mcode);

        fid = fopen(filename,'w');
        fprintf(fid,'%s',mcode);
        fclose(fid);
    end
end

% ****************************************************************************
% returns that part of the input string after removing the first comment
% block. The first comment block starts from the first '%' to the first
% character that is not in the comments or empty line after the first '%'
% ****************************************************************************
function body = removeComments(contents)

body ='';

% search for the first '%'
found = 0;
for i=1:length(contents)
    if contents(i) == '%'
        found = i;
        break;
    end
end

if found
    body = contents(1:found-1);
    contents = contents(found:end);

    NL = getNewLineCharacter();
    if ~isempty(contents)
        tails = find(contents==NL);
        if ~isempty(tails)
            head = 1;
            for i=1:length(tails)
                thisline = strjust(contents(head: tails(i)), 'left');
                if ~isempty(thisline) && thisline(1) ~='%' && thisline(1) ~= NL
                    body = [body, NL, contents(head: end)];
                    break;
                else
                    head = tails(i)+1;
                end
            end
        end
    end
else
    body = contents;
end


% ****************************************************************************
% returns a cell array of the properties that should be excluded from the
% exported layout code of a GUI for certain types
% ****************************************************************************
function list = getExclusionPropertyList()

% for figure type
figurelist.type = 'figure';
figurelist.properties{1} = 'FileName';
list{1} = figurelist;


% ****************************************************************************
% returns the commands that should be added before the exporting layout
% code of a GUI
% ****************************************************************************
function header = getExportHeader(figure, filename)

options = guideopts(figure);

[path, name, ext] = fileparts(filename);

returnname ='h1';
NL = getNewLineCharacter();
functionline = '';
% if options.release < 13
%     functionline =['function ', returnname, ' = matlab.hg.internal.openfigLegacy(filename, policy, varargin)', NL, ...
%         returnname, ' = ', name, '_LayoutFcn(policy);', NL, NL, ...
%         ];
% end

functionline =[functionline, ...
    'function ', returnname, ' = ', name, '_LayoutFcn(policy)'];

% if options.release < 13
%     functionline =['function ', returnname, ' = openfig(filename, policy)'];
% else
%     functionline =['function ', returnname, ' = ', name, '_LayoutFcn(policy)'];
% end

header =[...
    NL, NL, ...
    '% --- Creates and returns a handle to the GUI figure. ', NL, ...
    functionline, NL, ...
    '% policy - create a new figure or use a singleton. ''new'' or ''reuse''.' NL, NL, ...
    'persistent hsingleton;',NL,...
    'if strcmpi(policy, ''reuse'') & ishandle(hsingleton)',NL,...
    '    h1 = hsingleton;',NL,...
    '    return;',NL,...
    'end',NL];


% ****************************************************************************
% returns the commands that should be added after the exporting layout
% code of a GUI
% ****************************************************************************
function footer = getExportFooter(figure)

NL = getNewLineCharacter();

footer=[...
    NL,'hsingleton = h1;',NL];

% ****************************************************************************
% Return the position value in pixel unit of the given object
% ****************************************************************************
function pixelPos = localGetPixelPos(obj)
saveUnits = get(obj, 'units');

% Disable the Inspector property listeners since the setting of the "Units" property
% below is only temporary. This avoids excessive Inspector update traffic
% which can cause delayed layout effects when moving multiple objects (1318535)
cachedAutoUpdate = com.mathworks.mlservices.MLInspectorServices.isAutoUpdate();
com.mathworks.mlservices.MLInspectorServices.setAutoUpdate(false);

set(obj, 'units', matlab.ui.internal.PositionUtils.getPlatformPixelUnits());
pixelPos = get(obj, 'position');
set(obj, 'units', saveUnits);

% Restore the Inspector property listeners
com.mathworks.mlservices.MLInspectorServices.setAutoUpdate(cachedAutoUpdate);


% ****************************************************************************
% Set the position value of the given object in pixel unit
% ****************************************************************************
function localSetPixelPos(objs, pos)

for i=1:length(objs)
    if iscell(objs)
        obj = objs{i};
    else
        obj = objs(i);
    end
    saveUnits = get(obj, 'units');
    unitChanged = false;
    if ~strcmp(saveUnits,matlab.ui.internal.PositionUtils.getPlatformPixelUnits)
        unitChanged = true;
        % Disable the Inspector property listeners since the setting of the "Units" property
        % below is only temporary. This avoids excessive Inspector update traffic
        % which can cause delayed layout effects when moving multiple objects (1318535)
        cachedAutoUpdate = com.mathworks.mlservices.MLInspectorServices.isAutoUpdate();
        com.mathworks.mlservices.MLInspectorServices.setAutoUpdate(false);
        
        set(obj, 'units', matlab.ui.internal.PositionUtils.getPlatformPixelUnits());
    end
    if (length(pos)==2)
        % this is the displacement. not the position
        where = matlab.ui.internal.PositionUtils.getPlatformPixelPosition(obj); %getpixelposition(obj);
        where(1) = where(1)+pos(1);
        % y displacement coordinate is from top
        where(2) = where(2)-pos(2);
    else
        where= pos(1,((i-1)*4+1):(i*4));
    end
    size = get(obj,'pos');
    set(obj, 'position', where);
    
    if unitChanged 
        % Restore the Inspector property listeners
        com.mathworks.mlservices.MLInspectorServices.setAutoUpdate(cachedAutoUpdate);
        
        % If the position was changed while the MLInspectorServices.setAutoUpdate
        % was temorarily suspended, setting the unit back below will cause
        % the Inspector to refresh its properties
        set(obj, 'units', saveUnits);
    end

    if isExternalControl(obj)
        moveExternalControl(obj, where);
    end

    updateChildrenWhenResize(obj, [where(3)-size(3) where(4)-size(4)]);
end

% ****************************************************************************
% Change children position when container position changed
% ****************************************************************************
function out = updateChildrenPosition(objs, oldposs)
out = {0};
for i=1:length(objs)
    obj = objs{i};
    oldpos = oldposs{i};
    if iscontainer(obj)
        pos = localGetPixelPos(obj);
        if (pos(4) ~= oldpos(4))
            out = {1};
            updateChildrenWhenResize(obj, [pos(3)-oldpos(3), pos(4)- oldpos(4)]);
        end
    end
end

% ****************************************************************************
%
% *************************************************************************
function out = iscontainer(obj)

out =0;
if ishghandle(obj,'uicontainer') 
    out =1;
elseif ishghandle(obj,'uipanel')
    out =1;
elseif ishghandle(obj, 'figure')
    out =1;
end

% ****************************************************************************
% Return the value of the string property of given object
% ****************************************************************************
function str = localGetString(obj)
str = '';

if ishghandle(obj, 'uicontrol')
    str = get(obj, 'string');
elseif isa(handle(obj),'matlab.ui.container.ButtonGroup')
    str = get(obj, 'title');
elseif ishghandle(obj,'uipanel')
    str = get(obj, 'title');
end

if ~iscell(str) && min(size(str)) > 1
    str = cellstr(str);
end

% ****************************************************************************
% Find all the children of given OBJECTS. Return a cell array of child, Adapter,
% and MObjectProxy in the order for each child.
% This function is called by:
%       duplicateGobject
%       readSavedFigure
%       snapshotFigure
% ****************************************************************************
function [hndl,adpt,prox, peer, parent, menus, menuparents, toolbar, toolparents] = localScanChildren(objects, offset, filter)

kids =[];
for i=1:length(objects)
    kids = [kids; guidemfile('findAllChildFromHere',objects(i), filter)];
end

% This handles the children inside figure (axes, uicontrol, ActiveX)
limit = length(kids);
hndl = cell(limit,1);
adpt = cell(limit,1);
prox = cell(limit,1);
peer = cell(limit,1);
parent  = cell(limit,1);

drawnow;
for i = 1:limit
    obj = kids(i);

    accountForHGIncompatibilities(obj);

    myparent = get(obj, 'Parent');
    position = localGetPixelPos(myparent);
    parentHeight = position(4);

    %create external controls if it has not been created
    if isExternalControl(obj)
        info = getExternalControlInfo(obj);
        if info.Runtime
            control = createExternalControl(myparent, info.Type, obj);
        else
            control = info.Instance;
        end
    end

    % update position if needed for the top level objects
    if ~isempty(find(objects == obj))
        pos = localGetPixelPos(obj);
        if ~isempty(offset)
            pos = pos + offset;
            localSetPixelPos(obj, pos);
        end
    end
    
    parent{i} = requestJavaAdapter(myparent);
    if isExternalControl(obj)
        info = getExternalControlInfo(obj);
        hndl{i} = obj;
        adpt{i} = requestJavaAdapter(control);
        peer{i} = requestJavaAdapter(obj);
        str=[];
        str{1} = info.ProgID;
        str{2} = info.Name;
        prox{i} = com.mathworks.toolbox.matlab.guide.palette.ActiveXProxy(0,str,peer{i},parentHeight);
    else
        type = get(obj,'Type');
        str = localGetString(obj);

        % do not delete axes children
        %if strcmpi(type, 'axes')
        % contents = get(obj,'children');
        % if ~isempty(contents)
        % this is where I delete axes children
        %    delete(contents);
        % end
        %end
        hndl{i} = obj;
        adpt{i} = requestJavaAdapter(hndl{i});
        peer{i} = adpt{i};
        % When creating the Java proxy, we get the HG Java peer and pass it
        % to the Java side instead of letting the Java side come back again
        % to do that. Doing so speed up the GUI loading. See g592253.
        view =[];
        try
            if ishghandle(hndl{i},'uicontrol')
                provider = handle(adpt{i}).getGUIDEView();
                if ~isempty(provider)
                    view = provider.getGUIDEView();
                end
            end
        catch e
        end
        prox{i} = com.mathworks.toolbox.matlab.guide.palette.GObjectProxy(adpt{i},str,parentHeight,view);
    end

    % initialize the last known valid tag
    initLastValidTag(obj);
end

% This handles the menu children, toolbar& its children
if length(objects) == 1 && ishghandle(objects,'figure')
    [menus, menuparents]= getGuiMenus(objects);
    [toolbar, toolparents]= getGuiToolbar(objects);
end


% ****************************************************************************
% Move graphics objects
% ****************************************************************************
function out = moveGobject(varargin)

localSetPixelPos(varargin{1}, varargin{4});
for i=1:length(varargin{1})
    [out{2*i-1}, out{2*i}] = getProperty(varargin{1}{i});
end

% *************************************************************************
% ***
% Mark the layout corresponding to the given figure as dirty
% ****************************************************************************
function markDirty(fig)

layout_ed = getappdata(fig, 'GUIDELayoutEditor');
layout_ed.setDirty(1);

% ****************************************************************************
% Move graphics objects backward in the stack order for rendering
% ****************************************************************************
function out = moveGobjectOrder(varargin)

out = {};

obj = varargin{1};
direction = varargin{2};
uistack(double(obj), direction);

% ****************************************************************************
% Move graphics objects backward in the stack order for rendering
% ****************************************************************************
function out = moveGobjectBackward(varargin)

out = {};

items = length(varargin)/2;
for i=1:items
    obj = varargin{i*2-1};
    step = varargin{i*2};
    uistack(double(obj),'down',step);
end


% ****************************************************************************
% Move graphics objects forward in the stack order for rendering
% ****************************************************************************
function out = moveGobjectForward(varargin)

out = {};

items = length(varargin)/2;
for i=1:items
    obj = varargin{i*2-1};
    step = varargin{i*2};
    uistack(double(obj),'up',step);
end

% ****************************************************************************
% Loads or creates a figure, initializing it for internal use by GUIDE. If a
% filename is specified, it loads the figure from that file, otherwise it
% creates a new figure.
% ****************************************************************************
function [fig, isunsavedtemplate] = newGuideFig(layout_ed, filename)

% this app data is used to indicate that a figure is being created as the
% hidden GUIDE figure. It is used by gui_mainfcn
setappdata(0,'CreatingGUIDEFigure', 1);

% are we creating a GUI from a template without saving it?
isunsavedtemplate = false;

if nargin == 2 && ~isempty(filename)
    %Load figure using hgload. For template in non-saving mode, the file(s)
    %is in the system TEMP directory. Currently, we have to change
    %directory to where the GUI file(s) is before calling hgload because
    %any set createFcn will be called by hgload and the GUI file(s) may not
    %be on MATLAB path. The figure is set to invisible.
    [p,f,e] = fileparts(filename);
    if isempty(e)
        e = getString(message('MATLAB:guide:guidefunc:GuiFileExtension'));
    end
    filename = fullfile(p, [f, e]);

    targetpath = p;
    istemplate =0;
    istemplatesave = 0;
    current =pwd;
    if isappdata(0, 'templateFile')
        istemplate =1;
        istemplatesave = getappdata(0, 'templateFileSave');
        [templatedir, f, e] = fileparts(getappdata(0, 'templateFile'));
        targetpath = templatedir;
    end

    if ~isequal(current, targetpath)
        % Load the GUI from targetpath. Add the current directory to the
        % path in case any files under the current directory are needed
        % when loading the snap shot figure from the targetpath
        % oldpath=addpath(current);
        % cd(targetpath);
        oldpath=addpath(targetpath);
    end
    overrides.Visible = 'off';
    overrides.IntegerHandle = 'off';
    [fig, old_vals] = hgload(filename, overrides);
     
    % If any unsupported object is found during handling unsupported child
    % objects of the fig file recursively, warn the user
    unsupportedObjectTypes = handleUnsupportedObjectTypes(fig);
    if ~isempty(unsupportedObjectTypes)
        unsupportedObjectTypesString = strjoin(unique(unsupportedObjectTypes), ', ');
        warningTitle = getString(message('MATLAB:guide:guidefunc:UnsupportedObjectTypesWarningTitle'));
        warningString = getString(message('MATLAB:guide:guidefunc:UnsupportedObjectTypes', unsupportedObjectTypesString));
        uiwait(warndlg(warningString,warningTitle,'modal'));
    end

 	% mark this as a GUIDE figure
    markGuideFigure(fig);    

    %workaround for CreateFcn not called to create ActiveX
    peers=findobj(findall(allchild(fig)),'type','uicontrol','style','text');    
    for i=1:length(peers)
        if isappdata(peers(i),'Control')
            actxproxy(peers(i));
        end
    end
    
    % HG does not create popupmenu Java peer when loading fig file using
    % hgload
    popups=findobj(allchild(fig),'style','popupmenu');
    if ~isempty(popups)
        u=uipanel(fig);
        for i=1:length(popups)            
            parent =get(popups(i),'parent');
            order = get(parent,'Children');
            set(popups(i),'parent',u);
            set(popups(i),'parent',parent);
            set(parent,'Children', order);
        end
        delete(u)
    end

    % Make sure the figure is not showing (g186544)
    set(fig, 'Visible', 'off');

    if ~isequal(current, targetpath)
        %cd(current);
        path(oldpath);
    end

    % set the created figure property so that it shows correct property
    % value in GUIDE (inspector)
    if isfield(old_vals{1}, 'Visible')
        vis = old_vals{1}.Visible;
    else
        vis = 'on';
    end
    if isfield(old_vals{1}, 'IntegerHandle')
        intHandle = old_vals{1}.IntegerHandle;
    else
        intHandle = 'on';
    end

    setappdata(fig, 'GUIDELayoutEditor', layout_ed);
    set(fig, 'visible', vis);
    set(fig, 'integerhandle', intHandle);

    % If it is from template, MATLAB files and callback properties of figure and
    % uicontrols need to be updated to point to the correct MATLAB file if it is
    % opened in saving mode, or change to AUTOMATIC if it is opened in
    % nonsaving mode. This is done by calling 'Save'. In template nonsaving
    % mode, the file(s) under system TEMP directory are deleted.
    if istemplate
        guidefunc('save', fig, filename);
        if ~istemplatesave
            isunsavedtemplate = true;
%            layout_ed.setLayoutUntitled;
        end
    end

    % Set the GUIDE internal flags properly to reflect the following two
    % things:
    %       1. GUI is in FIG only or FIG/MATLAB file format
    %       2. The last MATLAB file that this GUI saved to
    options = guideopts(fig);
    % Set active_h to [] if it is not since this is loaded from Fig file
    % and we do not have an activated GUI yet. There may already be an open
    % figure for this GUI by running the GUI MATLAB file directly, it will be
    % picked up when activating.
    options.active_h =[];

    if istemplate && ~istemplatesave
        figFile = options.template;
        [p,f,e]= fileparts(figFile);
        mFile = fullfile(p, [f,'.m']);
    else
        figFile = get(fig,'filename');
        [fpath,name,ext]=fileparts(figFile);
        mFile = fullfile(fpath, [name '.m']);
        options.lastFilename = figFile;
    end

    if ~exist(mFile)
        options.mfile = 0;
        if isfield(options, 'lastSavedFile')
            options = rmfield(options, 'lastSavedFile');
        end
    end
    if options.mfile && ~istemplatesave
        % update the lastSavedFile saved in figure file in case the GUI
        % files were moved/copied to another location after creation
        options.lastSavedFile = mFile;
    end

    % this is where we convert all GUIDE generated callbacks in GUIs prior 
    % 8a from string to function handle 
    if options.mfile
        [p,f,e] = fileparts(options.lastSavedFile);
        guidemfile('convertCallbackToFunctionHandle',f, fig);  
    end
    
    guideopts(fig, options);

else % create blank figure, don't load from FIG-file
    intHandle = 'off';
    vis = 'on';

    fig = figure('windowstyle', 'normal', ...
        'visible','off',...
        'menubar','none',...
        'numbertitle','off',...
        'handlevisibility','callback',...
        'integerhandle', 'off',...
        'name','Untitled',...
        'units','character',...
        'resize','off');
    
    % store this release number if one is not there already
    options = guideopts(fig);
    options.release = getGuiReleaseNumber;
    guideopts(fig, options);

    if nargin > 0
        setappdata(fig, 'GUIDELayoutEditor', layout_ed);
    end
    markGuideFigure(fig);
    set(fig, 'visible', vis);
    set(fig, 'integerhandle', intHandle);
    set(fig,'tag',nextTag(fig));
end

% get system color if it is set
options = guideopts(fig);
if options.syscolorfig
    set(fig,'color', get(0, 'defaultuicontrolbackgroundcolor'));
end

if isequal(getappdata(0, 'MathWorks_GUIDE_testmode'),1)
    options.mfile = 0;
    guideopts(fig, options);
end

% initialize the last known valid tag
initLastValidTag(fig);

if isappdata(0,'CreatingGUIDEFigure')
    rmappdata(0,'CreatingGUIDEFigure');
end

setappdata(fig, 'initTags', getCurrentTags(fig));
fig = double(fig);

% ****************************************************************************
% utility for returning the next unique tag for any object
% ****************************************************************************
function tag = nextTag(obj)

fig = getParentFigure(obj);
if isempty(fig)
    tag = '';
else
    options = guideopts(fig);
    if isExternalControl(obj)
        control = getExternalControlInfo(obj);
        objType = control.Type;
    else
        objType = get(obj,'type');
        if(strcmp(objType,'uicontrol'))
            objType = get(obj,'style');
        end
    end
    if ~isfield(options.taginfo,objType)
        options.taginfo.(objType) = 1;
    end
    num = options.taginfo.(objType);
    tag = [objType, num2str(num)];
    options.taginfo.(objType) = num+1;
    guideopts(fig,options);
end


% ****************************************************************************
% Display a confirmation dialog for overwriting existing file, path
% indicates from where this function is called. It can be:
%       save
%       activate: from GUIDE Activation
%       export: from GUIDE exporting
%       callback: from callback change in Toolbar Editor
% The default is 'save' and it does nothing but return 1
% ****************************************************************************
function answer = okToProceed(h, path)

if isequal(getappdata(0, 'MathWorks_GUIDE_testmode'),2)
    answer = 1;
    return;
end

import com.mathworks.mwswing.MJOptionPane;
import com.mathworks.toolbox.matlab.guide.LayoutPrefs;

fig=getParentFigure(h);

if nargin<2,  path ='save'; end

answer = 1;
prefstring = [];

if strcmpi(path, 'activate')
    prefstring = LayoutPrefs.ACTIVATE;
elseif strcmpi(path, 'export')
    prefstring = LayoutPrefs.EXPORT;
elseif strcmpi(path, 'callback')
    prefstring = LayoutPrefs.CHANGEDEFAULTCALLBACK;
% elseif strcmpi(path, 'editcallback')
%     % only need to show the confirmation dialog if the callback if not
%     % something GUIDE generated
%     data = getappdata(h, 'RefreshCallback');
%     if ~isempty(data)
%         hndls = data{1};
%         whichCb= data{2};
%         for i=1:length(hndls)
%             if ~guidemfile('isAutoGeneratedCallback',hndls{i}, whichCb, get(h,'FileName'));
%                 prefstring = LayoutPrefs.OVERRIDEUSERCALLBACK;
%                 break;
%             end
%         end
%     end   
end

if ~isempty(prefstring)
    pref = LayoutPrefs.getLayoutBooleanPref(prefstring);

    if pref
        if isappdata(fig,'GUIDELayoutEditor')
            layout_ed = getappdata(fig, 'GUIDELayoutEditor');
            frame = layout_ed.getFrame;
        else
            oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            frame = get(fig,'JavaFrame');
            warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            frame = javax.swing.SwingUtilities.getWindowAncestor(frame.getFigurePanelContainer);
        end

        wish = edtMethod('showSaveProceed', ...
            'com.mathworks.toolbox.matlab.guide.serialization.MfileOverwriteDialog', ...
            frame, prefstring);

        % return 0 for everything other than YES
        if wish ~= MJOptionPane.YES_OPTION
            answer = 0;
        end
    end
end


% ****************************************************************************
% path indicates from where this function is called. It can be:
%       save:
%       saveas:
%       activate: from GUIDE Activation
%       export: from GUIDE exporting
%       openeditor: from GUIDE open MATLAB Editor
%       editcallback: from GUIDE view callback
% See also: okToProceed
% ****************************************************************************
function [success, istemp] = saveBeforeAction(fig, path)

% Get current status of all involved files.
status = getGuiStatus(fig);

% Do save or save as if needed before activation
success = 1;
istemp = 0;

needsave =0;
issaveas =0;
targetname=[];
if status.figure.saved
    if ~status.figure.exist || (status.mfile.file && ~status.mfile.exist)
        % user may have deleted fig and/or m file, regenerate
        needsave = 1;
        targetname = get(fig,'FileName');
    elseif  status.figure.dirty || (status.mfile.file && status.mfile.dirty)
        if  strcmpi(path, 'saveas')
            if status.figure.writable && (status.mfile.file && status.mfile.writable)
                needsave = 1;
            end
        elseif  ~strcmpi(path, 'openeditor')
            needsave = 1;
        elseif status.figure.dirty
            needsave =1;
        end
    else
        if strcmpi(path, 'editcallback')
            needsave = 1;
        end
    end
else
    if ~strcmpi(path, 'saveas')
        if status.mfile.file
            needsave = 1;
            issaveas = 1;
        else
            % figure only mode, have not saved. need to save to temporary figure file
            % so that tests for layout can be run automatically.
            istemp =1;
            figfile = [tempname,getString(message('MATLAB:guide:guidefunc:GuiFileExtension'))];
            oldName = get(fig,'filename');
            setappdata(fig, 'ActivateTemp', 1);
            success = guidefunc('save', fig, figfile);
            rmappdata(fig, 'ActivateTemp');
        end
    end
end

if needsave
    if ~okToProceed(fig, path)
        success = 0;
    else
        if issaveas
            success = guidefunc('saveAs', fig);
        else
            if ~isempty(targetname)
                success = guidefunc('save', fig, targetname);
            else
                success = guidefunc('save', fig);
            end
        end
    end
end

% ****************************************************************************
% Open the m file associated to this GUI in Callback Editor if the GUI is in
% figure/m mode. If the GUI has not been saved, save it first
% ****************************************************************************
function out = openCallbackEditor(varargin)

out = {};
fig = varargin{1};

if ishandle(fig)
    options = guideopts(fig);
    if options.mfile
        [success, istemp] = saveBeforeAction(fig, 'openeditor');

        if success && ~istemp
            figfile = get(fig,'FileName');
            [path, file, ext] = fileparts(figfile);
            mfile = fullfile(path, [file, '.m']);
            matlab.desktop.editor.openDocument(mfile);
        end
    end
end

% ****************************************************************************
% Open figure in Guide
% ****************************************************************************
function out = openFigure(varargin)
import com.mathworks.toolbox.matlab.guide.LayoutMRUFiles;

out = {};

filespec = {'*.fig', getString(message('MATLAB:guide:GuiFileDescription')); ...
    '*.m',   getString(message('MATLAB:guide:guidefunc:CodeFileDescription'));...
    '*.*',   getString(message('MATLAB:guide:guidefunc:AllFilesDescription'))};

lastdir = char(LayoutMRUFiles.getLastOpenFile);
if isempty(lastdir)
    lastdir = fullfile(pwd, '\');
end

[filename, pathname] = uigetfile(filespec, getString(message('MATLAB:guide:OpenDialogTitle')), lastdir);

if isequal(filename, 0) || isequal(pathname, 0) %CANCEL
    return;
end

selectfile = fullfile(pathname, filename);
[p, f, e] = fileparts(selectfile);
if strcmp(e, getString(message('MATLAB:guide:guidefunc:GuiFileExtension')))
    guide(selectfile);
else
    uiopen(selectfile, 'direct');
end

% update last open dir
LayoutMRUFiles.setLastOpenFile(selectfile);

%uiwait(msgbox('please add code for opening here', 'modal'));


% ****************************************************************************
% Create a figure from saved file. Return figure, its UDD adapter, initial
% properties, initial position, and child list.
% ****************************************************************************
function out = readSavedFigure(varargin)

layout_ed = varargin{1};
filename = varargin{2};
[fig, unsavedtemplate] = newGuideFig(layout_ed, filename);
out{1} = unsavedtemplate;
out{2} = fig;
out{3} = requestJavaAdapter(fig);
[out{4}, out{5}] = getProperty(fig);
out{6} = guidemfile('getCallbackProperties', fig);
out{7} = localGetPixelPos(fig);
[out{8}, out{9}] = guideopts(fig);

% This is called both before saving and before loading the GUI
reverseExternalControlPeer(fig);
[out{10:18}] = localScanChildren(fig, [],[]);

% ****************************************************************************
% Change the layout(figure) size in GUIDE
% ****************************************************************************
function out = resizeFigure(varargin)

fig = varargin{1};
size = varargin{2};
saveUnits = get(fig, 'units');
set(fig, 'units', matlab.ui.internal.PositionUtils.getPlatformPixelUnits());
pos = get(fig, 'position');
y = pos(2) + pos(4) - size(2);
set(fig, 'position', [pos(1) y size]);
set(fig, 'units', saveUnits);

updateChildrenWhenResize(fig, [size(1)-pos(3) size(2)-pos(4)]);
% force a completion call
[out{1}, out{2}] = getProperty(fig);

% ****************************************************************************
% update the position of all uicontrols and axes so that they appear to
% follow top-left coordinates instead of the default HG's bottom-left
% ****************************************************************************
function updateChildrenWhenResize(parent, displacement)
if ~isempty(find(displacement)>0)
    filter.recursiveSearch = 0;
    children = guidemfile('findAllChildFromHere',parent, filter);

    for i=1:length(children)
        if ~strcmpi(get(children(i),'Units'), 'normalized')
            oldunit = get(children(i),'Units');
            set(children(i),'Units', matlab.ui.internal.PositionUtils.getPlatformPixelUnits());
            pos = get(children(i),'Position');
            pos(2) = pos(2)+ displacement(2);
            set(children(i),'Position',pos);
            set(children(i),'Units', oldunit);
        end
    end
end


% ****************************************************************************
% Saves an internal GUIDE figure to a fig file
% ****************************************************************************
function saveGuideFig(fig, filename)

% remove this from appdata for two reasons:
% 1) we don't want it saved/reloaded with the figure
% 2) there's a bug in saving with java objects...
layout_ed = getappdata(fig, 'GUIDELayoutEditor');
options = guideopts(fig);
if isappdata(fig, 'GUIDELayoutEditor')
    rmappdata(fig, 'GUIDELayoutEditor');
end

[pname, funcname, ext] = fileparts(filename);
if options.mfile
    guidemfile('updateFile', fig, filename);
end

% Remove initTags data so it is not saved in fig
if(isappdata(fig, 'initTags'))
    rmappdata(fig, 'initTags');
end

%uiwait(msgbox(['saving figure to file: ' filename]))

% This is called both before saving and before loading the GUI
reverseExternalControlPeer(fig);
% update external controls before saving the figure so that updated
% information will be saved in the FIG-file later.
saveExternalControl(fig, filename);

% we should not save guidata in the GUI FIG-file since it is belongs to
% runtime not design time
tools = [];
if isappdata(fig,'tools')
    tools = getappdata(fig,'tools');
    rmappdata(fig,'tools');
end
data=guidata(fig);
guidata(fig,[]);

% Clean up the GUIDE figure state before saving it
clearGuideFigure(fig);
% need to change to handle when saving
hgsave(handle(fig), filename);
% restore GUIDE figure flag first after save
markGuideFigure(fig);
if ~isempty(layout_ed)
    setappdata(fig, 'GUIDELayoutEditor', layout_ed)
end
set(fig, 'filename', filename)
com.mathworks.services.ObjectRegistry.getLayoutRegistry.change({handle(fig)});

guidata(fig,data);
if ~isempty(tools)
    setappdata(fig,'tools', tools);
end

%restore external control information removed during saving
afterSaveExternalControl(fig);

% Update the opts lastFilename to the current filename
options = guideopts(fig);
options.lastFilename = filename;
guideopts(fig, options);

% call again to restore order
reverseExternalControlPeer(fig);

% Restore the initTags to reflect the current state
setappdata(fig, 'initTags', getCurrentTags(fig));


% ****************************************************************************
% change the properties of given graphical objects
% ****************************************************************************
function out = setProperties(varargin)

handles = varargin{1};
hnumber = length(handles);
for k=1:hnumber
    fields = varargin{k*2}';
    values = varargin{k*2+1};
    
    if ~isExternalControl(handles{k})
%         if ishghandle(handles{k},'figure')
%             index = find(ismember(fields,'Visible'));
%             if (index>0)
%                 fields(index) =[];
%                 values(index) = [];
%
%             end
%         end
        setProperty(double(handles{k}), fields,values);
    else
        setProperty(handle(handles{k}), fields,values);
    end
end

out{1} = 0;

% ****************************************************************************
% change the properties in FIELDS of the object given in HANDLE to those given
% in VALUES
% ****************************************************************************
function setProperty(h, fields, values)

if isExternalControl(h)
    peerfields = guidemfile('getCallbackProperties', h);
    if length(peerfields)>0
        peerfields = {'Tag', peerfields{:}}';
    else
        peerfields ={'Tag'};
    end
    count = length(peerfields);

    % Need to use decreasing index. Callback properties are added at the
    % end of uicontrol peer. It is possible that callback properties added
    % are overlapping with other properties of external control. For
    % example, there may be two 'Click' cells in fields.
    matched =0;
    for j=length(fields):-1:1
        obj = h.Peer;
        if matched <count
            if ismember(fields{j}, peerfields)
                obj = h;
                matched= matched+1;
            end
        end
        try
            set(obj, fields{j}, values{j});
        catch
        end
    end
else    
    %metadata
    index=(ismember(fields,getPropertyMetaDataName()));
    metadata=[];
    if ~isempty(find(index))
        metadata = values{find(index)};
        %remove metadata
        fields=fields(~index);
        values=values(~index);
    end
   
    % get the current position of figure first
    if iscontainer(h)
        oldunit = get(h,'Units');
        set(h,'Units',matlab.ui.internal.PositionUtils.getPlatformPixelUnits());
        posnow = get(h,'Position');
        set(h,'Units',oldunit);
    end
    % must change 'units' and 'font units' first if they exist
    for i=1:length(fields)
        if (strcmp(fields{i},'Units') || strcmp(fields{i}, 'FontUnits'))
            set(h, fields{i},values{i});
        end
    end

    % second chance to set 'units' and 'font units' first

    % 'units' and 'font units' are special cases and therefore are set
    % before any other properties.  Otherwise, we want to set the
    % properties in the "forward" order in order not to modify the "modes"
    % of paired properties.  For example, if a background color on a figure
    % or axes is modified, an undo unit is created that will reset
    % properties.  If setting properties is run backwards during this undo
    % unit, all the "mode" properties will be set to "manual", rather then
    % kept the same.  Because all the "mode" properties are AFTER their
    % "master" properties, we need to set the properties in the "forward"
    % order.
    for i=1:length(fields)
        try
            % uitable peer is 
            % recreated when setting parent to its current parent
            if ~strcmpi(fields{i}, 'parent') || ~isequal(get(h,'parent'),values{i})  
                set(h, fields{i}, values{i})
            end
        catch
        end
    end

    % get the position of figure after setting property
    if iscontainer(h)
        oldunit = get(h,'Units');
        set(h,'Units',matlab.ui.internal.PositionUtils.getPlatformPixelUnits());
        poslater = get(h,'Position');
        set(h,'Units',oldunit);

        % update children position if figure size changed
        updateChildrenWhenResize(h, [poslater(3)-posnow(3), poslater(4)-posnow(4)]);
    end

    %apply metadata
    if ~isempty(metadata)
        setPropertyMetaData(h, fields, values, metadata); 
    end

end


% ****************************************************************************
% takes an existing figure and 'snapshots' it into a GUIDE internal figure
% ****************************************************************************
function out = snapshotFigure(varargin)

layout_ed = varargin{1};
fig = varargin{2};

filename = [tempname getString(message('MATLAB:guide:guidefunc:GuiFileExtension'))];
hgsave(handle(fig), filename);
newFig = newGuideFig(layout_ed, filename);

% If we are editing an existing open figure, forget which file it
% may have come from - we don't want to automatically overwrite
% that file when we do Save.  This will make the figure do a
% SaveAs the first time it is saved, and will protect the
% original fig file.
set(newFig, 'filename', '');
options = guideopts(fig);
delete(filename);

out{1} = true;
out{2} = newFig;
out{3} = requestJavaAdapter(newFig);
[out{4}, out{5}] = getProperty(newFig);
out{6} = guidemfile('getCallbackProperties', newFig);
out{7} = localGetPixelPos(newFig);
[out{8}, out{9}] = guideopts(newFig);
[out{10:18}] = localScanChildren(newFig, [],[]);

% ****************************************************************************
% use uiputfile to return a valid filename. filename will be checked to make
% sure it is a valid Matlab name. If the return name if empty, the user had
% pressed CANCEL
% ****************************************************************************
function [outputname, filterindex] = getOutputFilename(fig, filterspec, title, defaultname)
import com.mathworks.toolbox.matlab.guide.LayoutMRUFiles;
import com.mathworks.mwswing.MJOptionPane;

outputname = [];
filterindex = [];

layout_ed = getappdata(fig, 'GUIDELayoutEditor');
frame = layout_ed.getFrame;

if isequal(getappdata(0, 'MathWorks_GUIDE_testmode'),2)
    if (iscell(filterspec))
        % export
        name = defaultname;
    else
        % save
        name = filterspec;
    end

    outputname = fullfile(pwd,name);
    return;
end

% Put up an Export dialog box, and check the return result.
% If the user picks a bad name, put up an error message and then redisplay
% the Export dialog, until the user gets it right, or Cancels.
needreentry = 1;
while needreentry
    % open the uiputfile in the directory of the current open GUI if it is
    % saved already. If not, open in pwd.
    lastdir = char(LayoutMRUFiles.getLastSaveFile);
    if isempty(lastdir)
        lastdir=pwd;
    else
        lastdir = fileparts(lastdir);
    end

    [filename, pathname, filterindex] = uiputfile(filterspec, title, fullfile(lastdir,defaultname));

    if isequal(filename, 0) || isequal(pathname, 0)
        %user pressed CANCEL
        return;
    end

    % add file ext if not there, check to see whether file extension is OK
    if (iscell(filterspec))
        ext = filterspec{filterindex};
        ext = ext(find(ext=='.'):end);
    else
        [pe, fe, ext] = fileparts(filterspec);
    end

    [p, f, e, ErrMsg] = checkValidFilename([pathname filename], ext, true);

    % If error, show it and the user entered an illegal file name, show the error and popup the dialog again.
    if ~isempty(ErrMsg)
        edtMethod('showMessageDialog', 'com.mathworks.mwswing.MJOptionPane', ...
            frame, ErrMsg, getDialogTitle(), MJOptionPane.ERROR_MESSAGE);
        needreentry =1;
    else
        % now we have a legal figure file name, do save
        outputname = fullfile(p, [f e]);
        needreentry = 0;

        % update last save dir
        LayoutMRUFiles.setLastSaveFile(outputname);
    end
end % end while needreentry

% ****************************************************************************
% Returns the number of objects in the figure (h or its parent figure) whose
% Tag property is 'tag
% ****************************************************************************
function result = getTagCount(h, tag)

result = 0;

if ~strcmpi(get(h,'Type'),'Figure')
    fig = get(h,'Parent');
else
    fig =h;
end

list = findall(fig);

for i=1:length(list)
    if ispc
        match = strcmpi(tag, get(list(i),'Tag'));
    else
        match = strcmp(tag, get(list(i),'Tag'));
    end

    if match
        result = result +1;
    end
end

% ****************************************************************************
% Function test whether a given file can be opened for writing
% ****************************************************************************
function out = iswritable(filename)
out = false;

wasthere = (exist(filename,'file') > 0);
fid=fopen(filename,'a');
if fid > 0
    out = true;
    fclose(fid);
    if ~wasthere
        delete(filename);
    end
end

% ****************************************************************************
% initialize last valid tag property of uicontrol
% ****************************************************************************
function out = initLastValidTag(h)

out = {};
if isvarname(get(h,'Tag'))
    setappdata(h,tagPropertyLastValid, get(h,'Tag'));
else
    setappdata(h,tagPropertyLastValid, '');
end

% ****************************************************************************
% string used by Tag property change listener
% ****************************************************************************
function string = tagPropertyLastValid
string = 'lastValidTag';

% ****************************************************************************
% Handles file and callback updates when Tag property changes
% ****************************************************************************
function out = updateTag(varargin)

handles = varargin{1};
types = varargin{2};
styles = varargin{3};
hnumber = length(handles);
refresh = 0;
for i=1:hnumber
    switch types{i}
        case ACTIVEX

        otherwise
            out = updateTagProperty(handles{i}, hnumber);
            if out && (refresh ==0)
                refresh = 1;
            end

    end
end

if refresh
    com.mathworks.mlservices.MLInspectorServices.refreshIfOpen;
end

out = {};


% ****************************************************************************
% Helper function for update Tag property
% ****************************************************************************
function out = updateTagProperty(h, numselected)

out = 0;
if isempty(ishandle(h))
    return;
end
oldTag = getappdata(h, tagPropertyLastValid);
newTag = get(h,'Tag');

% Tag value validation should be moved to Inspector
if ~isvarname(newTag)
    set(h, 'Tag', oldTag);
    out = 1 ;
else
    if ~isvarname(oldTag)
        % update last valid tag
        setappdata(h, tagPropertyLastValid, newTag);
        return;
    elseif strcmp(newTag, oldTag)
        return;
    end

    if ~strcmpi(get(h,'Type'),'Figure')
        fig = getParentFigure(h);
    else
        fig = h;
    end

    % show warning dialog if more than one component is using the same tag
    if getTagCount(h, newTag)>1
        usermessage = sprintf('%s',getString(message('MATLAB:guide:guidefunc:SameTagForMultipleComponents', newTag)));
        warndlg(usermessage, getDialogTitle(),'modal');
    end

    % update m file when tag changed only when GUIDE is in fig/mfile mode
    status = getGuiStatus(fig);
    if status.figure.exist && status.mfile.file 
        filename ='';
        if status.mfile.exist
            filename = get(fig,'Filename');
        else
            opts =guideopts(fig);
            if isfield(opts,'lastSavedFile')
                filename = opts.lastSavedFile;
            end
        end
        if ~isempty(filename)
            [path, file, ext] = fileparts(filename);

            % reset existing callbacks to AUTOMATIC, only those
            % callback properties whose value is generated by GUIDE
            % already will be changed here.
            guidemfile('resetAutoCallback', h, file, {oldTag});
        end        
    end
    % update last valid tag
    setappdata(h, tagPropertyLastValid, newTag);
end

% *************************************************************************
% get the release number for GUIDE GUI
% *************************************************************************
% We need a more reliable way to get this information. There was a problem
% in R13.0.1
function rnumber = getGuiReleaseNumber
rnumber = str2double(version('-release'));

% *************************************************************************
%
% *************************************************************************
function [adapters, parents] = getGuiMenus(fig)

show = get(0, 'showhiddenhandles');
set(0, 'showhiddenhandles', 'on');
menus=menueditfunc('getMenuHandles',fig);
set(0, 'showhiddenhandles', show);

adapters={};
parents={};
if ~isempty(menus)
    for i=1:length(menus)
        adapters{end+1} = requestJavaAdapter(menus(i));
        parents{end+1} = requestJavaAdapter(get(menus(i),'parent'));

        % initialize the last known valid tag
        initLastValidTag(menus(i));
    end
end

% *************************************************************************
%
% *************************************************************************
function [adapters, parents] = getGuiToolbar(fig)

children = guidemfile('getToolbarToolInFigure', fig);

adapters={};
parents={};
if ~isempty(children)
    for i=1:length(children)
        adapters{end+1} = requestJavaAdapter(children(i));
        parents{end+1} = requestJavaAdapter(get(children(i),'parent'));

        % initialize the last known valid tag
        initLastValidTag(children(i));
    end
end

% *************************************************************************
% The code below is for supporting external controls in GUIDE. Following is
% a list of functions in this file:
%       ACTIVEX
%
%       isExternalControl(obj)
%       getExternalControlInfo(obj)
%       setExternalControlInfo(obj, info)
%       createExternalControlInfo(varargin)
%
%       createExternalControl(varargin)
%       createExternalControlInstance(fig, position, info)
%       createExternalControlPeer(fig, position, info)
%       connectExternalControlPeer(control, peer)
%       getExternalControlCreator(obj)
%
%       copyExternalControl(original, parent)
%       saveExternalControl(fig, filename)
%       moveExternalControl(obj, pos)
%       selectActiveXControl(varargin)
%       showPropertyPage(varargin)
%
% Some code also added to guidemfile, functions that were added or affected
% by supporting external control in guidemfile are:
%       isExternalControl
%       getCallbackProperties
%       getCallbackProperty
%       setCallbackProperty
%       setAutoCallback
%       chooseCopyCallbacks
%       makeFunctionPostComment
% *************************************************************************

% *************************************************************************
% return the Type string of ActiveX controls
% *************************************************************************
function string = ACTIVEX

string = 'activex';


% *************************************************************************
% test whether a HG object is really used as a wrapper for an external
% control, such as ActiveX
% *************************************************************************
function result = isExternalControl(obj)

result = 0;

% ActiveX does not support application data
if any(ishandle(obj))
    try
        result = isappdata(obj, 'Control');
    catch
        result = 0;
    end
end

% *************************************************************************
% obtain the external control information saved on its HG wrapper
% *************************************************************************
function info = getExternalControlInfo(obj)

info =[];

if isExternalControl(obj)
    info = getappdata(obj, 'Control');
end


% *************************************************************************
%o set the external control information on its HG wrapper
% *************************************************************************
function setExternalControlInfo(obj, info)

if ishandle(obj)
    setappdata(obj, 'Control', info);
end

% *************************************************************************
% return the string that will be used as the CreateFcn callback  of the
% HG wrapper for creating the external control
% *************************************************************************
function creator = getExternalControlCreator(obj)

creator ='';
if isExternalControl(obj)
    control = getExternalControlInfo(obj);
    switch control.Type
        case ACTIVEX
            creator = 'actxproxy(gcbo);';
    end
end


% *************************************************************************
% make a copy an external control
% *************************************************************************
function duplicate = copyExternalControl(original, parent)

duplicate =[];
if isExternalControl(original)
    info = getExternalControlInfo(original);

    duplicate = handle(makeCopyInParent(original,parent));
    % Empty createFcn so that external control is not created as in running
    % mode
    set(duplicate,'createFcn',[]);

    % make copy of external control with the same properties
    control = info.Instance;
    type = info.Type;
    [properties{1}, properties{2}] = getProperty(control);

    switch type
        case ACTIVEX
            info.Instance = [];
            info.Serialize = '';
            info.Runtime =0;
            setExternalControlInfo(duplicate, info);

            h = createExternalControl(parent, type, duplicate, properties);
    end
end

% *************************************************************************
% make a copy an external control
% *************************************************************************
function duplicate = makeCopyInParent(original, parent)

% createFcn should not be called when copying
createfcn = get(original,'createFcn');
set(original,'createFcn', []);

all=findall(original);
units= get(all,'units');
funits= get(all,'fontunits');
if ~iscell(units)
    units = {units};
end
if ~iscell(funits)
    funits = {funits};
end
set(all,'units',matlab.ui.internal.PositionUtils.getPlatformPixelUnits());
set(all,'fontunits','points');

duplicate = copyobj(original, parent);

copies=findall(duplicate);
for i=1:length(all)
    set(all(i),'units',units{i});
    set(copies(i),'units',units{i});
    set(all(i),'fontunits',funits{i});
    set(copies(i),'fontunits',funits{i});
end

set(original,'createFcn', createfcn);
set(duplicate,'createFcn', createfcn);

% *************************************************************************
% reverse the child order of HG objects used as peers of external controls
% *************************************************************************
function reverseExternalControlPeer(fig)
% HG is creating the last added object first. We rely on the CreateFcn of
% HG peer of external control for creating external control. We need to
% reverse the order of these peers so that external controls are created in
% the right order
kids= allchild(fig);
limit = length(kids);
index = zeros(limit,1);
found = false;
for i=1:limit
    if isExternalControl(kids(i))
        index(i,1)= 1;
        found= true;
    end
end

if found
    kids(find(index)) = flipud(kids(index==1));
    set(fig,'Children',kids);
end

% *************************************************************************
% save an external control
% *************************************************************************
function saveExternalControl(fig, filename)

kids= handle(allchild(fig));
limit = length(kids);
[pname, funcname, ext] = fileparts(filename);

for i=1:limit
    if isExternalControl(kids(i))
        control = getExternalControlInfo(kids(i));
        switch control.Type
            case ACTIVEX
                % serialize of Activex control
                try
                    afname = [funcname, '_', get(kids(i), 'Tag')];
                    controlfile = fullfile(pname, afname);
                    save(control.Instance, controlfile);
                    control.Serialize = afname;
                catch
                end

                % save callback info for registering events handlers in
                % running mode
                callbacks = control.Callbacks;
                eventlist = guidemfile('getCallbackProperties', kids(i));
                for j=1:length(eventlist)
                    if ~isempty(get(kids(i), char(eventlist{j})))
                        if isempty(find(ismember(callbacks, eventlist{j})))
                            callbacks{end+1} = eventlist{j};
                        end
                    end
                end
                control.Callbacks = callbacks;

                % reset the external control instance so that it will not
                % be saved as part of the app data when the figure itself
                % is saved. It needs to be restored after the figure is
                % saved. See afterSaveExternalControl
                control.Instance =[];
                
                setExternalControlInfo(kids(i), control);
        end
    end
end

% *************************************************************************
% clean up after the figure is saved
% *************************************************************************
function afterSaveExternalControl(fig)

kids= handle(allchild(fig));
limit = length(kids);

for i=1:limit
    if isExternalControl(kids(i))
        control = getExternalControlInfo(kids(i));
        switch control.Type
            case ACTIVEX
                % restore the removed external control instance handle
                % during saving the GUI
                control.Instance = get(kids(i),'Peer');
                
                setExternalControlInfo(kids(i), control);
        end
    end
end

% *************************************************************************
% change the position of an external control
% *************************************************************************
function moveExternalControl(obj, pos)

if isExternalControl(obj)
    info = getExternalControlInfo(obj);
    type = info.Type;
    control = info.Instance;
    switch type
        case ACTIVEX
            if ishandle(control)
                control.move(pos);
            end
    end

end


% *************************************************************************
% create HG uicontrol
% *************************************************************************
function h = createUicontrol(varargin)

parent = varargin{1};

% for creating new UIcontrol
if (~isempty(varargin{7}) && ~isempty(varargin{8}))
    % from RedoAdd or UndoDeletef
    fields = varargin{7}';
    values = varargin{8};
    h = uicontrol('parent', parent);
    setProperty(h, fields, values);
else
    % from create new object. The position passed from Java is in
    % pixel.
    h = uicontrol('Parent', parent, ...
        'Units', matlab.ui.internal.PositionUtils.getPlatformPixelUnits(), ...
        'Position', varargin{4}, ...
        'Style', varargin{5}, ...
        'String', varargin{6});

    configNewGobject(h,parent, 0);
end

% *************************************************************************
% create uitable
% *************************************************************************
function h = createUitable(varargin)
parent = varargin{1};

if strcmpi(varargin{5},'table')
    % for creating new UIcontrol
    if (~isempty(varargin{7}) && ~isempty(varargin{8}))
        % from RedoAdd or UndoDeletef
        h = uitable('parent', parent);
        drawnow;
        fields = varargin{7}';
        values = varargin{8};
        setProperty(h, fields, values);
    else
        % from create new object. The position passed from Java is in
        % pixel.
        h = uitable('parent', parent, ...
            'units', matlab.ui.internal.PositionUtils.getPlatformPixelUnits, ...
            'position', varargin{4});
        set(h,'data',getInitialUitableData(h));

        configNewGobject(h,parent, 0);
    end
end

% *************************************************************************
% make sure the HG object has the right property values require by the GUI
% options
% *************************************************************************
function out = configNewGobject(h, parent, external)

out = {};

options = guideopts(parent);

if isprop(handle(h),'Units')
    if strcmp(options.resize, 'simple')
        set(h,'units','normalized')
    else
        set(h,'units','character');
    end
end

if ~external
    set(h,'tag',nextTag(h));
    if strcmp(get(h,'type'),'uicontrol') && options.mfile && options.callbacks
        guidemfile('chooseAutoCallbacks',h);
    end

    % run possible existing createfcn we added for the component to apply
    % changes that will be seen in runtime
    hObject = h;
    handles = struct();
    type=get(h,'type');
    style =type;
    if strcmpi(type,'uicontrol')
        style = get(h,'style');
    end
    eval(guidemfile('makeFunctionPostComment', h, 'CreateFcn',type,style,get(h,'Tag')));
end

% *************************************************************************
% create HG axes
% *************************************************************************
function h = createAxes(varargin)

parent = varargin{1};

% for creating new Axes
if (~isempty(varargin{7}) && ~isempty(varargin{8}))
    % from RedoAdd or UndoDelete
    h = axes('parent', parent);
    fields = varargin{7}';
    values = varargin{8};
    setProperty(h, fields, values);
else
    h = axes('parent', parent, ...
        'units', matlab.ui.internal.PositionUtils.getPlatformPixelUnits(), ...
        'position', varargin{4});

    configNewGobject(h,parent,0);
end

% *************************************************************************
% create HG containers
% *************************************************************************
function h = createContainer(varargin)

parent = varargin{1};
type = varargin{2};
position = varargin{4};
style = varargin{5};
title = varargin{6};
properties{1} = varargin{7}';
properties{2} = varargin{8};

pUnits = matlab.ui.internal.PositionUtils.getPlatformPixelUnits();
switch style
    case 'panel'
        h = uipanel('parent', parent,'units', pUnits, 'position', position,'title', title);
    case 'buttongroup'
        h = uibuttongroup('parent', parent,'units', pUnits,'position', position,'title', title);
    otherwise
        h = uicontainer('parent', parent,'units', pUnits,'position', position);
end

if ~isempty(properties{1})
    setProperty(h, properties{1}, properties{2});
else
    configNewGobject(h, parent,0);
end

% *************************************************************************
% create an external control for GUIDE
% *************************************************************************
function h = createExternalControl(varargin)

fig =varargin{1};
type = varargin{2};

peer = [];              %the uicontrol peer for external control
position = [];          %the location where the external control should be
properties{1} =[];      %properties is P/V pairs for undo/redo and copy
properties{2} =[];
undoredo = 0;           %flag to indicate whether from undo/redo

% First, create or get external control info structure.
if length(varargin)>4   % first time creation or from redo/undo
    info = createExternalControlInfo(varargin{:});

    properties{1} = varargin{7}';
    properties{2} = varargin{8};
    position = varargin{4};
    if ~isempty(properties{1});
        undoredo =1;
    end
else
    peer = varargin{3};
    info = getExternalControlInfo(peer);
    position = getpixelposition(peer);

    if length(varargin) == 4    % copy/paste or duplicate
        properties{1} = varargin{4}{1};
        properties{2} = varargin{4}{2};
    end
end

% Second, create external control and possibly its peer
runtime = info.Runtime;
if ~runtime
    % first time/undoredo/copy/paste/duplicate
    info.Instance = createExternalControlInstance(fig, position, info);

    % create the uicontrol peer: first time/undoredo
    if isempty(peer)
        peer = createExternalControlPeer(fig, position, info);
        configNewGobject(peer, fig, 1);
    end
else
    % update peer units to be Character or normalized when loading previously
    % saved GUI
    configNewGobject(peer, fig, 1);
end
info.Runtime = 0;
h = info.Instance;
% store updated external control info
setExternalControlInfo(peer, info);

% Third, add instance properties for all the external events for
% automatically generating callbacks in MATLAB file.
eventlist = guidemfile('getCallbackProperties', peer);
for i=1:length(eventlist)
    if ~isprop(peer, eventlist{i})
        % we do not need to serialize these instance properties
        createDynamicProperty(peer, eventlist{i});
        if ismember(eventlist{i}, info.Callbacks)
            guidemfile('setAutoCallback', peer,  eventlist{i});
        end
    end
end

% Fourth, connect external control and its uicontrol peer by instance
% property:
set(peer,'HandleVisibility', 'off');
set(peer,'Visible', 'off');
connectExternalControlPeer(h, peer)

% Fifth, apply P/V pairs if given for undoredo/copy
if ~isempty(properties{1});
    fields = properties{1};
    values = properties{2};
    setProperty(peer, fields, values);
    h.Peer = peer;
    peer.Peer = h;
end

% Last, correct Tag and CreateFcn properties if needed
if ~runtime && ~undoredo
    set(peer, 'Tag', nextTag(peer));
end
set(peer, 'CreateFcn', getExternalControlCreator(peer));



% *************************************************************************
% create a real external control in MATLAB
% *************************************************************************
function instance = createExternalControlInstance(fig, position, info)

instance=[];
switch info.Type
    case ACTIVEX
        % The Position from Java is in PlatformPixels, in this case
        % devicepixels for Windows. We need to convert that to pixels to
        % give to the actxcontrol API. 
        pos = matlab.ui.internal.PositionUtils.getPlatformPixelRectangleInPixels(position, fig);
        instance = actxcontrol(info.ProgID, pos, double(fig));
end

% *************************************************************************
% create the HG wrapper for an external control
% *************************************************************************
function peer = createExternalControlPeer(fig, position, info)

peer = uicontrol('parent', fig, 'Units',  matlab.ui.internal.PositionUtils.getPlatformPixelUnits(), ...
    'position', position, 'style', 'text');
%uistack(peer,'bottom');

peer=handle(peer);


% *************************************************************************
% set an external control and its HG wrapper so that they can find each
% other
% *************************************************************************
function connectExternalControlPeer(control, peer)

peer =handle(peer);
if ~isprop(peer, 'Peer')
    % we do not need to serialize this instance properties
    createDynamicProperty(peer, 'Peer');
end
if ~isprop(control, 'Peer')
    control.addproperty('Peer');
end
control.Peer = peer;
peer.Peer = control;


% *************************************************************************
% return the information about an external control that needs to be saved
% on its HG wrapper
% *************************************************************************
function info = createExternalControlInfo(varargin)

% Create fields common to all external controls
info.Type = varargin{2};        % external control type
info.Style = varargin{5};       % external control style
info.Instance = [];             % store the handle to the created external control in MATLAB
info.Runtime = 0;               % indicates whether it is called from bringing in a running figure
info.Callbacks = {};            % cell array for storing those callbacks that have stubs in MATLAB file

% Create fields specific to external controls
switch info.Type
    case ACTIVEX
        info.ProgID = char(varargin{6}{1}); % ProgID of ActiveX, needed by actxcontrol
        info.Name = char(varargin{6}{2});   % Name of ActiveX
        info.Serialize = '';                % the disk file where Activex is serialized
end



% *************************************************************************
% This is where to get necessary information about a control that is being
% created in GUIDE layout before it is shown.
% *************************************************************************
function out = prepareProxy(varargin)
out = {};

type = varargin{1};
switch type
    case ACTIVEX
        out = selectActiveXControl;
end


% *************************************************************************
% show the actxcontrolselect dialog for user to select an ActiveX
% *************************************************************************
function out = selectActiveXControl(varargin)
out = {};
if isappdata(0, 'MathWorks_GUIDE_testmode')
    % Do not show dialog to select ActiveX control in test mode. Use one
    % control comes along with MATLAB instead
    list = getActiveXControlList;
    index = find(ismember(list{1}, 'MWSAMP.MwsampCtrl.1'));
    if isempty(index)
        system(sprintf('regsvr32 /s "%s"', ...
            fullfile(matlabroot,'toolbox\matlab\winfun',computer('arch'),'mwsamp.ocx')));
        list = getActiveXControlList;
        index = find(ismember(list{1}, 'MWSAMP.MwsampCtrl.1'));
    end
    info = {char(list{2}(index)), char(list{1}(index))};
else
    [h, info] = actxcontrolselect('User',getDialogTitle());
end

if ~isempty(info)
    out{1} = {info{2}, info{1}};
else
    out{1} ={};
end

% ****************************************************************************
% return the list of all ActiveX controls on a computer system
% ****************************************************************************
function out = getActiveXControlList

out = {};

controls = actxcontrollist;
out{1} = controls(:,2);
out{2} = controls(:,1);

% *************************************************************************
% use Propedit to change the properties of an object. For ActiveX, this
% will show its built-in property pages.
% *************************************************************************
function out =  showPropertyPage(varargin)

out = {};

phandle = handle(varargin{1});
fig = getParentFigure(phandle);
if isExternalControl(phandle)
    phandle = phandle.Peer;
end
    propedit(phandle);

    % we only need to run the following code when there are changes to the
    % Activex properties. This is impossible to get at this time.
    markDirty(fig);
    com.mathworks.mlservices.MLInspectorServices.refreshIfOpen;
%end

% ****************************************************************************
% change an option of the specified figure
% ****************************************************************************
function out = setOption(varargin)

out = {};
fig = varargin{1};
name = varargin{2};
value = varargin{3};

% get current options
current_options = guideopts(fig);

% modify the specified option
current_options.(name) = value;

% reset the options
guideopts(fig, current_options);

% ****************************************************************************
% show design time error in an error dialog
% ****************************************************************************
function out = showErrorDialog(e,errmessage)

out = {};

links = matlab.internal.display.isHot;
feature('hotlinks',0);
c= onCleanup(@()feature('hotlinks',links));

% show error dialog
h = errordlg(e.getReport(), getDialogTitle());

% Add 'goto error' button
if ~isempty(e.stack)
    gotoline = e.stack(1).line;
    gotofile = e.stack(1).file;

    if gotoline >0 && ~isempty(gotofile)
        ok = findobj(allchild(h),'Type','uicontrol', 'Style','pushbutton');
        if ~isempty(ok)
            goto = uicontrol('Parent',h, ...
                             'String',getString(message('MATLAB:guide:guidefunc:GotoErrorButtonText')),...
                             'Units','pixel',...
                             'Callback', {@gotoErrorLine,  gotofile, gotoline});

            gotosize= get(goto,'Extent');
            gotosize(3) = gotosize(3)+20;
            oksize = getpixelposition(ok);
            figsize =getpixelposition(h);

            gap = 20;
            space = (figsize(3) - gotosize(3) - gap - oksize(3));
            if  space<0
                figsize(3) = figsize -space;
                setpixelposition(h,figsize);
            end
            space = (figsize(3) - gotosize(3) - gap - oksize(3))/2;

            setpixelposition(ok, [space, oksize(2), oksize(3), oksize(4)]);
            setpixelposition(goto, [space+gap+oksize(3),oksize(2),gotosize(3), oksize(4)]);
        end
    end
end

function gotoErrorLine(src, data, file, line)

deleteInDesignTime(getParentFigure(src));
%delete(getParentFigure(src));
matlab.desktop.editor.openAndGoToLine(file, line);

% *************************************************************************
% Given a figure, get a map of the current handles:tags
% *************************************************************************
function out = getCurrentTags(fig)
handles = guihandles(fig);

out = struct('handle', [], 'tag', []);

if(isempty(handles))
    return;
end

tags = fieldnames(handles);
for i=1:length(tags)
   nextTag = char(tags(i));
   nextHandle = handles.(nextTag);
   out(i).handle = handle(nextHandle);
   out(i).tag = nextTag;
end

% *************************************************************************
%  Load an invisible hg gui, and delete it. Gets initialization done.
% *************************************************************************
function preloadFigure(varargin)
filename = varargin{1};
overrides.Visible = 'off';
overrides.IntegerHandle = 'off';
try
[fig, old_vals] = hgload(filename, overrides);
delete(fig);
catch
    %Swallow any error in pre-loading
end

% *************************************************************************
% Get back auto-corrections to filename, and possible error message.
% *************************************************************************
function [p, f, e, ErrMsg]=checkValidFilename(filepath, expectedExtension, fromSaveAs)
ErrMsg = '';
[p, f, e] = fileparts(filepath);
% check to see whether a valid Matlab name
if isempty(f)
    ErrMsg = sprintf('%s',getString(message('MATLAB:guide:guidefunc:InvalidFilenameEmpty', filepath)));
elseif ~isvarname(f)
    ErrMsg = sprintf('%s',getString(message('MATLAB:guide:guidefunc:InvalidFilenameNonfunctionName', filepath, num2str(namelengthmax))));
end
if (~isempty(expectedExtension))
    if (isempty(e))
        e = expectedExtension;
    end

    % in MATLAB, .fig extension is not case sensitive, .m extension is
    exterror = false;
    if strcmpi(expectedExtension,getString(message('MATLAB:guide:guidefunc:GuiFileExtension')))
        if ~strcmpi(e, expectedExtension)
            exterror = true;
        end
    elseif ~strcmp(e, expectedExtension)  % Don't allow any other extension
        exterror = true;
    end
    if exterror
       ErrMsg = sprintf('%s',getString(message('MATLAB:guide:guidefunc:InvalidFileExtensions', [f e], expectedExtension)));
    end
end

if ~fromSaveAs
   if ~isempty(ErrMsg)
      ErrMsg = sprintf('%s',getString(message('MATLAB:guide:guidefunc:ChangeFilenameInInspectora', ErrMsg)));
   end
end

% *************************************************************************
%
% *************************************************************************
function out = guide2tool(varargin)
out=guidetoolfunc(varargin{:});

% *************************************************************************
% mark a figure as a GUIDE figure
% *************************************************************************
function markGuideFigure(fig, varargin)
createDynamicProperty(handle(fig), 'GUIDEFigure');

% *************************************************************************
% 1. Remove GUIDEFigure flag from the GUIDE Figure before saving
% 2. Convert stored active figure handle to double before saving to avoid 
%    serialization of the runtime (active) figure within the GUI fig file
% *************************************************************************
function clearGuideFigure(fig, varargin)
p = findprop(handle(fig), 'GUIDEFigure');
delete(p);


if isappdata(fig, 'GUIDEOptions')
    appd = getappdata(fig, 'GUIDEOptions');
    if isfield(appd, 'active_h')
        appd.active_h = double(appd.active_h);
        setappdata(fig, 'GUIDEOptions', appd);
    end
end

function createDynamicProperty(obj, propname)
obj =handle(obj);
p = findprop(obj,propname);
assert(isa(obj,'dynamicprops'));
if isempty(p) 
    p = addprop(obj,propname);
    p.Hidden = true;
    p.Transient = true;
end

% *************************************************************************
% handle HG incompatibilities that impact GUIDE GUI
% *************************************************************************
function accountForHGIncompatibilities(obj)

% first, the callback of buttons in buttongroup needs to be removed
parent = get(obj,'Parent');
if ishghandle(obj,'uicontrol') && isa(handle(parent),'matlab.ui.container.ButtonGroup'); 
    callback = get(obj,'callback');
    if ~isempty(callback) && iscell(callback) && length(callback)==2 ...
    && isa(callback{1},'function_handle') && isequal(func2str(callback{1}), 'manageButtons')...
    && isequal(parent, callback{2})
        set(obj,'callback',[]);
    end
end

% *************************************************************************
% helper function of adding new line
% *************************************************************************
function newline = getNewLineCharacter()

newline = getString(message('MATLAB:guide:guidefunc:NewLineCharacter'));

% *************************************************************************
% helper function of adding new line
% *************************************************************************
function title = getDialogTitle()

title = getString(message('MATLAB:guide:ComponentName'));


% Legend and ColorBar objects are not on the guide palette and were never 
% intended to be supported.    In HG1 however, the user could add those 
% objects to a figure outside of guide and they would inadvertently be loaded 
% correctly in guide because those objects are an axes which guide does
% support.   In HG2 however, the Legend and ColorBar have changed types;  
% guide doesn't know how to handle the new types and throws exceptions.  

% Since legend and colorbar objects are really not supported, the fix for 
% is that we will no longer load unsupported object types into GUIDE but 
% instead throw a warning on the command line.
% Since legend and colorbar objects were never really supported, and these 
% are edge cases,  this new behavior is regardless of what version of HG is 
% used.   An undesirable side-effect of this solution is that if the user 
% then saves the fig file where the legend and colorbar objects have been 
% removed,  the legend and colorbar objects are removed from the file.
%
% Removing Uitabgroups and orange charts as well since they are new in HG2 
% and are not supported in GUIDE (g1158784, g1523111).
%
% The function will return a cell array of any unsupported object types 
% found in the figure recursively. It returns an empty cell if none found.
function invalidObjectTypes = handleUnsupportedObjectTypes(fig) 
% loop over the children of the fig file
childObjects = get(fig,'Children');
numChildren = length(childObjects);
invalidObjectTypes = {}; 

for i=numChildren:-1:1
    childObjectHandle = handle(childObjects(i));
    childObjectType= handle(childObjectHandle).Type;
    % if any of the children is of an unsupported object type, then delete
    % the child object from the fig and set the warning flag to true so the
    % warning can be thrown
     if ( strcmp(childObjectType,'legend') ||...
          strcmp(childObjectType,'colorbar') ||...
          strcmp(childObjectType,'uitabgroup') || ... % g1158784
          isa(childObjectHandle,'matlab.graphics.chart.Chart')) %g1523111

        delete(childObjectHandle);
        invalidObjectTypes{end+1} = childObjectType;
     elseif ~isempty(get(childObjectHandle, 'Children'))
        unsupportedChildren = handleUnsupportedObjectTypes(childObjectHandle);
        invalidObjectTypes = [invalidObjectTypes, unsupportedChildren];
     end
     
end
