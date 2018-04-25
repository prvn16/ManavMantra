function done = handleSimulinkPrinting(pj)
% HANDLESIMULINKPRINTING - internal helper function to handle simulink
% figure for printing process.

%  Copyright 2016 The MathWorks, Inc.


% Function handle to be used for Simulink/Stateflow printing.
% Make persistent for efficiency (sramaswa)

persistent slSfPrintFcnHandle;

try
    done = false;
    if(isSLorSF(pj))
        % Printer dialog
        if (ispc() && strcmp(pj.Driver,'setup'))
            eval('SLM3I.SLDomain.showPrintSetupDialog(pj.Handles{1}(1))');
            done = true;
            return;
        end
        
        if(isempty(slSfPrintFcnHandle))
            slSfPrintFcnHandle = LocalGetSlSfPrintFcnHandle;
        end
        %pj = name(pj);
        feval(slSfPrintFcnHandle, pj);
        done = true;
    end % if(isSLorSF(pj))
catch me
    % We want to see the complete stack in debug mode...
    if(pj.DebugMode)
        rethrow(me);
    else % ...and a simple one in non-debug
        throwAsCaller(me);
    end
end
end

function fHandle = LocalGetSlSfPrintFcnHandle

cwd = pwd;
try
    cd(fullfile(matlabroot,'toolbox','simulink','simulink','private')); %#ok<*MCCD,MCMLR,MCTBX>
    fHandle = str2func('slsf_print');
    if(~isa(fHandle, 'function_handle'))
        throw(MException('MATLAB:UndefinedFunction',sprintf('%s',getString(message('MATLAB:uistring:print:UndefinedFunctionOrVariable','slsf_print')))));
    end
catch me
    cd(cwd);
    rethrow(me);
end

cd(cwd);
end