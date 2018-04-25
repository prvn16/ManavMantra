function aboutslfixpoint
%ABOUTSLFIXPOINT About Fixed-Point Designer.
%   ABOUTSLFIXPOINT displays the version number and the copyright notice in
%   a modal dialog box.

%   Copyright 2006-2012 The MathWorks, Inc.

tlbx = ver('fixedpoint');
str = sprintf([tlbx.Name ' ' tlbx.Version '\n',...
	'Copyright 1994-' datestr(tlbx.Date,10) ' The MathWorks, Inc.']);
msgbox(str,tlbx.Name,'modal');

