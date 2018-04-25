function fonts = listfonts(handle)
%LISTFONTS Get list of available system fonts in cell array.
%   C = LISTFONTS returns list of available system fonts.
%
%   C = LISTFONTS(H) returns system fonts with object's FontName
%   sorted into the list.
%
%   Examples:
%     Example1:
%       list = listfonts
%
%     Example2:
%       h = uicontrol('Style', 'text', 'string', 'My Font');
%       list = listfonts(h)
%
%   See also UISETFONT.

%   Copyright 1984-2014 The MathWorks, Inc.

persistent systemfonts;
if nargin == 1
    try
        currentfont = {get(handle, 'FontName')};
    catch %#ok<CTCH>
        currentfont = {''};
    end
else
    currentfont = {''};
end

isjava = usejava('awt');

if isempty(systemfonts)
    if isjava
        fontlist = com.mathworks.mwswing.FontUtils.getFontNames.toArray();
        fonts = cell(fontlist);
    else
        fonts = {};
    end
    
    % always add postscipt fonts to the system fonts list.
    systemfonts = [fonts;
        {
        'AvantGarde';
        'Bookman';
        'Courier';
        'Helvetica';
        'Helvetica-Narrow';
        'NewCenturySchoolBook';
        'Palatino';
        'Symbol';
        'Times';
        'ZapfChancery';
        'ZapfDingbats';
        }];
end

% add the current font to the system font list if it's there
if isempty(currentfont{1})
    fonts = systemfonts;
else
    fonts = [systemfonts; currentfont];
end

% return a sorted and unique font list to the user
[f,i] = unique(lower(fonts));  %#ok
fonts = fonts(i);
