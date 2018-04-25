classdef requirementsConstants
% This class provides constants frequently used by files in REQUIREMENTS.
% 
% Accessing a constant property is 0.000010 ms faster each time 
% than accessing a persistent variable. This is achieved by the caching 
% mechanism of MCOS; every constant property gets initialized only once.
%
% Different sets of relevant constants are grouped, so this file can be
% easily split, if some constants need to be shared by files outside
% REQUIREMENTS in the future.

    properties (Constant)
        % TO DO: Move other frequently used common constants here.
        % For example, computer('arch'), db locations, etc.
        
        % Comment out the following lines for now, because WHICH uses
        % hard-coded English strings.
        % They are not removed because they may be useful in the future in
        % case the WHICH result is internationalized.
%         BuiltInStr = getString(message('MATLAB:depfun:req:BuiltIn'));
%         lBuiltInStr = length(getString(message('MATLAB:depfun:req:BuiltIn')));
%         
%         BuiltInStrAndATrailingSpace = [getString(message('MATLAB:depfun:req:BuiltIn')) ' '];
%         lBuiltInStrAndATrailingSpace = length([getString(message('MATLAB:depfun:req:BuiltIn')) ' ']);
%         
%         MethodStr = getString(message('MATLAB:depfun:req:Method'));
%         lMethodStr = length(getString(message('MATLAB:depfun:req:Method')));
%         
%         IsABuiltInMethodStr = getString(message('MATLAB:ClassText:whichBuiltinMethod',''));     
%         lIsABuiltInMethodStr = length(getString(message('MATLAB:ClassText:whichBuiltinMethod','')));
%         
%         ConstructorStr = getString(message('MATLAB:ClassText:whichConstructor',''));
%         lConstructorStr = length(getString(message('MATLAB:ClassText:whichConstructor','')));
        
        BuiltInStr = 'built-in';
        lBuiltInStr = length('built-in');
        
        % This is solely for performance.
        BuiltInStrAndATrailingSpace = 'built-in ';
        lBuiltInStrAndATrailingSpace = length('built-in ');
        
        MethodStr = 'method';
        lMethodStr = length('method');
        
        IsABuiltInMethodStr = ' is a built-in method';
        lIsABuiltInMethodStr = length(' is a built-in method');
        
        ConstructorStr = ' constructor';
        lConstructorStr = length(' constructor');
    end
    
    properties (Constant)
        FileSep = filesep;        
        MatlabRoot = matlabroot;        
        isPC = ispc;

        req_dir = fullfile(fileparts(mfilename('fullpath')));
        arch = computer('arch');

        pcm_db_prefix = 'pcm_';
        pcm_db_postfix = '_db';
    end
    
    properties (Constant)
        mcr_pid_min = 35000;
        mcr_pid_max = 35999;
        full_mcr_pid = 1000;
        
        % Every deployed application depends on the smallest MCR,
        % which is MATLAB runtime - Numerics now.
        required_min_product_mcr = 35010;
        % Every target depends on MATLAB, except MCR target.
        required_min_product_other = 1;
        
        % MCR external product ids
        mcr_core_pid = 35000;
        mcr_numerics_pid = 35010;
        mcr_gpu_pid = 35001;
    end
    
    properties (Constant)
        matlabBuiltinClasses =  { ...
                'cell';'char';'double';'int8';'int16';'int32';'int64'; ...
                'handle';'logical';'opaque';'single';'struct'; ...
                'uint8';'uint16';'uint32';'uint64' ...
                };
        matlabBuiltinClassSet = containers.Map( ...
                { ...
                'cell';'char';'double';'int8';'int16';'int32';'int64'; ...
                'handle';'logical';'opaque';'single';'struct'; ...
                'uint8';'uint16';'uint32';'uint64' ...
                }, ...
                true(16,1));
    end

     properties (Constant)
        % The two lists below are orderred by precedence (high to low).
        analyzableMatlabFileExt = {'.mlapp' '.mlx' '.m'};
        executableMatlabFileExt = {['.' mexext] '.mlapp' '.mlx' '.p' '.m'};
        
        % The two lists below are orderred by reversed precedence (low to
        % high). They are useful when precedence is not important. Newly
        % introduced file types (higher precedence) do not exist as widely
        % as traditional file types (lower precedence). Checking file types
        % in this order benefits performance.
        analyzableMatlabFileExt_reverseOrder = {'.m' '.mlx' '.mlapp'};
        executableMatlabFileExt_reverseOrder = {'.m' '.p' '.mlx' '.mlapp' ['.' mexext]};
        
        % Size of the two lists regardless the order
        analyzableMatlabFileExtSize = 3;
        executableMatlabFileExtSize = 5;
        
        % regexp file extension pattern
        analyzableMatlabFileExtPat = '\.(m|mlx|mlapp)$';
        executableMatlabFileExtPat = ['\.(m|p|mlx|mlapp|' mexext ')$'];
        
        % Correspondent unordered fields in the WHAT result. (There are 
        % more fileds in the WHAT result, but REQURIEMENTS does not care.)
        whatFields = {'mex' 'mlapp' 'mlx' 'm' 'p'};
        
        % Data file extensions
        dataFileExt = {'.fig' '.mat'};
        dataFileExtSize = 2;
    end
    
    methods
    end
end