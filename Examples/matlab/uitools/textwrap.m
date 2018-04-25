function [OutString,varargout]=textwrap(varargin)
%TEXTWRAP Return wrapped string matrix for given UI Control.
%  OUTSTRING=TEXTWRAP(UIHANDLE,INSTRING) returns a wrapped
%  string cell array (OUTSTRING) that fits inside the given uicontrol. 
%
%  OUTSTRING is the wrapped string matrix in cell array format.
%  
%  UIHANDLE is the handle of the object the string is placed in.
%  
%  INSTRING is a cell array. Paragraph breaks are implemented for 
%  each cell.  Each cell of the array is considered to be a separate
%  paragraph and must only contain a string vector.  If the 
%  paragraph is carriage return delimited, TEXTWRAP will wrap the 
%  paragraph lines at the carriage returns.
%
%  OUTSTRING=TEXTWRAP(INSTRING, COLS) returns a wrapped string cell 
%  array whose lines are wrapped at COLS if the paragraph is not 
%  carriage return delimited. If a paragraph does not have COLS 
%  characters, the text in the paragraph will not be wrapped. 
%  
%  OUTSTRING=TEXTWRAP(UIHANDLE,INSTRING,COLS) returns an
%  OUTSTRING that is wrapped at COLS.
%
%  [OUTSTRING,POSITION]=TEXTWRAP(UIHANDLE, ...) where POSITION is 
%  the recommended position of the uicontrol in the units of the 
%  uicontrol.  
%
%
%   Examples:
%       MsgHandle = uicontrol('style', 'text', 'position', [20 20 100 100]);
%       MsgString = {'This is a long message string that needs to be wrapped'};
%       WrapString=textwrap(MsgHandle,MsgString);
%
%       MsgString = {'This is a long message string that needs to be wrapped'};
%       WrapString=textwrap(MsgString, 45);
%
%       MsgHandle = uicontrol('style', 'text', 'position', [20 20 100 100]);
%       MsgString = {'This is a long message string that needs to be wrapped'};
%       [WrapString,NewMsgTxtPos]=textwrap(MsgHandle,MsgString,45);
%
%   See also ALIGN, UICONTROL.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargout<1 || nargout>2
  error(message('MATLAB:textwrap:InvalidNumberOutputs'));
end
narginchk(2,3);
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin==3
  UIHandle=varargin{1};
  if iscell(varargin{2})
    InString=varargin{2};
  else
    error(message('MATLAB:textwrap:InvalidSecondInput'));
  end % if iscell
    
  Columns=varargin{3};
  
else
  if ishghandle(varargin{1},'uicontrol')
    UIHandle=varargin{1};
    InString=varargin{2};
    Columns=[];    
  elseif iscell(varargin{1})
    UIHandle=[];
    InString=varargin{1};
    Columns=varargin{2};
  else
    error(message('MATLAB:textwrap:InvalidFirstInput'));
    
  end % if isnumeric
end

if ~isempty(UIHandle)
  if ~ishghandle(UIHandle)
      error(message('MATLAB:textwrap:InvalidHandle'));
  end 
  UIPosition=get(UIHandle,'Position');
  UIWidth=UIPosition(3);
  %UIHeight=UIPosition(4);

  TempObj=copyobj(UIHandle,get(UIHandle,'Parent'));
  set(TempObj,'Visible','off','Max',100);
end % if ~isempty

NumPara=numel(InString);
OutString={};
ReturnChar=newline;

for lp=1:NumPara
  Para=InString{lp};  

  if isempty(Para)
    NumNewLines=0;
    OutString=[OutString;{' '}];
    
  else
    Loc=find(Para==ReturnChar);
    TempPara={};
    if ~isempty(Loc)
      Loc=[0 Loc length(Para)+1]; %#ok<AGROW>
      for lp=length(Loc)-1:-1:1  %#ok<FXSET>
        TempPara{lp,1}=Para(Loc(lp)+1:Loc(lp+1)-1);
      end        
    else
      TempPara=Para; 
    end  
    Para=cellstr(TempPara);
    NumNewLines=size(Para,1);
    % Cellstr uses deblank, which removes all trailing white spaces. 
    % Ensure that empty strings are replaced with a space (g843407).
    if (NumNewLines == 1) && isempty(Para{1})
        Para{1} = ' ';
    end       
  end % if isempty

  for LnLp=1:NumNewLines
    if ~isempty(Columns)
      WrappedCell=LocalWrapAtColumn(Para{LnLp,1},Columns);
    else
      WrappedCell=LocalWrapAtWidth(Para{LnLp,1},TempObj,UIWidth);   
    end % if        
    OutString=[OutString;WrappedCell];
  end % for LnLp
