function setProfilerHtmlText(htmlText)
%SETPROFILERHTMLTEXT Pass the generated profiler HTML text to Java

% Copyright 2016 The MathWorks, Inc.

import com.mathworks.mde.profiler.Profiler;
Profiler.setHtmlText(htmlText);
end