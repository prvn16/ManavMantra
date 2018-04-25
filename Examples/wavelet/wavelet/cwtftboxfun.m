function varargout = cwtftboxfun(arg)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-2010.
%   Last Revision: 24-Nov-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

if nargin<1
    % FaceColor , FaceAlpha , EdgeColor
    %----------------------------------
    varargout{1} = {...
        [1 0.9 0.7] , 0.5  , [1 0 0]; ...
        [1   1   1] , 0.3  , [1 1 1]; ...
        [0.7 1 0.7] , 0.6  , [0 1 0]  ...
        };
    
    return;
end;
[hObject,fig] = gcbo;
par = get(hObject,'Parent');
usr = get(par,'Userdata');
handles = guihandles(fig);
switch arg
    case 1 , cwtfttool('SEL_or_UNSEL_or_DEL_BOX',fig,[],handles,1,usr);
    case 2 , cwtfttool('SEL_or_UNSEL_or_DEL_BOX',fig,[],handles,-1,usr);
    case 3 , cwtfttool('SEL_or_UNSEL_or_DEL_BOX',fig,[],handles,0,usr);
end