end % for NumPara

if ~isempty(UIHandle)
  set(TempObj,'String',OutString);
  Extent=get(TempObj,'Extent');
  Position=[UIPosition(1:2) Extent(3:4)];
  delete(TempObj);

else
  Position=[0 0 0 0];  
end % if ~isempty

if nargout==2,varargout{1}=Position;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetWrapLoc %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WrapLoc=LocalGetWrapLoc(Para,Columns)

Width=size(Para,2);
if isequal(Width,0) || isempty(Columns)
  WrapLoc=[];
else
  Para=[Para ' '];  
  Locs=find(Para==' ');  
  WrapLoc=Locs(find(Locs<=Columns)); %#ok<FNDSB>
  % Need to take care of the case where the word is wider than the width
  if isempty(WrapLoc)
    WrapLoc=Columns;
  end
end % if  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalWrapAtColumn %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WrappedCell=LocalWrapAtColumn(Para,Columns)

WrappedCell={''};
LineNo=1;
WrapLoc=LocalGetWrapLoc(Para,Columns);
while ~isempty(WrapLoc)
  LocHigh=WrapLoc(end);  
  if LocHigh>length(Para)
    LocHigh=length(Para);
  end    
  WrappedCell{LineNo,1}=Para(1:LocHigh);
  Para(1:LocHigh)=[];
  Para=fliplr(deblank(fliplr(Para)));  
  WrapLoc=LocalGetWrapLoc(Para,Columns);
  LineNo=LineNo+1;
end % while  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalWrapAtWidth %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WrappedCell=LocalWrapAtWidth(Para,TempObjHandle,UIWidth)

%Width=size(Para,2);
Para=[Para ' '];
SpaceLocs=find(Para==' ');
WrappedCell={};

if ~isempty(SpaceLocs)
  EndOfPara=false;  
  NeedToWrapLine=false;
  LocLowIndex=0;    LocHighIndex=1;  
  LocLow=1;         LocHigh=SpaceLocs(LocHighIndex)-1;  
  while ~EndOfPara
    while ~NeedToWrapLine
      TrialString=Para(LocLow:LocHigh);
      set(TempObjHandle,'String',TrialString);
      TempExtent=get(TempObjHandle,'Extent');
      NeedToWrapLine=TempExtent(3)>=UIWidth;
      if ~NeedToWrapLine
        if LocHighIndex==length(SpaceLocs)
          NeedToWrapLine=true;
        else
          LocHighIndex=LocHighIndex+1;
          LocHigh=SpaceLocs(LocHighIndex)-1;
        end % if LocHighIndex 
      else
        % Check that the number of words is >1       
        if (LocHighIndex-LocLowIndex)>1
          LocHighIndex=LocHighIndex-1;
          LocHigh=SpaceLocs(LocHighIndex)-1;        
        end % if
      end % if ~NeedToWrapLine      
    end % while ~NeedToWrapLine 
    WrappedCell=[WrappedCell;{Para(LocLow:LocHigh)}];

    LocLowIndex=LocHighIndex;
    LocHighIndex=LocHighIndex+1;

    LocLow=SpaceLocs(LocLowIndex)+1;
    if LocHighIndex<=length(SpaceLocs)
      LocHigh=SpaceLocs(LocHighIndex)-1;
      NeedToWrapLine=false;
    else
      EndOfPara=true;
    end % if
  end % while ~EndOfPara  
% There are no spaces in the text so it can't be wrapped.  
else
  WrappedCell={Para};
  
end % if ~isempty




