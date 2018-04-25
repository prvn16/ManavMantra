function fireprintbehavior(pj,callbackName)
    %FIREPRINTBEHAVIOR Fire callback for Print behavior customization
    %    Helper function for printing. Do not call directly.
     
    %   Copyright 1984-2017 The MathWorks, Inc.

    h = pj.Handles{1};
    allobj = findall(h, 'Type', 'figure', ...
                 '-or', 'Type', 'axes', ...
                 '-or', 'Type', 'polaraxes', ...
                 '-or', 'Type', 'legend', ...
                 '-or', '-isa', 'matlab.graphics.shape.internal.ScribeGrid', ...
                 '-or', '-isa', 'matlab.graphics.chart.Chart');
    for k=1:length(allobj)
        obj = allobj(k);
        if ishandle(obj) % callbacks might delete other handles
            behavior = hggetbehavior(obj,'Print','-peek');
            if ~isempty(behavior) && isprop(behavior, callbackName) && ...
                    ~isempty(get(behavior,callbackName))
                
                % provide appdata for obj to use during its print callback
                pci.DriverClass = pj.DriverClass;
                setappdata(obj,'PrintCallbackInfo',pci);
                c = onCleanup(@() rmappdata(obj,'PrintCallbackInfo'));
                
                cb = get(behavior,callbackName);
                if isa(cb,'function_handle')
                    cb(handle(obj),callbackName);
                elseif iscell(cb)
                    if length(cb) > 1
                        feval(cb{1},handle(obj),callbackName,cb{2:end});
                    else
                        feval(cb{1},handle(obj),callbackName);
                    end
                else
                    feval(cb,handle(obj),callbackName);
                end
            end
        end
    end
end
