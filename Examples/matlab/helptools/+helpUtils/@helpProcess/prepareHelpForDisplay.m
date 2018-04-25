function prepareHelpForDisplay(hp)
    if hp.displayBanner
        appendBanner(hp);
    end        
    if ~isempty(hp.helpStr)
        if hp.wantHyperlinks && hp.needsHotlinking
            % Make "see also", "overloaded methods", etc. hyperlinks.
            hp.hotlinkHelp;
        end

        referenceLink = hp.getReferenceLink();
        overloadsLink = hp.getOverloadsLink();
        
        if ~isempty(referenceLink) || ~isempty(overloadsLink)
            hp.helpStr = [hp.helpStr 10 referenceLink overloadsLink];
        end
        
        if ~hp.isDir
            demoTopic = hp.getDemoTopic;
            if ~isempty(demoTopic)
                demoText   = helpUtils.createMatlabCommandWithTitle(hp.wantHyperlinks, getString(message('MATLAB:introspective:displayHelp:PublishedOutputInTheHelpBrowser')), 'showdemo', demoTopic);
                hp.helpStr = [hp.helpStr demoText];
            end
        end
    end
end

function appendBanner(hp)
    bannerTopic = hp.objectSystemName;
    if isempty(bannerTopic)
         bannerTopic = hp.topic;
         if hp.helpOnInstance
             % Not an object; use the InstanceIsA message instead
             hp.helpStr = '';
         end
    end
    if isempty(hp.helpStr)
        % since there is no help, just say what the input resolved to
        if hp.helpOnInstance
            hp.helpStr = helpUtils.getInstanceIsa(hp.inputTopic, bannerTopic);
            hp.needsHotlinking = false;
            hp.fullTopic = '';
        else
            hp.topic = hp.inputTopic;
            hp.objectSystemName = hp.inputTopic;
        end
    else
        if hp.wantHyperlinks && hp.commandIsHelp
            bannerTopic = ['<strong>', bannerTopic, '</strong>'];
        end
        helpForTopic = getString(message('MATLAB:help:HelpForBanner', bannerTopic));
        hp.helpStr = sprintf('%s%s', helpForTopic, hp.helpStr);
    end
end

%   Copyright 2007 The MathWorks, Inc.
