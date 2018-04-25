function mlxdoc(topic)
%mlxdoc Opens a live code documentation .
%   mlxdoc(topic) opens the documentation in help browser after reading the documentation from live script file.
%   Copyright 2017 The MathWorks, Inc. 
    html = internal.help.livecodedoc.getMlxDoc(topic);
    web(['text://' html], '-helpbrowser');
end
