function fontstruct = uisetfont_helper(varargin)
%   Copyright 2007-2008 The MathWorks, Inc.
[fontstruct,title,fhandle] = parseArgs(varargin{:});

fcDialog = matlab.ui.internal.dialog.DialogUtils.createFontChooser();
fcDialog.Title = title;
if ~isempty(fontstruct)
    fcDialog.InitialFont = fontstruct;
end

c = matlab.ui.internal.dialog.DialogUtils.disableAllWindowsSafely();
fontstruct = showDialog(fcDialog);
delete(c);

if  ~isempty(fhandle)
    setPointFontOnHandle(fhandle,fontstruct);
end

% Done. MCOS Object fcDialog cleans up and its java peer at the end of its
% scope(AbstractDialog has a destructor that every subclass
% inherits)
function [fontstruct,title,handle] = parseArgs(varargin)
handle = [];
fontstruct = [];
title = getString(message('MATLAB:uistring:uisetfont:TitleFont'));
if nargin>2
    error(message('MATLAB:uisetfont:TooManyInputs')) ;
end
if (nargin==2)
    if ~ischar(varargin{2})
        error(message('MATLAB:uisetfont:InvalidTitleType'));
    end
    title = varargin{2};
end
if  (nargin>=1)
    if ishghandle(varargin{1})
        handle = varargin{1};
        fontstruct = getPointFontFromHandle(handle);
    elseif isstruct(varargin{1})
        fontstruct = varargin{1};
    elseif ischar(varargin{1})
        if (nargin > 1)
            error(message('MATLAB:uisetfont:InvalidParameterList'));
        end
        title = varargin{1};
    else
        error(message('MATLAB:uisetfont:InvalidFirstParameter'));
    end
end

%Given the dialog, user chooses to select or not select
function fontstruct = showDialog(fcDialog)
fcDialog.show;
fontstruct = fcDialog.SelectedFont;
if isempty(fontstruct)
    fontstruct = 0;
end


%Helper functions to convert font sizes based on the font units of the
%handle object
function setPointFontOnHandle(fhandle,fontstruct)
tempunits = getPropIfExists(fhandle,'FontUnits');
try
    setPropIfExists(fhandle,fontstruct);
catch ex %#ok<NASGU>
end
setPropIfExists(fhandle,'FontUnits',tempunits);

function fs = getPointFontFromHandle(fhandle)
tempunits = getPropIfExists(fhandle,'FontUnits');
setPropIfExists(fhandle, 'FontUnits', 'points');

fs = [];
try       
    fs = addToStructIfPropExists(fhandle, 'FontName',fs);
    fs = addToStructIfPropExists(fhandle, 'FontWeight',fs);
    fs = addToStructIfPropExists(fhandle, 'FontAngle',fs);
    fs = addToStructIfPropExists(fhandle, 'FontUnits',fs);
    fs = addToStructIfPropExists(fhandle, 'FontSize',fs);
catch ex %#ok<NASGU>
end    
if(isempty(fs))
    error(message('MATLAB:uisetfont:NoFontProperties'));
end
setPropIfExists(fhandle, 'FontUnits', tempunits);



function val = getPropIfExists(obj,prop)
val = [];
if isprop(obj,prop)
    val = get(obj,prop);
end

function setPropIfExists(obj,prop,val)
if isstruct(prop)
    for f = fieldnames(prop)'
        setPropIfExists(obj,f{:},prop.(f{:}));
    end
else
    if isprop(obj,prop)
        set(obj,prop,val);
    end
end

function str = addToStructIfPropExists(obj,prop,str)
if isprop(obj,prop)
    str.(prop) = get(obj,prop);
end
