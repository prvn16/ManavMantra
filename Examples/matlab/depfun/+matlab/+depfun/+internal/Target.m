classdef Target

    methods (Static)
        function t = parse(name)
            import matlab.depfun.internal.Target;
            t = Target.Unknown;
            if strcmpi(name,'MCR')
                t = Target.MCR;
            elseif strcmpi(name,'MATLAB')
                t = Target.MATLAB;
            elseif strcmpi(name,'PCTWorker')
                t = Target.PCTWorker;
            elseif strcmpi(name,'All')
                t = Target.All;
            elseif strcmpi(name,'None')
                t = Target.None;
            elseif strcmpi(name,'Deploytool')
                t = Target.Deploytool;
            end
        end
        
        function s = str(t)
            import matlab.depfun.internal.Target;
            s = '';
            switch t
              case { Target.MCR, 0 }
                s = 'MCR';
              case { Target.MATLAB, 1 }
                s = 'MATLAB';
              case { Target.PCTWorker, 2 }
                s = 'PCTWorker';
              case { Target.All, 3 }
                s = 'All';
              case { Target.None, 4 }
                s = 'None';
              case { Target.Unknown, 5 }
                s = 'Unknown';
              case { Target.Deploytool, 6 }
                s = 'Deploytool';
            end
        end

        function k = int(t)
            import matlab.depfun.internal.Target;
            if ischar(t), t = Target.parse(t); end
            k = -1;
            switch t
              case Target.MCR
                k = int32(0);
              case Target.MATLAB
                k = int32(1);
              case Target.PCTWorker
                k = int32(2);
              case Target.All
                k = int32(3);
              case Target.None
                k = int32(4);
              case Target.Unknown
                k = int32(5);
              case Target.Deploytool
                k = int32(6);
            end
        end
    end

% A Completion must have a Target, that is, an environment in which the 
% files in the Completion are expected to execute.
    enumeration
        MCR, MATLAB, PCTWorker, All, None, Unknown, Deploytool
    end
end


