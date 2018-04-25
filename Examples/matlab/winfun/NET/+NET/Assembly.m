%NET.Assembly represents a .NET Assembly class.
% NET.Assembly class instance is returned as a result of  NET.addAssembly
% API. NET.Assembly has following properties:
%
%   AssemblyHandle:	An instance of System.Reflection.Assembly class of the
%                   added assembly.
%   Classes:        Mx1 cell array of class names of the added assembly.
%   Enums:          Mx1 cell array of enums of the added assembly. 
%   Structures:     Mx1 cell array of structures of the added assembly. 
%   GenericTypes:   Mx1 cell array of generic types of the added assembly.
%   Interfaces:     Mx1 cell array of interface names of the added assembly. 
%   Delegates:      Mx1 cell array of delegates of the added assembly.  

%   Copyright 2008 The MathWorks, Inc.
classdef Assembly < handle
    %read only properties
    properties (SetAccess = private)
        AssemblyHandle = [];
        Classes = {};
        Structures = {};
        Enums = {};
        GenericTypes = {};
        Interfaces = {};
        Delegates = {};
    end
    %hidden properties for status flags
    properties (Hidden = true)
        Classes_Read = false;
        Structures_Read = false;
        Enums_Read = false;
        GenericTypes_Read = false;
        Interfaces_Read = false;
        Delegates_Read = false;
    end
    methods
        %constructor - sets the AsssemblyHandle property
        function ct = Assembly(asm)
            if(~isempty(asm))
                ct.AssemblyHandle = asm;
            end
        end
       
        %overloaded display - display only the property names, not values
        function disp(this)
            fprintf(['  ',getString(message('MATLAB:NET:DisplayMethodNETAssemblyHandle'))]);
            fprintf(getString(message('MATLAB:NET:DisplayMethodPackageNETn')))
            properties(this)
        end
        
        %property Classes
        function value = get.Classes(this)
            if(~this.Classes_Read)
                types = this.AssemblyHandle.GetExportedTypes;
                count = 1;
                for i=1:types.Length
                   type = types.Get(i-1);
                   %A generic type or delegate type can return true for
                   %classes, so we really need to remove such conditions
                   %for creatible classes
                   if (type.IsClass) && (~type.IsInterface) && (~type.IsGenericType) && (~type.IsSubclassOf(System.Type.GetType('System.Delegate')))
                       val = char(type.FullName.ToString);
                       this.Classes{count,1} = val;
                       count = count + 1;
                   end
                end
                %set the flag
                this.Classes_Read = true;
            end
            %return the result
            value = this.Classes;
        end
        
        %property Interfaces
        function value = get.Interfaces(this)
            if(~this.Interfaces_Read)
                types = this.AssemblyHandle.GetExportedTypes;
                count = 1;
                for i=1:types.Length
                   type = types.Get(i-1);
                   if (type.IsInterface)
                       val = char(type.FullName.ToString);
                       this.Interfaces{count,1} = val;
                       count = count + 1;
                   end
                end
                %set the flag
                this.Interfaces_Read = true;
            end
            %return the result
            value = this.Interfaces;
        end
        
        %property Enums
        function value = get.Enums(this)
            if(~this.Enums_Read)
                types = this.AssemblyHandle.GetExportedTypes;
                count = 1;
                for i=1:types.Length
                   type = types.Get(i-1);
                   if (type.IsEnum)
                       val = char(type.FullName.ToString);
                       this.Enums{count,1} = val;
                       count = count + 1;
                   end
                end
                %set the flag
                this.Enums_Read = true;
            end
            %return the result
            value = this.Enums;
        end
       
        %property GenericTypes
        function value = get.GenericTypes(this)
            if(~this.GenericTypes_Read)
                types = this.AssemblyHandle.GetExportedTypes;
                count = 1;
                for i=1:types.Length
                   %get the type
                   type = types.Get(i-1);
                   if (type.IsGenericType)
                       val = char(type.UnderlyingSystemType.ToString);
                       this.GenericTypes{count,1} = val;
                       count = count + 1;
                   end
                end
                %set the flag
                this.GenericTypes_Read = true;
            end
            %return the result
            value = this.GenericTypes;
        end
        
        %property Delegates
        function value = get.Delegates(this)
            if(~this.Delegates_Read)
                types = this.AssemblyHandle.GetExportedTypes;
                count = 1;
                for i=1:types.Length
                   %get the type
                   type = types.Get(i-1);
                   if (type.IsSubclassOf(System.Type.GetType('System.Delegate')))
                       val = char(type.FullName.ToString);
                       this.Delegates{count,1} = val;
                       count = count + 1;
                   end
                end
                %set the flag
                this.Delegates_Read = true;
            end
            %return the result
            value = this.Delegates;
        end
        
        %property Structures
        function value = get.Structures(this)
            if(~this.Structures_Read)
                types = this.AssemblyHandle.GetExportedTypes;
                count = 1;
                for i=1:types.Length
                   %get the type
                   type = types.Get(i-1);
                   if (type.IsValueType) && (~type.IsClass) && (~type.IsEnum) && (~type.IsInterface) && (~type.IsGenericType) 
                       val = char(type.FullName.ToString);
                       this.Structures{count,1} = val;
                       count = count + 1;
                   end
                end
                %set the flag
                this.Structures_Read = true;
            end
            %return the result
            value = this.Structures;
        end
    end
end
