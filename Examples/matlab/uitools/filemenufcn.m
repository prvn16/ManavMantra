function filemenufcn(hfig, cmd)
% This function is undocumented and will change in a future release

%FILEMENUFCN Implements part of the figure file menu.
%  FILEMENUFCN(CMD) invokes file menu command CMD on figure GCBF.
%  FILEMENUFCN(H, CMD) invokes file menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    FileClose
%    FileExportSetup
%    FileNew
%    FileOpen
%    FilePageSetup
%    FilePreferences
%    FilePrintPreview
%    FilePrintSetup
%    FileSave
%    FileSaveAs

%    FileExport - merged into FileSaveAs
%    FilePost - internal use only

%  Copyright 1984-2012 The MathWorks, Inc.

narginchk(1,2);

if nargin > 1
    cmd = convertStringsToChars(cmd);
end

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

switch cmd
    case 'FilePost'
        localPost(hfig)
    case 'UpdateFileNew'
        localUpdateNewMenu(hfig)
    case 'FileNew'
        localNewFigure(hfig)       
    case 'NewGUI'
        guide
    case 'NewVariable'
        localNewVariable(hfig);
    case 'NewModel'
        % Availability of simulink is verified in 'UpdateFileNew'
        open_system(new_system);
    case 'NewCodeFile'
        matlab.desktop.editor.newDocument;
    case 'FileOpen'
        uiopen figure
    case 'FileClose'
        close(hfig)
    case 'FileSave'
        localSave(hfig)
    case 'FileSaveAs'
        localSaveExport(hfig, false)
    case 'GenerateCode'
        makemcode(hfig,'Output','-editor');
    case 'FileImportData'
        uiimport('-file')
    case 'FileSaveWS'
        localFileSaveWS(hfig);
    case 'FileExport'
        localSaveExport(hfig, false)
    case 'FileExportSetup'
        exportsetupdlg(hfig)
    case 'FilePreferences'
        preferences
    case 'FilePageSetup'
        pagesetupdlg(hfig)
    case 'FilePrintSetup'
        printdlg -setup
    case 'FilePrintPreview'
        printpreview(hfig)
    case 'FileExportAs'
        %To ensure save-as operation from export dialog box
        localSaveExport(hfig, true)
    case 'FileExitMatlab'
        exit
end

% --------------------------------------------------------------------
function  [jframe] = localGetJavaFrame(hfig)
% Get java frame for figure window

jframe = [];

% store the last warning thrown
[ lastWarnMsg, lastWarnId ] = lastwarn;

% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jpeer = get(hfig,'JavaFrame');
warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);

if ~isempty(jpeer)
   jcanvas = jpeer.getAxisComponent; 
   jframe = javax.swing.SwingUtilities.getWindowAncestor(jcanvas);
end

