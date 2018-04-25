function varargout = old_pagesetupdlg(Action,varargin)
%OLD_PAGESETUPDLG  Obsolete setup dialog

%   Copyright 1984-2017 The MathWorks, Inc.

switch nargin
case 0
    Fig = gcbf;
	if isempty(Fig)
	  Fig = gcf;
	end
   Dlg = LocalInitFig(Fig);
   if nargout==1
      varargout{1} = Dlg;
   end
case 1
   if isnumeric(Action) && ishandle(Action) ...
              && strcmp(get(Action,'Type'),'figure')
	 Dlg = LocalInitFig(Action);
	 if nargout==1
	   varargout{1} = Dlg;
	 end
	 return
   end
   Dlg = gcbf;
   Data = get(Dlg,'UserData');
   DispatchAction(Action, Dlg, Data);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% DispatchAction %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function DispatchAction(Action, Dlg, Data)
switch Action
case 'Apply'
  try
     Data = LApply(Data);
     % SAVE NEW VALUES
     for lp=1:length(Data.Properties)
        Temp=LocalGet(Data.Fig,Data.Properties{lp});
        if ~iscell(Temp), Temp={Temp}; end 
        Data.OrigData(:,lp)=Temp;
     end
  catch
     errordlg('Unable to set Page Settings.');
  end

case 'Cancel'
  try
     for lp=1:length(Data.Properties)
        LocalSet(Data.Fig,Data.Properties{lp},Data.OrigData(:,lp));
     end
     LocalDealWithPageFig(Data);      
     LocalClose(Data,Dlg)
  catch
     delete(Data.Fig);
     errordlg(['Page Setup may have closed without' ...
                sprintf(newline) ...
                'restoring some printing properties.']);
  end

case 'CenterOnPage'
  LocalCenterOnPage(Data)
  LocalUpdate(Data);      

case 'Close'
  try
     Data = LApply(Data);
     LocalClose(Data,Dlg)
  catch ex
     error(message('MATLAB:old_pagesetupdlg:unableToClose'));
     %{ 
     The following lines are never executed
     if ishandle(Dlg)
        delete(Dlg);
     end
     %}
  end

case 'Default'
  % suppress restoring of old manual position
  Data.SavedPosition = [];

  % this blows away the current PrintTemplate Object too...
  for lp=1:length(Data.Properties)
     LocalSet(Data.Fig,Data.Properties{lp}, ...
             get(0,['DefaultFigure' Data.Properties{lp}]));
  end

  positionMode = LocalGet(Data.Fig(1),'PaperPositionMode');
  Data = LSelect(findobj(Dlg,'Tag',positionMode),Data);

  Data.PrintTemplate = LGetDefaultPrintTemplate;
  % should setting the default add a print template object?
  LocalSet(Data.Fig,'PrintTemplate',Data.PrintTemplate);

  driverColor = LGetFromTemplate(Data.Fig(1),'DriverColor');
  driverColorStr = LDriverColor2DriverColorStr(driverColor);
  LSelect(findobj(Data.Dlg, 'Tag', driverColorStr),Data);
  matchLimitsAndTicks = ...
          LGetFromTemplate(Data.Fig(1),'MatchLimitsAndTicks');
  LSelect(findobj(Data.Dlg, 'Tag', 'matchlimitsandticks'), ...
          Data, ...
          matchLimitsAndTicks);

  LocalUpdate(Data);      
  LocalDealWithPageFig(Data);


case 'FillPage'
  for lp=1:length(Data.Fig)
     PaperUnits=LocalGet(Data.Fig(lp),'PaperUnits');
     LocalSet(Data.Fig(lp),'PaperUnits','inches');      
     PaperPosition=[.25 .25 LocalGet(Data.Fig(lp),'PaperSize')-.5];
     LocalSetFigPos(Data.Fig(lp),PaperPosition, ...
             Data.AutoMode)
     LocalSet(Data.Fig,'PaperUnits',PaperUnits);
  end
  LocalUpdate(Data);      


case 'FixedAR'  % Fill Page, Matching Figure Aspect Ratio
  for lp=1:length(Data.Fig)
     PaperUnits=LocalGet(Data.Fig(lp),'PaperUnits');
     Units=LocalGet(Data.Fig,'Units');
     LocalSet(Data.Fig(lp),'PaperUnits','inches');      
     % CurrentPos=LocalGet(Data.Fig(lp),'PaperPosition');
     LocalSet(Data.Fig(lp),'Units','inches');      
     CurrentPos=LocalGet(Data.Fig(lp),'Position');

     PaperSize=LocalGet(Data.Fig(lp),'PaperSize')-0.5;

     HorizRatio=PaperSize(1)/CurrentPos(3);
     VertRatio=PaperSize(2)/CurrentPos(4);

     if HorizRatio<VertRatio
        NewPos=[0.25 0.25 PaperSize(1)        CurrentPos(4)*HorizRatio];
     else
        NewPos=[0.25 0.25 CurrentPos(3)*VertRatio PaperSize(2)        ];
     end        

     LocalSetFigPos(Data.Fig(lp),NewPos,Data.AutoMode)
     LocalSet(Data.Fig(lp),'PaperUnits', PaperUnits);
     LocalSet(Data.Fig(lp),'Units', Units);         
     LocalCenterOnPage(Data)
  end

  LocalUpdate(Data);

case 'Help'
  try
     helpview([docroot,'/techdoc/pgsetup']);
  catch ex
     errordlg(['Unable to open help for Page Setup:' ...
                sprintf(newline) ...
                ex.getReport('basic')]);
  end

case 'Key'
  switch get(Dlg,'CurrentCharacter')
  case 13 % enter
     old_pagesetupdlg Close;
  case 27 % escape
     old_pagesetupdlg Cancel;
  end

