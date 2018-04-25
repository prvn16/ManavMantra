function [t,d] = readtree(fig)
%READTREE Read wavelet packet decomposition tree from a figure.
%   T = READTREE(F) reads the wavelet packet
%   decomposition tree from the figure F.
%
%   Example:
%     x   = sin(8*pi*(0:0.005:1));
%     t   = wpdec(x,3,'db2');
%     fig = drawtree(t);
%     %-------------------------------------
%     % Use the GUI to split or merge Nodes.
%     %-------------------------------------
%     t = readtree(fig)
%
%   See also DRAWTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision 08-May-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

wins = wfindobj('figure');
if ~isempty(find(wins==fig,1))
    func = lower(get(fig,'Tag'));
    if isequal(func,'wp1dtool') || isequal(func,'wp2dtool')
        t = feval(func,'read',fig);
    else
        t = []; d = [];
        msg = getWavMSG('Wavelet:moreMSGRF:No_Tree_AND_DS',num2str(fig));
        warndlg(msg,getWavMSG('Wavelet:moreMSGRF:WARNING'));
    end
else
    msg = getWavMSG('Wavelet:moreMSGRF:Invalid_NumFIG',num2str(fig));
    warndlg(msg,getWavMSG('Wavelet:moreMSGRF:WARNING'));
end
