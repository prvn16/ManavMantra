function startscribeobject(objtype,fig)
%STARTSCRIBEOBJECT Initialize insertion of annotation.

%   Copyright 1984-2014 The MathWorks, Inc.

plotedit(fig,'on');
hPlotEdit = plotedit(fig,'getmode');

objtypes = {'rectangle','ellipse','textbox','doublearrow','arrow','textarrow','line'};
if (strcmpi(objtype, 'none'))
    tindex = 0;
   if isappdata(fig, 'StartScribeObject')
       %See comment on line 41(Turning off the other toggles will call ...)
       %to understand why this is important
       return
   end
else
    tindex = find(strcmpi(objtype,objtypes));
end
if isempty(tindex)
    error(message('MATLAB:startscribeobject:UnknownObjectType'));
end

% turn off other toggles
setappdata(fig, 'StartScribeObject', 1);
t = {...
 uigettool(fig,'Annotation.InsertRectangle'),...
 uigettool(fig,'Annotation.InsertEllipse'),...
 uigettool(fig,'Annotation.InsertTextbox'),...
 uigettool(fig,'Annotation.InsertDoubleArrow'),...
 uigettool(fig,'Annotation.InsertArrow'),...
 uigettool(fig,'Annotation.InsertTextArrow'),...
 uigettool(fig,'Annotation.InsertLine'),...
 uigettool(fig,'Annotation.Pin')};
ntoggles = length(t);
for k=1:ntoggles-1
    if k~=tindex && ~isempty(t{k})
        set(t{k},'state','off');
    end
end
rmappdata(fig, 'StartScribeObject');

% Specify the object to be created
hMode = hPlotEdit.ModeStateData.CreateMode;
hMode.ModeStateData.ObjectName = objtype;

% Revert to the default mode if there is nothing to be done.
if tindex == 0
    activateuimode(hPlotEdit,'');
    return;
end

% If the mode is already started (i.e. we are switching objects, skip this
% step.
if ~isactiveuimode(hPlotEdit,'Standard.ScribeCreate')
    activateuimode(hPlotEdit,hMode.Name);
end







