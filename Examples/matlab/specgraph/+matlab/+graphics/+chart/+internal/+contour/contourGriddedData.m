function contourLines = contourGriddedData(x, y, z, levels, linkStrips)
%contourGriddedData ContourLine objects for grid defined on Cartesian mesh
%
%   contourLines = matlab.graphics.chart.internal.contour.contourGriddedData(x,y,z,levels)
%   returns a column vector of matlab.graphics.chart.internal.contour.ContourLine
%   objects with one element for each element of the levels vector that
%   corresponds to an actual contour line.
%
%   contourLines = matlab.graphics.chart.internal.contour.contourGriddedData(___, linkStrips)
%   uses linkStrips to determine if strips having common end point should
%   be linked together. If linkStrips is true (the default), then there
%   will be only one strip per curve. This option is slower, but may be
%   needed if the output is to be used for geometric processing. If
%   linkStrips is false, the code may run faster, but the output should be
%   used only for display.
%
%   Example
%   -------
%   [x,y,z] = peaks;
%   levels = -6:2:6;
%   contourLines = matlab.graphics.chart.internal.contour.contourGriddedData(x,y,z,levels)
%
%   See also matlab.graphics.chart.internal.contour.ContourLine

% Copyright 2014 The MathWorks, Inc.

if nargin < 5
    linkStrips = true;
end

numLevels = numel(levels);
if numLevels == 0
    contourLines = matlab.graphics.chart.internal.contour.ContourLine.empty();
else
    contourLines(numLevels,1) = matlab.graphics.chart.internal.contour.ContourLine;
end

for k = 1:numLevels
    level = levels(k);
    s = matlab.graphics.chart.generatecontourlevel(x,y,z,level);
    if isempty(s)
        contourLines(k).Level = level;
    else
        vertexData = s.LineVertices;
        stripData = s.LineStripData;
        if linkStrips
            [vertexData, stripData] ...
                = matlab.graphics.chart.internal.contour.linkLineStrips(vertexData, stripData);
        end
        contourLines(k) = matlab.graphics.chart.internal.contour.ContourLine(level, vertexData, stripData);
    end
end
contourLines = removeEmpty(contourLines);
