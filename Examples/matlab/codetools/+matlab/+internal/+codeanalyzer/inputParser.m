classdef inputParser < handle
% MATLAB.INTERNAL.CODEANALYZER.INPUTPARSER parses the inputs to
% mlint/checkcode. It identifies the different inputs sorts them into
% the following bins: files to be anaylzed, input options, text (if
% any).
%
% The following properties of the class have a PUBLIC GET access and
% can be read by its clients.
% matlab.internal.codeanalyzer.inputParser properties:
%   files - The list of files that need to be analyzed.
%   fileListWasCell - A boolean indicating whether or not the input was
%                     a cell array.
%   outputType - A string representing the requested output type
%   text - A boolean indicating whether -text was specified in the
%          input argument.
%   doNotResolveFileNames - A boolean indiciating that the class need
%                           not resolve the file names to obtain fully
%                           qualified names.`
%   options - A cell array of input options (e.g. -id, -string etc.)
%   msgIdsWereRequested - A boolean indicating whether or not -id was
%                         specified.
%
% matlab.internal.codeanalyzer.inputParser methods:
%   inputParser - The constructor
%   parse - Parse the inputs
%
% See also, CHECKCODE

% Copyright 2014 MathWorks.

    properties( SetAccess=private, GetAccess=public )
        files;                  % List of files to be analyzed
        fileListWasCell;        % True if file list (given to checkode) was a cell array
        outputType;             % The output type (string, display, or struct)
        hasText;                % True if -text was specified
        doNotResolveFileNames;  % True if input was text or if -fullpath was specified
        options;                % Flags to be passed to mlintmex
        msgIdsWereRequested;    % True if -id was specified
    end

    methods

        function obj = inputParser
        % The default constructor. It sets the default values of the
        % all member variables.

            obj.files = {};
            obj.fileListWasCell = false;
            obj.outputType = '';
            obj.hasText = false;
            obj.doNotResolveFileNames = true;
            obj.options = {};
            obj.msgIdsWereRequested = false;
        end

        %------------------------------------------------------------------

        function parse( this, nout, varargin )
        % PARSE parses all the input arguments to checkcode/mlint and
        % and store them in the appropriate member variable.
        % Input arguments:
        % nout: The number of output arguments requested from
        %       checkcode/mlint
        % varargin: Input arguments to mlint/checkcode.

            nargs = varargin;

            % Look for cell array of files and save them in the variable files, at the
            % same time remove them from nargs. There could be file names outside the
            % cell array.
            nargs = this.extractCellArrayOfFiles( nargs );

            % Determine the outputType and delete the flags from nargs
            nargs = this.determineOutputType( nout, nargs );

            % Extract all inputs begining with a "-" and store them in the variable
            % inputArgs (except "-text"). Remove these arguments from nargs.
            nargs = this.parseAllRemainingOptions( nargs );

            % If there are any arguments left to parse they must be files
            % and/or the text body.
            if( ~isempty( nargs ) )
                if( this.fileListWasCell )
                    ignoredArgs = sprintf( ' %s', nargs{:} );
                    warning( message( 'MATLAB:mlint:UnusedArgs', ignoredArgs ) );
                else
                    this.findTextAndFiles( nargs );
                end
            end

            if( ~this.fileListWasCell && isempty( this.files ) )
                error( message( 'MATLAB:mlint:NoFile' ) );
            end

            % If output type is set to struct but input args does not contain
            % -struct (either because we removed it or it wasn't supplied), then
            % add -struct to input args.
            if( strcmp( this.outputType, 'struct' ) && ~any( strcmp( this.options, '-struct' ) ) )
                this.options = [this.options {'-struct'}];
            end

            this.addDefaultConfigIfNoneWasSpecified();

            this.resolveFileNames();

        end

        %------------------------------------------------------------------

    end

    methods( Access=private )

        function nargs = extractCellArrayOfFiles( this, nargs )
            cellArgIdx = cellfun( @iscell, nargs );
            if( any( cellArgIdx ) )
                this.files = nargs{cellArgIdx};
                nargs = nargs( ~cellArgIdx );
                this.fileListWasCell = true;
            else
                this.fileListWasCell = false;
            end
        end

        %------------------------------------------------------------------

        function nargs = determineOutputType( this, nout, nargs )

            this.outputType = getDefaultOutputType( nout );

            optIdx = cellfun( @(x)( ~isempty(x) && x(1) == '-' ), nargs );
            if( ~any( optIdx ) )
                return;
            end

            idx = find( optIdx );
            filterMask = ones( 1, numel(nargs) );
            for i = 1:numel( idx )
                switch( nargs{idx(i)} )
                  case '-string'
                    this.outputType = 'string';
                    filterMask( idx(i) ) = 0;
                  case { '-disp', '-display' }
                    this.outputType = 'display';
                    filterMask( idx(i) ) = 0;
                  case '-struct'
                    this.outputType = 'struct';
                    filterMask( idx(i) ) = 0;
                end
            end
            nargs = nargs( logical( filterMask  ) );

        end

        %------------------------------------------------------------------

        function nargs = parseAllRemainingOptions( this, nargs )
            optArgIdx = cellfun( @(x)( ~isempty(x) && x(1) == '-' ), nargs );
            if( any( optArgIdx ) )
                this.options = [this.options nargs( optArgIdx )];
                nargs = nargs( ~optArgIdx );
            end

            % Extract -fullpath and -text and set doNotResolvePaths
            fPathIdx = cellfun( @(x)strcmp( x, '-fullpath' ), this.options );
            this.options = this.options( ~fPathIdx );

            txtIdx  = cellfun( @(x)strcmp( x, '-text' ), this.options );
            this.hasText = any( txtIdx );

            this.doNotResolveFileNames = any( fPathIdx ) || this.hasText || ( this.fileListWasCell && isempty( this.files ) );
            this.msgIdsWereRequested = any( strcmp( this.options, '-id' ) );

        end

        %------------------------------------------------------------------

        function findTextAndFiles( this, nargs )
            this.files = nargs;
        end

        %------------------------------------------------------------------

        function addDefaultConfigIfNoneWasSpecified(this)
        %s = ~isempty( cellfun( @(x)regexp( x, '-config', 'once' ), this.options, 'UniformOutput', false ) );
            s = cellfun( @(x)~isempty( regexp( x, '-config', 'once' ) ), this.options, 'UniformOutput', false );
            if( any( cell2mat( s ) ) )
                return;
            end

            cfgArg = sprintf( '-config=%s', getDefaultCheckCodeConfig() );
            this.options = [this.options {cfgArg}];
        end

        %------------------------------------------------------------------

        function resolveFileNames( this )
            if( this.doNotResolveFileNames )
                return;
            end
            for i = 1:numel( this.files )
                this.files{i} = matlab.internal.codeanalyzer.getFullyQualifiedName( this.files{i} );
            end
        end

        %------------------------------------------------------------------

    end

end

%=========================================================================%
%                          HELPER FUNCTIONS                               %
%=========================================================================%

function outputType = getDefaultOutputType( nout )
% GETDEFAULTOUTPUTTYPE returns the default output type based on number of
% input arguments

    if( nout == 0 )
        outputType = 'display';
    else
        outputType = 'struct';
    end

end

%--------------------------------------------------------------------------

function defaultCfgFile = getDefaultCheckCodeConfig()
% GETDEFAULTCONFIG returns the default config file used to be used by
% checkcode. If one is not found then checkcode uses the factory settings.

    if( usejava('jvm') )
        defaultCfgFile = char( com.mathworks.widgets.text.mcode.MLintPrefsUtils.getActiveConfiguration.getFile().getAbsolutePath() );
    else
        cfgFileName = 'MLintDefaultSettings.txt';
        defaultCfgFile = fullfile( prefdir, cfgFileName );
        if( ~exist( defaultCfgFile, 'file' ) )
            defaultCfgFile = 'factory';
        end
    end

end

%--------------------------------------------------------------------------
