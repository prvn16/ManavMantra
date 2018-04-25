function fig = getfigurefordesktopclient (dtclient)
% This undocumented function may be removed in a future release.
  
% Copyright 2006-2007 The MathWorks, Inc.

% loop over all the figures and find out which one 
% has this DTClientBase 
fig = [];
ch = allchild(0);
for i =1:length(ch)
    f = ch(i);
    if usejava('swing') && ~isempty(f) && ishghandle(f) && ...
            isequal(fig2client(f), dtclient)
            fig = f;
            return;
    end
end

function client = fig2client(fig)
jp = javaGetFigureFrame(fig);
drawnow;
% imagine we make this easy to get
client = [];
if isempty(jp)
    return;
end
ac = jp.getAxisComponent;
if isa(ac,'com.mathworks.hg.peer.FigureClientProxy$FigureDTClientBase')
    client = ac;
    return;
end
if isempty(ac)
    return;
end
acp = ac.getParent;
if isa(acp,'com.mathworks.hg.peer.FigureClientProxy$FigureDTClientBase')
    client = acp;
    return;
end
if isempty(acp)
    return;
end
acpp = acp.getParent;
if isa(acpp,'com.mathworks.hg.peer.FigureClientProxy$FigureDTClientBase')
    client = acpp;
    return;
end
if isempty(acpp)
    return;
end
client = acpp.getParent;