classdef RandStream < handle
%RANDSTREAM Random number stream.
%   (Pseudo)random numbers in MATLAB come from one or more random number
%   streams.  The simplest way to generate arrays of random numbers is to use
%   RAND, RANDI, or RANDN.  These functions all draw values from the same
%   stream of uniform pseudorandom numbers, known as the global random number
%   stream.  You can create other streams that act separately from the current
%   global stream, and you can use their RAND, RANDI, or RANDN methods to
%   generate arrays of random numbers.  You can also designate any random
%   number stream you create as the global stream.
%
%   To create a single random number stream, use the RandStream constructor.
%   To create multiple independent random number streams, use RandStream.CREATE.
%   The RNG function provides a simple interface to create a new global stream.
%
%   STREAM = RandStream.GETGLOBALSTREAM returns the current global random
%   number stream, i.e., the one that the RAND, RANDI, and RANDN functions
%   currently draw values from.
%
%   PREVSTREAM = RandStream.SETGLOBALSTREAM(STREAM) sets STREAM as the current
%   global random number stream, i.e., designates it as the stream that the
%   RAND, RANDI, and RANDN functions will draw values from.  PREVSTREAM is the
%   stream that was previously designated as the global random number stream.
%
%   A random number stream S has properties that control its behavior.  Access or
%   assign to a property using P = S.Property or S.Property = P.
%
%   RandStream properties:
%      Type            - (Read-only) identifies the type of generator algorithm
%                        used by the stream.
%      Seed            - (Read-only) the seed value used to create the stream.
%      NumStreams      - (Read-only) the number of streams created at the same
%                        time as the stream.
%      StreamIndex     - (Read-only) the stream's index among the group of streams
%                        in which it was created.
%      State           - the internal state of the generator.  You should not depend
%                        on the format of this property, or attempt to improvise a
%                        property value.  The value you assign to S.State must be a
%                        value read from S.State previously.  Use RESET to return a
%                        stream to a predictable state without having previously read
%                        from the State property.
%      Substream       - the index of the substream to which the stream is
%                        currently set.  The default is 1.  Multiple substreams are
%                        not supported by all generator types.
%      NormalTransform - the transformation algorithm that RANDN(S, ...) uses
%                        to generate normal pseudorandom values from uniform
%                        values.  The property value is one of 'Ziggurat' (the
%                        default), 'Polar', or 'Inversion'.
%      Antithetic      - a logical value indicating whether S generates antithetic
%                        uniform pseudorandom values, that is, the usual values
%                        subtracted from 1.  The default is false.
%      FullPrecision   - a logical value indicating whether S generates values
%                        using its full precision.  Some generators are able to
%                        create pseudorandom values faster, but with fewer random
%                        bits, if FullPrecision is false.  The default is true.
%  
%   The sequence of pseudorandom numbers produced by a random number stream S is
%   determined by the internal state of its random number generator.  Saving and
%   restoring the generator's internal state via the 'State' property allows you
%   to reproduce output.
%
%   Examples:
%
%      Create a single stream and designate it as the current global stream:
%         s = RandStream('mt19937ar','Seed',1)
%         RandStream.setGlobalStream(s);
%
%      Create three independent streams:
%         [s1,s2,s3] = RandStream.create('mrg32k3a','NumStreams',3);
%         r1 = rand(s1,100000,1); r2 = rand(s2,100000,1); r3 = rand(s3,100000,1);
%         corrcoef([r1,r2,r3])
%
%      Create only one stream from a set of three independent streams, and
%      designate it as the current global stream:
%         s2 = RandStream.create('mrg32k3a','NumStreams',3,'StreamIndices',2)
%         RandStream.setGlobalStream(s2);
%
%      Reset the global random number stream that underlies RAND, RANDI, and
%      RANDN back to its beginning, to reproduce previous results:
%         stream = RandStream.getGlobalStream;
%         reset(stream);
%
%      Save and restore the current global stream's state to reproduce the
%      output of RAND:
%         stream = RandStream.getGlobalStream;
%         savedState = stream.State;
%         u1 = rand(1,5)
%         stream.State = savedState;
%         u2 = rand(1,5) % u2 contains exactly the same values as u1
%
%      Reset the global random number stream to its "factory default" initial
%      settings.  This causes RAND, RANDI, and RANDN to start over, as if in a
%      new MATLAB session.
%         s = RandStream('mt19937ar','Seed',0)
%         RandStream.setGlobalStream(s);
%
%      Reinitialize the global random number stream using a seed based on the
%      current time.  This causes RAND, RANDI, and RANDN to return different
%      values in different MATLAB sessions.  NOTE: It is usually not desirable
%      to do this more than once per MATLAB session.
%         s = RandStream('mt19937ar','Seed','shuffle')
%         RandStream.setGlobalStream(s);
%
%      Change the transformation algorithm that RANDN uses to create normal
%      pseudorandom values from uniform values.  Note that this does not
%      replace or reset the global stream.
%         stream = RandStream.getGlobalStream;
%         stream.NormalTransform = 'inversion'
%
%   RandStream methods:
%       RandStream/RandStream  - Create a random number stream.
%       create                 - Create multiple independent random number streams.
%       list                   - List available random number generator algorithms.
%       getGlobalStream        - Get the current global random number stream.
%       setGlobalStream        - Replace the global random number stream.
%       reset                  - Reset a stream to its initial internal state.
%       rand                   - Pseudorandom numbers from a uniform distribution.
%       randn                  - Pseudorandom numbers from a standard normal distribution.
%       randi                  - Pseudorandom integers from a uniform discrete distribution.
%       randperm               - Random permutation.
%
%   See also RNG, RANDFUN/RAND, RANDFUN/RANDN, RANDFUN/RANDI.