case 'MovePositionDown'
  if Data.AutoMode
     % abort if paperposition mode is not set to manual
     return
     % or else, set the paperposition mode to manual
     % and proceed...
  end

  BoxPos=LocalGetBoxPos(Data);
  NewBoxPos=dragrect(BoxPos);

  if any(NewBoxPos~=BoxPos)
     InFlag=LocalInAxes(Data,NewBoxPos);        
     if InFlag
        LocalSetPaperPosition(Data,NewBoxPos);
     end          
  end        

case 'Position'
  try
     pos = str2double(get(Data.PaperPosition,'String'));  % calls eval
     LocalSet(Data.Fig,'PaperPosition',pos);
  catch
     warndlg(['A valid Paper Position must be entered.  ', ...
                'Old value still set.'],'Paper Position Warning');
     return
  end     
  for lp=1:length(Data.Fig)
     LocalSetFigPos(Data.Fig(lp), ...
             LocalGet(Data.Fig(lp),'PaperPosition'),Data.AutoMode)
  end
  LocalSetPaperPositionBox(Data)

case 'PrintDlgCall'
  LocalUpdate(Data);

case 'ResizePositionDown'

  BoxPos=LocalGetBoxPos(Data);

  set(gcbf,'Units','pixels'); % hack

  NewBoxPos=rbbox(BoxPos);

  if any(NewBoxPos~=BoxPos)
     InFlag=LocalInAxes(Data,NewBoxPos);        
     if InFlag
        LocalSetPaperPosition(Data,NewBoxPos);  
     end          
  end  

  for lp=1:length(Data.Fig)
     LocalSetFigPos(Data.Fig(lp), ...
             LocalGet(Data.Fig(lp),'PaperPosition'),Data.AutoMode);
  end

case 'select'
  Data = LSelect(gcbo,Data);
  LocalUpdate(Data);

case 'Units'
  UnitInfo=get(Data.PaperUnits,{'String','Value'});
  LocalSet(Data.Fig,'PaperUnits',UnitInfo{1}{UnitInfo{2}});
  LocalUpdate(Data);      

end

if ishandle(Dlg)
  set(Dlg,'UserData',Data);  
end

%%%% New code

function Data = LSelect(button, Data, varargin)
% update radio buttons
iGroup = find(Data.UIC==button);
switch get(button,'Style')
case 'radiobutton'  
   set(button,'Value',1);
   set(Data.UIGroup{iGroup},'Value',0);
case 'checkbox'  % toggle check boxes
   % the uicontrol toggles its value on its own
   % set(button,'Value', ~get(button,'Value'));
end

% update dialog state variables and set HG/Simulink properties
switch Data.UIGroupProp{iGroup}
case 'PaperOrientation'
   oldOrientation = LocalGet(Data.Fig, 'PaperOrientation');
   newOrientation = get(button,'Tag');
   if ~strcmp(newOrientation, oldOrientation)
      LocalSet(Data.Fig, 'PaperOrientation', newOrientation);
   end
   LocalDealWithPageFig(Data);
   
case 'MatchFigure'
   Data.AutoMode = strcmp(get(button,'Tag'),'auto');
   
   % enable or disable manual setting fields
   if Data.AutoMode % disable 
      Data.SavedPosition = LocalGet(Data.Fig(1), ...
              'PaperPosition');
      Data.SavedUnits = LocalGet(Data.Fig(1),'PaperUnits');
      set(Data.PositionBox,...
              'FaceColor',[.9 .9 .9], ...
              'ButtonDownFcn','');
      set(Data.PositionBox(2:end),...
              'Visible', 'off');
      set(Data.ManualPositionUI,'Enable','off');
      
   else % enable
      if ~isempty(Data.SavedPosition)
         newUnits = LocalGet(Data.Fig(1),'PaperUnits');
         LocalSet(Data.Fig,'PaperUnits',Data.SavedUnits);
         LocalSetFigPos(Data.Fig(1),Data.SavedPosition, ...
                 Data.AutoMode);
         LocalSet(Data.Fig,'PaperUnits',newUnits);
      end
      set(Data.PositionBox,...
              {'FaceColor' 'ButtonDownFcn'},...
              cat(2,Data.PositionBoxFaceColor, ...
              Data.PositionBoxFcn));
      set(Data.PositionBox(2:end),...
              'Visible', 'on');
      set(Data.ManualPositionUI,'Enable','on');      
   end

   LocalSet(Data.Fig, 'PaperPositionMode', get(button,'Tag'));
      
case 'DriverColor'
   driverColorStr = get(button,'Tag');
   driverColor = LDriverColorStr2DriverColor(driverColorStr);
   
   Data.PrintTemplate = LSetTemplate(Data.PrintTemplate,...
           'DriverColor', driverColor);
   Data.PrintTemplateDirty = 1;

case 'MatchLimitsAndTicks'
   if nargin==2
      matchLimitsAndTicks = get(button,'Value');
   else % being set by default button
      matchLimitsAndTicks = varargin{1};
      button = findobj(Data.Dlg,'Tag','matchlimitsandticks');
      set(button,'Value', matchLimitsAndTicks);
   end
   
   Data.PrintTemplate = LSetTemplate(Data.PrintTemplate,...
           'MatchLimitsAndTicks', matchLimitsAndTicks);
   Data.PrintTemplateDirty = 1;   
end


% copied from pagedlg

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCenterOnPage %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCenterOnPage(Data)
PaperSize=LocalGet(Data.Fig(1),'PaperSize');
PaperPosition=LocalGet(Data.Fig(1),'PaperPosition');
PaperPosition(1)=(PaperSize(1)-PaperPosition(3))/2;
PaperPosition(2)=(PaperSize(2)-PaperPosition(4))/2;
LocalSet(Data.Fig,'PaperPosition',PaperPosition);

%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalClose %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalClose(Data,Dlg)
if isnumeric(Data.Fig) && ishandle(Data.Fig)
   % Take care of problem with figure being deleted
   % LocalSet(Data.Fig,'ResizeFcn',Data.ResizeFcn)   
