function comeventcallback(hSrc, hEvent, userMfileName)

args = hEvent.get;
vals = struct2cell(args);
numargs = size(vals, 1);

% arguments must be passed to the MATLAB file in the following order
%1 - object (com,progid) - vals{2}
%2 - event id - vals{3}
%(3:end-2) - event args - vals{4:end}
%end-1 args - all of above for users to know about event args names
%end - event name - vals{1}

% Copyright 1984-2010 The MathWorks, Inc.

if (numargs >= 4)
    try
        feval(userMfileName, vals{2}, vals{3}, vals{4:end}, args, vals{1});
    catch
        if (isa(userMfileName, 'function_handle'))
            userMfileName = func2str(userMfileName);
        end

        error(message('MATLAB:comeventcallback:EventFiring', vals{ 1 }, userMfileName))
    end    
else 
    try
        feval(userMfileName, vals{2}, vals{3}, args, vals{1});
    catch
        if (isa(userMfileName, 'function_handle'))
            userMfileName = func2str(userMfileName);
        end    
                
        error(message('MATLAB:comeventcallback:EventFiring', vals{ 1 }, userMfileName))
    end
end
