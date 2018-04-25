function referenceLink = getReferenceLink(hp)
    hp.getDocTopic;
    if ~isempty(hp.docTopic) && hp.commandIsHelp
                
        if hp.wantHyperlinks
            referenceLink = getString(message('MATLAB:helpUtils:displayHelp:ReferencePageFor', hp.docTopic));
            referenceLink = helpUtils.formatHelpTextLine(helpUtils.createMatlabLink('doc', hp.docTopic, referenceLink));
        else
            referenceLink = getString(message('MATLAB:helpUtils:displayHelp:NoHotlinksReferencePageFor'));
            referenceLink = helpUtils.createMatlabCommandWithTitle(hp.wantHyperlinks, referenceLink, 'doc', hp.docTopic);
        end
    else
        referenceLink = '';
    end
end

