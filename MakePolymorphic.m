classdef MakePolymorphic
    %MAKEPOLYMORPHIC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
        fn = 'fn'
        gentype = 'lib'
        launch = ''
        u = fi(1:10,true,16,11);
    end
    
    methods
        function obj = MakePolymorphic(inputArg1,inputArg2)
            %MAKEPOLYMORPHIC Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        function y = user_written_sum(obj,u)
            % Setup
            F = fimath('RoundingMethod','Floor',...
                'OverflowAction','Wrap',...
                'SumMode','KeepLSB',...
                'SumWordLength',32);
            u = setfimath(u,F);
            y = fi(0,true,32,get(u,'FractionLength'),F);
            % Algorithm
            for i=1:length(u)
                y(:) = y + u(i);
            end
            % Cleanup
            y = removefimath(y);
        end
        
        function xx = genCode(obj)
            %             codegen user_written_sum -args {u} -config:lib -launchreport
            cfg = coder.config('lib')
%             cfg.CustomSource = 'main.c'
%             cfg.CustomInclude = 'c:\myfiles'
            codegen -config cfg obj@user_written_sum
            
            %             xx = ['codegen ', obj.fn, ' -args ', '{mp.u}', ' -config:', obj.gentype, ' ', obj.launch]
%             feval('codegen', obj.fn);
        end
    end 
end

