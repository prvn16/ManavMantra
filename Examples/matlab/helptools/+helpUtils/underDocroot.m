function fullpath = underDocroot(varargin)
% underDocroot - Find a file that is expected to be under the docroot.  
%   This method will return an empty array if the file is not found.

%   Copyright 2008-2014 The MathWorks, Inc.
fullpath = '';

testpath = fullfile(docroot,varargin{:});
if exist(testpath,'file')
    fullpath = testpath;
end
