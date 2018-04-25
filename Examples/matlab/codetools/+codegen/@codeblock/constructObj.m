function varargout = constructObj(hThis,momento,code_parent)
% Recursively traverse momento hierarchy and create a parellel
% hierarchy of code objects. Each code object encapsulates 
% the constructor and helper functions.

%   Copyright 2007-2014 The MathWorks, Inc.

% Create code object
set(hThis,'MomentoRef',momento);
if nargin == 3
    % Add code object to hierarchy
    addChildren(code_parent,hThis);
end

% Get children first
momento_kids = findobj(momento,'-depth',1);

% First kid is always self, so ignore index 1
for n = 2:length(momento_kids)
    % Recurse down to children
    hChil = codegen.codeblock;
    constructObj(hChil,momento_kids(n),hThis);
end

hObj = get(momento,'ObjectRef');
if ~isempty(hObj) && ishandle(hObj) && ~get(momento,'Ignore')
    local_populate_code_object(hThis,hObj);
end

if nargout==1
   varargout{1} = hThis;
end

%----------------------------------------------------------%
function local_populate_code_object(hCode,hObj)
% Generate constructor

% If HGObject, delegate to behavior object
flag = true;
if ishghandle(hObj)

    % Check app data
    info = getappdata(hObj,'MCodeGeneration');
    if isstruct(info) && isfield(info,'MCodeConstructorFcn')
        fcn = info.MCodeConstructorFcn;
        if ~isempty(fcn)
            hgfeval(fcn,hObj,hCode);
            flag = false;
        end
        
    % Check behavior object  
    else
        hb = hggetbehavior(hObj,'MCodeGeneration','-peek');
        if ~isempty(hb)
            fcn = get(hb,'MCodeConstructorFcn');
            if ~isempty(fcn)
                hgfeval(fcn,hObj,hCode);
                flag = false;
            end
        end
    end
end

% special work around for method dispatching bug geck 200436
if flag && strcmp(class(hObj),'graph2d.lineseries')
    codetoolsswitchyard('mcodeConstructorLineSeries',hObj,hCode);
    flag = false;
end

% delegate to object if it implements interface
if flag  
  if internal.matlab.codetools.isMethod(hObj,'mcodeConstructor')
      mcodeConstructor(hObj,hCode);
  else
      % private function
      codetoolsswitchyard('mcodeDefaultConstructor',hObj,hCode); 
  end
end
