function txt_msg = wwaiting(option,fig,in3,in4)
%WWAITING Wait and display a message.
%   OUT1 = WWAITING(OPTION,FIG,IN3,IN4)
%   fig is the handle of the figure.
%
%   OPTION = 'on' , 'off'
%
%   OPTION = 'msg'    (display a message)
%    IN3 is a string.
%
%   OPTION = 'create' (create a text for messages)
%   IN3 and in4 are optional.
%   IN3 is height of the text (in pixels).
%   IN4 is a string.
%   OUT1 is the handle of the text.
%
%   OPTION = 'handle'
%   OUT1 is the handle of the text.
%
%   OPTION = 'close'  (delete the text)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
% $Revision: 1.11.4.10 $

child = wfindobj('figure');
if isempty(child) || isempty(find(child==fig,1)) , return; end
tag_msg = 'Txt_Message';
txt_msg = findobj(fig,'Style','text','Tag',tag_msg);

switch option
    case {'on','off'}
        if ~isempty(txt_msg) , set(txt_msg,'Visible',option); end
        mousefrm(0,'arrow');
        drawnow;

    case 'msg'
        %  in3 = msg
        %------------------
        if ~isempty(txt_msg)
            if nargin<4 , mousefrm(0,'watch'); end
            nblines = size(in3,1);
            if nblines==1 , in3 = char(' ',in3); end 
            set(txt_msg,'Visible','On','String',in3);
            drawnow;
        end

    case 'create'
        % in3 = "position"  (optional)
        % in4 = msg         (optional)
        % out1 = txt_msg
        %------------------
        uni = get(fig,'Units');
        pos = get(fig,'Position');
        tmp = get(0,'DefaultUicontrolPosition');
        yl  = 2.75*tmp(4);
        if strcmp(uni(1:3),'pix')
            xl = pos(3);
        elseif strcmp(uni(1:3),'nor')
            xl = 1;
            [~,yl] = wfigutil('prop_size',fig,1,yl);
        end
        if nargin>2
            xl = xl*in3;
            if nargin==3
                msg = '';
                vis = 'off';
            else
                msg = in4;
                nblines = size(msg,1);
                if nblines==1 , msg = char(' ',msg); end 
                vis = 'on';
                mousefrm(0,'watch');
            end
        end
        msgBkColor = mextglob('get','Def_MsgBkColor');
        pos_txt_msg = [0 0 xl yl];
        txt_msg = uicontrol(...
                        'Parent',fig,...
                        'Style','text',...
                        'Units',uni,...
                        'Position',pos_txt_msg,...
                        'Visible',vis,...
                        'String',msg,...
                        'BackgroundColor',msgBkColor, ...
                        'Tag',tag_msg...
                        );
        if strcmpi(vis(1:2),'on') , drawnow; end

    case 'handle'

    case 'close'
        delete(txt_msg);
        mousefrm(0,'arrow');

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal')); 
end
