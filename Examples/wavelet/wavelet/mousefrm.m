function mousefrm(h,forme)
%MOUSEFRM Change mouse aspect.
%   MOUSEFRM(H,F)
%   H = vector of handles (figures or root).
%   F = string for pointer aspect : 'arrow', 'watch', ....
%   MOUSEFRM(H) is equivalent to MOUSEFRM(H,'arrow').
%   MOUSEFRM is equivalent to MOUSEFRM(0,'arrow').

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

if     nargin==0 , forme = 'arrow'; h = 0; 
elseif nargin==1 , forme = 'arrow';
end
allfig = wfindobj('figure');
if any(double(h))       
    hind = wcommon(h,allfig);
    h = h(hind);
else
    h = allfig;
end
set(h,'Pointer',forme);
