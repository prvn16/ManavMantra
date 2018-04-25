function [sx,sy] = mdw1dclustcoor(x,y,axe,idxSORT)
%MDW1DCLUSTCOOR Manage display of coordinates values.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Jul-2006.
%   Last Revision: 01-Oct-2006.

tag = get(axe,'Tag');
switch tag
    case 'Axe_View_PART'
        sx = ['Sig ' int2str(idxSORT(round(x)))];
        sy = ['Clu ' int2str(round(y))];
    otherwise
        sx = ['X = ' , wstrcoor(x,5,7)];
        sy = ['Y = ' , wstrcoor(y,5,7)];
end
