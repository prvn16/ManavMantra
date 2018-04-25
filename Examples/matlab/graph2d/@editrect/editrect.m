function A = editrect(varargin)
%EDITRECT/EDITRECT Make editrect object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 


if nargin==0
   A.Class = 'editrect';
   A.origin = [];
   A.Objects = [];
   A = class(A,'editrect',editline);
   return
end

el = editline(varargin{:});

ax = get(el,'Axis');

A.Class = 'editrect';
A.origin = [];

b = text('Visible','off',...
        'Parent',ax,...
        'HandleVisibility','off');
A.Objects = scribehandle(hgbin(b));

A = class(A,'editrect',el);
AH = scribehandle(A);
