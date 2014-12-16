function stop = checkprogress(x,optimValues,state)
    stop = false;
    persistent history;
    switch state
        case 'init'
            hold on
        case 'iter'
            if iscolumn(fval)
                history.fval = [history.fval; optimValues.fval'];
            else
                history.fval = [history.fval; optimValues.fval];
            end
            if iscolumn(x)
                history.x = [history.x; x'];
            else
                history.x = [history.x; x];
            end

            subplot(2,2,1)
            plot(optimValues.iteration,optimValues.fval(:,1))
            title('Revenue Diff')

            subplot(2,2,2)
            plot(optimValues.iteration,optimValues.fval(:,2))
            title('Consumption Diff')

            subplot(2,2,3)
            plot(optimValues.iteration,optimValues.x(:,1))
            subtitle('Endogenous 1')

            subplot(2,2,4)
            plot(optimValues.iteration,optimValues.x(:,2))
            subtitle('Endogenous 2')

        case 'done'
            hold off
        otherwise
    end
end

