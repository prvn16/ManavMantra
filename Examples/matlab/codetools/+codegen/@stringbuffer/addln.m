function addln(hText,str)
% Append new line of text 

% Copyright 2006 The MathWorks, Inc.

t = get(hText,'Text');

% Convert to cell string if not already
if ~iscellstr(str)
   str = {str};
end

if length(t)>0
    set(hText,'Text',{t{:},str{:}});
else
    set(hText,'Text',str);
end