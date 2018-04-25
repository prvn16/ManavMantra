function cb_highlightinfrange
% CB_HIGHLIGHTINFRANGE Highlights the results that are outputs if the derived ranges are non-finite
%
%   Copyright 2010-2014 The MathWorks, Inc.

me = fxptui.getexplorer;

try
    results = [me.getBlkDgmResults me.getMdlBlkResults];
    for idx = 1:numel(results)
        % cannot display parameters as of now
        if ismember(results(idx).getElementName, {'Output', '1'}) || ...
            isa(results(idx),'fxptds.MATLABVariableResult') && strcmpi(results(idx).getScope, 'output')
            hasinsufficientrange = results(idx).hasInsufficientRange;
            if hasinsufficientrange
                if results(idx).isAnyDesignRangeEmpty && (isa(results(idx).getUniqueIdentifier,'fxptds.SimulinkIdentifier') && ...
                        isa(results(idx).getUniqueIdentifier.getObject, 'Simulink.Inport'))
                    %  possible source of empty range signals
                    if ~ismember({fxptui.message('hiliteInportBlk')}, results(idx).getComment)
                        results(idx).addComment(fxptui.message('hiliteInportBlk')); 
                    end
                    results(idx).setInsufficientRangeInterface(true); % = true;
                    me.hilightListNode(results(idx), [0.9 0.2 0.4]);
                else
                    if ~ismember({fxptui.message('hiliteBlkwithoutDesign')}, results(idx).getComment)
                        results(idx).addComment(fxptui.message('hiliteBlkwithoutDesign'));
                    end
                    results(idx).setInsufficientRange(true);
                    me.hilightListNode(results(idx),  [1 0.8 0.8]);
                end
            else % does has sufficient range but check for empty intersection
                % check to see intersection
                if results(idx).hasConflictingDesignAndDerivedRangeIntersection
                    if ~ismember({fxptui.message('hiliteEmptyRange')}, results(idx).getComment)
                            results(idx).addComment(fxptui.message('hiliteEmptyRange')); 
                    end
                    results(idx).setEmptyIntersection(true);
                    me.hilightListNode(results(idx), [0.9 0.2 0.4]);
                end
            end
        end
    end
catch e%#ok
    %consume errors if the attempted operations fail
end


% [EOF]
