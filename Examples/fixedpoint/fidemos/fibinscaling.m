function varargout = fibinscaling(varargin)
% FIBINSCALING Fi Binary Point Scaling Demo

% Copyright 2002-2004 The MathWorks, Inc.

% Last Modified by GUIDE v2.5 23-Nov-2004 10:08:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fiscaling_OpeningFcn, ...
                   'gui_OutputFcn',  @fiscaling_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%--------------------------------------------------------------------------
function fiscaling_OpeningFcn(hObject, eventdata, handles, varargin)
% --- Executes just before fiscaling is made visible.

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fiscaling (see VARARGIN)

% Choose default command line output for fiscaling
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fiscaling wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%--------------------------------------------------------------------------
function varargout = fiscaling_OutputFcn(hObject, eventdata, handles) 
% --- Outputs from this function are returned to the command line.

% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%--------------------------------------------------------------------------
function slider1_Callback(hObject, eventdata, handles)
% --- Executes on slider movement.

% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
lastBP = get(hObject,'userData');
sliderVal = -round(get(hObject,'Value'));
set(hObject,'Value',-sliderVal)
set(handles.textFL,'string',['Fraction Length: ' num2str(sliderVal)]);
if isempty(lastBP)
    lastBP = handles.textBP0;
end
set(lastBP,'string','');
switch sliderVal
    case 0
        lastBP = handles.textBP0;
        set(lastBP,'string','^ ');
    case 1
        lastBP = handles.textBP1;
        set(lastBP,'string','^ ');
    case 2
        lastBP = handles.textBP2;
        set(lastBP,'string','^ ');
    case 3
        lastBP = handles.textBP3;
        set(lastBP,'string','^ ');
    case 4
        lastBP = handles.textBP4;
        set(lastBP,'string','^ ');
    case 5
        lastBP = handles.textBP5;
        set(lastBP,'string','^ ');
    case -1
        lastBP = handles.textBPm1;
        set(lastBP,'string','^ ');
    case -2
        lastBP = handles.textBPm2;
        set(lastBP,'string','^ ');
    case -3
        lastBP = handles.textBPm3;
        set(lastBP,'string','^ ');
end
set(hObject,'userData',lastBP);

% Update gui
updateGui(hObject,handles,sliderVal)           

%-------------------------------------------------------------------
function slider1_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%--------------------------------------------------------------------------
function cbSigned_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
% hObject    handle to checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0);
%--------------------------------------------------------------------------

function cbSigned_Callback(hObject, eventdata, handles)
% --- Executes on button press in cbSigned.
% hObject    handle to cbSigned (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fl = -round(get(handles.slider1,'Value'));
updateGui(handles.slider1,handles,fl);

%--------------------------------------------------------------------------
function editBit_Callback(hObject, eventdata, handles)
% --- Executes on text change+ enter in editBit2

% Check value in the bit
checkBitBox(hObject,handles)

% Update gui
fl = -round(get(handles.slider1,'Value'));
updateGui(handles.slider1,handles,fl);

%--------------------------------------------------------------------------
function updateGui(hObject,handles, fl)
% Syncs up text & edit boxes, displays and compute real world value (fi)

% Determine is signed or unsinged
cbSignedVal = get(handles.cbSigned,'Value');
if cbSignedVal
    signStr = 'true';
else
    signStr = 'false';
end

% Update the scaling boxes
set(handles.textScaleBit0,'string',['2^',num2str(-fl)]);
set(handles.textScaleBit1,'string',['2^',num2str(-fl+1)]);
set(handles.textScaleBit2,'string',['2^',num2str(-fl+2)]);

% Set the MSB (signed or unsigned correctly)
if cbSignedVal
    set(handles.textScaleBit2,'String',['-2^',num2str(-fl+2)]);
end


% Create a fi and display it
bit0 = get(handles.editBit0,'string');
bit1 = get(handles.editBit1,'string');
bit2 = get(handles.editBit2,'string');
binstr = [bit2,bit1,bit0];


hfi = fi(0,cbSignedVal,3,fl);
hfi.bin = binstr;
ficode = sprintf(['a = fi(0,%s,3,%d)\n',...
               'a.bin = ''%s'''],...
               signStr,fl,binstr);
set(handles.textFiDisplay,'String',ficode);
set(handles.textValue,'String',[' ',num2str(double(hfi))]);
set(handles.textSigned,'String',[' ',signStr]);
set(handles.textFracLength,'String',[' ',num2str(fl)]);

%--------------------------------------------------------------------------
function checkBitBox(hObject,handles)
% Parse the value entered in the bit edit box
% Clip to length 1 always and check to see if it is '1' or '0' only
% Check for correct length and type of bit string
bitstr = get(hObject,'String');
if isempty(bitstr)
bitstr = '0';
else
    if length(bitstr)~= 1
        bitstr = bitstr(1);
    end
    if (~strcmpi(bitstr,'1') && ~strcmpi(bitstr,'0'))
        bitstr = '0';
    end
end
set(hObject,'String',bitstr);

%--------------------------------------------------------------------------
function pushbutton1_Callback(hObject, eventdata, handles)
% --- Executes on button press in pushbutton1.
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcbf);

%--------------------------------------------------------------------------
function pushbutton2_Callback(hObject, eventdata, handles)
% --- Executes on button press in pushbutton2.
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
htmlpath = fullfile(matlabroot,'toolbox','fixedpoint','fidemos','html','fiscalingdemo.html');
web(htmlpath,'-helpbrowser');
%--------------------------------------------------------------------------


