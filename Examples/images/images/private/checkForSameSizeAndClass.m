function checkForSameSizeAndClass(X, Y, ~)
%checkForSameSizeAndClass used by immultiply,imdivide,imabsdiff
%   private function to check that X and Y have the same size and class.
    
% Copyright 2007-2011 The MathWorks, Inc.
    
if ~strcmp(class(X),class(Y))
    error(message('images:checkForSameSizeAndClass:mismatchedClass'))
end

if ~isequal(size(X),size(Y))
    error(message('images:checkForSameSizeAndClass:mismatchedSize'))
end
