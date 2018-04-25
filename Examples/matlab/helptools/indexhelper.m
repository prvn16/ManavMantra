function indexhelper(demosroot,source,callback,product,label,file)
% INDEXHELPER A helper function for the demos index page.

% Matthew J. Simoneau, January 2004
% Copyright 1984-2011 The MathWorks, Inc.

% Remove escaping.
if (nargin > 0)
    demosroot = decode(demosroot);
end
if (nargin > 1)
    source = decode(source);
end
if (nargin > 2)
    callback = decode(callback);
end
if (nargin > 3)
    product = decode(product);
end
if (nargin > 4)
    label = decode(label);
end
if (nargin > 5)
    file = decode(file);
end

if isempty(callback)
    callback = source;
end
if isempty(file)
   body = '';
   base = '';
else
   fullpath = fullfile(demosroot,file);
   f = fopen(fullpath);
   if (f == -1)
      error(message('MATLAB:indexhelper:OpenFailed', fullpath));
   end
   body = fread(f,'char=>char')';
   fclose(f);
   base = ['file:///' fullpath];
end
   
if isempty(callback)
   web(fullpath,'-helpbrowser')
else
   demowin(callback,product,label,body,base,{})
end

%===============================================================================
function label=decode(label)

% For some reason, the browser doesn't encode "+", so we must do it here.
label = strrep(label,'+','%2B');
% Decode any Unicode characters that the browser encoded.
label = char(java.net.URLDecoder.decode(char(label),'UTF-8'));
