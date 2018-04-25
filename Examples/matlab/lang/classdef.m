%CLASSDEF Define new class or sub-class.
%   The keyword CLASSDEF denotes the start of a MATLAB class
%   definition.  The MATLAB language defines classes including
%   double, logical, struct, and cell.  These classes control
%   how values stored in variables behave, including how they
%   are displayed and allowed forms of indexing.
%
%   You can use class definitions to add new classes or add
%   specialized sub-classes based on existing classes.
%
%   CLASSDEF begins a block terminated by END.  Only white
%   space and comments can precede the class definition.
%
%   You must place a class definition in a file with the same
%   name as the class, with a filename extension of '.m'.
%
%   Example:
%   %Create a class named payment, placed in file 'payment.m'
%   classdef payment
%       properties
%           rate;
%           term;
%           principle;
%       end
%       methods
%           function obj = payment(r,t,p)
%               obj.rate = r;
%               obj.term = t;
%               obj.principle = p;
%           end
%           function disp(obj)
%               i = obj.rate/(12*100);
%               payAmt = (obj.principle * i)/(1 - (1+i)^(-obj.term));
%               s = sprintf('%s%.2f%s%4.2f%s%.2f%s%d%s',...
%                   'Payment per month on a loan of $', obj.principle,...
%                   ' at an annual interest rate of ', obj.rate,...
%                   '% is $', payAmt, ' for ', obj.term, ' months.');
%               disp(s);
%           end
%       end
%   end
%
%   See also PROPERTIES, METHODS, EVENTS.

%   Copyright 2007 The MathWorks, Inc. 
