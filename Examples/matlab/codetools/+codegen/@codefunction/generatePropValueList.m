function hNewFuncs = generatePropValueList(hFunc, hPropList, CommentName, hObjectArg)
%generatePropValueList  Add a sequence of property-value pairs to a function call
%
%  generatePropValueList(Func, PropList, CommentName) adds a set of
%  property-value pairs to the function Func.  PropList must be a vector of
%  codegen.momentoproperty objects which provide the property names and
%  values.  CommentName is a string that is used to generate argument
%  comments and should refer to the name of the object that the properties
%  are for.  If CommentName is omitted, and empty string is used for this
%  part of the description.
%
%  generatePropValueList(Func, PropList, CommentName,  hObjectArg)
%  specifies a codeargument which represents the object that the properties
%  will be set on.  If any of the momentoproperty values is itself a
%  momento and this argument is specified, then this function will generate
%  function calls that first get that property value from the object and
%  then set the new momento's values on it. The additional function calls
%  that this generates will be returned as a vector of new
%  codegen.codefunction objects.  It is the user's responsibility to add
%  these extra function calls to the code being generated.

% Copyright 2003-2015 The MathWorks, Inc.

if nargin<4
    hObjectArg = [];
end
if nargin<3
    CommentName = '';
end

hNewFuncs = [];

n_props = length(hPropList);
for n = 1:n_props
   hProp = hPropList(n);
   
   if ~hProp.Ignore
      PropName = hProp.Name;
      PropValue = hProp.Value;
      
      if isa(PropValue,'codegen.momento')
          % If the value is a momento object, we need to create a new
          % post-constructor function which calls the SET method. There is
          % an assumption that the constructor will have generated a valid
          % handle for us to use.
          
          if ~isempty(hObjectArg)
              % Add Input arguments, recursing to the next level of nesting.
              hSubPropList = get(PropValue,'PropertyObjects');
              
              % Create an argument object to represent the intermediate object
              hPropObjectArg = codegen.codeargument('Name',PropName,...
                  'IsParameter',true,...
                  'IsOutputArgument',true, ...
                  'Value',PropValue.ObjectRef);
              
              % Try to generate the next call to set.  It will return an
              % empty if there was nothing to do.
              hSetFuncs = codegen.codefunction.createSetCall(hPropObjectArg, hSubPropList, PropName);
              
              if ~isempty(hSetFuncs)                  
                  % Create the call to get the object that these new
                  % functions depend on
                  hGetFunc = codegen.codefunction;
                  hGetFunc.Name = 'get';
                  hGetFunc.addArgin(hObjectArg);
                  hGetFunc.addArgin(codegen.codeargument('Value', PropName));
                  hGetFunc.addArgout(hPropObjectArg);
                  
                  hNewFuncs = [hNewFuncs, hGetFunc, hSetFuncs];
              end
          else
              % Ignore momento properties if there is no source object to
              % get the base property value from
          end
          
      else
          hPropName = codegen.codeargument('Value',PropName,'ArgumentType',codegen.ArgumentType.PropertyName);
          hPropValue = codegen.codeargument(...
              'Name', PropName, ...
              'Value', PropValue, ...
              'ArgumentType',codegen.ArgumentType.PropertyValue, ...
              'IsParameter', hProp.IsParameter, ...
              'DataTypeDescriptor', hProp.DataTypeDescriptor, ...
              'Comment', sprintf('%s %s', CommentName, PropName));
          
          hFunc.addArgin(hPropName);
          hFunc.addArgin(hPropValue);
      end
   end
end
