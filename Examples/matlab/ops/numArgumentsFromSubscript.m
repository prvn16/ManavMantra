%NUMARGUMENTSFROMSUBSCRIPT Number of arguments for indexing methods
%   N = NUMARGUMENTSFROMSUBSCRIPT(A,S,INDEXINGCONTEXT) returns the number of 
%   values that are returned from indexed reference statements of the form 
%   A{I}, A.f, or A(I).f, and the number of values required by indexed 
%   assignment statements, [A{I}] = B, [A.f] = B, or [A(I).f] = B.
%   
%   Arguments:
%   A - Array that is being indexed
%   S - Indexing structure, as returned by SUBSTRUCT
%   INDEXINGCONTEXT - One of the following enumerated values:
%     matlab.mixin.util.IndexingContext.Statement - Indexed reference used as a
%                                                   statement (e.g., obj.a)
%     matlab.mixin.util.IndexingContext.Expression - Indexed reference used as 
%                                                    an argument to a function
%                                                    (e.g., func(obj.a))
%     matlab.mixin.util.IndexingContext.Assignment - Indexed assignment 
%                                                    (e.g., [obj.a] = x)
%   
%   Example:
%      For array A:
%         >> A = {1 2 3;4 5 6};
%      The indexing statement:
%         >> A{1,1:3}
%      Returns three values:
%         ans =
%              1
%         ans =
%              2
%         ans =
%              3
%      The indexing operation A{1,1:3} is represented by the indexing structure:
%         >> S = substruct('{}',{1,1:3});
%      
%      The number of values returned by the indexing statement is:
%      
%         >> n = numArgumentsFromSubscript(A,S,...
%                   matlab.mixin.util.IndexingContext.Statement)
%         n =
%              3
%   
%   Overload NUMARGUMENTSFROMSUBSCRIPT in user-defined classes to customize
%   indexing behavior. Use this function to modify the number of arguments
%   MATLAB expects to be returned by overloaded subsref methods, and expects to
%   pass to overloaded subsasgn methods. 
%   
%   See also SUBSTRUCT, SUBSREF, SUBSASGN.

%   Copyright 2015 The MathWorks, Inc.
%   Built-in function.

