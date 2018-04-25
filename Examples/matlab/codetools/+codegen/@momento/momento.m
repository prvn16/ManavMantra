classdef momento < matlab.mixin.SetGet & matlab.mixin.Copyable & matlab.mixin.internal.TreeNode
    %codegen.momento class
    
    properties
        Name
        ObjectRef
        PropertyObjects =[]
        Ignore = false;
    end
    
    
    methods  % constructor block
        function hThis = momento(varargin)
            % Constructor for the momento object.
            % Traverse mcos hierarchy and create a parallel
            % hierarchy of momento objects which encapsulate visible,
            % non-default properties
            
            % Syntax: codegen.momento(h,options)
            %         codegen.momento(h,options,momento_parent)
            
            if ~isempty(varargin)
                hThis = local_construct_obj(varargin{:});
            end
            
        end
        
         % returns the parent of the object - for backward UDD
        % compatibility 
        function hPar = up(hThis)
            hPar = hThis.getParent();
        end
        
         % returns the parent of the object - for backward UDD
        % compatibility 
        function hChild = down(hThis)
            hChild = hThis.getFirstChild();
        end        
    end  % momento
end  % classdef

function varargout = local_construct_obj(h,options,momento_parent)
% Get this object's children
h = handle(h);
if ~local_does_support_codegen(h)
    return;
end

hNew = codegen.momento;
if nargin == 3
    % Add momento object to hierarchy
    momento_parent.addChildren(hNew);
    % hNew.connect(momento_parent,'up');
end

if isa(h, 'matlab.graphics.Graphics')
    kids = findall(h,'-depth',1);
    % If we have an axes check the decoration container for possible other
    % objects needing code generation. (e.g. Baseline) g826158
    if ishghandle(h,'axes')
        trueCh = findobjinternal(h.DecorationContainer,'-method','mcodeConstructor','-depth',inf);
        kids = [kids;trueCh];
    end
elseif ishandle(h)
    kids = findobj(h,'-depth',1);
else
    error(message('MATLAB:codegen:momento:invalidHandle'))
end

% remove this object from the resulting list of objects
kids(kids==h) = [];

% Determine traversal direction
if ~options.ReverseTraverse
    kids = flipud(kids);
end

% Recurse down to the children, ignoring this object
for n = 1:length(kids)
    kid = kids(n);
    
    % If object wants its child to be represented in code, then
    % recurse down.
    if ~local_mcodeIgnore(h,kid)
        % Create momento object and recurse down to children
        local_construct_obj(kid,options,hNew);
    end
    
end % for

if ~local_mcodeIgnore(h,h)
    % Populate momento object with visible non-default
    % properties corresponding to object, h
    local_populate_momento_object(hNew,h,options);
end

if nargout == 1
    varargout{1} = hNew;
end
end  % local_construct_obj

%----------------------------------------------------------%
function retval = local_does_support_codegen(h)
% Object must be an HG primitives or implement the mcode generation
% interface

retval = internal.matlab.codetools.isMethod(h,'mcodeConstructor') ...
    || internal.matlab.codetools.isMethod(h,'mcodeIgnoreHandle');
if ~retval && ishghandle(h)
    if isa(h, 'matlab.graphics.Graphics')
        retval = true;
    else
        retval = strcmp(get(get(classhandle(h),'Package'),'Name'),'hg');
    end
end
end  % local_does_support_codegen


%----------------------------------------------------------%
function local_populate_momento_object(momento,h,options)
% Add property info to momento object

% Create a set of information accessor functions that are tailored to this
% object.  This saves testing object-level state for every property.
InfoFuncs = createInfoAdapter(h);

if isa(h, 'matlab.graphics.Graphics')
    % We will need richer constructor name handling in the future.
    % For now...
    cls = metaclass(h);
    package = cls.ContainingPackage;
    if isempty(package)
        constr = cls.Name;
    else
        constr = lower(cls.Name(length(package.Name)+2:end));
    end
    allprops = cls.PropertyList;
else
    constr = h.classhandle.Name;
    cls = classhandle(h);
    allprops = cls.Properties;
end
set(momento,'Name',constr);
set(momento,'ObjectRef',h);

% Loop through property objects
for n = length(allprops):-1:1
    prop = allprops(n);
    
    % Test whether property should be generated
    if ~InfoFuncs.IgnoreProperty(h, prop)
        prop_name = prop.Name;
        
        % Store property info
        pobj = codegen.momentoproperty;
        set(pobj,'Name',prop_name);
        
        % If the property is a handle, recurse to its properties. If the
        % property name is "Parent", it must be treated differently,
        % otherwise there is a danger of an infinite loop. Make sure to
        % skip objects with their own constructors and values
        % corresponding to figure windows and the root object (0).
        prop_val = get(h,prop_name);
        if ~istall(prop_val) && (isscalar(prop_val) && ishandle(prop_val) && ...
                ~strcmpi(prop_name,'Parent') && ...
                ~ishghandle(prop_val, 'figure') && ...
                ~ishghandle(prop_val, 'root') && ...
                ~internal.matlab.codetools.isMethod(prop_val,'mcodeConstructor'))
            set(pobj,'Value',local_construct_obj(handle(prop_val),options));
        else
            set(pobj,'Value',prop_val);
        end
        set(pobj,'Object',prop);
        
        % Determine if the property should be an input argument to
        % the function
        set(pobj,'IsParameter',InfoFuncs.IsParameter(h, prop));
        
        tmp = get(momento,'PropertyObjects');
        set(momento,'PropertyObjects',[tmp,pobj]);
    end
end
end  % local_populate_momento_object



%----------------------------------------------------------%
function SFuncs = createInfoAdapter(hObj)

