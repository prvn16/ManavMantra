function [varargout] = fwdSubsref(A,s)
% Copyright 2015 The MathWorks, Inc 
try 
    [varargout{1:nargout}] = subsref(A,s); 
catch ME
    throwAsCaller(ME)
end 
end
    