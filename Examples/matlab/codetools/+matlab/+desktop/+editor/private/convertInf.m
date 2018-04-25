function val = convertInf(input, variablename)
% convertInf Convert INF and -INF to Java MIN and MAX Integers.

% Copyright 2010-2011 The MathWorks, Inc.

try
    matlab.desktop.editor.EditorUtils.assertNumericScalar(input, variablename);
    if input == inf
        val = java.lang.Integer.MAX_VALUE;
    elseif input == -inf
        val = java.lang.Integer.MIN_VALUE;
    else
        val = input;
    end
catch ex
    throwAsCaller(ex);
end

end
