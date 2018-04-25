function str = popupstr(handle)
%POPUPSTR Obsolete function.
%   POPUPSTR may be removed in a future version.

%POPUPSTR Get popup menu selection string.
%   STR = POPUPSTR(H) returns the currently selected string
%   for the popup menu uicontrol whose handle is H.
%
%   Example:
%       h1 = uicontrol('Style', 'popup', 'String', 'A|B|C', 'Value', 1);
%       %select an item and pop1 should return that item
%       pop1 = popupstr(h1)
%
%   See also UICONTROL

%  Steven L. Eddins, April 1994
%  Copyright 1984-2008 The MathWorks, Inc.

obsolete = true;

pick_list = get(handle, 'String');
selection = get(handle, 'Value');
if (iscell(pick_list))
    str = pick_list{selection};
else
    str = deblank(pick_list(selection,:));
end