end
delete(Dlg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalDealWithPageFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDealWithPageFig(Data)
FigName=LocalFigName(Data.Fig);
PageFig=findall(0,'Name',['Print: ' FigName]);
if ~isempty(PageFig)
  printdlg('PageDlgCall',PageFig);
end        
          
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalFigName %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function FigName=LocalFigName(Fig)

if length(Fig)>1
    if iscell(Fig)
        FigName='Multiple Systems';
    else
        FigName='Multiple Figures';
    end
    return
end

Fig=Fig(1);

% Check to see if it's HG
if isnumeric(Fig)
    FigName = dlgfigname( Fig );
else
    FigName=['System: ' LocalGet(Fig,'name')];
end

%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGet %%%%%
%%%%%%%%%%%%%%%%%%%%
function Value=LocalGet(HandleStr,Parameter)

% Deal with SL model
if iscell(HandleStr)
  if length(HandleStr)==1
    HandleStr=HandleStr{1};
  end
  Value=get_param(HandleStr,Parameter);
else
  Value=get(HandleStr,Parameter);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetBoxPos %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function BoxPos=LocalGetBoxPos(Data)

PX=get(Data.PositionBox(1),'XData');
PY=get(Data.PositionBox(1),'YData');
AxisPos=get(Data.AxisHandle,'Position');     
OX=AxisPos(1);OY=AxisPos(2);      
BoxPos=[OX+PX(1) OY+PY(1) PX(3)-PX(1) PY(3)-PY(1)];
       
%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInAxes %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function InFlag=LocalInAxes(Data,NewBoxPos)

XPos=[NewBoxPos(:,1)       ; sum(NewBoxPos([1 3]))
      sum(NewBoxPos([1 3])); NewBoxPos(:,1)               
     ];
YPos=[NewBoxPos(:,2)           ; NewBoxPos(:,2)         
      sum(NewBoxPos([2 4])); sum(NewBoxPos([2 4]))
     ];
AxesPos=get(Data.AxisHandle,'Position');AxesPos=AxesPos+[7 7 -14 -14];   
XRect=[AxesPos(1)         ; sum(AxesPos([1 3]))     
       sum(AxesPos([1 3])); AxesPos(1)
      ];         
YRect=[AxesPos(2)         ; AxesPos(2)
       sum(AxesPos([2 4])); sum(AxesPos([2 4]))
      ];
InFlag=any(inpolygon(XPos,YPos,XRect,YRect));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalResizePaper %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ...
 ...
LocalResizePaper(Data)

PaperUnits=LocalGet(Data.Fig(1),'PaperUnits');
LocalSet(Data.Fig(1),'PaperUnits','inches');
PaperSize=LocalGet(Data.Fig(1),'PaperSize');
LocalSet(Data.Fig(1),'PaperUnits',PaperUnits);

ScaleFactor=1.2*max(PaperSize);
Scale=Data.Scale;
X=PaperSize(1)/ScaleFactor*Scale;Y=PaperSize(2)/ScaleFactor*Scale;
ax = get(Data.PaperHandle,'Parent');
XOffset = mean(get(ax,'XLim'))-X/2;
YOffset = mean(get(ax,'YLim'))-Y/2;
set(Data.PaperHandle, ...
   'XData',[XOffset X+XOffset X+XOffset XOffset   ], ...
   'YData',[YOffset YOffset   Y+YOffset Y+YOffset ]  ...
   );

%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSet %%%%%
%%%%%%%%%%%%%%%%%%%%
function LocalSet(HandleStr,Parameter,Value)

% SL
if iscell(HandleStr)
  RootSys=unique(bdroot(HandleStr));
  LockSetting=get_param(RootSys,'Lock');
  for lp=1:length(RootSys)
    set_param(RootSys{lp},'Lock','off');
  end
  
  if iscell(Value)
    for lp=1:length(HandleStr)
      set_param(HandleStr{lp},Parameter,Value{lp});
    end
  else
    for lp=1:length(HandleStr)
      set_param(HandleStr{lp},Parameter,Value);
    end
  end
  
  for lp=1:length(RootSys)
    set_param(RootSys{lp},'Lock',LockSetting{lp});
  end
  
% HG
else
   if iscell(Value)
      Parameter={Parameter};
   end
   % switch Parameter
   % case 'PaperOrientation'
   %    orient(HandleStr,Value');
   % otherwise
      set(HandleStr,Parameter,Value)
   % end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetFigPos %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetFigPos(Fig,PaperPos,AutoMode)

if isnumeric(Fig)
  FigUnits=get(Fig,'Units');      
end

PaperUnits=LocalGet(Fig,'PaperUnits');
if isnumeric(Fig)
  LocalSet(Fig,'Units',PaperUnits);
end
if AutoMode && isnumeric(Fig)
  if isnumeric(Fig)
    FigPos=LocalGet(Fig,'Position');
    FigPos(2)=FigPos(2)+FigPos(4)-PaperPos(4);
    FigPos(3:4)=PaperPos(3:4);
    % LocalSet(Fig,'ResizeFcn',ResizeFcn);
  
    LocalSet(Fig,'PaperPosition',PaperPos);
    LocalSet(Fig,'Position',FigPos);      
    drawnow  
    
    % LocalSet(Fig,'ResizeFcn','pagedlg FigResize');
    
  else
    LocalSet(Fig,'PaperPosition',PaperPos);
    
  end
  
  LocalSet(Fig,'PaperPositionMode','auto');

else
  LocalSet(Fig,'PaperPosition',PaperPos);
end        


if isnumeric(Fig)
  LocalSet(Fig,'Units',FigUnits);      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetPaperPosition %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetPaperPosition(Data,BoxPos)

AxisPos=get(Data.AxisHandle,'Position');     
OX=AxisPos(1);OY=AxisPos(2);      
PP=BoxPos-[OX OY 0 0];

PaperUnits=LocalGet(Data.Fig,'PaperUnits');
LocalSet(Data.Fig,'PaperUnits','inches');
PaperSize=LocalGet(Data.Fig(1),'PaperSize');
PaperSizeXData=get(Data.PaperHandle,'XData');
PaperSizeYData=get(Data.PaperHandle,'YData');
ScaleFactor=1.2*max(PaperSize);
Scale=Data.Scale;
PP(1)=PP(1)-PaperSizeXData(1);
PP(2)=PP(2)-PaperSizeYData(1);
PP=PP*ScaleFactor/Scale;

LocalSet(Data.Fig,'PaperPosition',PP);
LocalSet(Data.Fig,'PaperUnits',PaperUnits);
set(Data.PaperPosition, ...
    'String',mat2str(LocalGet(Data.Fig(1),'PaperPosition'),5));

LocalSetPaperPositionBox(Data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetPaperPositionBox %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetPaperPositionBox(Data)

PaperUnits=LocalGet(Data.Fig(1),'PaperUnits');
LocalSet(Data.Fig(1),'PaperUnits','inches');
PaperSize=LocalGet(Data.Fig(1),'PaperSize');

PaperSizeXData=get(Data.PaperHandle,'XData');
PaperSizeYData=get(Data.PaperHandle,'YData');
XOffset=PaperSizeXData(1);
YOffset=PaperSizeYData(1);
ScaleFactor=1.2*max(PaperSize);
Scale=Data.Scale;

PP=LocalGet(Data.Fig(1),'PaperPosition')/ScaleFactor*Scale;
XD=XOffset+[PP(1) PP(1)+PP(3) PP(1)+PP(3) PP(1)];
YD=YOffset+[PP(2) PP(2)       PP(2)+PP(4) PP(2)+PP(4)];
WH=6;

LocalSet(Data.Fig(1),'PaperUnits',PaperUnits);
set(Data.PositionBox(1),'XData',XD,'YData',YD);

set(Data.PositionBox(2), ...
   'XData',XD(1)+[  0  WH WH 0], ...
   'YData',YD(1)+[  0  0 WH   WH]  ...
   );

set(Data.PositionBox(3), ...
   'XData',XD(2)+[-WH  0  0  -WH], ...
   'YData',YD(2)+[  0  0 WH   WH]  ...
   );

set(Data.PositionBox(4), ...
   'XData',XD(3)+[-WH    0  0  -WH], ...
   'YData',YD(3)+[-WH  -WH  0    0]  ...
   );

set(Data.PositionBox(5), ...
   'XData',XD(4)+[  0   WH WH    0], ...
   'YData',YD(4)+[-WH  -WH  0    0]  ...
   );


    
%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalUpdate %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdate(Data)

LocalResizePaper(Data)
LocalSetPaperPositionBox(Data)

set(Data.PaperSize,'String',LSizeVec2Str(LocalGet(Data.Fig(1),'PaperSize')));
set(Data.PaperPosition, ...
    'String',mat2str(LocalGet(Data.Fig(1),'PaperPosition'),5));
set(Data.PaperUnits,'Value', ...
      find(strcmp(LocalGet(Data.Fig(1),'PaperUnits'), ...
                  get(Data.PaperUnits,'String'))) ...
   );

orientation = LocalGet(Data.Fig(1),'PaperOrientation');
LSelect(findall(Data.Dlg, 'Tag', orientation),Data);

if Data.AutoMode
  LocalSet(Data.Fig,'PaperPositionMode','auto');  
end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Dlg=LocalInitFig(Fig)

oldPointer = get(Fig,'Pointer');
set(Fig,'Pointer','watch');

FigName = LocalFigName(Fig);
Dlgname = ['Page Setup - ' FigName ];

Dlg=findall(0,'Name',Dlgname);
DlgFlag=~isempty(Dlg);

if DlgFlag
   figure(Dlg);
   set(Fig,'Pointer',oldPointer);
   return
end

% SETUP STORAGE FOR STATE %%%%%%%%%%%%%%%%%%
Data.Fig=Fig;
Data.Properties={...
        'PaperType',...
        'PaperUnits', ...
        'PaperPosition', ...
        'PaperPositionMode', ...
        'PaperOrientation', ...
        'PrintTemplate'};

% SAVE ORIGINAL VALUES
for lp=1:length(Data.Properties)
   Temp=LocalGet(Fig,Data.Properties{lp});
   if ~iscell(Temp)
       Temp={Temp}; 
   end
   Data.OrigData(:,lp)=Temp;
end

% paper parameter values

if isnumeric(Fig(1))
  PaperUnits=set(Fig(1),'PaperUnits');
else
  ObjParams=get_param(Fig{1},'ObjectParameters');
  PaperUnits=ObjParams.PaperUnits.Enum;
end


% LAYOUT CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set spacing between UI elements and figure borders, then build
% up the dialog from the bottom row up.

% adjustment factors for character units
% work in character units.
fx = 3.75;
fy = 9.75;

% obsolete dimensions
% Offset=3/fy;

% new base dimensions
FigWidth=420/fx;

margin = 10;
LMarginW = margin/fx;
RMarginW = margin/fx;
TMarginH = 20/fy;
BMarginH = 15/fy;

btnW = 55/fx; btnH = 18/fy;
frameGutterH = 8/fy;
frameGutterW = 8/fx;
framePadW = 10/fx;
framePadH = 12/fy;

rowH = 18/fy;
btnPad = 6/fx;

White=[1 1 1];
Black=[0 0 0];

% DERIVED DIMENSIONS

% establish some landmarks
frameW = (FigWidth-LMarginW-RMarginW-frameGutterW)/2.5;
% starting coordinates for each column's frames
col(1) = LMarginW;
col(2) = LMarginW+frameW+frameGutterW;

% STANDARD HG PROPERTIES %%%%%%%%%%%%%%%%%%%%

Std = struct(...
        'Units'             , 'character' , ...
        'HandleVisibility'  , 'callback'  , ...   
        'Interruptible'     , 'off'       , ...   
        'BusyAction'        , 'queue');
FigColor=get(0,'DefaultUicontrolBackgroundColor');
if isequal(FigColor,Black)
   fgcolor = White; % special case for a black background
else
   fgcolor = get(0,'DefaultUicontrolForegroundColor');
end

% CREATE A FIGURE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Dlg = figure(Std             , ...
            'Color'          ,FigColor         , ...
            'Colormap'       ,[]               , ...
            'DoubleBuffer'   ,'on'             , ...
            'Renderer'       ,'painters'       , ...
            'Menubar'        ,'none'           , ...
            'Resize'         ,'off'            , ...
            'Pointer'        ,'watch'            , ...            
            'Visible'        ,'off'            , ...
            'Name'           ,Dlgname          , ...
            'KeyPressFcn'    ,{@LocalCallback, 'Key'}, ...
            'IntegerHandle'  ,'off'            , ...            
            'CloseRequestFcn',{@LocalCallback, 'Cancel'}, ...                
            'WindowStyle'    ,'modal'          , ...
            'Tag'            ,'Page Dialog'    , ...
            'NumberTitle'    ,'off'              ...
            );


Std.Parent = Dlg;
UICProps = Std;
UICProps.HorizontalAlignment = 'left';
UICProps.FontUnits            = 'Points';
UICProps.FontSize             = get(0,'FactoryUIControlFontSize');
UICProps.ForegroundColor      = fgcolor;
UICProps.BackgroundColor      = FigColor;

RadioProps = UICProps;
RadioProps.Style = 'radio';
PushProps = UICProps;
PushProps.Style = 'pushbutton';
PushProps.HorizontalAlignment = 'center';
CheckProps = UICProps;
CheckProps.Style = 'check';
PopupProps = UICProps;
PopupProps.Style = 'popup';
PopupProps.BackgroundColor = White;
PopupProps.ForegroundColor = Black;
TextProps = UICProps;
TextProps.Style = 'text';
EditProps = UICProps;
EditProps.Style = 'edit';
EditProps.BackgroundColor = White;
EditProps.ForegroundColor = Black;

% bottom row of buttons
% Help Cancel Done (OK?)

iUI = 0;
iGroup = 0;

BtnPos= zeros(5,4);
% Help
BtnPos(1,:)=[LMarginW BMarginH btnW btnH];
% Default
BtnPos(2,:)=BtnPos(1,:)+[btnW+btnPad 0 0 0];
% Cancel
BtnPos(5,:)=[FigWidth-RMarginW-btnW BMarginH btnW btnH];
% Apply
BtnPos(4,:)=BtnPos(5,:)-[btnW+btnPad 0 0 0];
% OK
BtnPos(3,:)=BtnPos(4,:)-[btnW+btnPad 0 0 0];

% leave some space before adding frames above these buttons
bottomSpacer = 10/fy;
frameBottom = BMarginH + btnH + bottomSpacer;

% 3 frames in left column
% create frames from the bottom up so that computing the row
% positions is easy

frames = struct(...
        'Label', {'Color' 'Limits' 'Orientation'},...
        'Rows', {4 2 2});
frPos = [col(1) frameBottom frameW 0];
posv = {};
fr = zeros(1,length(frames));
for i = 1:length(frames)
   [fr(i), frPos, posv{i}] = LCreateFrame(frPos, frames(i).Label, ...
           framePadW, framePadH, frames(i).Rows, rowH, Dlg, ...
           FigColor,fgcolor);
   frPos = frPos + [0 frPos(4)+frameGutterH 0 -frPos(4)];
end
frPos = frPos - [0 frPos(4)+frameGutterH 0 -frPos(4)];


% create controls from the top down, so that tab proceeds from
% the top down

% Orientation %%%%%%%%%%%%%%%%%%%%%

orientposv = posv{3};
isLandscape = strcmp(LocalGet(Fig(1),'PaperOrientation'),'landscape');
iUI = iUI+1;
ui(iUI) = uicontrol(RadioProps,...
        'String','Portrait',...
        'Tag','portrait',...
        'Callback',{@LocalCallback, 'select'},...                
        'Position',orientposv(1,:),...
        'Value',~isLandscape);
iUI = iUI+1;
ui(iUI) = uicontrol(RadioProps,...
        'String','Landscape',...
        'Tag','landscape',...
        'Callback',{@LocalCallback, 'select'},...                
        'Position',orientposv(2,:),...
        'Value',isLandscape);

iGroup = iGroup+1;
Data.UIC(iGroup) = ui(iUI);
Data.UIGroup{iGroup} = ui(iUI-1);
Data.UIGroupProp{iGroup} = 'PaperOrientation';

iGroup = iGroup+1;
Data.UIC(iGroup) = ui(iUI-1);
Data.UIGroup{iGroup} = ui(iUI);
Data.UIGroupProp{iGroup} = 'PaperOrientation';

% Limits %%%%%%%%%%%%%%%%%%%%%

limposv = posv{2};
matchLimitsAndTicks = LGetFromTemplate(Fig(1),'MatchLimitsAndTicks');
iUI = iUI+1;
ui(iUI) = uicontrol(CheckProps,...
        'String','Match Axes Limits and Ticks',...
        'Tag','matchlimitsandticks',...
        'ToolTip',...
           'Match limits and ticks on screen and on page',...
        'Callback', {@LocalCallback, 'select'},...
        'Position',limposv(1,:),...
        'Value',matchLimitsAndTicks);

iGroup = iGroup+1;
Data.UIC(iGroup) = ui(iUI);
Data.UIGroup{iGroup} = [];
Data.UIGroupProp{iGroup} = 'MatchLimitsAndTicks';

% Color %%%%%%%%%%%%%%%%%%%%%

colorposv = posv{1};
uicontrol(TextProps,...
        'String', 'Print colored lines and text in:',...
        'Tag', 'printcolor',...
        'Position', colorposv(1,:));

driverColor = LGetFromTemplate(Fig(1),'DriverColor');
iUI = iUI+1;
ui(iUI) = uicontrol(RadioProps,...
        'String', 'Black and White',...
        'Tag', 'mono',...
        'Callback',{@LocalCallback, 'select'},...        
        'Position', colorposv(2,:),...
        'Value', ~driverColor);
iUI = iUI+1;
ui(iUI) = uicontrol(RadioProps,...
        'String','Color',...
        'Tag','color',...
        'Callback',{@LocalCallback, 'select'},...
        'Position',colorposv(3,:),...
        'Value',driverColor);

iGroup = iGroup+1;
Data.UIC(iGroup) = ui(iUI);
Data.UIGroup{iGroup} = ui(iUI-1);
Data.UIGroupProp{iGroup} = 'DriverColor';

iGroup = iGroup+1;
Data.UIC(iGroup) = ui(iUI-1);
Data.UIGroup{iGroup} = ui(iUI);
Data.UIGroupProp{iGroup} = 'DriverColor';


% Position %%%%%%%%%%%%%%%%%%%%%

frameTop = frPos(2)+frPos(4);
frPos = [col(2) frameBottom 1.5*frameW frameTop-frameBottom];
[~, frPos, posv] = LCreateFrame(frPos, 'Size and Position', ...
        framePadW, framePadH, 11, rowH, Dlg, FigColor, fgcolor);

autoMode = strcmp(LocalGet(Data.Fig,'PaperPositionMode'),'auto');
iUI = iUI+1;
ui(iUI) = uicontrol(RadioProps,...
        'String','Match Figure Screen Size',...
        'Tag','auto',...
        'Callback',{@LocalCallback, 'select'},...
        'Position', posv(1,:),...
        'Value', autoMode);
iUI = iUI+1;
ui(iUI) = uicontrol(RadioProps,...
        'String', 'Set Manual Position and Size',...
        'Tag', 'manual',...
        'Callback',{@LocalCallback, 'select'},...        
        'Position', posv(2,:),...
        'Value', ~autoMode);

Data.ManualPositionUI = [];

iGroup = iGroup+1;
Data.UIC(iGroup) = ui(iUI);
Data.UIGroup{iGroup} = ui(iUI-1);
Data.UIGroupProp{iGroup} = 'MatchFigure';

iGroup = iGroup+1;
Data.UIC(iGroup) = ui(iUI-1);
Data.UIGroup{iGroup} = ui(iUI);
Data.UIGroupProp{iGroup} = 'MatchFigure';

% inset row 3 and lower
inset = 4;
posv(3:end,1) = posv(3:end,1) + inset;
posv(3:end,3) = posv(3:end,3) - inset;
% Axes for page layout preview fills four rows from row 3 to row 7

AxesPos = [posv(7,1) posv(7,2)+rowH/2  posv(7,3) rowH*4.5];
% axes is created below

% Paper Size %%%%%%%%%%%%%%%%%%%%%

rowleft = posv(8,:)./[1 1 3 1];
iUI = iUI+1;
ui(iUI) = uicontrol(TextProps,...
        'String', 'Paper Size: ',...
        'ToolTip', 'Width x Height', ...        
        'HorizontalAlignment','right',...
        'Tag', 'PaperSize',...
        'Callback','',...
        'Position', rowleft);

rowmid = rowleft+[rowleft(3) 0 0 0];
iUI = iUI+1;
paperSizeV = LocalGet(Fig(1),'PaperSize');
paperSizeStr = LSizeVec2Str(paperSizeV);
ui(iUI) = uicontrol(TextProps,...
        'String', paperSizeStr,...
        'ToolTip', 'Width x Height', ...        
        'Tag', 'PaperSizeEdit',...
        'Callback','',...
        'Position', rowmid);
Data.PaperSize=ui(iUI);

rowright = rowmid + [rowmid(3) 0 0 0];
iUI = iUI+1;
ui(iUI) = uicontrol(PopupProps,...
        'String', PaperUnits,...
        'Tag', 'PaperUnitsEdit',...
        'Callback',{@LocalCallback, 'Units'},...
        'Position', rowright);
Data.PaperUnits = ui(iUI);

% Paper Position %%%%%%%%%%%%%%%%%%%%%

rowleft = posv(9,:)./[1 1 3 1];
iUI = iUI+1;
ui(iUI) = uicontrol(TextProps,...
        'String', 'Paper Position: ',...
        'ToolTip', '[Left Bottom Width Height]', ...
        'HorizontalAlignment','right',...
        'Tag', 'PaperSize',...
        'Callback','',...
        'Position', rowleft);

rowmid = rowleft+[rowleft(3) 0 rowleft(3) 0];
iUI = iUI+1;
str = mat2str(LocalGet(Fig(1),'PaperPosition'),5);
ui(iUI) = uicontrol(EditProps,...
        'String', str,...
        'Tag', 'PaperPositionEdit',...
        'ToolTip', '[Left Bottom Width Height]', ...
        'Callback',{@LocalCallback, 'Position'},...
        'Position', rowmid);
Data.PaperPosition=ui(iUI);
% Data.UIOldVal{iUI} = str;  % this causes an assert!
Data.ManualPositionUI(end+1) = ui(iUI);

% Center  |  Fill  |  Fill, Fix AR  %%%%%%%%%%%%%%%%%%%%%
rowleft = posv(11,:)./[1 1 3 1];
rowmid = rowleft+[rowleft(3) 0 0 0];
rowright = rowmid+[rowleft(3) 0 0 0];
iUI = iUI+1;
ui(iUI) = uicontrol(PushProps,...
        'String', 'Center',...
        'ToolTip','Center on Page',...        
        'Tag', 'CenterOnPage',...
        'Callback',{@LocalCallback, 'CenterOnPage'},...
        'Position', [rowleft(1:2) btnW btnH]);
Data.ManualPositionUI(end+1) = ui(iUI);

iUI = iUI+1;
ui(iUI) = uicontrol(PushProps,...
        'String', 'Fill',...
        'ToolTip','Fill Page',...
        'Tag', 'FillPage',...
        'Callback',{@LocalCallback, 'FillPage'},...
        'Position', [rowmid(1:2) btnW btnH]);
Data.ManualPositionUI(end+1) = ui(iUI);

iUI = iUI+1;
ui(iUI) = uicontrol(PushProps,...
        'String', 'Max Aspect',...
        'ToolTip','Fill Page, Matching Figure Aspect Ratio',...        
        'Tag', 'FixedAR',...
        'Callback',{@LocalCallback, 'FixedAR'},...
        'Position', [rowright(1:2) btnW btnH]);
Data.ManualPositionUI(end+1) = ui(iUI);
Scale=110;  % CONSTANT
FigHeight=sum(AxesPos([2 4]));

% compute the figure size
Units=get(0,'Units');
set(0,'Units','character');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',Units);
% FigPos=[(ScreenSize(3)-FigWidth)/2 (ScreenSize(4)-FigHeight-20)/2 ...
%      FigWidth FigHeight];
 FigPos=[(ScreenSize(3)-FigWidth)/2 (ScreenSize(4)-FigHeight-20/fy)/2 ...
      FigWidth FigHeight];

    
%%% Set up the controls

Btn=Std;
Btn.FontUnits            = 'Points'                         ;
Btn.FontSize             = get(0,'FactoryUIControlFontSize');
Btn.ForeGroundColor      = fgcolor                            ;
Btn.HorizontalAlignment  = 'center'                         ;
Btn.Style                = 'pushbutton'                     ;    
Ctl=Btn;

    
BtnString={'Help';'Default';'OK';'Apply';'Cancel';};
BtnTag={'Help';'Default';'Done';'Apply';'Cancel';};
BtnCall={{@LocalCallback, 'Help'};...
         {@LocalCallback, 'Default'};...
         {@LocalCallback, 'Close'};...
         {@LocalCallback, 'Apply'};...           
         {@LocalCallback, 'Cancel'}};
    
              
%%% Create Everything    


Std.Parent=Dlg; Btn.Parent=Dlg; Ctl.Parent=Dlg; 
BtnHandles = zeros(1,length(BtnTag));
for lp=1:length(BtnTag)
  BtnHandles(lp)=uicontrol(Btn      , ...
                          'Position',BtnPos(lp,:) , ...          
                          'Tag'     ,BtnTag{lp}   , ...
                          'Callback',BtnCall{lp}  , ...
                          'String'  ,BtnString{lp}  ...
                          );             

    % add a border to the OK button
    if strcmp(BtnString{lp},'OK')
       LAddBorder(BtnHandles(lp));
    end
end      

AxisHandle=axes(Std                 , ...
               'Position'           ,AxesPos       , ...
               'Units'              ,'character'      , ...               
               'Tag'                ,'Axes'        , ...
               'XLim'               ,[1 AxesPos(3)], ...   
               'YLim'               ,[1 AxesPos(4)], ...                   
               'XTickMode'          ,'manual'      , ...
               'XTick'              ,[]            , ...
               'XTickLabelMode'     ,'manual'      , ...
               'XTickLabel'         ,[]            , ...
               'YTickMode'          ,'manual'      , ...
               'YTick'              ,[]            , ...
               'YTickLabelMode'     ,'manual'      , ...
               'YTickLabel'         ,[]            , ...
               'Box'                ,'on'          , ...                   
               'Color'              ,[.6 .6 .6]        ...
               );

% Note: 4 changes were made to deal with dragrect not respecting the
% figure units.  The two lines below and the lines in the figure
% and axis creation that set the units back to pixels.  These lines
% should be removed when dragrect starts doing the right thing.
set(AxisHandle,'Units','pixels');
NewAxesPos=get(AxisHandle,'Position');
set(AxisHandle,'XLim',[1 NewAxesPos(3)],'YLim',[1 NewAxesPos(4)]);

PaperHandle=patch('Parent'          ,AxisHandle   , ...
                  'HandleVisibility','callback'   , ...
                  'Interruptible'   ,'off'        , ...
                  'BusyAction'      ,'queue'      , ...
                  'XData'           ,[.1 .9 .9 .1], ...
                  'YData'           ,[.1 .1 .9 .9], ...
                  'FaceColor'       ,White        , ...
                  'EdgeColor'       ,Black        , ...
                  'LineStyle'       ,'-'            ...                     
                 );
              
% When pixel units are available for axes children this all simplifies    
PositionHandle=copyobj(PaperHandle([1 1 1 1 1]),AxisHandle);
set(PositionHandle(1), ...
   'LineStyle'       ,':'                       , ...
   'FaceColor'       ,[.9 .9 .9]                 , ...   
   'ButtonDownFcn'   ,{@LocalCallback, 'MovePositionDown'}   ...
   );
     
set(PositionHandle(2:end), ...
   'FaceColor'           ,Black                        , ...
   'ButtonDownFcn'       ,{@LocalCallback, 'ResizePositionDown'}  ...
   );   

Data.AxisHandle=AxisHandle;                   
Data.PaperHandle=PaperHandle;
Data.PositionBox=PositionHandle;
Data.PositionBoxFcn = get(PositionHandle,'ButtonDownFcn');
Data.PositionBoxFaceColor = get(PositionHandle,'FaceColor');
Data.PositionBoxEdgeColor = get(PositionHandle,'EdgeColor');
Data.ResizeFcn(1:length(Data.Fig),1)={''};
Data.AutoMode=autoMode;
Data.Scale=Scale;

if autoMode
   set(Data.PositionBox,...
           'FaceColor',[.9 .9 .9], ...
           'ButtonDownFcn','');
   set(Data.PositionBox(2:end),...
           'Visible', 'off');
   set(Data.ManualPositionUI,'Enable','off');
end

Data.SavedPosition = [];
Data.SavedUnits = [];

Data.Dlg = Dlg;
   
Data.PrintTemplate = get(Data.Fig,'PrintTemplate');
Data.PrintTemplateDirty = 0;

% write a print template object if the user hits okay
if isempty(Data.PrintTemplate)
   Data.PrintTemplate = LGetDefaultPrintTemplate;
   Data.PrintTemplateDirty = 1;
end

set(Data.PaperUnits,'Value', ...
      find(strcmp(LocalGet(Data.Fig(1),'PaperUnits'), ...
                  PaperUnits)) ...
   );


% Turn off the print button if more than one figure is sent to pagedlg
% This is becaus printdlg is not vectorized.
if isnumeric(Data.Fig) && length(Data.Fig)>1
  set(BtnHandles(2),'Enable','off');
end

  
LocalUpdate(Data)

FigPos(4) = frPos(2)+frPos(4)+TMarginH;
%get(Dlg,'Units')

set(Dlg,'Units','character',...
        'Position',FigPos,...
        'Visible','on',...
        'Pointer','arrow',...
        'UserData',Data);

set(Fig,'Pointer',oldPointer);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Layout utility functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAddBorder
% Add a border to the default button

function border = LAddBorder(uic)
parent = get(uic,'Parent');
oldUnits = get(uic,'Units');
color = get(uic,'ForegroundColor');
set(uic,'Units','pixels');
pos = get(uic,'Position');
border = axes('Units','pixels','Position',pos,...
        'Parent',parent,...
        'XTick',[],'YTick',[],'ZTick',[],...
        'Color','none',...
        'XColor', color,...
        'YColor', color,...        
        'Box','on');
set(uic,'Position',pos+[1 1 -2 -2]);
set(uic,'Units',oldUnits);



function [fr, position, posv] = LCreateFrame(position, heading, ...
        framePadW, framePadH, nRows, rowH, parent, bgcolor, fgcolor)
if position(4)==0   % auto select height based on number of rows
   height = nRows*rowH + 2*framePadH;
   position(4) = height;
end
% fr = uicontrol('Parent',parent,...
%         'Units','character',...
%         'Style','frame',...
%         'Position', position);

% instead of a uicontrol, use two transparent offset axes to
% create the pseudo 3D border
fr = axes('Parent',parent,...
        'Units','character',...
        'Box', 'on',...
        'Color', 'none',...
        'XTick',[],...
        'YTick',[],...
        'ZTick',[],...
        'Position', position);

if isequal(bgcolor,[0 0 0])
   lighterColor = [.7 .7 .7];
   darkerColor = [.5 .5 .5];
else
   lighterColor = brighten(bgcolor, .7);
   darkerColor = brighten(bgcolor, -.6);
end
set(fr,'Units','pixels',...
        'XColor',lighterColor,...
        'YColor',lighterColor);
fr2 = copyobj(fr,parent);
pixelpos = get(fr,'Position');
set(fr, 'Position', pixelpos+[1 -1 0 0]);
set(fr2, 'Position', pixelpos,...
        'XColor',darkerColor,...
        'YColor',darkerColor);

t = uicontrol('Parent',parent,...
        'Units','character',...
        'BackgroundColor',bgcolor,...
        'ForegroundColor',fgcolor,...
        'Style','text',...
        'String',heading);
e = get(t,'extent');
tpos = [position(1) + framePadW ...
        sum(position(1,[2 4])) - e(4)/1.6 ...
        e(3:4)];
set(t,'Position',tpos);

posv = zeros(nRows,4);
% fill rows from the top of the frame
frameTop = position(2)+position(4)-framePadH;
rowLeft = position(1) + framePadW;
rowWidth = position(3) - 2*framePadW;
for i=1:nRows
   posv(i,:) = [rowLeft ...
              frameTop - i*rowH ...
              rowWidth ...
              rowH];
end
   



function pt = LGetDefaultPrintTemplate
pt = printtemplate;
try
   % drivers in form: -dxxx
   pt.DriverColor = defaultprtcolor;
catch
   % invalid driver
   pt.DriverColor = 0; % mono
end
pt.AxesFreezeTicks = 0;
pt.AxesFreezeLimits = 0;



function value = LGetFromTemplate(fig, property)
pt = getprinttemplate(fig);
noTemplate = isempty(pt);
switch property
case 'DriverColor'
   if noTemplate % get the default driver color
      try
         % drivers in form: -dxxx
         value = defaultprtcolor;
      catch
         % invalid driver
         value = 0; % mono
      end

   else
      value = pt.DriverColor;
   end
case 'MatchLimitsAndTicks'
   if noTemplate % default:  don't freeze ticks
      value = 0;
   else
      value = pt.AxesFreezeTicks;
      % for now, assume that AxesFreezeLimits is set in sync...
   end
end
   

function val = LDriverColorStr2DriverColor(str)
if strncmpi('c',str,1) % starts with C 'C' or 'color'
   val = 1;
else % starts with M  'M' or 'mono'
   val = 0;
end

function str = LDriverColor2DriverColorStr(val)
if val
   str = 'color';
else
   str = 'mono';
end


function pt = LSetTemplate(pt, prop, val)
if isempty(pt)
   pt = printtemplate;
end   
switch prop
case 'DriverColor'
   pt.DriverColor = val;
case 'MatchLimitsAndTicks'
   pt.AxesFreezeTicks = val;
   pt.AxesFreezeLimits = val;
end
   


function Data = LApply(Data)
oldPtr = get(Data.Dlg,'Pointer');
set(Data.Dlg,'Pointer','watch');
% only thing left to set is the PrintTemplate
if isnumeric(Data.Fig) && ishandle(Data.Fig)
   if Data.PrintTemplateDirty
      set(Data.Fig,'PrintTemplate', Data.PrintTemplate);
   end
end
set(Data.Dlg,'Pointer',oldPtr);

function str = LSizeVec2Str(vec)
str = [num2str(vec(1),5) ' x ' num2str(vec(2),5)];

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCallback %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCallback(~,~,Action)
    old_pagesetupdlg(Action);
    