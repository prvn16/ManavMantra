function evalInputArray = inputPreProc(preprocfunc,inputvals)

% Copyright 2009 The MathWorks, Inc.

persistent preprocessingCache;

cachedLasterror = lasterror;
try
    for k=1:length(inputvals)
        inp = inputvals{k};
        if k<=length(preprocessingCache) && ...
                isequal(preprocessingCache(k).preprocfunc,preprocfunc) && ...
                isequal(inp,preprocessingCache(k).rawinput)
            inputvals{k} = preprocessingCache(k).processedinput;
        else    
            processedInput = feval(preprocfunc,inp);
            if k==1
               preprocessingCache = struct('preprocfunc',{preprocfunc},'rawinput',...
                  {inp},'processedinput',{processedInput}); 
            else
               preprocessingCache(k) = struct('preprocfunc',{preprocfunc},'rawinput',...
                 {inp},'processedinput',{processedInput});
            end
            inputvals{k} = processedInput;
        end
    end
    evalInputArray = inputvals;
catch
    evalInputArray = [];
    lasterror(cachedLasterror);
end
    