%   Copyright 2008-2012 The MathWorks, Inc. 

    properties(GetAccess='public', SetAccess='protected')
        %TYPE Random number stream generator algorithm.
        %   The Type property of a random number stream identifies the
        %   generator algorithm that the stream uses.  Type is a read-only
        %   property.
        %
        %   See also RANDSTREAM.
        Type = '';
        
        %SEED Random number stream seed.
        %   The Seed property of a random number stream contains the seed
        %   value used to create the stream.  Seed is a read-only property.
        %
        %   See also RANDSTREAM, RESET.
        Seed = uint32(0);
        
        %NUMSTREAMS Number of random number streams created at the same time.
        %   The NumStreams property of a random number stream contains the
        %   number of streams created at the same time as the stream.
        %   NumStreams is a read-only property.
        %
        %   See also RANDSTREAM.
        NumStreams = uint64([]);
        
        %STREAMINDEX Random number stream index.
        %   The StreamIndex property of a random number stream contains the
        %   stream's index among the group of streams in which it was created.
        %   StreamIndex is a read-only property.
        %
        %   See also RANDSTREAM.
        StreamIndex = uint64([]);
    end
    
    properties(GetAccess='protected', SetAccess='protected')
        Params = [];
        SpawnIncr = uint64([]);
    end
    properties(Hidden, GetAccess='public', SetAccess='protected')
        % This property should not be relied upon
        StreamID = uint64(0);
    end
    
    properties(Dependent=true, GetAccess='public', SetAccess='public')
        %STATE Random number stream generator state.
        %   The State property of a random number stream contains the internal
        %   state of the generator.  You should not depend on the format of
        %   this property, or attempt to improvise a property value.  The value
        %   you assign to S.State must be a value read from S.State previously.
        %   Use RESET to return a stream to a predictable state without having
        %   previously read from the State property.
        %
        %   See also RANDSTREAM, RESET.
        State;
        
        %SUBSTREAM Random number stream substream index.
        %   The Substream property of a random number stream contains the
        %   index of the substream to which the stream is currently set.  The
        %   default is 1. Multiple substreams are not supported by all
        %   generator types.
        %
        %   See also RANDSTREAM.
        Substream;
        
        %NORMALTRANSFORM Random number stream normal transformation algorithm.
        %   The NormalTransform property of a random number stream identifies
        %   the transformation algorithm that its RANDN method uses to
        %   generate normal pseudorandom values from uniform values.  The
        %   property value is one of 'Ziggurat' (the default), 'Polar', or
        %   'Inversion'.
        %
        %   See also RANDSTREAM, RANDN.
        NormalTransform;
        
        %ANTITHETIC Random number stream antithetic values flag.
        %   The Antithetic property of a random number stream is a logical
        %   value indicating whether the stream generates antithetic uniform
        %   pseudorandom values, that is, the usual values subtracted from 1.
        %   The default value is false.
        %
        %   See also RANDSTREAM.
        Antithetic;
        
        %FULLPRECISION Random number stream full precision flag.
        %   The FullPrecision property of a random number stream is a logical
        %   value indicating whether the stream generates values using its
        %   full precision.  Some generators are able to create pseudorandom
        %   values faster, but with fewer random bits, if FullPrecision is
        %   false.  The default value is true.
        %
        %   See also RANDSTREAM.
        FullPrecision;
    end
    methods % subsref is overloaded, but need these so that struct will work
        function b = get.State(a),           b = builtin('_RandStream_getset_mex','state',a.StreamID);         end
        function b = get.Substream(a),       b = builtin('_RandStream_getset_mex','substream',a.StreamID);     end
        function b = get.NormalTransform(a), b = builtin('_RandStream_getset_mex','randnalg',a.StreamID);      end
        function b = get.Antithetic(a),      b = builtin('_RandStream_getset_mex','antithetic',a.StreamID);    end
        function b = get.FullPrecision(a),   b = builtin('_RandStream_getset_mex','fullprecision',a.StreamID); end
    end

    properties(Constant=true, GetAccess='protected')
        % The local function localGetSetGlobalStream maintains a handle to
        % the current global and legacy streams in persistent variables that
        % are, in effect, static properties of the class, but modifiable.  The
        % streamIDs are also stored in C++ static variables in the built-in
        % code.
        
        BuiltinTypes = ...
             {'dsfmt19937'  'mcg16807' 'mlfg6331_64'   'mrg32k3a'      'mt19937ar' 'shr3cong' 'swb2712'  };
        CompatNames = ...
             {'simdTwister' 'v4'       'multFibonacci' 'combRecursive' 'twister'   'v5normal' 'v5uniform' };
        BuiltinDescrs = ...
             {'MATLAB:RandStream:list:dsfmt19937Description' 'MATLAB:RandStream:list:mcg16807Description' 'MATLAB:RandStream:list:mlfg6331_64Description' ...
              'MATLAB:RandStream:list:mrg32k3aDescription' 'MATLAB:RandStream:list:mt19937arDescription' ...
              'MATLAB:RandStream:list:shr3congDescription' 'MATLAB:RandStream:list:swb2712Description'
              };
        VisibleMethods = getMethodNames();
    end
    properties(Hidden=true, Constant=true, GetAccess='public')
        DefaultStartupType = 'mt19937ar';
    end
    
    methods(Static=true, Access='public')
        function [varargout] = create(type, varargin)
