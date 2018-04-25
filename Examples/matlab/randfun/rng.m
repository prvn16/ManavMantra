function settings = rng(arg1,arg2)
%RNG Control the random number generator used by RAND, RANDI, and RANDN.
%   RNG(SD) seeds the random number generator using the non-negative
%   integer SD so that RAND, RANDI, and RANDN produce a predictable
%   sequence of numbers.
%
%   RNG('shuffle') seeds the random number generator based on the current
%   time so that RAND, RANDI, and RANDN produce a different sequence of
%   numbers after each time you call RNG.
%
%   RNG(SD,GENERATOR) and RNG('shuffle',GENERATOR) additionally specify the
%   type of the random number generator used by RAND, RANDI, and RANDN.
%   GENERATOR is one of:
%
%       Generator              Description
%      ------------------------------------------------------------------ 
%      'twister'               Mersenne Twister
%      'simdTwister'           SIMD-oriented Fast Mersenne Twister
%      'combRecursive'         Combined Multiple Recursive
%      'multFibonacci'         Multiplicative Lagged Fibonacci
%      'v5uniform'             Legacy MATLAB 5.0 uniform generator
%      'v5normal'              Legacy MATLAB 5.0 normal generator
%      'v4'                    Legacy MATLAB 4.0 generator
%
%   RNG('default') puts the settings of the random number generator used by
%   RAND, RANDI, and RANDN to their default values so that they produce the
%   same random numbers as if you restarted MATLAB. In this release, the
%   default settings are the Mersenne Twister with seed 0.
%
%   SCURR = RNG returns the current settings of the random number generator
%   used by RAND, RANDI, and RANDN. The settings are returned in a
%   structure SCURR with fields 'Type', 'Seed', and 'State'.
%    
%   RNG(S) restores the settings of the random number generator used by
%   RAND, RANDI, and RANDN back to the values captured previously by
%   S = RNG.
%
%   SPREV = RNG(...) returns the previous settings of the random number
%   generator used by RAND, RANDI, and RANDN before changing the settings.
%
%      Example 1: Retrieve and Restore Generator Settings
%         s = rng           % get the current generator settings
%         x = rand(1,5)     % RAND generates some values
%         rng(s)            % restore the generator settings
%         y = rand(1,5)     % generate the same values so x and y are equal
% 
%      Example 2: Restore Settings for Legacy Generator
%         prevS = rng(0,'v5uniform') % use legacy generator, save previous settings
%         x = rand                   % legacy startup value .9501
%         rng(prevS)                 % restore the previous settings
%
%   See <a href="matlab:helpview([docroot '\techdoc\math\math.map'],'update_random_number_generator')">Replace Discouraged Syntaxes of rand and randn</a> to use RNG to replace
%   RAND or RANDN with the 'seed', 'state', or 'twister' inputs.
%
%   See also RAND, RANDI, RANDN, RandStream, NOW.


%   See <a href="http://www.mathworks.com/access/helpdesk/help/techdoc/math/brn4ixh.html#brvku_2">Choosing a Random Number Generator</a> for details on these generators.

%   Copyright 2010-2011 The MathWorks, Inc. 

if nargin == 0 || nargout > 0
    % With no inputs, settings will be returned even when there's no outputs
    s = RandStream.getGlobalStream();
    if strcmpi(s.Type,'legacy');
        settings = struct('Type','Legacy','Seed',legacySeedStr(),'State',{s.State});
    else
        settings = struct('Type',RandStream.compatName(s.Type),'Seed',s.Seed,'State',{s.State});
    end
end

if nargin > 0
    if isstruct(arg1) && isscalar(arg1)
        inSettings = arg1;
        if nargin > 1
            error(message('MATLAB:rng:maxrhs'));
        elseif ~isempty(setxor(fieldnames(inSettings),{'Type','Seed','State'}))
            throw(badSettingsException);
        end
        if strcmpi(inSettings.Type,'legacy')
            handleLegacyStruct(inSettings); % restores the legacy stream state
        else
            % Create a new stream as specified, then set its state
            try
                s = RandStream(inSettings.Type,'Seed',inSettings.Seed);
                s.State = inSettings.State;
            catch me
                throw(badSettingsException);
            end
            RandStream.setGlobalStream(s);
        end
    else
        if isnumeric(arg1) && isscalar(arg1) % rng(seed) or rng(seed,gentype)
            seed = arg1;
            if nargin == 1
                gentype = getCurrentType;
            else
                gentype = arg2;
                if ~ischar(gentype)
                    error(message('MATLAB:rng:badSecondOpt'));
                elseif strcmpi(gentype,'legacy')
                    errorLegacyGenType;
                end
            end
        elseif ischar(arg1)
            if strcmpi(arg1,'shuffle') % rng('shuffle') or rng('shuffle',gentype)
                seed = RandStream.shuffleSeed;
                if nargin == 1
                    gentype = getCurrentType;
                else
                    gentype = arg2;
                    if ~ischar(gentype)
                        error(message('MATLAB:rng:badSecondOpt'));
                    elseif strcmpi(gentype,'legacy')
                        errorLegacyGenType;
                    end
                end
            elseif strcmpi(arg1,'default') % rng('default')
                if nargin > 1
                    error(message('MATLAB:rng:maxrhs'));
                end
                seed = 0;
                gentype = RandStream.DefaultStartupType;
            else % possibly rng(gentype) or rng(gentype,seed)
                error(message('MATLAB:rng:badFirstOpt'));
            end
        else
            error(message('MATLAB:rng:badFirstOpt'));
        end
        
        % Create a new stream using the specified seed
        try
            s = RandStream(gentype,'Seed',seed); % RandStream handles the compatibility names
        catch me
            if strcmp(me.identifier,'MATLAB:RandStream:create:UnknownRNGType')
                error(message('MATLAB:rng:unknownRNGType',gentype));
            elseif strcmp(me.identifier,'MATLAB:RandStream:BadSeed')
                error(message('MATLAB:rng:badSeed'));
            else
                throw(me);
            end
        end
        RandStream.setGlobalStream(s);
    end
end


% This function allows a caller to save and restore legacy stream state
% structure even when MATLAB is switched out of legacy mode in between the
% saving and restoring.
function handleLegacyStruct(s)
% If the struct appears valid, activate the legacy stream, and set
% its state(s) from the struct.
if isequal(s.Seed,legacySeedStr()) % the legacy stream struct does not store a seed
    rand('state',0); %#ok<RAND>
    legacy = RandStream.getGlobalStream();
    try
        legacy.State = s.State;
    catch me % the state field must have been altered
        throwAsCaller(badSettingsException);
    end
else % the seed field must have been altered
    throwAsCaller(badSettingsException);
end


function e = badSettingsException
e = MException('MATLAB:rng:badSettings',getString(message('MATLAB:rng:badSettings')));


function str = legacySeedStr
str = 'Not applicable';


function gentype = getCurrentType
curr = RandStream.getGlobalStream();
gentype = curr.Type;
if strcmpi(gentype,'legacy')
    % Disallow reseeding when in legacy mode, even with a zero seed
    suggestion = RandStream.compatName(RandStream.DefaultStartupType);
    throwAsCaller(MException('MATLAB:rng:reseedLegacy',getString(message('MATLAB:rng:reseedLegacy',suggestion))));
end

% Disallow specifying 'legacy' as a generator type, even with a zero seed
function errorLegacyGenType
suggestion = RandStream.compatName(RandStream.DefaultStartupType);
throwAsCaller(MException('MATLAB:rng:createLegacy',getString(message('MATLAB:rng:createLegacy',suggestion))));
