function cleanMATLABState

%Neural network toolbox overrides
import java.awt.Frame;
frames = Frame.getFrames();
for i = 1:numel(frames)
    className = frames(i).getClass().getCanonicalName();
    if isequal(strfind(className, 'com.mathworks.toolbox.nnet'), 1)
        frames(i).setVisible(false);
    end
end

rng(0);
close all hidden;
fclose all;
evalin('base','builtin(''clear'',''clear'')');
evalin('base','clear');
dbclear all;