%RANDSTREAM.CREATE Create multiple independent random number streams.
%   [S1,S2,...] = RandStream.CREATE('GENTYPE','NumStreams',N) creates N
%   random number streams that use the uniform pseudorandom number generator
%   algorithm specified by GENTYPE, and that are independent in a pseudorandom
%   sense. These streams are not necessarily independent from streams created
%   at other times.  Multiple streams are not supported by all generator
%   types.  Type "RandStream.list" for a list of possible values for GENTYPE,
%   or see <a href="matlab:helpview([docroot '\techdoc\math\math.map'],'choose_random_number_generator')">Choosing a Random Number Generator</a> for details on these generator
%   algorithms.
%
%   S = RandStream.CREATE('GENTYPE') creates a single random stream.  However,
%   the RANDSTREAM constructor is a more concise alternative when you need to
%   create only a single stream.
%
%   [ ... ] = RandStream.CREATE(..., 'PARAM1',val1, 'PARAM2',val2, ...) allows
%   you to specify optional parameter name/value pairs to control creation of
%   the stream(s).  Parameters are:
%
%      NumStreams      - the total number of streams of this type that will be
%                        created, across sessions or labs.  Default is 1.
%      StreamIndices   - the stream indices that should be created in this call.
%                        Default is 1:N, where N is the value given with the
%                       'NumStreams' parameter.
%      Seed            - a non-negative scalar integer seed with which to
%                        initialize all streams, or 'shuffle' to create a seed
%                        based on the current time.  Default is 0.
%      NormalTransform - the transformation algorithm that RANDN(S, ...) uses
%                        to generate normal pseudorandom values from uniform
%                        pseudorandom values.  The property value is one of
%                        'Ziggurat' (the default), 'Polar', or 'Inversion'.
%      CellOutput      - a logical flag indicating whether or not to return the
%                        stream objects as elements of a cell array.  Default is
%                        false.
%
%   'NumStreams', 'StreamIndices', and 'Seed' can be used to ensure that
%   multiple streams created at different times are independent.  Streams of the
%   same type and created using the same value for 'NumStreams' and 'Seed', but
%   with different values of 'StreamIndices', are independent even if they were
%   created in separate calls to RandStream.CREATE.  Instances of different
%   generator types may not be independent.
%
%   Examples:
%
%      Create three independent streams:
%         [s1,s2,s3] = RandStream.create('mrg32k3a','NumStreams',3);
%         r1 = rand(s1,100000,1); r2 = rand(s2,100000,1); r3 = rand(s3,100000,1);
%         corrcoef([r1,r2,r3])
%
%      Create only one stream from a set of three independent streams, and
%      designate it as the current global stream:
%         s2 = RandStream.create('mrg32k3a','NumStreams',3,'StreamIndices',2)
%         RandStream.setGlobalStream(s2);
%
%   See also RANDSTREAM, RANDSTREAM/RANDSTREAM, RANDSTREAM.LIST, RANDSTREAM/RAND,
%            RANDSTREAM/RANDI, RANDSTREAM/RANDN, RANDSTREAM.GETGLOBALSTREAM,
%            RANDSTREAM.SETGLOBALSTREAM

            if nargin < 1
                error(message('MATLAB:RandStream:TooFewInputs'));
            end
            
            pnames = {'numstreams' 'streamindices' 'seed' 'normaltransform' 'celloutput' 'parameters'};
            dflts =  {          1              []      0                []        false           []          []};
            [nstreams,streamIdx,seed,randnalg,celloutput,params] = ...
                                                        getargs(pnames, dflts, varargin{:});         
            if ~ischar(type)
                error(message('MATLAB:RandStream:create:InvalidRNGType'));
            end
            if ~isnumeric(nstreams) || ~isreal(nstreams) || ~isscalar(nstreams) || ...
               ~(1<=nstreams && nstreams<2^64 && nstreams==round(nstreams))
                error(message('MATLAB:RandStream:create:BadNumStreams'));
            end
            if ischar(seed) && isequal(lower(seed),'shuffle')
                seed = RandStream.shuffleSeed;
            elseif ~isnumeric(seed) || ~isreal(seed) ||~isscalar(seed) || ~(0<=seed && seed<2^32)
                % Allow non-integer seed so that sum(100*clock) works.  Will truncate below.
                error(message('MATLAB:RandStream:create:BadSeed'));
            end
            if ~isnumeric(streamIdx) || ~isreal(streamIdx)
                error(message('MATLAB:RandStream:create:BadStreamIndex'));
            end
            if isempty(params)
                % none given, it will be defaulted to zero below
            elseif ~isnumeric(params) || ~isreal(params) || ~isvector(params) ...
                                      || ~all(params == round(params)) || ~all(params >= 0)
                error(message('MATLAB:RandStream:create:BadParams'));
            elseif any(strcmpi(type,RandStream.BuiltinTypes))
                error(message('MATLAB:RandStream:create:ParamNotValid', type));
            end
            if isempty(streamIdx)
                streamIdx = 1:nstreams;
            end
            
            if (celloutput && nargout > 1) || (nargout > numel(streamIdx))
                error(message('MATLAB:RandStream:create:TooManyOutputs'));
            end
            
            type = RandStream.algName(type(:)');
            streams = cell(1,length(streamIdx));
            for i = 1:numel(streamIdx)
                index = streamIdx(i);
                if ~(1<=index && index<=nstreams && index==round(index))
                    error(message('MATLAB:RandStream:create:BadStreamIndex'));
                end
                
                % Fill in the stream properties by hand to avoid repeating the
                % overhead of repeated, identical argument processing by the constructor
                % s = RandStream('type', 'seed',seed, 'normaltransform',randnalg, 'param',params);
                s = RandStream.newarray(1);
                s.Type = type;
                s.Seed = uint32(floor(seed)); % truncate if not integer
                s.Params = uint64(params); % possibly empty
                s.NumStreams = uint64(nstreams);
                s.StreamIndex = uint64(index); % stored one-based
                s.SpawnIncr = uint64(nstreams);
                s.StreamID = builtin('_RandStream_create_mex',s.Type,s.NumStreams,s.StreamIndex,s.Seed,s.Params);
                if ~isempty(randnalg), set(s,'NormalTransform',randnalg); end
                streams{i} = s;
            end
            
            if celloutput
                varargout{1} = streams;
            else
                varargout = streams;
            end
        end
                
        function list
%RANDSTREAM.LIST List available random number generator algorithms.
%   RandStream.LIST lists all the generator algorithms that may be used when
%   creating a random number stream with RandStream or RandStream.CREATE.
%   See <a href="matlab:helpview([docroot '\techdoc\math\math.map'],'choose_random_number_generator')">Choosing a Random Number Generator</a> for details on these generator
%   algorithms.
%
%   See also RANDSTREAM, RANDSTREAM.CREATE.
            genNames = num2cell(char(strcat(RandStream.BuiltinTypes,':')),2);
            genDescrs = RandStream.BuiltinDescrs;
            [~,j] = sort(genNames); % display them sorted by generator name
            fprintf('\n%s\n\n',getString(message('MATLAB:RandStream:list:AvailableGenerators')));
            for i = 1:length(genNames)
                fprintf('%s  %s\n',genNames{j(i)},getString(message(genDescrs{j(i)})));
            end
        end
        
        function old = setGlobalStream(stream)
%RANDSTREAM.SETGLOBALSTREAM Replace the global random number stream.
%   PREVSTREAM = RandStream.SETGLOBALSTREAM(STREAM) sets STREAM as the current
%   global random number stream, i.e., designates it as the stream that the
%   RAND, RANDI, and RANDN functions will draw values from. PREVSTREAM is the
%   stream that was previously designated as the global random number stream.
%
%   RAND, RANDI, and RANDN all rely on the same stream of uniform pseudorandom
%   numbers, known as the global random number stream.  RAND draws one value
%   from that stream to generate each uniform value it returns;  RANDI draws
%   one uniform value from that stream to generate each integer value it
%   return; and RANDN draws one or more uniform values to generate each normal
%   value it returns.  Note that there are also RAND, RANDI, and RANDN methods
%   for which you specify a specific random stream from which to draw values.
%
%   The RNG function is a shorter alternative for many uses of
%   RANDSTREAM.setGlobalStream.
%
%   See also RNG, RANDSTREAM, RANDSTREAM.GETGLOBALSTREAM,
%            RANDFUN/RAND, RANDFUN/RANDN, RANDFUN/RANDI.
            if nargout > 0
                old = localGetSetGlobalStream();
            end
            localGetSetGlobalStream(stream);
        end

        function stream = getGlobalStream
%RANDSTREAM.GETGLOBALSTREAM Get the current global random number stream.
%   STREAM = RandStream.GETGLOBALSTREAM returns the current global random
%   number stream, i.e., the stream that the RAND, RANDI, and RANDN functions
%   draw values from.
%
%   RAND, RANDI, and RANDN all rely on the same stream of uniform pseudorandom
%   numbers, known as the global random number stream.  RAND draws one value
%   from that stream to generate each uniform value it returns;  RANDI draws
%   one uniform value from that stream to generate each integer value it
%   return; and RANDN draws one or more uniform values to generate each normal
%   value it returns.  Note that there are also RAND, RANDI, and RANDN methods
%   for which you specify a specific random stream from which to draw values.
%
%   The RNG function is a shorter alternative for many uses of
%   RANDSTREAM.getGlobalStream.
%
%   See also RNG, RANDSTREAM, RANDSTREAM.SETGLOBALSTREAM,
%            RANDFUN/RAND, RANDFUN/RANDN, RANDFUN/RANDI.
            stream = localGetSetGlobalStream();
        end
    end
    
    methods(Access='public')
        function s = RandStream(type, varargin)
%RANDSTREAM Create a random number stream.
%   S = RandStream('GENTYPE') creates a random number stream that uses the
%   uniform pseudorandom number generator algorithm specified by GENTYPE.
%   Type "RandStream.list" for a list of possible values for GENTYPE, or
%   see <a href="matlab:helpview([docroot '\techdoc\math\math.map'],'choose_random_number_generator')">Choosing a Random Number Generator</a> for details on these generator
%   algorithms.
%
%   One you have created a random stream, you can use RANDSTREAM.setGlobalStream
%   to make it the global stream, so that RAND, RANDI, and RANDN draw values
%   from it.
%
%   [ ... ] = RandStream('GENTYPE', 'PARAM1',val1, 'PARAM2',val2, ...) allows
%   you to specify optional parameter name/value pairs to control creation of
%   the stream.  Parameters are:
%
%      Seed            - a non-negative scalar integer seed with which to
%                        initialize the stream, or 'shuffle' to create a seed
%                        based on the current time.  Default is 0.
%      NormalTransform - the transformation algorithm that RANDN(S, ...) uses
%                        to generate normal pseudorandom values from uniform
%                        pseudorandom values.  The property value is one of
%                        'Ziggurat' (the default), 'Polar', or 'Inversion'.
%
%   Streams created using RandStream may not be independent from each other.
%   Use RandStream.CREATE to create multiple streams that are independent.
%
%   Examples:
%
%      Create a random number stream, make it the global stream, and save and
%      restore its state to reproduce the output of RANDN:
%         s = RandStream('mrg32k3a');
%         RandStream.setGlobalStream(s);
%         savedState = s.State;
%         z1 = randn(1,5)
%         s.State = savedState;
%         z2 = randn(1,5) % z2 contains exactly the same values as z1
%
%      Return RAND, RANDI, and RANDN to their default startup settings:
%         s = RandStream('mt19937ar','Seed',0)
%         RandStream.setGlobalStream(s);
%
%      Replace the current global random number stream with a stream whose
%      seed is based on the current time, so RAND, RANDI, and RANDN will
%      return different values in different MATLAB sessions.  NOTE: It is
%      usually not desirable to do this more than once per MATLAB session.
%         s = RandStream('mt19937ar','Seed','shuffle');
%         RandStream.setGlobalStream(s);
%
%   See also RANDSTREAM, RANDSTREAM.CREATE, RANDSTREAM.LIST, RNG,
%            RANDSTREAM.GETGLOBALSTREAM, RANDSTREAM.SETGLOBALSTREAM,
%            RANDSTREAM/RAND, RANDSTREAM/RANDI, RANDSTREAM/RANDN.

            if nargin < 1
                error(message('MATLAB:RandStream:TooFewInputs'));
            end
            
            pnames = {'seed' 'normaltransform' 'parameters'};
            dflts =  {    0                []           [] };
            [seed,randnalg,params] = getargs(pnames, dflts, varargin{:});
            
            if ~ischar(type)
                error(message('MATLAB:RandStream:InvalidRNGType'));
            end
            if ischar(seed) && isequal(lower(seed),'shuffle')
                seed = RandStream.shuffleSeed;
            elseif ~isnumeric(seed) || ~isreal(seed) ||~isscalar(seed) || ~(0<=seed && seed<2^32)
                % Allow non-integer seed so that sum(100*clock) works.  Will truncate below.
                error(message('MATLAB:RandStream:BadSeed'));
            end
            
            if isempty(params)
                % none given, it will be defaulted to zero below
            elseif ~isnumeric(params) || ~isreal(params) || ~isvector(params) ...
                                      || ~all(params == round(params)) || ~all(params >= 0)
                error(message('MATLAB:RandStream:BadParams'));
            elseif any(strcmpi(type,RandStream.BuiltinTypes))
                error(message('MATLAB:RandStream:ParamNotValid', type));
            end    
            
            s.Type = RandStream.algName(type(:)');
            s.Seed = uint32(floor(seed)); % truncate if not integer
            s.Params = uint64(params); % possibly empty
            s.NumStreams = uint64(1);
            s.StreamIndex = uint64(1); % stored one-based
            s.SpawnIncr = uint64(1);
            s.StreamID = builtin('_RandStream_create_mex',s.Type,s.NumStreams,s.StreamIndex,s.Seed,s.Params);
            if ~isempty(randnalg), set(s,'NormalTransform',randnalg); end
        end
        
        % Display method
        function disp(s)
            isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');

            if (isLoose)
                fprintf('\n');
            end
            if isvalid(s) && s.StreamID>0
                if s == localGetSetGlobalStream()
                    fprintf('%s\n',getString(message('MATLAB:RandStream:disp:HeaderGlobal',s.Type)));
                else
                    fprintf('%s\n',getString(message('MATLAB:RandStream:disp:Header',s.Type)));
                end
                if isequal(lower(s.Type),'legacy')
                    state = builtin('_RandStream_getset_mex','state',s.StreamID);
                    switch state{1}(1)
                        case 1, randAlg = getString(message('MATLAB:RandStream:disp:V4UniformDescription'));
                        case 2, randAlg = getString(message('MATLAB:RandStream:disp:V5UniformDescription'));
                        case 3, randAlg = getString(message('MATLAB:RandStream:disp:V7p4UniformDescription'));
                    end
                    switch state{1}(2)
                        case 1, randnAlg = getString(message('MATLAB:RandStream:disp:V4NormalDescription'));
                        case 2, randnAlg = getString(message('MATLAB:RandStream:disp:V5NormalDescription'));
                    end
                    fprintf('  %s\n',getString(message('MATLAB:RandStream:disp:LegacyAlgs',randAlg,randnAlg)));
                else
                    if s.NumStreams > 1
                        fprintf('      StreamIndex: %d\n',s.StreamIndex);
                        fprintf('       NumStreams: %d\n',s.NumStreams);
                    end
                    fprintf('             Seed: %d\n',s.Seed);
                    fprintf('  NormalTransform: %s\n',get(s,'NormalTransform'));
                    if isscalar(s.Params)
                        fprintf('        Parameter: %s\n',mat2str(s.Params));
                    elseif ~isempty(s.Params)
                        fprintf('       Parameters: %s\n',mat2str(s.Params));
                    end
                end
            else
                error(message('MATLAB:RandStream:InvalidHandle'));
            end
        end
        
        % Subsref/Subsasgn
        function [varargout] = subsref(a,s)
            switch s(1).type
            case '()'
                error(message('MATLAB:RandStream:subsref:SubscriptReferenceNotAllowed'))
            case '{}'
                error(message('MATLAB:RandStream:subsref:CellReferenceNotAllowed'))
            case '.'
                if ~isvalid(a) || a.StreamID==0
                    error(message('MATLAB:RandStream:InvalidHandle'));
                end
                switch s(1).subs
                case RandStream.VisibleMethods
                    if isscalar(s)
                        args = {};
                    else
                        if length(s) > 2 || ~isequal(s(2).type, '()')
                            error(message('MATLAB:RandStream:subsref:InvalidMethodSyntax'));
                        end
                        args = s(2).subs;
                    end
                    [varargout{1:nargout}] = feval(s(1).subs,a,args{:});
                otherwise
                    if (length(s) > 1)
                        error(message('MATLAB:RandStream:subsref:InvalidPropertySyntax'));
                    end
                    switch s(1).subs
                    case 'State'
                        varargout{1} = builtin('_RandStream_getset_mex','state',a.StreamID);
                    case 'Substream'
                        varargout{1} = builtin('_RandStream_getset_mex','substream',a.StreamID);
                    case 'NormalTransform'
                        varargout{1} = builtin('_RandStream_getset_mex','randnalg',a.StreamID);
                    case 'Antithetic'
                        varargout{1} = builtin('_RandStream_getset_mex','antithetic',a.StreamID);
                    case 'FullPrecision'
                        varargout{1} = builtin('_RandStream_getset_mex','fullprecision',a.StreamID);
                    case {'Type' 'Seed' 'NumStreams' 'StreamIndex'}
                        varargout{1} = a.(s(1).subs);
                    otherwise
                        error(message('MATLAB:RandStream:subsref:UnrecognizedProperty', s(1).subs));
                    end
                end
            end
        end
        function c = subsasgn(a,s,b)
            switch s(1).type
            case '()'
                error(message('MATLAB:RandStream:subsasgn:SubscriptAssignmentNotAllowed'));
            case '{}'
                error(message('MATLAB:RandStream:subsasgn:CellAssignmentNotAllowed'));
            case '.'
                if ~isvalid(a) || a.StreamID==0
                    error(message('MATLAB:RandStream:InvalidHandle'));
                elseif (length(s) > 1)
                    error(message('MATLAB:RandStream:subsasgn:InvalidPropertySyntax'));
                end
                switch s(1).subs
                case 'State'
                    builtin('_RandStream_getset_mex','state',a.StreamID,b);
                case 'Substream'
                    builtin('_RandStream_getset_mex','substream',a.StreamID,b);
                case 'NormalTransform'
                    builtin('_RandStream_getset_mex','randnalg',a.StreamID,b);
                case 'Antithetic'
                    builtin('_RandStream_getset_mex','antithetic',a.StreamID,b);
                case 'FullPrecision'
                    builtin('_RandStream_getset_mex','fullprecision',a.StreamID,b);
                case 'Seed'
                    error(message('MATLAB:RandStream:subsasgn:IllegalSeedAssignment'));
                case {'Type' 'NumStreams' 'StreamIndex'}
                    error(message('MATLAB:RandStream:subsasgn:IllegalPropertyAssignment', s(1).subs));
                otherwise
                    error(message('MATLAB:RandStream:subsasgn:UnrecognizedProperty', s(1).subs));
                end
                c = a;
            end
        end
    end
    
    methods(Access='protected')
        function advance(s,nsteps)
            builtin('_RandStream_advance',s,nsteps);
        end
    end
    
    methods(Hidden=true, Static=true, Access='public')
        function a = loadobj(b)
            if isequal(b.Type,'')
                % no point in throwing an error here
                warning(message('MATLAB:RandStream:InvalidHandle'));
                a = RandStream.newarray(1);
                return
            end
            
            try
                a = RandStream.newarray(1);
                a.Type = b.Type;
                a.Seed = b.Seed;
                a.Params = b.Params;
                a.NumStreams = b.NumStreams;
                a.StreamIndex = b.StreamIndex;
                a.SpawnIncr = b.SpawnIncr;
                a.StreamID = builtin('_RandStream_create_mex',a.Type,a.NumStreams,a.StreamIndex,a.Seed,a.Params);
                set(a,'Substream',b.Substream); % do this before state
                set(a,'State',b.State);
                if isfield(b,'NormalTransform')
                    set(a,'NormalTransform',b.NormalTransform);
                else
                    set(a,'NormalTransform',b.RandnAlg); % an old saved object
                end
                set(a,'Antithetic',b.Antithetic);
                set(a,'FullPrecision',b.FullPrecision);
            catch me
                warning(message('MATLAB:RandStream:loadobj:LoadError',me.message));
                a = RandStream.newarray(1);
            end
        end
        
        function seed = shuffleSeed
            % Create a seed based on 1/100ths of a second, this repeats itself
            % about every 497 days.
            
            % Wait until the time changes enough to guarantee a unique seed for each call.
            seed0 = mod(floor(now*8640000),2^31-1); % traditionally this was sum(100*clock)
            for i = 1:100
                seed = mod(floor(now*8640000),2^31-1);
                if seed ~= seed0, break; end
                pause(.01); % smallest recommended interval
            end
        end
        
        function name = compatName(name)
            % Convert real algorithm names to friendlier names.
            i = find(strcmpi(name,RandStream.BuiltinTypes)); % exact match
            if isscalar(i)
                name = RandStream.CompatNames{i};
            else % isempty(i)
                % The algorithm must not have a friendlier name
            end
        end
        
        function name = algName(name)
            if strcmpi(name,'v4uniform') || strcmpi(name,'v4normal')
                % Be forgiving and accept v4uniform and v4normal, but do not
                % accept v5 by itself.
                name = 'v4';
            elseif strcmpi(name, 'legacy')
                error(message('MATLAB:RandStream:CantCreateLegacy'));
            end
            
            % Convert friendly names to real algorithm names.  Do not allow
            % partial match, to prevent potential conflict with new generators.
            i = find(strcmpi(name,RandStream.CompatNames));
            if isscalar(i)
                name = RandStream.BuiltinTypes{i};
            else % isempty(i)
                % Assume it's an algorithm name
            end
        end
    end
        
    methods(Static=true, Access='protected')
        function globe = createGlobalStream()
            globe = RandStream.newarray(1);
            globe.Params = [];
            globe.NumStreams = uint64(1);
            globe.StreamIndex = uint64(1);
            globe.SpawnIncr = uint64(0);
            [globe.StreamID,globe.Type,globe.Seed] = builtin('_RandStream_getset_mex','defaultstream');
            % antithetic, normalTransform, substream, and state come from existing defaultstream C++ object
        end
        function legacy = createLegacyStream()
            legacy = RandStream.newarray(1);
            legacy.Type = 'legacy';
            legacy.Seed = uint32(0); % this will usually be a lie
            legacy.Params = [];
            legacy.NumStreams = uint64(1);
            legacy.StreamIndex = uint64(1);
            legacy.SpawnIncr = uint64(0);
            legacy.StreamID = builtin('_RandStream_getset_mex','legacystream');
            % antithetic, normalTransform, substream, and state come from existing legacystream C++ object
        end
    end
    
    methods(Hidden=true, Access='public')
        % Destructor
        function  delete(s)
            builtin('_RandStream_delete',s);
        end
        function b = saveobj(a)
            if isequal(a.Type,'legacy')
                % no point in throwing an error here
                warning(message('MATLAB:RandStream:saveobj:SavingLegacyStream'));  
                b = struct('Type','', 'StreamID',0);
                return
            end
            
            try
                b = get(a);

                % These are not get-able properties
                b.Params = a.Params;
                b.SpawnIncr = a.SpawnIncr;
                
                % Do not save a.StreamID, it will be meaningless
            catch me
                warning(message('MATLAB:RandStream:saveobj:SaveError',me.message));  
                b = struct('Type','', 'StreamID',0);
            end
        end
            

        % Methods that we inherit from base handle class, but do not want
        function a = fields(varargin),          throwUndefinedError; end %#ok<STOUT>     
        function a = lt(varargin),              throwUndefinedError; end %#ok<STOUT>
        function a = le(varargin),              throwUndefinedError; end %#ok<STOUT>
        function a = ge(varargin),              throwUndefinedError; end %#ok<STOUT>
        function a = gt(varargin),              throwUndefinedError; end %#ok<STOUT>
        function a = permute(varargin),         throwUndefinedError; end %#ok<STOUT>
        function a = reshape(varargin),         throwUndefinedError; end %#ok<STOUT>
        function a = transpose(varargin),       throwUndefinedError; end %#ok<STOUT>
        function a = ctranspose(varargin),      throwUndefinedError; end %#ok<STOUT>
        function [a,b] = sort(varargin),        throwUndefinedError; end %#ok<STOUT>
        
        % Inherit default EQ, NE, ISVALID, FIELDNAMES, FINDPROP,
        % ADDLISTENER, NOTIFY from base handle class
        
        % All of these have to be taken away because they can create
        % non-scalar or empty arrays of objects.
        function a = findobj(varargin),         throwUndefinedError; end %#ok<STOUT>
        function a = cat(varargin),             throwNoCatError();   end %#ok<STOUT>
        function a = horzcat(varargin),         throwNoCatError();   end %#ok<STOUT>
        function a = vertcat(varargin),         throwNoCatError();   end %#ok<STOUT>
    end
    methods(Hidden = true, Static = true)
        function a = empty(varargin) %#ok<STOUT>
            error(message('MATLAB:RandStream:NoEmptyAllowed'));
        end
    end
end


function throwNoCatError()
me = MException('MATLAB:RandStream:NoCatAllowed', ...
                getString(message('MATLAB:RandStream:NoCatAllowed')));
throwAsCaller(me);
end

function throwUndefinedError()
st = dbstack;
name = regexp(st(2).name,'\.','split');
me = MException('MATLAB:RandStream:UndefinedFunction', ...
                getString(message('MATLAB:RandStream:UndefinedFunction',name{2})));
throwAsCaller(me);
end


function names = getMethodNames
    names = methods('RandStream');
end


function stream = localGetSetGlobalStream(stream)
persistent globe;
persistent legacy;
mlock

% If the local handle to the global/legacy stream is empty, this is
% the first time through, so we need to create the stream.  If the
% local handle is invalid, the stream must have been deleted at some
% point, so we need to get hold of the new stream that was created
% automatically underneath.
if builtin('_RandStream_inLegacyMode')
    if isempty(legacy) || ~isvalid(legacy)
        legacy = RandStream.createLegacyStream();
    end
    globe = legacy;
elseif isempty(globe) || ~isvalid(globe)
    globe = RandStream.createGlobalStream();
end

if nargin == 0
    stream = globe;
elseif isa(stream,'RandStream') && isvalid(stream)
    builtin('_RandStream_getset_mex','defaultstream', stream.StreamID);
    globe = stream;
else
    error(message('MATLAB:RandStream:setglobalstream:InvalidInput'));
end
end


function [varargout] = getargs(pnames,dflts,varargin)

% Initialize some variables
nparams = length(pnames);
varargout = dflts;
unrecog = {};
nargs = length(varargin);

% Must have name/value pairs
if mod(nargs,2)~=0
    error(message('MATLAB:RandStream:WrongNumberArgs'));
else
    % Process name/value pairs
    for j=1:2:nargs
        pname = varargin{j};
        if ~ischar(pname)
            error(message('MATLAB:RandStream:BadParamName'));
        end
        i = find(strncmpi(pname,pnames,length(pname)));
        if isscalar(i)
            varargout{i} = varargin{j+1};
        elseif isempty(i)
            error(message('MATLAB:RandStream:UnrecognizedParamName',pname));
        else
            error(message('MATLAB:RandStream:AmbiguousParamName',pname));
        end
    end
end

varargout{nparams+1} = unrecog;

end
