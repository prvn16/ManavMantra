function Out = set(h,varargin)
%SET  Set properties of event object.
%
%   SET(H,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the timemetadata object H to the value VALUE.  An equivalent syntax 
%   is 
%       H.PropertyName = VALUE
%
%   SET(H,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   event property values with a single statement.
%
%   SET(H,'Property') displays values for the specified property in H.
%
%   SET(H) displays all properties of H and their values. 
%
%   See also TIMEMETADATA\GET.

%   Copyright 2006-2016 The MathWorks, Inc.

ni = nargin;
no = nargout;
if ~isa(h,'tsdata.timemetadata')
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',h,varargin{:});
   return
elseif no && ni>2
   error(message('MATLAB:tsdata:timemetadata:set:invSyntax'));
end

% Get public properties and their assignable values
allProps = fieldnames(h);
if ni<=2
   propValues = cell(1,length(allProps));
   for k=1:length(allProps)
       propValues{k} = h.(allProps{k});
   end
   asgnValues = tspvformat(propValues);   
end

% Handle read-only cases
if ni==1
   % SET(H) or S = SET(H)
   if no
      Out = cell2struct(asgnValues,allProps,1);
   else
      disp(tspvformat(allProps,asgnValues))
   end
elseif ni==2
   % SET(H,'Property') or STR = SET(H,'Property')
   % Return admissible property value(s)
   try
      [~,imatch] = tspnmatch(varargin{1},allProps,10);
      if no
         Out = asgnValues{imatch};
      else
         disp(asgnValues{imatch})
      end
   catch me
      rethrow(me)
   end
   
else
   % SET(H,'Prop1',Value1, ...)
   ename = inputname(1);
   if isempty(ename)
      error(message('MATLAB:tsdata:timemetadata:set:badVar'))
   elseif rem(ni-1,2)~=0
      error(message('MATLAB:tsdata:timemetadata:set:invPropValPairs'))
   end
   
   % Match specified property names against list of public properties and
   % set property values at object level
   % RE: a) Include all properties to appropriately detect multiple matches
   %     b) Limit comparison to first 10 chars (because of qualityinfo)
   try
      for i=1:2:ni-1
         varargin{i} = tspnmatch(varargin{i},allProps,10);
         h.(tspnmatch(varargin{i},allProps,10)) = varargin{i+1};
      end        
   catch me
      rethrow(me)
   end
   
   % Assign ts in caller's workspace
   assignin('caller',ename,h)
   
end


