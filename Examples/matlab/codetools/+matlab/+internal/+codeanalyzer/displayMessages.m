classdef displayMessages < matlab.internal.codeanalyzer.outputMsg
    
    methods
        
        function obj = displayMessages( wasCell, files, text, msgIdsWereRequested )
            obj@matlab.internal.codeanalyzer.outputMsg( wasCell, files, text, msgIdsWereRequested );
        end
        
        function output( this, msg )
            
            if( this.fileListWasAnEmptyCell() || this.inputWasText || ~matlab.internal.display.isHot )
                disp( msg );
                return;
            end
            
            % We are looking for the following pattern in the output string:
            % ==== /some/file.m ====
            % The regular expressions are:
            % Regexp pattern for "==== " is (=+\s*)
            % Regexp pattern for " ====" is (\s*=+)
            %
            % Creating a pattern for the file name is difficult as it may contains
            % characters, spaces (may be), and slashes or back slashes. It may also
            % consist of special characters.Thus we use "." which matches any
            % character, so the pattern becomes (.+). However .+ will match everything
            % until it sees a new line; so we make it lazy (i.e. not greedy) by adding
            % a "?". Thus the pattern is (=+\s*)(.+?)(\s*=+)
            msgHeaderPattern = '(=+\s*)(.+?)(\s*=+)';
            
            
            st = regexp( msg, msgHeaderPattern );
            
            if( numel( this.fileList ) == 1 )
                lineHyperLinkReplacePattern = sprintf('<a href="matlab: opentoline(''%s'',$1)">L $1</a>', replaceBackSlashesWithSlashes( this.fileList{1} ) );
                msg = regexprep(msg,'L (\d+)', lineHyperLinkReplacePattern);
            else
                % Separate out each section
                % extract FileName
                % Add Hyperlink to file and lines
                msgStrCell = cell( 1, length( st ) );
                fileNamePattern = '=+\s*(?<fileName>.+?)\s*=+';
                for i = 1:length(st);
                    
                    if( i == length(st) )
                        msgStrCell{i} = msg( st(i):end );
                    else
                        msgStrCell{i} = msg( st(i):st(i+1)-1 );
                    end
                    
                    msgStr = msgStrCell{i};
                    
                    theFile = regexp( msgStr, fileNamePattern, 'names' );
                    
                    % In the string "==== filename ====", add hyperlink to the file
                    % name
                    fileHyperLinkReplacePattern = '$1<a href="matlab: edit(''$2'')">$2</a>$3';
                    msgStr = regexprep( msgStr, msgHeaderPattern, fileHyperLinkReplacePattern );
                    
                    % Add Hyperlinks in line numbers
                    lineHyperLinkReplacePattern = sprintf('<a href="matlab: opentoline(''%s'',$1)">L $1</a>', replaceBackSlashesWithSlashes( theFile.fileName ) );
                    msgStr = regexprep(msgStr,'L (\d+)', lineHyperLinkReplacePattern);
                    
                    msgStrCell{i} = msgStr;
                    
                end
                
                msg = sprintf( '%s\n', msgStrCell{:} );
                
            end
            
            disp( msg );
            
        end
    end
    
end

%--------------------------------------------------------------------------

function str = replaceBackSlashesWithSlashes( str )

str = strrep( str, '\', '/' );

end