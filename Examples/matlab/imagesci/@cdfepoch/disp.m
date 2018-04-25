function disp(obj)
%DISP   DISP for CDFEPOCH object.

%   binky
%   Copyright 2001-2013 The MathWorks, Inc.

% If obj is not scalar, then just display the size
if ~isscalar(obj)
    s = size(obj);
    disp(sprintf('     [%dx%d cdfepoch]', s(1), s(2)));
else
    if isempty(obj.date) %#ok<I18N_Dir_Date>
        disp('     Empty cdfepoch object.');
    else
        disp(['     ' datestr(todatenum(obj),0)]);
    end
end
