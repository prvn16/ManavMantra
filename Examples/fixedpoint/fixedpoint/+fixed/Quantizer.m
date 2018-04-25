classdef (StrictDefaults)Quantizer < matlab.System
    %Quantizer Quantize fixed-point numbers
    %   Q = fixed.Quantizer returns a quantizer object, Q, that quantizes
    %   fixed-point (fi) numbers using the fixed-point settings of Q.
    %
    %   Q = fixed.Quantizer(NT,RM,OA) returns a fixed-point quantizer with
    %   numerictype NT, RoundingMethod RM, OverflowAction OA.
    %
    %   Q = fixed.Quantizer(S,WL,FL,RM,OA) returns a fixed-point binary
    %   point scaling quantizer with Signed property S, WordLength WL,
    %   FractionLength FL, RoundingMethod RM, and OverflowAction OA.
    %
    %   Q = fixed.Quantizer('PropertyName', PropertyValue, ...) returns a
    %   quantizer object, Q, with each specified property set to the
    %   specified value.
    %
    %   Quantize method syntax:
    %
    %   Y = quantize(Q, X) returns Y, the result of quantizing the input
    %   array X using the settings in Q. X can be any fixed-point number fi
    %   except a boolean. Note that if X is a scaled double, the data of Y
    %   and X will be the same and only the fixed-point settings of Y will
    %   change.
    %
    %   When class(X) is a double or single Y = X. This functionality lets
    %   you share the same code for both floating-point data types and fi
    %   when quantizers are present.
    %
    %   Quantizer methods:
    %
    %   quantize    - See above description for use of this method
    %   numerictype - Get a numerictype for the current quantizer settings    
    %   clone       - Create quantizer object with same property values
    %
    %   Quantizer properties (defaults set apart by <>):
    %
    %                    Signed: {<true>, false}
    %                Signedness: {<Signed>, Unsigned}
    %                WordLength: Positive integer, <16>
    %            FractionLength: Integer = -FixedExponent, <15>
    %             FixedExponent: Integer = -FractionLength, <-15>
    %                     Slope: Double, <2^-15>
    %     SlopeAdjustmentFactor: Double, <1>, must be greater than or equal to 1 and less than 2
    %                      Bias: Double, <0>
    %            RoundingMethod: {Ceiling, Convergent, <Floor>, Nearest, Round, Zero}
    %            OverflowAction: {<Wrap>, Saturate}
    %
    %   % EXAMPLE: Use Quantizer object to reduce the wordlength resulting 
    %   %          from adding two fixed-point numbers 
    %   Q = fixed.Quantizer; % Signed, WordLength=16, FractionLength=15
    %   x1 = fi(0.1,1,16,15);
    %   x2 = fi(0.8,1,16,15);
    %   y  = quantize(Q,x1+x2);
    %
    %   % EXAMPLE: Use Quantizer object to change a binary point scaled
    %   %          fixed-point fi to a slope-bias scaled fixed-point fi
    %   Qsb = fixed.Quantizer(numerictype(1,7,1.6,0.2),'Round','Saturate');
    %   ysb = quantize(Qsb, fi(pi,1,16,13));
    %
    %   See also NUMERICTYPE, FI, QUANTIZER.
    
    %   Copyright 2011-2016 The MathWorks, Inc.
    
    %#codegen
    %#ok<*EMCLS>
    
    properties (Nontunable) 
        % Signed Logical value indicating whether output is signed
        Signed = true;
        %WordLength Number of bits used to represent the output
        %   Specify the WordLength as a positive integer.
        WordLength = 16;
        %SlopeAdjustmentFactor Slope adjustment factor scaling value
        %   Total slope is equal to SlopeAdjustmentFactor * 2^FixedExponent.
        SlopeAdjustmentFactor = 1;
        %FixedExponent Fixed exponent integer scaling value
        %   Total slope is equal to SlopeAdjustmentFactor * 2^FixedExponent.
        FixedExponent = -15;
        %Bias Fixed-point bias.
        Bias = 0;
    
        %Signedness Fixed-point signedness
        %   Specify the Signedness as one of ['Signed' | 'Unsigned'].
        Signedness;
        %Slope Fixed-point total slope.
        %   Total slope is equal to SlopeAdjustmentFactor * 2^FixedExponent.
        Slope;
        %FractionLength Scaling for least-significant bit (LSB) of output
        %   For integer fraction length FL, the LSB is scaled by 2^(-FL).
        FractionLength;
   
        %RoundingMethod Rounding method for fixed-point operations
        %   Specify the rounding method as one of ['Ceiling' |
        %   'Convergent' | {'Floor'} | 'Nearest' | 'Round' | 'Zero'].
        RoundingMethod = 'Floor';
        %OverflowAction Overflow action for fixed-point operations
        %   Specify the overflow action as one of [{'Wrap'} | 'Saturate'].
        OverflowAction = 'Wrap';
    end
        
    properties(Constant, Hidden)
        % fixpt enum properties        
        SignednessSet     = matlab.system.StringSet({'Signed','Unsigned'});
        RoundingMethodSet = matlab.system.StringSet({...
            'Ceil','Ceiling','Convergent','Floor',...
            'Nearest','Round','Fix','Zero'});
        OverflowActionSet = matlab.system.StringSet({'Wrap','Saturate'});
    end
    
    
    methods
        % CONSTRUCTOR
        function obj = Quantizer(varargin)
            if (nargin > 0)
                firstArg = varargin{1};
                
                if islogical(firstArg) || isnumeric(firstArg)
                    % -----------------------------------
                    % % fixed.Quantizer(S,WL,FL,RM,OA)
                    % -----------------------------------
                    if isempty(coder.target)
                        narginchk(0,5); 
                    end
                    
                    if isempty(coder.target) || (nargin < 4)
                        % Simulation with ANY NUMBER OF ARGS, or
                        % Code generation with AT MOST 3 (S,WL,FL) ARGS
                        setProperties(obj, nargin, varargin{:}, ...
                            'Signed','WordLength','FractionLength', ...
                            'RoundingMethod','OverflowAction');
                    elseif (nargin == 4)
                        % Code generation WITH 4 ARGS (case-insensitivity)
                        setProperties(obj, nargin, ...
                            varargin{1}, varargin{2}, varargin{3}, ...
                            varargin{4}, ...
                            'Signed','WordLength','FractionLength', ...
                            'RoundingMethod');
                    else
                        % Code generation WITH 5 ARGS (case-insensitivity)
                        setProperties(obj, nargin, ...
                            varargin{1}, varargin{2}, varargin{3}, ...
                            varargin{4}, varargin{5}, ...
                            'Signed','WordLength','FractionLength', ...
                            'RoundingMethod','OverflowAction');
                    end
                    
                elseif isnumerictype(firstArg)
                    % -----------------------------------------
                    % % fixed.Quantizer(NT,RM,OA)
                    % -----------------------------------------
                    if isempty(coder.target)
                        narginchk(0,3); 
                    end
                    
                    validateattributes(firstArg,{'embedded.numerictype'},...
                        {'scalar'}, '','numerictype');
                    
                    % Allow case-insensitivity and ability to check certain
                    % fixpt scaling settings in code generation.
                    if isempty(coder.target)
                        % Simulation
                        if ~isfixed(firstArg)
                            error(message('fixed:fi:quantizerFromFiNTArgMustBeFixedPoint'));
                        elseif isscalingunspecified(firstArg)
                            error(message('fixed:fi:quantizerFromFiNoUnspecifiedScaling'));
                        end
                        
                        if nargin > 1
                            obj.RoundingMethod = varargin{2};
                            if nargin > 2
                                obj.OverflowAction = varargin{3};
                            end
                        end
                    else
                        % Code generation
                        if nargin > 1
                            obj.RoundingMethod = varargin{2};
                            
                            if nargin > 2
                                obj.OverflowAction = varargin{3};
                            end
                        end
                    end
                    
                    obj.Signed                = firstArg.Signed;
                    obj.WordLength            = firstArg.WordLength;
                    obj.SlopeAdjustmentFactor = firstArg.SlopeAdjustmentFactor;
                    obj.FixedExponent         = firstArg.FixedExponent;
                    obj.Bias                  = firstArg.Bias;
                else
                    % Name-Value pairs provided as input arguments
                    if ~isempty(coder.target) && (nargin > 1)
                        % Codegen does not support case-insensitive strings
                        for valIdx = 1:2:(nargin-1)
                            if ischar(varargin{valIdx+1})
                                setProperties(obj, 2, varargin{valIdx}, ...
                                    varargin{valIdx+1});
                            else
                                setProperties(obj, 2, varargin{valIdx}, ...
                                    varargin{valIdx+1});
                            end
                        end
                    else
                        setProperties(obj, nargin, varargin{:});
                    end
                end
            end
        end
                                      
        % SETs
        function set.Signed(obj,val)
            if ~isempty(coder.target)
                eml_invariant(eml_is_const(val),...
                    'Coder:builtins:Explicit',...
                    'The value set to Signed must be constant.');
            end
            validateattributes(val,{'logical','numeric'},{'scalar'}, ...
                '','Signed');
            obj.Signed = logical(val);
        end
        
        function set.WordLength(obj,val)
            if ~isempty(coder.target)
                eml_invariant(eml_is_const(val),...
                    'Coder:builtins:Explicit',...
                    'The value set to WordLength must be constant.');
            end
            validateattributes(val,{'numeric'}, ...
                {'real','finite','positive','integer','scalar'}, ...
                '','WordLength');
            obj.WordLength = double(val);
        end
        
        function set.FixedExponent(obj,val)
            if ~isempty(coder.target)
                eml_invariant(eml_is_const(val),...
                    'Coder:builtins:Explicit',...
                    'The value set to FixedExponent must be constant.');
            end
            validateattributes(val,{'numeric'}, ...
                {'real','finite','integer','scalar'}, ...
                '','FixedExponent');
            obj.FixedExponent = double(val);
        end
        
        function set.RoundingMethod(obj,val)
            if ~isempty(coder.target)
                eml_invariant(eml_is_const(val),...
                    'Coder:builtins:Explicit',...
                    'The value set to RoundingMethod must be constant.');
            end
            obj.RoundingMethod = val; 
        end
        
        function set.OverflowAction(obj,val)
            if ~isempty(coder.target)
                eml_invariant(eml_is_const(val),...
                    'Coder:builtins:Explicit',...
                    'The value set to OverflowAction must be constant.');
            end            
            obj.OverflowAction = val; 
        end
        
        % SETs for (ideally) Dependent properties
        function set.Signedness(obj,val)
            if ~isempty(coder.target)
                eml_invariant(eml_is_const(val),...
                    'Coder:builtins:Explicit',...
                    'The value set to Signedness must be constant.');
            end
            % Validation handled by 'SignednessSet' constant property
            obj.Signed = strcmpi(val, 'signed'); %#ok
        end
        
        function set.Slope(obj,val)
            if ~isempty(coder.target)
                eml_invariant(eml_is_const(val),...
                    'Coder:builtins:Explicit',...
                    'The value set to Slope must be constant.');
            end
            validateattributes(val,{'numeric'}, ...
                {'real','finite','positive','scalar'}, ...
                '','Slope');
            
            fexp = floor(log2(val));
            
            obj.SlopeAdjustmentFactor = val ./ (2^fexp); %#ok
            obj.FixedExponent         = fexp;            %#ok
        end
        
        function set.FractionLength(obj,val)
            if ~isempty(coder.target)
                eml_invariant(eml_is_const(val),...
                    'Coder:builtins:Explicit',...
                    'The value set to FractionLength must be constant.');
            end
            validateattributes(val,{'numeric'}, ...
                {'real','finite','integer','scalar'}, ...
                '','FractionLength');
            
            obj.FixedExponent = -val; %#ok
        end
        
        % GETs for (ideally) Dependent properties
        function val = get.Signedness(obj)
            if obj.Signed
                val = 'Signed';
            else
                val = 'Unsigned';
            end
        end
                                      
        function val = get.FractionLength(obj)
            val = -(obj.FixedExponent);
        end
                                      
        function val = get.Slope(obj)
            val = obj.SlopeAdjustmentFactor * 2^(obj.FixedExponent);
        end
        
        % DISPLAYSCALARELEMENT
        function displayScalarElement(obj)
            binaryPointScaling = ...
                isequal(obj.SlopeAdjustmentFactor,1) && isequal(obj.Bias,0);
            
            if binaryPointScaling
                disp(   '    Binary point scaling');
            else
                disp(   '        Slope and bias scaling');
            end
            disp(' ');
            fprintf(    '            Signedness: %s\n', obj.Signedness);
            fprintf(    '            WordLength: %s\n', num2str(obj.WordLength));
            if binaryPointScaling
                fprintf('        FractionLength: %s\n', num2str(obj.FractionLength));
            else
                fprintf('                 Slope: %s\n', num2str(obj.Slope));
                fprintf('                  Bias: %s\n', num2str(obj.Bias));
            end
            disp(strcat(    '        RoundingMethod: ''', obj.RoundingMethod, ''''));
            disp(strcat(    '        OverflowAction: ''', obj.OverflowAction, ''''));
        end
        
        % NUMERICTYPE
        function T = numerictype(obj)
            %   T = numerictype(Q) returns a numerictype T which contains
            %   the output data type settings of the quantizer Q.
            if isequal(obj.SlopeAdjustmentFactor,1) && isequal(obj.Bias,0)
                % Binary point scaling
                T = numerictype(obj.Signed, obj.WordLength, obj.FractionLength);
            else
                % Slope-bias scaling
                T = numerictype(obj.Signed, obj.WordLength, obj.Slope, obj.Bias);
            end
        end                                    
        
        % QUANTIZE
        function out = quantize(obj,x)
            %   Y = quantize(Q, X) returns Y, the result of quantizing the input array
            %   X according to the settings in Q. X can be any fixed-point number fi
            %   except for a boolean. Note that if X is a scaled double, the data of Y
            %   will be the same as the data of X. Only the fixed-point settings of Y
            %   will change.
            %
            %   Y = quantize(Q, X) when class(X) is equal to double or single will
            %   leave Y = X. This functionality enables sharing the same code for both
            %   floating-point data types and fi when quantizers are present.
            %
            out = quantizefi(x, numerictype(obj), ...
                obj.RoundingMethod, obj.OverflowAction);
        end

    end % METHODS
           
end % CLASSDEF