% Build up a list of can-be-ignored checks to do.  The order of these
% checks is important and should not be altered.  The function handle is
% created as a chain-of-responsibility, with each new test passing on
% control to the previously defined test if it needs to.  The tests are built up in
% reverse order and the chain terminates with this default "false" answer.
IgnorePropTests = @(h, prop) false;

if isa(hObj, 'matlab.graphics.Graphics')
    % Special case for Graphics objects - check the defaults
    IgnorePropTests = @(h, prop) local_mcodeIgnoreHGProperty(h,prop) || IgnorePropTests(h, prop);
elseif isa(hObj, 'handle.handle')
    % All older objects test the factory value
    IgnorePropTests = @(h, prop) isequal(get(h, prop.Name), prop.FactoryValue) || IgnorePropTests(h, prop);
end

% All objects use the default implementation of mcodeIgnoreProperty
IgnorePropTests= @(h, prop) codetoolsswitchyard('mcodeDefaultIgnoreProperty',h,prop) || IgnorePropTests(h, prop);

if internal.matlab.codetools.isMethod(hObj,'mcodeIgnoreProperty')
    % Add a delegation to object if it implements the mcodeIgnoreProperty interface
    IgnorePropTests = @(h, prop) mcodeIgnoreProperty(h, prop) || IgnorePropTests(h, prop);
end

% Add tests that check whether property is Visble and publically
% accessible.  These tests are the first ones performed when the
% IgnorePropTests function handle is called.
if isa(hObj, 'handle.handle')
    IgnorePropTests = @(h, prop) (strcmp(prop.Visible,'off') ...
        || strcmp(prop.AccessFlags.PublicSet,'off') ...
        || strcmp(prop.AccessFlags.PublicGet,'off') ...
        || IgnorePropTests(h, prop));
else
    IgnorePropTests = @(h, prop) (prop.Hidden ...
        || ~strcmp(prop.SetAccess,'public') ...
        || ~strcmp(prop.GetAccess,'public') ...
        || IgnorePropTests(h, prop));
end

% Return the function call which applies the list of ignore tests
SFuncs.IgnoreProperty = IgnorePropTests;

% Return a function that tests whether a property should be a parameter
if internal.matlab.codetools.isMethod(hObj,'mcodeIsParameter')
    SFuncs.IsParameter = @mcodeIsParameter;
else
    SFuncs.IsParameter = @(h, prop) codetoolsswitchyard('mcodeDefaultIsParameter',h,prop);
end
end  % createInfoAdapter


%----------------------------------------------------------%
function bool = local_mcodeIgnore(h1,h2)
% Determine whether we should query object

% If HGObject, delegate to behavior object
flag = true;
if ishghandle(h1)
    
    % Check app data
    info = getappdata(h1,'MCodeGeneration');
    if isstruct(info) && isfield(info,'MCodeIgnoreHandleFcn')
        fcn = info.MCodeIgnoreHandleFcn;
        if ~isempty(fcn)
            bool = hgfeval(fcn,h1,h2);
            flag = false;
        end
        
        % Check behavior object
    else
        % ToDo: Consider deprecating use of behavior object since it is
        % a performance hit at creation time.
        hb = hggetbehavior(h1,'MCodeGeneration','-peek');
        if ~isempty(hb)
            fcn = get(hb,'MCodeIgnoreHandleFcn');
            if ~isempty(fcn)
                bool = hgfeval(fcn,h1,h2);
                flag = false;
            end
        end
    end
end

% Delegate to object if it implements interface
if flag
    if internal.matlab.codetools.isMethod(h1,'mcodeIgnoreHandle')
        bool = mcodeIgnoreHandle(h1,h2);
    else
        bool = codetoolsswitchyard('mcodeDefaultIgnoreHandle',h1,h2);
    end
end
end  % local_mcodeIgnore


%----------------------------------------------------------%
function bool = local_mcodeIgnoreHGProperty(hObj,hProp)
% Ignore HG properties generic to all GObjects

bool = false;

prop_name = hProp.Name;
instance_value = get(hObj,prop_name);
if isprop(hObj,'Type')
    obj_name = get(hObj,'Type');
else
    obj_name = class(hObj);
end
default_prop_name = ['Default',obj_name,prop_name];
has_hg_default = false;

% If the object is an hg primitive (or subclass), ignore
% the value of the property if it is an HG root default.
if ~ishghandle(hObj,'hggroup')
    % Can't use FINDPROP here to test for property since some
    % root properties are not registered with UDD.
    % When that is fixed, the try/end can be removed.
    try
        default_value = local_getDefaultValue(prop_name, default_prop_name);
        has_hg_default = true;
        bool = (isempty(default_value) && isempty(instance_value)) || isequal(default_value,instance_value);
    catch anError %#ok<NASGU> We don't need to use the error object.  Move on.
    end
end

% Ignore property if value is a UDD default
if ~bool && ~has_hg_default && hProp.HasDefault
    factory_value = hProp.DefaultValue;
    bool = ~istall(hProp.DefaultValue) && ((isempty(factory_value) && isempty(instance_value)) || isequal(factory_value,instance_value));
end
end  % local_mcodeIgnoreHGProperty


%----------------------------------------------------------%
function default = local_getDefaultValue(prop_name, default_prop_name)
if any(strcmp(prop_name, {'UIContextMenu', 'CurrentObject', 'CurrentAxes', ...
        'Parent', 'XLabel', 'YLabel', 'ZLabel', 'XGridHandle', 'YGridHandle', 'ZGridHandle', ...
        'Title'}))
    default = [];
else
    default = get(0,default_prop_name);
end
end  % local_getDefaultValue

