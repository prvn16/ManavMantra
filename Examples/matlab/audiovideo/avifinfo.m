function [m,d] = avifinfo(filename)
%AVIFINFO Text description of AVI-file contents.
%   AVIFINFO will be removed in a future release. Use VIDEOREADER
%   instead.


% Copyright 1984-2013 The MathWorks, Inc.

warning(message('MATLAB:audiovideo:avifinfo:FunctionToBeRemoved')); 

try
    warnState = warning('OFF', 'MATLAB:audiovideo:aviinfo:FunctionToBeRemoved');
    warnCleaner = onCleanup(@()warning(warnState));
    d = evalc('disp(aviinfo(filename))');
    m = 'AVI-File';
catch exception
    d = '';
    m = exception.message;
end
