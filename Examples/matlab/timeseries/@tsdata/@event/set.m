function Out = set(e,varargin)
%SET  Set properties of event object.
%
%   SET(E,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the event E to the value VALUE.  An equivalent syntax 
%   is 
%       E.PropertyName = VALUE
%
%   SET(E,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   event property values with a single statement.
%
%   SET(E,'Property') displays values for the specified property in E.
%
%   SET(E) displays all properties of E and their values. 
%
%   See also EVENT\GET.

%   Copyright 2006-2011 The MathWorks, Inc.

ni = nargin;
no = nargout;
if ~isa(e,'tsdata.event'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',e,varargin{:});
   return
elseif no && ni>2,
   error(message('MATLAB:tsdata:event:set:invOutArg'));
end

% Get public properties and their assignable values
if ni<=2,
   AllProps = fieldnames(e);  
   PropNames = fieldnames(struct(e));
   PropValues = struct2cell(struct(e));
   AsgnValues = tspvformat(PropValues(1:length(PropNames)));   
else
   % Add obsolete property Td   
   AllProps = fieldnames(e);
end


% Handle read-only cases
if ni==1,
   % SET(E) or S = SET(E)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      disp(tspvformat(AllProps,AsgnValues))
   end
elseif ni==2,
   % SET(E,'Property') or STR = SET(E,'Property')
   % Return admissible property value(s)
   try
      [Property,imatch] = tspnmatch(varargin{1},AllProps,10);
      if no,
         Out = AsgnValues{imatch};
      else
         disp(AsgnValues{imatch})
      end
   catch me
      rethrow(me)
   end
   
else
   % SET(E,'Prop1',Value1, ...)
   ename = inputname(1);
   if isempty(ename),
      error(message('MATLAB:tsdata:event:set:invVarArg'))
   elseif rem(ni-1,2)~=0,
      error(message('MATLAB:tsdata:event:set:invPropValPairs'))
   end
   
   % Match specified property names against list of public properties and
   % set property values at object level
   % RE: a) Include all properties to appropriately detect multiple matches
   %     b) Limit comparison to first 10 chars (because of qualityinfo)
   try
      for i=1:2:ni-1,
         varargin{i} = tspnmatch(varargin{i},AllProps,10);
         e.(tspnmatch(varargin{i},AllProps,10)) = varargin{i+1};
      end        
   catch me
      rethrow(me)
   end
   
   % Assign ts in caller's workspace
   assignin('caller',ename,e)
   
end


