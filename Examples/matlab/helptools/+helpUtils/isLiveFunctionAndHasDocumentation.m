function b = isLiveFunctionAndHasDocumentation(topic)
%isLiveFunction Checks if the live file contains documentation.
%   isLiveFunction(topic) Checks using topic as file path.
%   Copyright 2017 The MathWorks, Inc. 
      docXML = helpUtils.getDocumentationXML(topic);
      b = ~isempty(char(docXML)); 
end
 