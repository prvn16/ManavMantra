
%   Copyright 2014-2016 The MathWorks, Inc.

classdef returnMessageStruct < matlab.internal.codeanalyzer.outputMsg

    methods
        function obj = returnMessageStruct( wasCell, files, text, msgIdsWereRequested )
            obj@matlab.internal.codeanalyzer.outputMsg( wasCell, files, text, msgIdsWereRequested );
        end

        function opMsg = output( this, ipMsg )
            if( this.fileListWasAnEmptyCell() )
                opMsg = this.handleEmptyInputFileList();
                return;
            end

            idx = 0;
            opMsg = struct([]);
            for i = 1:numel( ipMsg )
                % The following if statement is here because the function:
                % s = mlintmex( '-struct', '-text', <some text>, <file> );
                % returns a cell array of size 2. The first element is a struct array
                % of messages, while the 2nd element is an empty array. We need to
                % remove this empty array
                if( ~isstruct( ipMsg{i} ) && isempty( ipMsg{i} ) )
                    continue;
                end
                idx = idx + 1;
                opMsg{idx, 1} = this.addLineAndColumnToStruct( ipMsg{i} );
            end

            opMsg = this.removeIdField( opMsg );

            if( ~this.fileListWasCell &&...
                    numel( opMsg ) == 1 && iscell( opMsg ) )
                opMsg = opMsg{1};
            end

        end
    end

    methods( Access = private )
        function msg = addLineAndColumnToStruct( this, msg )
            if( numel( msg ) == 0 )
                strFlds = {'message',{},'line',{},'column',{},'fix',{}};
                if( this.idsWereRequested )
                    strFlds = [ strFlds { 'id', {} } ];
                end
                if isfield(msg, 'severity')
                    strFlds = [ strFlds { 'severity', {} } ];
                end
                msg = struct( strFlds{:} );
                return;
            end

            for i = 1:numel( msg )
                loc = msg(i).loc;
                msg(i).line = loc(:,1);
                msg(i).column = loc( :, 2:3 );
            end

            msg = rmfield( msg, 'loc' );
        end

        function msg = removeIdField( this, msg )
            if( this.idsWereRequested )
                return;
            end
            if( iscell( msg ) )
                for i = 1:numel( msg )
                    msg{i} = this.removeIdField( msg{i} );
                end
            else
                if( isfield( msg, 'id' ) )      % We need this check because we could have created an empty struct without ID field in addLineAndColumnToStruct
                    msg = rmfield( msg, 'id' );
                end
            end

        end

    end

end
