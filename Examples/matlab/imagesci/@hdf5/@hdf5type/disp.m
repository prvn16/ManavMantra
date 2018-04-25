function disp(hObj)
%DISP DISP for an hdf5.hdf5type object
%   hdf5.hdf5type.disp is not recommended.  Use h5disp instead.
%
%   See also H5DISP.

%   Copyright 1984-2013 The MathWorks, Inc.

if (numel(hObj) == 1)
    disp([class(hObj) ':']);
    disp(' ');
    disp(get(hObj));
else
    builtin('disp', hObj);
end



