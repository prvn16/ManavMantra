function toMCode(hCodeLine,hText)
% Generates code based on input codetext object

% Copyright 2006-2015 The MathWorks, Inc.

var = get(hCodeLine,'Text');
txt = [];
for n = 1:length(var)
    val = var{n};
    if ischar(val)
        txt = [txt,val];
    elseif isa(val, 'message')
        % Convert message objects to strings
        txt = [txt, getString(val)];
    else
        hObj = val;
        if ~isprop(hObj,'Ignore') || ~get(hObj,'Ignore')
            try
                txt = [txt,get(hObj,'String')];
            catch
            end
        end
    end
end

hText.addln(txt);
