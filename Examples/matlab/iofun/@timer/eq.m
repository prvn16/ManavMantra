function [iseq, heq] = eq(arg1, arg2)
%EQ ==  Equal.
%
%    C = EQ(A,B) does element by element comparisons between timer objects
%    A and B and returns a logical indicating if they refer to the 
%    same timer objects. 
%
%    Note: EQ is automatically called for the syntax 'A == B'.
%
%    See also TIMER/NE, TIMER/ISEQUAL
%

%    Copyright 2001-2017 The MathWorks, Inc.

heq = eq@handle(arg1,arg2);
iseq = heq;
if isa(arg1,'timer')
    arg1Valids = arg1.isvalid();
    iseq = iseq & arg1Valids;
end

if isa(arg2,'timer')
    arg2Valids = arg2.isvalid();
    iseq = iseq & arg2Valids;
end
