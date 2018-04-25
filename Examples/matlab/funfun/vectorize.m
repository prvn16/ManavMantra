function v = vectorize(s)
%VECTORIZE Vectorize expression.
%   VECTORIZE(S), when S is a string expression, inserts a '.' before
%   any '^', '*' or '/' in S.  The result is a character string.
%
%   VECTORIZE will not accept INLINE function objects in a future
%   release. Use anonymous functions and FUNC2STR instead.
%
%   VECTORIZE(FUN), when FUN is an INLINE function object, vectorizes the
%   formula for FUN.  The result is the vectorized version of the INLINE
%   function.
%
%   See also INLINE/FORMULA, INLINE, FUNCTION_HANDLE.

%   Copyright 1984-2012 The MathWorks, Inc. 

v = char(s);
if isempty(v)==1
    v = [];
else    
    % Remove extra . in case of already vectorized operations
    v = strrep(v,'.*','*');
    v = strrep(v,'./','/');
    v = strrep(v,'.^','^');
    
    % Add . to vectorize *, / and ^ operations
    v = strrep(v,'*','.*');
    v = strrep(v,'/','./');
    v = strrep(v,'^','.^');
end


