function showExample(arg)
% 
%   Copyright 2017 The MathWorks, Inc. 

metadata = findExample(arg);
id = metadata.id;

htmlFile = com.mathworks.mlwidgets.help.examples.ExampleLinkRetriever.getDocUrlForExampleId(id);

% Display the results.
if ~isempty(htmlFile)
    web(char(htmlFile));
end

