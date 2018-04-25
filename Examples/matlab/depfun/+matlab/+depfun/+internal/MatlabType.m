classdef MatlabType < int32
% MatlabType
    enumeration
        NotYetKnown         (0) % Not enough info. yet
        MCOSClass           (1) % Matlab Common Object System
        UDDClass            (2) % Universal Data Dictionary
        OOPSClass           (3) 
        BuiltinClass        (4) % A built-in class-like object (e.g., cell)
        ClassMethod         (5) % Method of MCOS class or OOPS class
        UDDMethod           (6) % Method of UDD class, g887983
        UDDPackageFunction  (7) % UDD package function, 1@, no+
        Function            (8) % A non-method function
        BuiltinFunction     (9) % A function implemented in C++
        BuiltinMethod      (10) % A method of a builtin class
        BuiltinPackage     (11) % A package registered by a shared library
        Data               (12) % MATLAB native data (.mat, .fig)
        Ignorable          (13) % A MATLAB symbol that must be ignored
        Extrinsic          (14) % A symbol or file from another land
        DotNetAPI          (15) % External .NET API
        JavaAPI            (16) % External Java API
        PythonAPI          (17) % External Python API
    end  
   
    methods

       function type = methodType(t)
           import matlab.depfun.internal.MatlabType;
           type = MatlabType.NotYetKnown;
           switch t
             case MatlabType.UDDClass
               type = MatlabType.UDDMethod;
             case MatlabType.OOPSClass
               type = MatlabType.ClassMethod;
             case MatlabType.MCOSClass
               type = MatlabType.ClassMethod;
             case MatlabType.BuiltinClass
               type = MatlabType.BuiltinMethod;
           end
       end

       function type = classType(t)
       % TODO: Add MCOSMethod and OOPSMethod to the enumeration, the
       % switch statement and the database. (See DependencyDepot.createTables).
           import matlab.depfun.internal.MatlabType;           
           type = MatlabType.NotYetKnown;
           switch t
             case MatlabType.UDDMethod
               type = MatlabType.UDDClass;
             case MatlabType.BuiltinMethod
               type = MatlabType.BuiltinClass;
           end
       end

       function tf = isUDD(t)
            import matlab.depfun.internal.MatlabType;           
            tf = ((t == MatlabType.UDDClass) || ...
                  (t == MatlabType.UDDMethod) || ...
                  (t == MatlabType.UDDPackageFunction));
       end

       function tf = isMCOS(t)
            import matlab.depfun.internal.MatlabType;
            tf = (t == MatlabType.MCOSClass);
       end

       function tf = isOOPS(t)
            import matlab.depfun.internal.MatlabType;
            tf = (t == MatlabType.OOPSClass);
       end

       function tf = isClass(t)
            import matlab.depfun.internal.MatlabType;
            % Answer the most common question first. Performance
            % optimization.
            if t == MatlabType.NotYetKnown
                tf = false;
            else
                tf = ((t == MatlabType.MCOSClass) || ...
                      (t == MatlabType.UDDClass) || ...
                      (t == MatlabType.OOPSClass) || ...
                      (t == MatlabType.BuiltinClass));
            end
        end

        function tf = isExtrinsic(t)
            import matlab.depfun.internal.MatlabType;
            tf =  (t == MatlabType.Extrinsic);
        end

        function tf = isFunction(t)
            import matlab.depfun.internal.MatlabType;
            tf =  ((t == MatlabType.Function) || ...
                   (t == MatlabType.BuiltinFunction));
        end
        
        function tf = isBuiltin(t)
            import matlab.depfun.internal.MatlabType;
            tf =  ((t == MatlabType.BuiltinClass) || ...
                   (t == MatlabType.BuiltinMethod) || ... 
                   (t == MatlabType.BuiltinPackage) || ... 
                   (t == MatlabType.BuiltinFunction));
        end
        
        function tf = isMethod(t)
            import matlab.depfun.internal.MatlabType;
            tf = (t == MatlabType.ClassMethod || ...
                  t == MatlabType.UDDMethod || ...
                  t == MatlabType.BuiltinMethod);
        end
        
        function tf = isUDDMethod(t)
            import matlab.depfun.internal.MatlabType;
            tf = (t == MatlabType.UDDMethod);
        end
        
        function tf = isUDDPackageFunction(t)
            import matlab.depfun.internal.MatlabType;
            tf = (t == MatlabType.UDDPackageFunction);
        end
        
        function tf = isDotNetAPI(t)
            import matlab.depfun.internal.MatlabType;
            tf =  (t == MatlabType.DotNetAPI);  
        end
        
        function tf = isJavaAPI(t)
            import matlab.depfun.internal.MatlabType;
            tf =  (t == MatlabType.JavaAPI);
        end
        
        function tf = isPythonAPI(t)
            import matlab.depfun.internal.MatlabType;
            tf =  (t == MatlabType.PythonAPI);
        end
    end
end
