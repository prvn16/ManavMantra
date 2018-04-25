classdef returnMessageString < matlab.internal.codeanalyzer.outputMsg
    
    methods
        function obj = returnMessageString( wasCell, files, text, msgIdsWereRequested )
            obj@matlab.internal.codeanalyzer.outputMsg( wasCell, files, text, msgIdsWereRequested );
        end
        function opMsg = output( this, ipMsg )
            if( this.fileListWasAnEmptyCell() )
                opMsg = this.handleEmptyInputFileList();
            else
                opMsg = ipMsg;
            end
        end
    end
    
end
