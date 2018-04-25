function add(hText,str)
% Append text to last line of text

% Copyright 2006-2007 The MathWorks, Inc.

if iscellstr(str)
  error(message('MATLAB:codegen:stringbuffer:invalidInput'))
end

t = get(hText,'Text');
t{end} = [t{end},str];
set(hText,'Text',t);