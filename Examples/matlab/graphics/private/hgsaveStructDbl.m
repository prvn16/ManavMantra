function hgS = hgsaveStructDbl(h, doAll)
%hgsaveStructDbl Save double handles to a structure.
%
%  hgsaveStructDbl converts handles into a structure ready for saving.
%  This function is called when MATLAB is using double HG handles.

%   Copyright 2009-2012 The MathWorks, Inc.


% if saving a figure and plotedit, zoom, camera toolbar,rotate3d or
% brushing are on, save their states and
% turn them off before saving
% and if scribe clear mode callback appdata
% exists, remove it.
hFigures = findall(h, 'type', 'figure');

plotediton = zeros(length(hFigures),1);
rotate3dstate = cell(length(hFigures),1);
zoomstate = cell(length(hFigures),1);
datacursorstate = false(length(hFigures),1);
panstate = false(length(hFigures),1);
scmcb = cell(length(hFigures),1);
camtoolbarstate = zeros(length(hFigures),1);
camtoolbarmode = cell(length(hFigures),1);
brushing = false(length(hFigures),1);

for i = 1:length(hFigures)
    camtoolbarstate(i) = cameratoolbar(hFigures(i),'GetVisible');
    plotediton(i) = plotedit(hFigures(i), 'isactive');
    rotate3dstate{i} = getappdata(hFigures(i),'Rotate3dOnState');
    zoomstate{i} = getappdata(hFigures(i),'ZoomOnState');
    datacursorstate(i) = strcmp(datacursormode(hFigures(i),'ison'),'on');
    panstate(i) = pan(hFigures(i),'ison');
    brushing(i) = brush(hFigures(i),'ison');
    s = getappdata(hFigures(i),'ScribeClearModeCallback');
    if camtoolbarstate(i)
        camtoolbarmode{i} = cameratoolbar(hFigures(i),'GetMode');
        cameratoolbar(hFigures(i),'save');
    end
    if ~isempty(s) && iscell(s)
        scmcb{i} = s;
        rmappdata(hFigures(i),'ScribeClearModeCallback');
    end
    if plotediton(i)
        plotedit(hFigures(i),'off');
    end
    if ~isempty(rotate3dstate{i})
        rotate3d(hFigures(i),'off');
    end
    if ~isempty(zoomstate{i})
        zoom(hFigures(i),'off');
    end
    if datacursorstate(i)
        datacursormode(hFigures(i),'off');
    end
    % Serialize data tip information:
    hDCM = datacursormode(hFigures(i));
    hDCM.serializeDatatips;
    if panstate(i)
        pan(hFigures(i),'off');
    end
    if brushing(i)
        brush(hFigures(i),'off')
    end
end

% Call preserialize method on objects that have one
fch = findall(h);
olddata = cell(length(fch),1);
for i=1:length(fch)
    [ lmsg, lid ] = lastwarn;
    ws = warning('off','MATLAB:hg:DoubleToHandleConversion');
    
    hh = handle(fch(i));
    
    warning(ws);
    lastwarn( lmsg, lid );
    
    if ismethod(hh,'preserialize')
        olddata{i} = {hh,preserialize(hh)};
    end
end


%If axes are linked, we need to capture this in the saved file
allAxes = unique(findall(h,'Type','axes'));
l = length(allAxes);
linkage = [];
for i = 1:l
    %For all the axes which are linked to other axes, obtain the handle to the
    %linkprop objects
    if isappdata(allAxes(i),'graphics_linkaxes')
        temp_link = getappdata(allAxes(i),'graphics_linkaxes');
        if ishandle(temp_link)
            linkage = [linkage temp_link];
        end
    end
end
linkage = unique(linkage);
targets = [];
for i = 1:length(linkage)
    param = '';
    t = get(linkage(i),'Targets');
    props = get(linkage(i),'PropertyNames');
    if any(strcmp(props,'XLim'))
        param = strcat(param,'x');
    end
    if any(strcmp(props,'YLim'))
        param = strcat(param,'y');
    end
    for j = 1:length(t)
        %Only store this information if the target is being saved
        if any(allAxes == t(j))
            setappdata(t(j),'graphics_linkaxes_targets',i);
            setappdata(t(j),'graphics_linkaxes_props',param);
        else
            t(j) = handle(-500);
        end
    end
    t(~ishandle(t)) = [];    
    targets = [targets t];
end

% Serialize any attached behavior objects
% This is a work around until HG supports MCOS serialization
hWithBehaviors = localSerializeBehaviorObjects(h);

% Serialize the Annotation property.
% This is a work around until HG supports composite object / UDD
% serialization.
hWithAnnotations = localSerializeAnnotations(h);

flags = {};
if doAll
    flags = {'all'};
end

%If we fail here, remove the additional application data
try
    hgS = handle2struct(h, flags{:}); 
catch ex
    for i = 1:length(targets)
        rmappdata(targets(i),'graphics_linkaxes_targets');
        rmappdata(targets(i),'graphics_linkaxes_props');
    end
    rethrow(ex);
end

% Remove temporary behavior serialization data
localClearBehaviorSerialization(hWithBehaviors);
% Remove temporary annotation serialization data.
localClearAnnotationSerialization(hWithAnnotations);


