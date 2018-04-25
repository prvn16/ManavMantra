function out = getCode( filename )
%getCode Returns the MATLAB code from the file as a string
%   code = matlab.internal.getCode('FILENAME') returns the contents of the MATLAB code file FILENAME as a
%   MATLAB string.

% Copyright 2013 The MathWorks, Inc.

% get filename
if ~ischar(filename) 
    error(message('MATLAB:internal:getCode:filenameNotString')); 
end

% do some validation
if isempty(filename) 
    error(message('MATLAB:internal:getCode:emptyFilename')); 
end

%find the helper function to delegate the file reading
[~,~,extension] = fileparts(filename);
getCodeFunction = ['matlab.internal.getcode' extension 'file'];

if (~isempty(which(getCodeFunction)))
    out = feval(getCodeFunction,filename);
else
    error(message('MATLAB:internal:getCode:invalidFile',filename));
end

end