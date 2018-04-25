function getdisp(obj)

try % display the builtin get's output
    out = get(obj.getJobjects);
    disp(out);
catch exception
    if ~all(isvalid(obj))
        % if given at least one invalid object, bail out now with error.        
        error(message('MATLAB:timer:invalid'));
    else
        throw(fixexception(exception));
    end    
end
