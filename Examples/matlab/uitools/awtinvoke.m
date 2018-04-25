function result = awtinvoke(obj, varargin)
% This function is undocumented and will change in a future release

%AWTINVOKE Invoke a Java method on the AWT event thread
%   This function is an internal helper function and will
%   likely change in a future release.
%
%   AWTINVOKE(OBJ,METHOD) asynchronously executes on the Java AWT
%   event dispatching thread the method named METHOD of Java object
%   OBJ. The method must not allow any arguments. Multiple calls to
%   AWTINVOKE execute on the AWT thread in the order that MATLAB
%   executed. To execute a static method pass in the fully qualified
%   class name as OBJ.
%
%   AWTINVOKE(OBJ,METHOD,ARG1,ARG2,...) executes the method named
%   METHOD for the Java object OBJ with arguments ARG1,etc.  Any
%   non-primitive agruments must be constructed before calling
%   AWTINVOKE. If the method is overloaded (meaning there is more than
%   one method with that name for the class) then the METHOD must be
%   either a Java Method object or a string of the form 'NAME(SIG)'
%   where SIG is the signature in JNI notation. To obtain the JNI
%   string from a signature convert the type of each input argument
%   according to the table:
%     boolean    Z
%     byte       B
%     char       C
%     short      S
%     int        I
%     long       J
%     float      F
%     double     D
%     class      Lclass;
%     type[]     [type
%   The class name must be fully qualified (eg. java.lang.String).
%   See http://java.sun.com/docs/books/tutorial/native1.1/summary/index.html
%
%   Example:
%     f = javax.swing.JFrame('Test');
%     awtinvoke(f,'setVisible(Z)',true);
% See Also: JAVACOMPONENT AWTCREATE

%   Copyright 2003-2007 The MathWorks, Inc.

%   AWTINVOKE(...,FUNC) asynchonously calls FUNC when the Java method
%   is finished. FUNC must be a function handle. The function is
%   executed once MATLAB executes a drawnow or returns to the command
%   prompt.
%
%   AWTINVOKE(...,FUNC,FARG1,FARG2,...) passes arguments FARG1, FARG2,
%   ... to FUNC.
%
if (nargin < 1)
    error(message('MATLAB:awtinvoke:InvalidFirstArgument'));
end

if (nargin < 2)
    error(message('MATLAB:awtinvoke:InvalidSecondArgument'));
end

funcIndex = 0;
args = varargin(2:end);
for k=length(varargin):-1:1
    if isa(varargin{k},'function_handle')
        funcIndex = k;
        args = varargin(2:k-1);
        break;
    end
end
% put an event in the AWT queue to call specified Java method
if ischar(obj)
    jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    cls = jloader.loadClass(obj);
    obj = []; % is ignored by java.lang.reflect.Method.invoke
elseif isjava(obj)
    cls = getClass(obj);
else
    error(message('MATLAB:awtinvoke:IllegalInput'));
end
methodname = varargin{1};
if isa(methodname,'java.lang.reflect.Method')
    meth = methodname;
elseif any(methodname == '(')

    % Traverse up the class hierarchy until a public class is found
    % (invoking a method on a protected/private class will error).
    [methodname, sig] = parseJavaSignature(methodname);
    while ~java.lang.reflect.Modifier.isPublic(getModifiers(cls))
        cls = getSuperclass(cls);
        if isempty(cls)
            break;
        end
    end
    if ~isempty(cls)
        meth = getMethod(cls,methodname,sig);
    else
        meth = [];
    end

else
    meths = getMethods(cls);
    meth = [];
    jmethodname = java.lang.String(methodname);
    for k=1:length(meths)
        if meths(k).getName.equals(jmethodname)
            if ~isempty(meth)
                error(message('MATLAB:awtinvoke:AmbiguousMethod', methodname));
            end
            meth = meths(k);
        end
    end
    if isempty(meth)
        error(message('MATLAB:awtinvoke:UnknownMethod', methodname));
    end
end
arglist = [];
if ~isempty(args)
    arglist = parseJavaArgs(args,getParameterTypes(meth));
end
if nargout == 0
    com.mathworks.jmi.AWTUtilities.invokeLater(obj, meth, arglist);
else
    result = com.mathworks.jmi.AWTUtilities.invokeAndWait(obj, meth, arglist);
end
if funcIndex > 0
    % put an event in the AWT queue to call back into MATLAB
    cb = handle(com.mathworks.jmi.Callback,'callbackProperties');
    set(cb,'delayedCallback',{@cbBridge,varargin(funcIndex:end)});
    cb.postCallback;
end

function cbBridge(obj, evd, args) %#ok
feval(args{:})


