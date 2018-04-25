function checkForSameSizeAndClass(X, Y)
%CHECKFORSAMESIZEANDCLASS used by imabsdiff.
%   private function to check that X and Y have the same size and class.
    
% Copyright 2012 The MathWorks, Inc.
    
if ~strcmp(classUnderlying(X),classUnderlying(Y))
    error(message('images:checkForSameSizeAndClass:mismatchedClass'))
end

if ~isequal(size(X),size(Y))
    error(message('images:checkForSameSizeAndClass:mismatchedSize'))
end
