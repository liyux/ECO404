function [optStr,fval,exitflag] = optimizePX(consType,pxStrInfo,targetVals,demandInfo,endogPS0);

solveOptions = optimoptions('fsolve','Display','iter','outputFcn',@plotProgress);
      switch consType
            case 'rev'
                if numel(endogPS0)~=1
                    warning(['You are trying to solve a single constraint problem and have ' num2str(numel(endogPS0)) ' endogenous variables.'])
                end
                [optStr,fval,exitflag]= fsolve(@(endogPS) revenueConstraint(endogPS,pxStrInfo,target.Rev,demandInfo),endogPS0);

            case 'dual'
                if numel(endogPS0)~=2
                    warning(['You are trying to solve a dual constraint problem and have ' num2str(numel(endogPS0)) ' endogenous variables.'])
                end
                [optStr,fval,exitflag] = fsolve(@(endogPS) revConsConstraint(endogPS,pxStrInfo,[targetVals.Rev;targetVals.Cons],demandInfo),endogPS0,solveOptions);
            otherwise
                error(['I don''t recognize the constraint type ' consType])
      end
        
function stop = plotProgress(x,optimValues,state)
    stop = false;
    persistent history
    switch state
        case 'init'
            hold on
            history.fval =[];
            history.x = [];
        case 'iter'
            if iscolumn(optimValues.fval)
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
            plot(optimValues.iteration,optimValues.fval(1))
            title('Revenue Diff')

            subplot(2,2,2)
            plot(optimValues.iteration,optimValues.fval(2))
            title('Consumption Diff')

            subplot(2,2,3)
            plot(optimValues.iteration,x(1))
            title('Endogenous 1')

            subplot(2,2,4)
            plot(optimValues.iteration,x(2))
            title('Endogenous 2')
            
            

        case 'done'
            hold off
        otherwise
    end
    
end

end