% --------------------------------------------------------------------
function  localFileSaveWS(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getSaveWorkspaceAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

% --------------------------------------------------------------------
function  localNewVariable(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getNewVariableAction;    
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

% --------------------------------------------------------------------
function  localUpdateNewMenu(hfig)

% If no Simulink, hide 'New Model' menu 
h = findall(hfig,'type','uimenu','Tag','figMenuFileNewModel'); 
if exist(fullfile(matlabroot,'toolbox/simulink/simulink/open_system.m'), 'file') 
    set(h,'Visible','on') 
else 
    set(h,'Visible','off'); 
end 


% --------------------------------------------------------------------
function localPost(hfig)
   
filemenuchildren = findall(allchild(hfig),'type','uimenu','Tag','figMenuFile');

filemenuprefs = findall(filemenuchildren,'Tag','figMenuFilePreferences');
filemenuexit = findall(filemenuchildren,'Tag','figMenuFileExitMatlab');

% Hide callbacks that require a java frame
if (usejava('awt') ~= 1)
    set(findall(filemenuchildren,'tag','figMenuFileSaveWorkspaceAs'),'Visible','off');
    set(findall(filemenuchildren,'tag','figMenuFileNewVariable'),'Visible','off');      
end

if ismac
    % If on Mac, hide items already in the MATLAB menu
    set(filemenuprefs,'Visible','off');
    set(filemenuexit, 'Visible','off');
else
    % If figure is not docked, hide 'Exit MATLAB' menu
    if strcmp(get(hfig,'WindowStyle'),'docked')
        set(filemenuexit,'Visible','on');
    else
        set(filemenuexit,'Visible','off');
    end
    
    % hide java dependent items if java is not supported 
    if ~usejava('MWT')
        % Hide File -> Preferences
        set(filemenuprefs,'Visible','off'); 
    end
end

% --------------------------------------------------------------------
function localNewFigure(hfig)

% Create a new figure replicating the WindowStyle from source figure.
figure('WindowStyle', get(hfig, 'WindowStyle'));

% --------------------------------------------------------------------
function localSave(hfig)
filename=get(hfig,'FileName');
if isempty(filename)
  filemenufcn(hfig,'FileSaveAs');
else
  types = localExportTypes(hfig);
  typevalue = getappdata(hfig,LASTEXPORTEDASTYPE);
  [p, f, ext] = fileparts(filename); %#ok<ASGLU>
  if isempty(typevalue)
      % This is here for backwards compatibility: if there is no last
      % exported as type in the figure's appdata, use the extension
      typevalue = localGetTypeFromExtension(hfig, ext);
  end
  
  % If the filename is .fig extension and there is a mismatch with the
  % file format being saved to. Correct the typevalue to reflect this. 
  % See g816907
  if strcmpi(ext,'.fig') && ~strcmpi(ext, types{typevalue,3})
      typevalue = localGetTypeFromExtension(hfig,'.fig');
  end
  
  localSaveExportHelper(hfig, filename, types, typevalue, false);
end       

% --------------------------------------------------------------------
function success = localSaveExportHelper(hfig, filename, types, typevalue, fromExport)
success = false;
setappdata(hfig,LASTEXPORTEDASTYPE,typevalue);

try
   % Handle the case where .fig file format consider for applied export
   % settings and if save-as from file-menu then store in normal way.
  if strcmp(types{typevalue,4},'fig') && ~fromExport
   saveas(hfig,filename);
  else
    style = localGetStyle(hfig);
    hgexport(hfig,filename,style,'Format',types{typevalue,4});
  end
  
  % Handle the case where the figure may have been closed.  Even if it was
  % closed, hgexport was most likely sucessful or it (or the print command)
  % would have produced an error.
  if ishghandle(hfig, 'figure')
    set(hfig,'FileName',filename);
  end
  success = true;
catch ex
  uiwait(errordlg(ex.getReport('basic','hyperlinks','off'),getString(message('MATLAB:uistring:filemenufcn:ErrorSavingFigureDialog')),'modal')); % Hyperlinks are turned off due to g606408
end

% --------------------------------------------------------------------
function str = LASTEXPORTEDASTYPE
str = 'FileMenuFcnLastExportedAsType';

% --------------------------------------------------------------------
function [types,filter] = localGetTypes(hfig, type_id)
types = localExportTypes(hfig);

% since the file selection dialog does not allow us to pre-select which
% filter to use, we will always put the default one at the top of the
% list. 
%
% DO NOT CHANGE THIS BEHAVIOR WITHOUT LOOKING AT THE FUNCTION BELOW:
% getOriginalTypeValueFromLocalTypeValue().  IT UNDOES THE WORK OF THIS
% FUNCTION!
types = [types(type_id,:); types(1:type_id-1,:); types(type_id+1:end,:)];
filter = types(:,1:2);

% --------------------------------------------------------------------
function type_id = getOriginalTypeValueFromLocalTypeValue(localTypeValue, lastExportTypeValue)
% See localGetTypes function: when displaying the save dialog, the last
% exported as type is brought to the top of the list, thus changing the
% positions of many type values in the list.  This function converts the
% local type value back to the original type value by undoing the index
% change.
if (localTypeValue == 1)
    % If the local type value is the first item in the list, then it is
    % the last exported as type
    type_id = lastExportTypeValue;
elseif (localTypeValue <= lastExportTypeValue)
    % If the local type value is not the last exported as type, but is
    % indexed before the lastExportTypeValue, then it has been bumped
    % forward one position in the list to make room for the last exported
    % as type at the top of the list.  Subtract 1 to get the original
    % value.
    type_id = localTypeValue - 1;
else
    % Otherwise, the local type value is some index beyond where all of the
    % changes happened, meaning that this index is the same in the local
    % list as it was in the original list.  Keep it the same.
    type_id = localTypeValue;
end

% --------------------------------------------------------------------
function [filename, EXT] = localGetFilename(hfig,default_ext)

filename=get(hfig,'FileName');

[PATH,FILENAME,EXT] = fileparts(filename);

if isempty(FILENAME)
    FILENAME = 'untitled';
end
if isempty(EXT)
    EXT = default_ext;
end

filename=[FILENAME EXT];

if ~isempty(PATH)
    filename = fullfile(PATH, filename);
end

% --------------------------------------------------------------------
function localSaveExport(hfig, fromExport)
persistent dlgshown;

if ~isempty(dlgshown)
    return;
end

typesorig = localExportTypes(hfig);
lastexporttypevalue = localGetDefaultType(hfig, typesorig);
lastexport_ext = typesorig{lastexporttypevalue,3};

[filename, default_ext] = localGetFilename(hfig,lastexport_ext);        %#ok

% If the filename is .fig extension and there is a mismatch with the
% file format being saved to. Correct the typevalue to reflect this.
% See g816907
[p, f, ext] = fileparts(filename); %#ok<ASGLU>
if strcmpi(ext,'.fig') && ~strcmpi(ext, lastexport_ext)
    lastexporttypevalue = localGetTypeFromExtension(hfig,'.fig');
end

[types,filter] = localGetTypes(hfig, lastexporttypevalue);

% uiputfile on unix will allow saving an empty file name, make sure we get
% a real one.
newfile='';
while isempty(newfile)
    dlgshown = true;
    [newfile, newpath, typevalue] = uiputfile(filter, getString(message('MATLAB:uistring:filemenufcn:TitleSaveAs')),filename);
    dlgshown = [];
end

if newfile == 0
    % user pressed cancel
    return;
end

% make sure a reasonable extension is used
[p,f,ext] = fileparts(newfile);                                         %#ok
if isempty(ext)
  ext = types{typevalue,3};
  newfile = [newfile ext];
end

filename=fullfile(newpath,newfile);
typevalueorig = getOriginalTypeValueFromLocalTypeValue(typevalue, lastexporttypevalue);

localSaveExportHelper(hfig, filename, typesorig, typevalueorig, fromExport);
setappdata(0,LASTEXPORTEDASTYPE,typevalueorig);

% --------------------------------------------------------------------
function list=localExportTypes(hfig)

% build the list dynamically from printtables.m
[a,opt,ext,d,e,output,name]=printtables(printjob(hfig));                                %#ok

% only use those marked as export types (rather than print types)
% and also have a descriptive name
valid=strcmp(output,'X') & ~strcmp(name,'') & ~strcmp(d, 'QT'); 
name = name(valid);
ext  = ext(valid);
opt  = opt(valid);

% remove eps formats except for the first one
iseps = strncmp(name,'EPS',3);
inds = find(iseps);
name(inds(2:end),:) = [];
ext(inds(2:end),:) = [];
opt(inds(2:end),:) = [];

for i=1:length(ext)
    ext{i} = ['.' ext{i}];
end
star_ext = ext;
for i=1:length(ext)
    star_ext{i} = ['*' ext{i}];
end
description = name;
for i=1:length(name)
    description{i} = [name{i} ' (*' ext{i} ')'];
end

% add fig file support to front of list
star_ext = [{'*.fig'};star_ext];
description = [{'MATLAB Figure (*.fig)'};description];
ext = [{'.fig'};ext];
opt = [{'fig'};opt];

[description,sortind] = sort(description);
star_ext = star_ext(sortind);
ext = ext(sortind);
opt = opt(sortind);

list = [star_ext(:), description(:), ext(:), opt(:)];

% Remove deprecated file types from the list so that the SaveAs GUI does 
% not warn. '*.ai' and '*.pkm' options removed from "list". Command line 
% alternatives can be used: '-dill' , '-pkm' 
list( ismember(list(:,1),{'*.ai', '*.pkm'}) , :) = []; 

% --------------------------------------------------------------------
function style = localGetStyle(hfig)
style = getappdata(hfig,'Exportsetup');
if isempty(style)
    try
        style = hgexport('readstyle','Default');
    catch
        style = hgexport('factorystyle');
    end
    style.Units = get(hfig, 'PaperUnits');
    if strcmp(get(hfig, 'PaperPositionMode'), 'auto')
        style.Width = 'auto';
        style.Height = 'auto';
    else
        ppos = get(hfig, 'PaperPosition');
        style.Width = ppos(3);
        style.Height = ppos(4);
        style.XMargin = ppos(1);
        style.YMargin = ppos(2);
    end
end

% --------------------------------------------------------------------
function type_id = localGetDefaultType(hFig, types)
% First, check if the figure has a default type
type_id = getappdata(hFig,LASTEXPORTEDASTYPE);
if isempty(type_id)
    % Next, check if the app has a default type
    type_id = getappdata(0,LASTEXPORTEDASTYPE);
    if isempty(type_id)
        % No default types: default to fig
        typeformats = types(:,4);
        type_id = find(strcmp(typeformats,'fig'));
    end
end

% --------------------------------------------------------------------
function type_id = localGetTypeFromExtension(hfig, ext)
types = localExportTypes(hfig);
typeextensions = types(:,3);
type_ids = find(strcmp(typeextensions,ext));
if ~isempty(type_ids) % For empty
    type_id = type_ids(1);
else  % For empty or invalid extensions use default file types (.fig)
    type_id = localGetDefaultType(hfig, types);
end

