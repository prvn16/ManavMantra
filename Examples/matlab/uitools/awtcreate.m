function comp = awtcreate(clsname, sign, varargin)
% This function is undocumented and will change in a future release

%AWTCREATE Create a java component with the given name on the AWT EDT
%
% AWTCREATE(CLASSNAME) invokes the no-argument constructor on the class
% specified by the CLASSNAME string on the AWT Event Dispatch thread
% synchronously and returns a handle to the java object.
%
% AWTCREATE(CLASSNAME, SIGNATURE, ARG1, ...) invokes the appropriate
% constructor on the class specified by the string CLASSNAME matching the
% signature specified by the string SIGNATURE with the specified arguments.
% The constructor is invoked on the AWT Event Dispatch Thread synchrocously
% and returns a handle to the java object.
%
% The string SIGNATURE is a signature in JNI notation. To obtain the JNI
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
% This is the safest way to create java components from the MATLAB thread.
%
% Example:
%
%  b = awtcreate('javax.swing.JButton');
%  awtinvoke(b,'setLabel(Ljava/lang/String;)','Hi')
%  hb = javacomponent(b);
%  hb.actionPerformedCallback = 'disp hi';
%
%  b = awtcreate('javax.swing.JButton', 'Ljava.lang.String;', 'Hi');
%  hb = javacomponent(b);
%  hb.actionPerformedCallback = 'disp hi';
%
% See Also: JAVACOMPONENT AWTINVOKE

%   Copyright 2005-2017 The MathWorks, Inc.

if (nargin == 0)
    error(message('MATLAB:awtcreate:IncorrectUsage'));
end

if (nargin > 0)
    % Handle first argument as a string for the class name
    if (isempty(clsname) || ~ischar(clsname))
        error(message('MATLAB:awtcreate:IncorrectUsage'));
    end
end

if (nargin == 2)
    error(message('MATLAB:awtcreate:IncorrectUsage'));
end

if (nargin > 2)
    % Handle second argument as a string for the constructor signatures
    if (isempty(sign) || ~ischar(sign))
        error(message('MATLAB:awtcreate:IncorrectUsage'));
    end
end

args = varargin;

try
    jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    cls = jloader.loadClass(clsname);
catch
    error(message('MATLAB:awtcreate:ClassNotFound'));
end

if (nargin == 1)
    try
        % No arg constructor
        comp = awtinvoke(cls, 'newInstance');
    catch
        comp = [];
    end
else
    [~, sig] = parseJavaSignature(sign);

    try
        cstr = cls.getConstructor(sig);
        argList = [];
        if ~isempty(args)
            argList = parseJavaArgs(args,cstr.getParameterTypes);
        end

        comp = awtinvoke(cstr, 'newInstance([Ljava.lang.Object;)', argList);
    catch
        comp = [];
    end

end
end

