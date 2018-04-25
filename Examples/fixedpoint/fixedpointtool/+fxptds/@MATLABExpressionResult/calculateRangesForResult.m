function calculateRangesForResult(this, proposalSettings)
    %Copyright 2016 The MathWorks, Inc.
    extremumSet = this.getExtremumSet(proposalSettings);
    this.setLocalExtremum(extremumSet);
end