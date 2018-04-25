function openTutorial(tutorialName)
%OPENTUTORIAL Opens the tutorial in App Designer specified by tutorialName

%   Copyright 2016 The MathWorks, Inc.

ade = appdesigner.internal.application.getAppDesignEnvironment();
ade.openTutorial(tutorialName);

end