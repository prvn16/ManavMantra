function [e, c] = parseCData(c, datalength)
import matlab.graphics.chart.primitive.utilities.CDataShape

e = [];
[c_rows,c_cols] = size(c);
if c_rows == datalength && c_cols == 1
    % Mx1 colormapped vector
    e = CDataShape.ColorMapped;
elseif c_rows == 1 && c_cols == 3
    % 1x3 RGB triplet
    e = CDataShape.ConstantColor;
elseif c_rows == 1 && c_cols == datalength
    % 1xM colormapped vector (1x3 RBG triplet takes precedence if M=3)
    e = CDataShape.ColorMapped;
    c = transpose(c);
elseif c_rows == datalength && c_cols == 3
    % Mx3 truecolor matrix
    e = CDataShape.TrueColor;
elseif c_rows == 1 && c_cols == 1
    % 1x1 colormapped scalar
    e = CDataShape.ColorMappedScalar;
end