%UMINUS Negate elements of fi object array
%   UMINUS(A) is called for the syntax '-A' when A is an object. -A negates
%   the elements of A. UMINUS does not support fi objects of data type 
%   Boolean.
%   
%   Example: Different results of negation in different overflow modes
%     % Note that when wrap occurs -(-1) = -1
%     % When saturation occurs -(-1) = 0.99..
%     fipref('NumericTypeDisplay','short','fimathDisplay','none');
%     format short g
%     a = fi(-1,true,8,7,'OverflowAction','Wrap')
%     % first for wrap mode 
%     -a
%     % returns -1
%     b = fi([-1-i -1-i],true,8,7,'OverflowAction','Wrap')
%     -b
%     % [-1-i -1-i]
%     b'
%     % [-1-i; -1-i]
%     c = fi(-1,true,8,7,'OverflowAction','Saturate')
%     % in this case with saturate mode
%     -c
%     % 0.99219
%     d = fi([-1-i -1-i],true,8,7,'OverflowAction','Saturate')
%     -d
%     % [0.99219 + 0.99219i  0.99219 + 0.99219i]
%     d'
%     % [-1 + 0.99219i  -1 + 0.99219i]
%
%   See also EMBEDDED.FI/PLUS, EMBEDDED.FI/MINUS, EMBEDDED.FI/MTIMES,  
%            EMBEDDED.FI/TIMES

%   Copyright 1999-2012 The MathWorks, Inc.
