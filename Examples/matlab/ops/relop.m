%Relational operators.
% < > Relational operators.
%     The six relational operators are <, <=, >, >=, ==, and ~=. A < B does
%     element by element comparisons between A and B and returns an array
%     with elements set to logical 1 (TRUE) where the relation is true and
%     elements set to logical 0 (FALSE) where it is not. A and B must have
%     compatible sizes. In the simplest cases, they can be the same size or
%     one can be a scalar. Two inputs have compatible sizes if, for every
%     dimension, the dimension sizes of the inputs are either the same or
%     one of them is 1.
%
% &   Element-wise Logical AND.
%     A & B is an array whose elements are logical 1 (TRUE) where both A
%     and B have non-zero elements, and logical 0 (FALSE) where either has
%     a zero element. A and B must have compatible sizes. In the simplest
%     cases, they can be the same size or one can be a scalar. Two inputs
%     have compatible sizes if, for every dimension, the dimension sizes of
%     the inputs are either the same or one of them is 1.
%
% &&  Short-Circuit Logical AND.
%     A && B is a scalar value that is the logical AND of scalar A and B.
%     This is a "short-circuit" operation in that MATLAB evaluates B only
%     if the result is not fully determined by A. For example, if A equals
%     0, then the entire expression evaluates to logical 0 (FALSE), regard-
%     less of the value of B.  Under these circumstances, there is no need
%     to evaluate B because the result is already known.
%
% |   Element-wise Logical OR.
%     A | B is an array whose elements are logical 1 (TRUE) where either A
%     or B has a non-zero element, and logical 0 (FALSE) where both have
%     zero elements. A and B must have compatible sizes. In the simplest
%     cases, they can be the same size or one can be a scalar. Two inputs
%     have compatible sizes if, for every dimension, the dimension sizes of
%     the inputs are either the same or one of them is 1.
%
% ||  Short-Circuit Logical OR.
%     A || B is a scalar value that is the logical OR of scalar A and B.
%     This is a "short-circuit" operation in that MATLAB evaluates B only
%     if the result is not fully determined by A. For example, if A equals
%     1, then the entire expression evaluates to logical 1 (TRUE), regard-
%     less of the value of B.  Under these circumstances, there is no need 
%     to evaluate B because the result is already known.
%
% ~   Logical complement (NOT).
%     ~A is an array whose elements are logical 1 (TRUE) where A has zero
%     elements, and logical 0 (FALSE) where A has non-zero elements.
%
% xor Exclusive OR.
%     xor(A,B) is logical 1 (TRUE) where either A or B, but not both, is 
%     non-zero.  See XOR.

%   Copyright 1984-2015 The MathWorks, Inc.
