%PLUS Append string arrays
%   STR = STR1 + STR2 appends elements of string arrays STR1 and STR2 into
%   string array STR.
%
%   STR1 and STR2 must have compatible sizes. In the simplest cases, they
%   can be the same size or one can be a scalar. Two inputs have compatible
%   sizes if, for every dimension, the dimension sizes of the inputs are
%   either the same or one of them is 1.
%
%   Either STR1 or STR2 can be a character array, a cell array, a numeric,
%   or logical array.
%
%   Example:
%       STR1 = "data";
%       STR2 = ".tar.gz";
%       STR1 + STR2           
%
%       returns  
%
%           "data.tar.gz"
%
%   Example:
%       STR1 = ["paper1","paper2"];
%       STR2 = '.docx';
%       STR1 + STR2           
%
%       returns  
%
%           "paper1.docx"    "paper2.docx"
%
%   Example:
%       STR1 = "data";
%       STR1 + {'.dat','.tar.gz'}  
%
%       returns
%
%           "data.dat"    "data.tar.gz"
%
%   See also STRCAT, HORZCAT, JOIN, COMPOSE, PAD, INSERTBEFORE, INSERTAFTER

%   Copyright 2015-2016 The MathWorks, Inc.
