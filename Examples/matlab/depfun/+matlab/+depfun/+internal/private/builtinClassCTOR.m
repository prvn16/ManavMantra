function [name, clsFile] = builtinClassCTOR(whichResult) 
% builtinClassCTOR Return the name and constructor file location for a
% built-in class. Return empty name if the whichResult does not refer to a
% built-in class.
    
    import matlab.depfun.internal.requirementsConstants;

    % Does the whichResult point to a built-in constructor? Two cases:
    % 
    %  which cell
    %     'built-in (c:\work\matlab\toolbox\matlab\datatypes\cell)'
    %
    %  which gpuArray
    %     'gpuArray is a built-in method' 
    % 
    name = '';
    clsFile = '';
    if ~isempty(strfind(whichResult, requirementsConstants.BuiltInStr)) 
        [name, clsFile] = builtinClassName(whichResult);
    end
end