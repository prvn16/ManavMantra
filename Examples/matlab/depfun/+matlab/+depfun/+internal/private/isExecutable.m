function tf = isExecutable(file)
% isExecutable Is file executable (based on extension).
% FILE is a single string of a file name. Performance really
% matters, as this function may be called thousands or millions of times.
% Therefore, the code is not as compact as it otherwise might be.

    import matlab.depfun.internal.requirementsConstants
    
    tf = false;    
    ext = extension(file);
    if ~isempty(ext)
        tf = ismember(ext, ...
             requirementsConstants.executableMatlabFileExt_reverseOrder);        
    end
end
