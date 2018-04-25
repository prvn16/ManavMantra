function mcodeConstructorLineSeries(hObj,hCode)
% Internal code generation method

% Generate code for "plot", "plot3", "loglog", & "semilog[x,y]"

% Copyright 2003-2015 The MathWorks, Inc.

% Variables used in code
is3D = ~isempty(get(hObj,'ZData'));
isVectorOutput = false;
isVectorX = true;
isVectorY = true;
isVectorZ = true;
hObjMomento = get(hCode,'MomentoRef');
local_generate_color(hObjMomento);
ignoreProp = {};

% If 2-D plot, then see if other lineseries objects with the same parent
% exist. Then check to see if they have the same xdata so we can consolidate
% the construction of many line handles into one call to plot as if
% doing "plot(rand(20,20))".
if ~is3D

    % Get list of peer objects with the same parent. Momento objects
    % are created by the code generation engine and represent the object's
    % state which needs to be represented in code form.
    set(hObjMomento,'Ignore',true);
    hParentMomento = up(hObjMomento);
    hPeerMomentoList = [];
    net_ydata = [];
    if ~isempty(hParentMomento)
        hPeerMomentoList = findobj(hParentMomento,'-depth',1);
        hConstructMomentoList = hObjMomento;
        hConstructLineList = hObj;
        net_ydata = get(hObj,'YData')';
        xdata = get(hObj,'XData');
    end

     [hDataSpaceObj , ~] = matlab.graphics.internal.plottools.getDataSpaceForChild(hObj);
    
    % Loop through peer momento objects
    for n = 2:length(hPeerMomentoList)
        hPeerMomento = hPeerMomentoList(n);
        hPeerObj = get(hPeerMomento,'ObjectRef');
        [hDataSpacePeerObj , ~] = matlab.graphics.internal.plottools.getDataSpaceForChild(hPeerObj);                     
        if isa(hPeerObj,'graph2d.lineseries') || isa(hPeerObj,'matlab.graphics.chart.primitive.Line')
            peer_xdata = get(hPeerObj,'XData');
            % If the momento object is a lineseries with the same
            % xdata as this object and belong to the same dataspace.
            if ~isequal(hPeerObj,hObj) && ...
                    ~get(hPeerMomento,'Ignore') && ...
                    isequal(xdata,peer_xdata) && ...
                    ~localHasConstructor(hPeerObj)&& ...
                    all(hDataSpaceObj == hDataSpacePeerObj)

                % Add handle to list of constructor output handles
                hConstructMomentoList = [hConstructMomentoList;hPeerMomento];
                hConstructLineList = [hConstructLineList;hPeerObj];
                net_ydata = [net_ydata,get(hPeerObj,'YData')'];
                % Mark the monento to be ignored by the code generation engine
                % since this momento object is already being
                % created by this constructor
                set(hPeerMomento,'Ignore',true);
                local_generate_color(hPeerMomento);
                % Constructor output is now a vector of handles
                isVectorOutput = true;
                isVectorY = false;
            end
        end
    end % for
else
    % If 3-D plot, then see if other lineseries objects with the same
    % dimensionality exist. Then check to see if they have the same xdata,
    % ydata, or zdata so we can consolidate the construction of many line
    % handles into one call to plot as if doing "h = peaks;plot3(1:49,1:49,h)".

    % Get list of peer objects with the same parent. Momento objects
    % are created by the code generation engine and represent the object's
    % state which needs to be represented in code form.
    set(hObjMomento,'Ignore',true);
    hParentMomento = up(hObjMomento);
    hPeerMomentoList = [];
    net_ydata = [];
    if ~isempty(hParentMomento)
        hPeerMomentoList = findobj(hParentMomento,'-depth',1);
        hConstructMomentoList = hObjMomento;
        hConstructLineList = hObj;
        net_xdata = get(hObj,'XData').';
        net_ydata = get(hObj,'YData').';
        net_zdata = get(hObj,'ZData').';
    end

    % Loop through peer momento objects
    for n = 2:length(hPeerMomentoList)
        hPeerMomento = hPeerMomentoList(n);
        hPeerObj = get(hPeerMomento,'ObjectRef');
        if isa(hPeerObj,'graph2d.lineseries') || isa(hPeerObj, 'matlab.graphics.chart.primitive.Line')
            peer_xdata = get(hPeerObj,'XData').';
            peer_ydata = get(hPeerObj,'YData').';
            peer_zdata = get(hPeerObj,'ZData').';

            % If the momento object is a lineseries with the same
            % xdata as this object.
            if ~isequal(hPeerObj,hObj) && ...
                    ~get(hPeerMomento,'Ignore') && ...
                    isequal(length(net_xdata),length(peer_xdata)) && ...
                    ~isempty(peer_zdata) && ...
                    ~localHasConstructor(hPeerObj)

                % Add handle to list of constructor output handles
                hConstructMomentoList = [hPeerMomento; hConstructMomentoList];
                hConstructLineList = [hPeerObj; hConstructLineList];
                if ~isequal(net_xdata,peer_xdata)
                    net_xdata = [net_xdata,peer_xdata];
                end
                if ~isequal(net_ydata,peer_ydata)
                    net_ydata = [net_ydata,peer_ydata];
                end
                if ~isequal(net_zdata,peer_zdata)
                    net_zdata = [net_zdata,peer_zdata];
                end

                % Mark the momento to be ignored by the code generation engine
                % since this momento object is already being
                % created by this constructor
                set(hPeerMomento,'Ignore',true);
                local_generate_color(hPeerMomento);
                % Constructor output is now a vector of handles
                isVectorOutput = true;
                isVectorX = isvector(net_xdata);
                isVectorY = isvector(net_ydata);
                isVectorZ = isvector(net_zdata);
            end
        end
    end % for

end % if

% Generate call to 'plot3', 'plot', 'loglog', 'semilogx', or 'semilogy'
if is3D
    constructor_name = 'plot3';
else
    hAxes = ancestor(hObj,'axes');
    is_logx = strcmpi(get(hAxes,'XScale'),'log');
    is_logy = strcmpi(get(hAxes,'YScale'),'log');

    % The axes mcodeConstructor method will ignore the XScale and YScale
    % properties if it is a simple log plot.
    if (is_logx && is_logy)
        constructor_name = 'loglog';
    elseif (is_logx)
        constructor_name = 'semilogx';
    elseif (is_logy)
        constructor_name = 'semilogy';
    else
        constructor_name = 'plot';
    end
end

% Specify constructor name
setConstructorName(hCode,constructor_name);

% Call helper function
plotutils('makemcode',hObj,hCode);

% Ignore source
ignoreProp = {ignoreProp{:},'XDataSource','YDataSource'};

% Make 'XData' default input argument
ignoreProp = {ignoreProp{:},'XData','XDataMode'};
if strcmp(hObj.XDataMode,'manual')
    if isVectorX
        objName = get(hObj,'XDataSource');
        objName = hCode.cleanName(objName,'X');
    else
        objName = 'XMatrix';
    end
    arg = codegen.codeargument('Name',objName,...
        'Value',hObj.XData,...
        'IsParameter',true);
    if ~isVectorX
        set(arg,'Value',net_xdata,'Comment',getString(message('MATLAB:codetools:private:mcodeConstructorLineSeries:MatrixOfXData')));
    else
        set(arg,'Value',get(hObj,'XData'),'Comment',getString(message('MATLAB:codetools:private:mcodeConstructorLineSeries:VectorOfXData')));
    end
    addConstructorArgin(hCode,arg);
end

% Make 'YData' default input argument
ignoreProp = {ignoreProp{:},'YData'};
if isVectorY
    objName = get(hObj,'YDataSource');
    objName = hCode.cleanName(objName,'Y');
else
    objName = 'YMatrix';
end
arg = codegen.codeargument('Name',objName,...
    'IsParameter',true);
if ~isVectorY
    set(arg,'Value',net_ydata,'Comment',getString(message('MATLAB:codetools:private:mcodeConstructorLineSeries:MatrixOfYData')));
else
    set(arg,'Value',get(hObj,'YData'),'Comment',getString(message('MATLAB:codetools:private:mcodeConstructorLineSeries:VectorOfYData')));
end

addConstructorArgin(hCode,arg);

% If 3-D plot, make 'ZData' default input argument
if is3D
    ignoreProp = {ignoreProp{:},'ZData','ZDataSource'};
    if isVectorZ
        objName = get(hObj,'ZDataSource');
        objName = hCode.cleanName(objName,'Z');
    else
        objName = 'ZMatrix';
    end
    arg = codegen.codeargument('Name',objName,...
        'Value',hObj.ZData,...
        'IsParameter',true);
    if ~isVectorZ
        set(arg,'Value',net_zdata,'Comment',getString(message('MATLAB:codetools:private:mcodeConstructorLineSeries:MatrixOfZData')));
    else
        set(arg,'Value',get(hObj,'ZData'),'Comment',getString(message('MATLAB:codetools:private:mcodeConstructorLineSeries:VectorOfZData')));
    end
    addConstructorArgin(hCode,arg);
end

% Ignore properties that were auto-generated
if local_isPropModeAuto(hObj, 'Color')
    ignoreProp = {ignoreProp{:},'Color'};
end
if local_isPropModeAuto(hObj, 'LineStyle')
    ignoreProp = {ignoreProp{:},'LineStyle'};
end
if local_isPropModeAuto(hObj, 'Marker')
    ignoreProp = {ignoreProp{:},'Marker'};
end

% Ignore list of properties
ignoreProperty(hCode,ignoreProp);

% Output is a vector handle, input is a matrix
if isVectorOutput

    % Customize output to be a vector handle
    hFunc = getConstructor(hCode);
    hArg = codegen.codeargument('Value',hConstructLineList,...
        'Name',get(hFunc,'Name'));
    addArgout(hFunc,hArg);

    % Let user know that the output is multiple line handles
    set(hFunc,'Comment',...
        getString(message('MATLAB:codetools:private:mcodeConstructorLineSeries:CreateMultipleLinesUsingMatrix',constructor_name)));

    % Generate calls to "set" command
    mcodePlotObjectVectorSet(hCode,hConstructMomentoList,@isDataSpecificFunction);

    % Output is a scalar handle
else

    % Force code generation of 'Color' property if manual
    if ~local_isPropModeAuto(hObj, 'Color') && ~hasProperty(hCode,'Color')
        addProperty(hCode,'Color')
    end

    % Generate param-value syntax for remaining properties
    generateDefaultPropValueSyntax(hCode);
end

%----------------------------------------------------------%
function flag = localHasConstructor(hLine)
% Determine whether the peer object should be ignored due to the presence
% of a custom constructor
% Check app data

flag = false;
info = getappdata(hLine,'MCodeGeneration');
if isstruct(info) && isfield(info,'MCodeConstructorFcn')
    fcn = info.MCodeConstructorFcn;
    if ~isempty(fcn)
        flag = true;
    end

    % Check behavior object
else
    hb = hggetbehavior(hLine,'MCodeGeneration','-peek');
    if ~isempty(hb)
        fcn = get(hb,'MCodeConstructorFcn');
        if ~isempty(fcn)
            flag = true;
        end
    end
end

%--------------------------------------------------------------%
function local_generate_color(hObjMomento)

% Color may not have been generated, but needs to have been since the
% HG default doesn't really apply:
hasColor = true;
hPropertyList = get(hObjMomento,'PropertyObjects');
hObj = get(hObjMomento,'ObjectRef');
if isempty(hPropertyList)
    hasColor = false;
else
    if isempty(findobj(hPropertyList,'Name','Color'))
        hasColor = false;
    end
end
if ~hasColor && ~local_isPropModeAuto(hObj, 'Color')
    pobj = codegen.momentoproperty;
    set(pobj,'Name','Color');
    set(pobj,'Value',get(hObj,'Color'));
    hPropertyList = [hPropertyList pobj];
    set(hObjMomento,'PropertyObject',hPropertyList);
end

%--------------------------------------------------------------%
function flag = isDataSpecificFunction(hObj, hProperty)
% Returns true is the function is generated as a side effect of the data,
% false otherwise

name = lower(get(hProperty,'Name'));

switch(name)
    case {'xdatamode','ydatasource','xdatasource','zdatasource','xdata','ydata','zdata'}
        flag = true;
        
    case 'color'
        flag = local_isPropModeAuto(hObj, 'Color');
    case 'linestyle'
        flag = local_isPropModeAuto(hObj, 'LineStyle');
    case 'marker'
        flag = local_isPropModeAuto(hObj, 'Marker');
    otherwise
        flag = false;
end


function isAuto = local_isPropModeAuto(hObj, PropName)
ModeName = [PropName 'Mode'];
ModeVal = get(hObj, ModeName);
isAuto = strcmp(ModeVal, 'auto');