% Call postserialize method on objects that have one and that we called
% preserialize on
for i = 1:length(olddata)
    if ~isempty(olddata{i})
        if ismethod(olddata{i}{1},'postserialize')
            postserialize(olddata{i}{:});
        end
    end
end

% restore plotedit, zoom, camera toolbar and rotate3d states if saving
% figures
for i = 1:length(hFigures)
    % if the camera toolbar was on, restore it
    if camtoolbarstate(i)
        cameratoolbar(hFigures(i),'toggle');
        cameratoolbar(hFigures(i),'SetMode',camtoolbarmode{i});
    end
    % if plotedit was on, restore it
    if plotediton(i)
        plotedit(hFigures(i),'on');
    end
    % if rotate3d was on, restore it
    if ~isempty(rotate3dstate{i})
        rotate3d(hFigures(i),rotate3dstate{i});
    end
    % if zoom was on, restore it
    if ~isempty(zoomstate{i})
        zoom(hFigures(i),zoomstate{i});
    end
    if datacursorstate(i)
        datacursormode(hFigures(i),'on');
    end
    % Remove any appdata that was created by the serialization
    hDCM = datacursormode(hFigures(i));
    hDCM.clearDatatipSerialization;
    if panstate(i)
        pan(hFigures(i),'on');
    end
    if brushing(i)
        brush(hFigures(i),'on');
    end
    % if there was a scribeclearmodecallback, reset it
    if ~isempty(scmcb{i})
        setappdata(hFigures(i),'ScribeClearModeCallback',scmcb{i});
    end
end

%Clean up
for i = 1:length(targets)
    rmappdata(targets(i),'graphics_linkaxes_targets');
    rmappdata(targets(i),'graphics_linkaxes_props');
end

%-------------------------------------------------%
function ret = localSerializeBehaviorObjects(h)

% Find all the objects with non-empty behavior objects
% struct = empty struct, the default value of 'behavior' property
ret = findall(h,'-and','-not',{'Behavior',struct},'-function',@localDoSerialize);
 
%-------------------------------------------------%
function ret = localSerializeAnnotations(h)

% Find all the objects that have an annotation property:
[ lmsg, lid ] = lastwarn;
ws = warning('off','MATLAB:hg:DoubleToHandleConversion');

ret = findall(h,'-function',@(h)(isprop(handle(h),'Annotation')));

warning(ws);
lastwarn( lmsg, lid );

% If the property has an a serialized annotation, skip it. Otherwise,
% serialize its annotations:
for i = 1:numel(ret)
    if isappdata(ret(i),'SerializedAnnotationV7')
        continue;
    end
    hA = get(ret(i),'Annotation');
    if ~isa(hA,'hg.Annotation')
        continue;
    end
    % The convention for the "Annotation" property is that each property is
    % a handle. The handle contains the state we are interested in:
    hP = get(hA);
    serProp = structfun(@localhandle2struct,hP,'UniformOutput',false);
    setappdata(ret(i),'SerializedAnnotationV7',serProp);
end


%-------------------------------------------------%
function localClearBehaviorSerialization(h)
% Remove temporary appdata serialization 

for n = 1:length(h)
   if ishghandle(h(n)) && isappdata(h(n),'SerializedBehaviorV7')
      rmappdata(h(n),'SerializedBehaviorV7');
   end
end

%-------------------------------------------------%
function localClearAnnotationSerialization(h)
% Remove temporary appdata serialization 

for n = 1:length(h)
   if ishghandle(h(n)) && isappdata(h(n),'SerializedAnnotationV7')
      rmappdata(h(n),'SerializedAnnotationV7');
   end
end

%-------------------------------------------------%
function [ret]= localDoSerialize(h)
% For the supplies handle, find all the behavior objects that 
% support serialization. Serialize each object in appdata

ret = false;
b = get(h,'Behavior');
if ~isempty(b)
    
    % Find behavior objects with 'Serialize' = true
    b = struct2cell(b);
    b = [b{:}];
    b = find(b,'Serialize',true);
   
    if ~isempty(b)
        appdata = struct;
   
        % Loop through each behavior object and create a structure 
        % that represents the state
        count = 1;
        for n = 1:length(b)
            
            % Serialize behavior object as a structure in appdata
            try %#ok
                s = localhandle2struct(b(n));
                if ~isempty(s) 
                   appdata(count).class = class(b(n));
                   appdata(count).properties = s;
                   count = count + 1;
                end
            end
        end
        setappdata(double(h),'SerializedBehaviorV7',appdata);
        ret = true;
    end
end

%-------------------------------------------------%
function s = localhandle2struct(hThis)
% Converts a generic UDD handle to a structure for serialization

s = [];
hCls = classhandle(hThis);
hProp = get(hCls,'Properties');

% Loop through properties
for n = 1:length(hProp)
    p = hProp(n);
    
    if ishandle(p)
        propname = get(p,'Name');
        propval = get(hThis,propname);

        % Serialize any properties that are public set, non-default
        if isequal(p.AccessFlags.Serialize,'on') && ...
           isequal(p.AccessFlags.PublicSet,'on') && ...
           ~isequal(get(p,'FactoryValue'),p)
              s.(propname) = propval;
        end
    end
end


