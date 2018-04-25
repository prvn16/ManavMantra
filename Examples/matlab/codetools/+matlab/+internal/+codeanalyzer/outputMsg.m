classdef outputMsg < handle
% MATLAB.INTERNAL.CODEANALYZER.OUTPUTMSG is an abstract base class to
% output messages returned by the built-in code analyzer.
%
% The following properties have a public GET access.
% matlab.internal.codeanalyzer.ouputMsg properties:
%   fileListWasCell - Boolean indicating whether the input was a cell
%                     array
%   fileList - The list of files that was analyzed by code analyzer
%   inputWasText - A boolean indicating whether -text was specified
%   idsWereRequested - A boolean indicating whether -id was specified
%
% The following *protected* methods are used by the concrete dervied
% classes:
% matlab.internal.codeanalyzer.outputMsg methods:
%   outputMsg - The constructor
%   wasFileListACellArray - Returns the value of fileListWasCell.
%   handleEmptyInputFileList - A method to handle output if an empty
%                              cell array was specified as input.

% Copyright 2014 MathWorks.

    properties( SetAccess=private, GetAccess=public )
        fileListWasCell;  % True if input file list to checkcode/mlint was a cell array
        fileList;         % List of files analyzed by code analyzer
        inputWasText;     % True if -text was specified
        idsWereRequested; % True if -id was specified
    end

    methods

        % Set methods for member variables

        function set.fileListWasCell( this, tf )
            this.fileListWasCell = tf;
        end

        %------------------------------------------------------------------

        function set.fileList( this, files )
            this.fileList = files;
        end

        %------------------------------------------------------------------

    end

    methods( Access=protected )

        function obj = outputMsg( wasCell, files, text, msgIdsWereRequested )
        % OUTPUTMSG is the protected constructor.
        % Input args:
        %   wasCell: Boolean indicating whether file list was a cell
        %            array
        %   files: Cell array of file names
        %   text: Boolean indicating whether -text was specified
        %   msgIdsWereRequested: Boolean indiciating whether -id was
        %                        specified

            obj.fileListWasCell = logical(wasCell);
            obj.fileList = files;
            obj.inputWasText = text;
            obj.idsWereRequested = msgIdsWereRequested;
        end

        %------------------------------------------------------------------

        function tf = wasFileListACellArray( this )
        % WASFILELISTACELLARRAY returns the the value in the member
        % variable fileListWasCell.
            tf = this.fileListWasCell;
        end

        %------------------------------------------------------------------

        function tf = fileListWasAnEmptyCell( this )
            tf = this.wasFileListACellArray() && isempty( this.fileList );
        end

        %------------------------------------------------------------------

        function opMsg = handleEmptyInputFileList( this ) %#ok<MANU>
        % HANDLEEMPTYINPUTFILELIST handles then special case when input
        % to checkcode/mlint was an empty cell.
            opMsg = {};
        end

        %------------------------------------------------------------------

    end

    methods( Static )

        function types = getValidOutputTypes()
            types = { 'string', 'struct', 'disp' };
        end

    end

    methods( Abstract )
        output( this, msg );
    end

end
