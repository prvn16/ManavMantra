function varargout = jpropeditutils(action,varargin) 
%JPROPEDITUTILS   a utility function for PropertyEditor.java 
%   JPROPEDITUTILS is a switchyard containing many different 
%   sub-functions. 
% 
%   'jinit'=============================== 
% 
%   [VFIELDS,VALUES,OFIELDS,OPTIONS,PATH]=JPROPEDITUTILS('jinit',H) 
%   [VFIELDS,VALUES,OFIELDS,OPTIONS,PATH]=JPROPEDITUTILS('jinit',H,PROPNAMES) 
% 
%   Calls jget , jset, and jpath, gets their return arguments, 
%   and returns everything in one call.j 
% 
%   Rather than trying to reconcile property names if the list of 
%   properties from get() and set() are different, JPROPEDITUTILS 
%   simply returns both sets of property names. 
% 
%   'jhelp'================================ 
% 
%   MSG = JPROPEDITUTILS('jhelp',H)
%   MSG = JPROPEDITUTILS('jhelp',TYPE) 
% 
%   H    is a handle to an object or a vector of handles to the same 
%   object type. 
%   TYPE is a string with an object type. 
%   MSG  is a status message 
% 
%   'japplyexpopts'=============================== 
% 
%   JPROPEDITUTILS('japplyexpopts',H) 
% 
%   H  is a vector of handles to figures 
% 
%   Saves current properties in appdata and Sets new ones.
%    
%   'jrestorefig'=============================== 
% 
%   JPROPEDITUTILS('jrestorefig',H) 
% 
%   H  is a vector of handles to figures 
% 
%   Restores properties that were set before japplyexopt function was called. 
% 
%   'jmeshcolor' ==================================== 
% 
%   C = JPROPEDITUTILS('jmeshcolor',H) 
% 
%   H is a handle to a surface or a patch object 
%   C is the FaceColor for the handle necessary to make the object appear 
%     as a hidden-line mesh 
% 
%   If H is a single object, C will be a number triple.  If H is a vector, 
%   C will be a cell array of colors. 
% 
%   In the event that the parent axis is visible "off" and the figure is  
%   color "none", the returned face color will be white [1 1 1] 
% 

%   Copyright 1984-2006 The MathWorks, Inc.

