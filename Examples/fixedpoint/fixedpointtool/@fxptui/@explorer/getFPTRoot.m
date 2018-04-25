function root = getFPTRoot(this)

% Copyright 2013 MathWorks, Inc

root = this.getRoot;
if isa(root,'DAStudio.DAObjectProxy')
    root = root.getMCOSObjectReference;
end
