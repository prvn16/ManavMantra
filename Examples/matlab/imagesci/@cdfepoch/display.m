function display(obj)
%DISPLAY   DISPLAY for CDFEPOCH object.

%   Copyright 2001-2013 The MathWorks, Inc.

if strcmp(get(0, 'FormatSpacing'), 'loose')
    loose = 1;
else
    loose = 0;
end;

%
% Name or ans
%
if loose ~= 0
    disp(' ');
end;

if isempty(inputname(1))
    disp('ans =');
else
    disp([inputname(1) ' =']);
end;

if loose ~= 0
    disp(' ');
end;

if isempty(todatenum(obj))
    msg = getString(message('MATLAB:imagesci:cdf:empty'));
    disp( ['     ' msg] );
    return;
elseif isequal(size(obj), [1 1])
    msg = getString(message('MATLAB:imagesci:cdf:notEmpty'));
    disp( ['     ' msg] );
end

disp(obj);