%[varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end

% actions are prefaced by j to avoid conflict 
% with built-in functions. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=jforcenavbardisplay(h,forceValue)
%Force object(s) to appear or not appear in property editor nav bar,
%regardless of their HandleVisibility and HitTest settings.

if nargin<2
    forceValue=1;
end

for i=1:length(h)
    setappdata(double(h),'PropertyEditorNavBarDisplay',forceValue);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function japplyexpopts(h)
% Used by Figure Copy Template preference panel

for i = 1:length(h) 
    axesList = findall(h(i), 'Type', 'axes', '-property', 'XLim'); % collect only cartesian Axes
    textList = findall(h(i), 'type', 'text'); 
    lineList = findall(h(i), 'type', 'line');
    uicontrolList = findall(h(i), 'type', 'uicontrol');
    hs = []; 
    ps = []; 
    vs = [];
    oldtextfontsize = zeros(length(textList),1); % for scaling font size
    oldaxesfontsize = zeros(length(axesList),1); 
    % save ALL properties first
    for j = 1:length(textList)
        oldtextfontsize(j) = get(textList(j),'fontsize');
        hs{end+1}=textList(j);  ps{end+1}='fontsize';    vs{end+1}=oldtextfontsize(j); %#ok<AGROW>
        hs{end+1}=textList(j);  ps{end+1}='fontweight';  vs{end+1}=get(textList(j),'fontweight'); %#ok<AGROW>
        hs{end+1}=textList(j);  ps{end+1}='color';       vs{end+1}=get(textList(j),'color'); %#ok<AGROW>
    end 
    for j = 1:length(axesList)
        oldaxesfontsize(j) = get(axesList(j),'fontsize');
        hs{end+1}=axesList(j);  ps{end+1}='fontsize';    vs{end+1}=oldaxesfontsize(j); %#ok<AGROW>
        hs{end+1}=axesList(j);  ps{end+1}='fontweight';  vs{end+1}=get(axesList(j),'fontweight'); %#ok<AGROW>
        hs{end+1}=axesList(j);  ps{end+1}='color';       vs{end+1}=get(axesList(j),'color'); %#ok<AGROW>
        hs{end+1}=axesList(j);  ps{end+1}='XLimMode';    vs{end+1}=get(axesList(j),'XLimMode'); %#ok<AGROW>
        hs{end+1}=axesList(j);  ps{end+1}='XTickMode';   vs{end+1}=get(axesList(j),'XTickMode'); %#ok<AGROW>
        hs{end+1}=axesList(j);  ps{end+1}='YLimMode';    vs{end+1}=get(axesList(j),'YLimMode'); %#ok<AGROW>
        hs{end+1}=axesList(j);  ps{end+1}='YTickMode';   vs{end+1}=get(axesList(j),'YTickMode'); %#ok<AGROW>
        hs{end+1}=axesList(j);  ps{end+1}='ZLimMode';    vs{end+1}=get(axesList(j),'ZLimMode'); %#ok<AGROW>
        hs{end+1}=axesList(j);  ps{end+1}='ZTickMode';   vs{end+1}=get(axesList(j),'ZTickMode'); %#ok<AGROW>
    end 
    for j = 1:length(lineList)
        hs{end+1}=lineList(j);  ps{end+1}='linewidth';   vs{end+1}=get(lineList(j),'linewidth'); %#ok<AGROW>
        hs{end+1}=lineList(j);  ps{end+1}='linestyle';   vs{end+1}=get(lineList(j),'linestyle'); %#ok<AGROW>
        hs{end+1}=lineList(j);  ps{end+1}='color';       vs{end+1}=get(lineList(j),'color'); %#ok<AGROW>
    end 
    for j = 1:length(uicontrolList)
        hs{end+1}=uicontrolList(j); ps{end+1}='visible'; vs{end+1}=get(uicontrolList(j),'visible'); %#ok<AGROW>
    end 
    
    eo.hSave = hs; 
    eo.propSave = ps; 
    eo.valSave = vs; 
    setappdata(h(i), 'eo_restore_info_080682', eo); 
    
    % then set the ones that need to be set
    %figfontbold = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.TextBold']); 
     figfontbold = com.mathworks.services.Prefs.getBooleanPref('CopyOptions.TextBold'); 
    if (figfontbold) 
        for j = 1:length(textList) 
            set(textList(j), 'fontweight', 'bold'); 
        end 
        for j = 1:length(axesList) 
            set(axesList(j), 'fontweight', 'bold');  
        end 
    end 
    %figfonttextBW = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.TextBW']); 
     figfonttextBW = com.mathworks.services.Prefs.getBooleanPref('CopyOptions.TextBW'); 

    if (figfonttextBW)   
        for j = 1:length(textList) 
            set(textList(j), 'color', 'black'); 
        end 
    end 
    %figfontchange = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.TextSizeChange']); 
    figfontchange = com.mathworks.services.Prefs.getBooleanPref('CopyOptions.TextSizeChange');

    if (figfontchange)
        %figfontsize = javaMethod('getIntegerPref','com.mathworks.services.Prefs', ['CopyOptions.TextSizeChangePref']);
        figfontsize = com.mathworks.services.Prefs.getIntegerPref('CopyOptions.TextSizeChangePref');
        if (figfontsize == 0)
            %strfontsize = javaMethod('getStringPref','com.mathworks.services.Prefs', ['CopyOptions.TextSizeChangeTo']);
            strfontsize = com.mathworks.services.Prefs.getStringPref('CopyOptions.TextSizeChangeTo');

            ifontsize = str2double(strfontsize);
            for j = 1:length(textList)
                set(textList(j), 'fontsize', ifontsize);
            end
            for j = 1:length(axesList)
                set(axesList(j), 'fontsize', ifontsize);
            end
        elseif (figfontsize == 1)
            %strfontincrease = javaMethod('getStringPref','com.mathworks.services.Prefs', ['CopyOptions.TextSizeIncrease']);
            strfontincrease = com.mathworks.services.Prefs.getStringPref('CopyOptions.TextSizeIncrease');

            ifontincrease = str2double(strfontincrease);
            for j = 1:length(textList)
                set(textList(j), 'fontsize', round(oldtextfontsize(j)*(ifontincrease/100)));
            end
            for j = 1:length(axesList)
                set(axesList(j), 'fontsize', round(oldaxesfontsize(j)*(ifontincrease/100)));
            end
        end
    end
     
    %figlineswidth = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.LinesWidthCustom']); 
    figlineswidth = com.mathworks.services.Prefs.getBooleanPref('CopyOptions.LinesWidthCustom'); 

    if (figlineswidth)
        %strlineswidth = javaMethod('getStringPref','com.mathworks.services.Prefs', ['CopyOptions.LinesWidth']); 
         strlineswidth = com.mathworks.services.Prefs.getStringPref('CopyOptions.LinesWidth');
        ilineswidth = str2double(strlineswidth); 
        for j = 1:length(lineList) 
            set(lineList(j), 'linewidth', ilineswidth); 
        end 
    end 
     
    %figlinesstylechange = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.LinesStyleChange']); 
     figlinesstylechange = com.mathworks.services.Prefs.getBooleanPref('CopyOptions.LinesStyleChange'); 

    if (figlinesstylechange) 
        styles = {'-', '--', '-.', ':'}; 
        for j = 1:length(lineList)
            %linecolor = 'black'; 
            if isequal([0 0 0], get(ancestor(lineList(j),'axes'), 'color'))
                linecolor = 'white';
            else
                linecolor = 'black';
            end
            set(lineList(j), 'color', linecolor);
            %linesstylepref = javaMethod('getIntegerPref','com.mathworks.services.Prefs', ['CopyOptions.LinesStylePref']);
             linesstylepref = com.mathworks.services.Prefs.getIntegerPref('CopyOptions.LinesStylePref');

            if (linesstylepref == 1) 
                styleindex = mod(j, 4); 
                if (styleindex == 0) 
                    styleindex = 4; 
                end 
                set(lineList(j), 'linestyle', styles{styleindex});
            end 
        end 
    end   
     
    %figlocklabels = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.LockAxesAndTickLabels']);
     figlocklabels = com.mathworks.services.Prefs.getBooleanPref('CopyOptions.LockAxesAndTickLabels'); 
    if (figlocklabels) 
        for j = 1:length(axesList) 
            set(axesList(j), 'XLimMode',    'manual'); 
            set(axesList(j), 'XTickMode',   'manual'); 
            set(axesList(j), 'YLimMode',    'manual'); 
            set(axesList(j), 'YTickMode',   'manual'); 
            set(axesList(j), 'ZLimMode',    'manual'); 
            set(axesList(j), 'ZTickMode',   'manual'); 
        end 
    end 
     
    %figshowuicontrols = javaMethod('getBooleanPref','com.mathworks.services.Prefs', ['CopyOptions.ShowUiControls']);
     figshowuicontrols = com.mathworks.services.Prefs.getBooleanPref('CopyOptions.ShowUiControls');

    if (figshowuicontrols == 0)   %hide uicontrols 
        for j = 1:length(uicontrolList) 
            set(uicontrolList(j), 'visible', 'off'); 
        end 
    end 
    
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jrestorefig(h)
% Used by Figure Copy Template preference panel
for i=1:length(h) 
    if (isappdata(h(i), 'eo_restore_info_080682'))  
        eo = getappdata(h(i), 'eo_restore_info_080682'); 
        for j = 1:length(eo.hSave) 
            try   % in case a handle (or other value) is bad  
                set(eo.hSave{j}, eo.propSave{j}, eo.valSave{j}) 
            catch
            end 
        end 
        rmappdata(h(i), 'eo_restore_info_080682'); 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function lightHandles=jaddlight(h) 
% Called when Insert Menu -> Light

if nargin<1 
    h=gca; 
end 

addedAxes=[0]; %#ok<NBRAK> %do this to prevent an empty==scalar comparison 
lightHandles=[]; 
for i=1:length(h) 
    axH=h(i); 
     
    try 
        hType=get(axH,'type'); 
    catch 
        hType=''; 
    end 
     
    while ~(isempty(hType) || strcmp(hType,'axes')) 
        try 
            axH=get(axH,'parent'); 
            hType=get(axH,'type'); 
        catch 
            axH=[]; 
            hType=''; 
        end 
    end 
     
    if ~isempty(axH) & ~any(find(addedAxes==axH))  %#ok<AND2>
        %note: this is pretty much cut-and-paste from camlight 
         
        %place the light up and to the right of the camera 
        pos  = get(axH, 'cameraposition' ); 
        targ = get(axH, 'cameratarget'   ); 
        dar  = get(axH, 'dataaspectratio'); 
        up   = get(axH, 'cameraupvector' ); 
         
        %check to see if the axis is right-handed 
        dirs=get(axH, {'xdir' 'ydir' 'zdir'});  
        num=length(find(lower(cat(2,dirs{:}))=='n')); 
        isRightHanded = mod(num,2); 
         
        az=30; 
        el=30; 
        if isRightHanded 
            az=-az; 
        end 
         
        lightPos = camrotate(pos,targ,dar,up,az,el,'camera',[]); 
         
        %change the position because the light is infinite 
        lightPos=lightPos-targ; 
        lightPos=lightPos/norm(lightPos); 
         
         
         
        lightHandles(end+1,1)=light(... 
            'Parent',axH,... 
            'Position',lightPos,... 
            'style','infinite'); 
        addedAxes(end+1,1)=axH; 
    end 
end 
