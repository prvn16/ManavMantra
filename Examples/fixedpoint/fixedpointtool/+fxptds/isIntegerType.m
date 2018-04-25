function isIntTypeStr = isIntegerType(dataTypeStr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isIntTypeStr = regexpi(dataTypeStr, '^(int|uint)(8|16|32)$', 'ONCE');