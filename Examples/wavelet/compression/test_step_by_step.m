function varargout = test_step_by_step(option,varargin)
%TEST_STEP_BY_STEP 
%   GUI tool used by Progressive Coefficients Significance Methods
%   functions. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Mar-2008.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

switch option
    case 'ini'
        stepFLAG = varargin{1};
        if iscell(stepFLAG)
            PUS_NEXT = stepFLAG{1};
            PUS_END  = stepFLAG{2};
            set([PUS_NEXT,PUS_END],'Enable','On');
        end
    
    case 'beg'
        stepFLAG = varargin{1};
        if iscell(stepFLAG)
            save_stepFLAG = stepFLAG;
            stepFLAG = 1;
        else
            save_stepFLAG = 0;
        end
        varargout = {save_stepFLAG , stepFLAG};

    case 'end'
        save_stepFLAG = varargin{1};
        PUS_NEXT = save_stepFLAG{1};
        PUS_END  = save_stepFLAG{2};
        val_INIT = get(PUS_NEXT,'UserData');
        val = val_INIT;
        while isequal(val,val_INIT)
            pause(0.1)
            val_FINISH = get(PUS_END,'UserData');
            if isequal(val_FINISH,1)
                set(PUS_END,'UserData',0);
                save_stepFLAG = 1;
                val = 1-val_INIT;
                set([PUS_NEXT,PUS_END],'Enable','Off');
            else
                val = get(PUS_NEXT,'UserData');
                pause(0.1)
            end
        end
        stepFLAG = save_stepFLAG;
        varargout = {save_stepFLAG , stepFLAG};

    case 'close'
        stepFLAG = varargin{1};
        if iscell(stepFLAG)
            PUS_NEXT = stepFLAG{1};
            PUS_END  = stepFLAG{2};
            set([PUS_NEXT,PUS_END],'Enable','Off');
        end
end