function fixpt_atan2_demo_plot(figno, in1, in2, in3, in4)
% Figure generation function
%
%    Copyright 1984-2016 The MathWorks, Inc.

switch figno 
    case 1
        % Figure 1: Vectoring Mode CORDIC Iterations
        %   inputs: xf, yf
        xf = in1; yf = in2;
        Niter2Draw = 8; % 
        xArray = [xf;zeros(size(xf))];
        yArray = [yf;zeros(size(yf))];
        figure(figno), clf
        plot(xArray(:,1:Niter2Draw), yArray(:,1:Niter2Draw), 'LineWidth', 2);
        legend('Iteration 0 (Input)',...
               'Iteration 1',...
                'Iteration 2',...
           'Iteration 3',...
           'Iteration 4',...
           'Iteration 5',...
           'Iteration 6',...
           'Iteration 7',...
                    'Location','NorthWest');
        for i=1:Niter2Draw-1
            text(xf(i),yf(i),int2str(i-1),'fontsize',12,'fontweight','b');
        end
        text(xf(Niter2Draw)+0.05,yf(Niter2Draw),...
            int2str(Niter2Draw-1),'fontsize',12,'fontweight','b');
        hold on, 
        plot([0,1.8]', [0, 0]', 'k:','HandleVisibility','off')
        xlabel('X','fontsize',12,'fontweight','b')
        ylabel('Y','fontsize',12,'fontweight','b')
        title('Vectoring Mode CORDIC Iterations','fontweight','b')
    case 2
        % Figure 2: Cumulative Angle and Rotator Magnitude Through Iterations
        % inputs: Niter, theta, angleAccumulator, rotatorMagnitude
        Niter = in1; theta = in2; 
        angleAccumulator = in3; rotatorMagnitude = in4;
        figure(figno), clf
        subplot(2,1,1)
        hold on
        plot([1 Niter],[theta theta]*180/pi,'c','LineWidth', 2);
        plot(1:Niter, angleAccumulator(1:Niter), 'r^-', ...
             'LineWidth', 2, 'MarkerEdgeColor','k',...
             'MarkerFaceColor','g','MarkerSize',10);
        grid
        xlabel('Iteration','fontsize',10)
        ylabel('Angle (degrees)','fontsize',12)
        title('Cumulative Angle Through Iterations','fontweight','b')
        legend('Actual angle','Calculated angle','Location','SouthEast')
        subplot(2,1,2)
        bar(0:Niter, rotatorMagnitude(1:Niter+1))
        title('CORDIC Rotator Magnitude','fontweight','b')
        axis([-1 10 0.95 1.7])
        xlabel('Iteration','fontsize',12)
        ylabel('Magnitude','fontsize',12)
    case 3
        % Figure 3: Overall Error of the Fixed-Point CORDIC Algorithm
        % inputs: theta, cordic_err
        theta = in1; cordic_err = in2;
        figure(figno)
        plot(theta, cordic_err,'LineWidth', 2)
        grid,
        legend('8 Iterations', '10 Iterations', '12 Iterations', ...
               '14 Iterations', '15 Iterations', ...
               'Location', 'NorthEast')
        xlabel('\theta (radians)','fontsize',12,'fontweight','b')
        ylabel('Error   \delta\theta (radians)','fontsize',12,'fontweight','b')
        title('Overall Error of the Fixed-Point CORDIC Algorithm',...
              'fontsize',11,'fontweight','b')
    case 4
        % Figure 4: Comparison of Algorithmic Errors
        % inputs: theta, cordic_algErr, poly_algErr
        theta = in1; cordic_algErr = in2;
        poly_algErr = in3;
        figure(figno)
        plot(theta, [cordic_algErr; poly_algErr],'LineWidth', 2)
        grid,
        legend('8IterCORDIC', '12IterCORDIC', '3rdOrderPoly', ...
               '5thOrderPoly', '7thOrderPoly',...
               'Location', 'NorthEast')
        xlabel('\theta (radians)','fontsize',12,'fontweight','b')
        ylabel('Error   \delta\theta (radians)','fontsize',12,'fontweight','b')
        title('Comparison of Algorithmic Errors','fontsize',12,'fontweight','b')
        
     case 5
        % Figure 5: Overall Error of the Fixed-Point polynomial approximation Algorithm
        % inputs: theta, poly_err
        theta = in1; poly_err = in2;
        figure(figno)
        plot(theta, poly_err,'LineWidth', 2)
        grid,
        legend('3rdOrder', '5thOrder', '7thOrder', ...
               'Location', 'NorthEast')
        xlabel('\theta (radians)','fontsize',12,'fontweight','b')
        ylabel('Error   \delta\theta (radians)','fontsize',12,'fontweight','b')
        title('Overall Error of the Fixpt Polynomial Approx Algorithm',...
              'fontsize',10,'fontweight','b')
    case 6
        % Figure 6: Overall Error of the Fixed-Point Lookup Table Based Algorithm
        % inputs: theta, lut_err
        theta = in1; lut_err = in2;
        figure(figno)
        plot(theta, lut_err,'r','LineWidth', 2)
        grid,
        xlabel('\theta (radians)','fontsize',12,'fontweight','b')
        ylabel('Error   \delta\theta (radians)','fontsize',12,'fontweight','b')
        title('Overall Error of the Fixpt LUT Based Approx Algorithm',...
              'fontsize',10,'fontweight','b')
        
    case 7
        % Figure 7: Comparison of Overall Errors
        % inputs: theta, cordic_err, poly_err, lut_err
        theta = in1; cordic_err = in2; poly_err = in3; lut_err = in4;
        figure(figno)
        plot(theta, [cordic_err' poly_err' lut_err'], 'LineWidth', 2)
        grid,
        legend('15IterCORDIC', '7thOrderPoly', '8bitLUT16bitInt', ...
               'Location', 'NorthEast')
        xlabel('\theta (radians)','fontsize',12,'fontweight','b')
        ylabel('Error   \delta\theta (radians)','fontsize',12,'fontweight','b')
        title('Comparison of Overall Fixed-Point Approx Errors','fontsize',12,'fontweight','b')
        
    otherwise
         disp('Unknown figure number.')
end



end

