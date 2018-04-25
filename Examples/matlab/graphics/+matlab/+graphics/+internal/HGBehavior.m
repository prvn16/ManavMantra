
%   Copyright 2013-2017 The MathWorks, Inc.

classdef HGBehavior < matlab.mixin.SetGet & matlab.mixin.Heterogeneous
   % This internal class which may be removed in a future release.
   % Abstract Base class for behavior objects. 
   % This is to support concatenation of behavior objects
   % Defining an abstract method dosupport
   methods (Abstract)
       dosupport(~,hTarget)
   end
   methods (Static)
       function deserializeBehaviorsStruct(obj, behaviors)
           b = [];
           for n = 1:length(behaviors)
               try
                   b(n) = feval(behaviors(n).class);
                   set(b(n), behaviors(n).properties);
               end
           end
           for n = 1:length(b)
               hgaddbehavior(obj, b(n));
           end 
       end       
   end
end
