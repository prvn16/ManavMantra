function [name, clsFile] = className(whichResult)
% className Given a path to a file, determine if the file belongs to a class.
% If so, return the name of the class and the path to the class
% constructor.
    
    % Check to see if the whichResult is the constructor for a built-in
    % class. There are two kinds of built-in constructors: those inherent
    % to MATLAB (like cell arrays) and those added by toolboxes (like
    % gpuArray).
    [name, clsFile] = builtinClassCTOR(whichResult);
 
    if isempty(name)
        [name, clsFile] = className_impl(whichResult);
    end
end
