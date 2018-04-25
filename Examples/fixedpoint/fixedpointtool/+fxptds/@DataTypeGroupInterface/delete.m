function delete(this)
    % DELETE this function cleans up the internal maps used in the
    % interface 
    
    % Copyright 2016 The MathWorks, Inc.
    
    this.clear();
   
    % clear the registered nodes
    this.nodes.remove(this.nodes.keys);
end