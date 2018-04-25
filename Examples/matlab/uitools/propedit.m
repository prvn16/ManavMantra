function varargout=propedit(h,varargin)
%PROPEDIT  Graphical property editor
%   PROPEDIT edits all properties of any selected HG object through the
%   use of a graphical interface.  PROPEDIT(HandleList) edits the
%   properties for the object(s) in HandleList.  If HandleList is omitted,
%   the property editor will edit the current figure.
%
%   Launching the property editor will enable plot editing for the figure.
%
%   Example:
%       f=figure;
%       u1 = uicontrol('Style','push', 'parent', f,'pos',...
%           [20 100 100 100],'string','button1');
%       u2 = uicontrol('Style','push', 'parent', f,'pos',...
%           [150 250 100 100],'string','button2');
%       u3 = uicontrol('Style','push', 'parent', f,'pos',...
%           [250 100 100 100],'string','button3');
%       hlist = [u1 u2 u3];
%       propedit(hlist);
%
%   See also INSPECT, PLOTEDIT, PROPERTYEDITOR

%   PROPEDIT(HandleList,'-noselect') will not put selection handles around
%   the objects or update the SCRIBE internal list of selected handles.  Be
%   careful using this - it is really only intended to be used if you have already
%   used SCRIBE to select the object.
%
%   PROPEDIT(HandleList,'-noopen') will not force the property editor to open.
%   If the property editor has not been opened yet or is invisible, it will
%   not pop open.
%
%   PROPEDIT(HandleList,'-tTABNAME') will open the property editor to the
%   requested tab.  Note that TABNAME is case sensitive and may be affected by
%   internationalization.
%
%   PROPEDIT(HandleList,'v6') used to open the property editor window used in
%   versions 6 and earlier, but is now deprecated.
%
%   WARNSTR = PROPEDIT(...) will return warning messages as a string instead of
%   calling the warning command.

%   Copyright 1984-2010 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

%---- Error if the conditions are bad:
v6 = nargin > 1 && isa(varargin{1},'char') && any(strcmpi(varargin,'v6'));
if v6
    error (message('MATLAB:propedit:V6'))
end

error(javachk('awt'));

if (nargin > 0) && isa(h, 'char')
    if strcmpi(h, '-noopen')
        error (message('MATLAB:propedit:NoopenFirst'))
    elseif strcmpi(h, '-noselect')
        error (message('MATLAB:propedit:NoselectFirst'))
    elseif any(strncmp('-t',h,2))
        error (message('MATLAB:propedit:TabFirst'))
    elseif strcmpi(h, 'v6')
        error (message('MATLAB:propedit:V6'))
    else
        error (message('MATLAB:propedit:NeedsHandle'))
    end
end


%---- Parse the arguments:   
noOpen=any(strcmpi(varargin,'-noopen'));

noSelect=any(strcmpi(varargin,'-noselect'));

%Make sure to check noOpen flag to prevent setting noSelect to true when
%we are about to open Property Editor
if (nargin > 0) && ~noSelect && noOpen
    if ishandle(h)
        noSelect = ~plotedit(ancestor(h, 'figure'),'isactive');
    else
        noSelect = false;
    end
end

matchedTab = find(strncmp('-t',varargin,2));
if ~isempty(matchedTab)
    tabName=varargin{matchedTab(1)};
    tabName=tabName(3:end); %#ok<NASGU>
else
    tabName=''; %#ok<NASGU>
end

% Make sure a figure exists and that currentFigure is properly initialized.
if nargin == 0 || isempty(h)
    h = gcf;
end
h=unique(h(ishandle(h)));  % strips out duplicates and invalid handles
if (numel(h) == 0)
    error (message('MATLAB:propedit:NoValidHandles'));
end
currentFigure = ancestor(h(1),'figure');
if isempty(currentFigure)
    if isa(h(1), 'graphics.datacursormanager')
        currentFigure = get(h(1), 'Figure');
    else
        currentFigure = gcf;
    end
end

if isa(handle(h), 'figure') && ...
    (strncmpi (get(handle(h),'Tag'), 'Msgbox', 6) || ...
     strcmpi (get(handle(h),'WindowStyle'), 'Modal'))
    return
end


if ~isempty(h)
    a = requestJavaAdapter(h);
    com.mathworks.mlservices.MLInspectorServices.inspectIfOpen(a);
    if ~noSelect && any (h ~= 0)
        selectobject (h,'replace');
    end
    if ~noOpen
        propertyeditor (double(currentFigure), 'show');
    end
    if propeditorIsOpen
        props = getplottool (currentFigure, 'propertyeditor');
        if ~isempty (a) && ~isempty(props)
            if iscell (a)
                a = [a{:}];
                javaMethodEDT('setObjects',props,a)
            else
                javaMethodEDT('setObject',props,a)
            end
        end
    end
    warnFlag=false;
else
    warnFlag=true;
end

if nargout>0
    varargout{1}=getString(message('MATLAB:propedit:InvalidObjectsPassed'));
elseif warnFlag
    warning(message('MATLAB:propedit:InvalidObjectsPassed'));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isOpen = propeditorIsOpen
if ispref('plottools', 'isdesktop')
    rmpref('plottools', 'isdesktop');
end
dt=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
isOpen = dt.isClientShowing('Property Editor');
