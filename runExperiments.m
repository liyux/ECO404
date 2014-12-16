function csOutput = runExperiments(csArray,arrayCol,demandInfo);
solveOptions = optimoptions('fsolve','Display','iter','outputFcn',@checkProgess);
history.x = [];
history.fval = [];
searchdir = [];

[numExp,csCols] = size(csArray);
for jj=1:numExp
    
    %extract base price structure and compute consumption, revenue, and household ouptuts
    basePX = csArray{jj,arrayCol.basePxStr};
    pxStrInfo.base = [basePX.Ulims(1) basePX.Ulims(2:end)-basePX.Ulims(1:end-1) basePX.Price(1) basePX.Price(2:end)-basePX.Price(1:end-1) basePX.FC]';
    pxStrInfo.blks = numel(basePX.Ulims);
    if numel(basePX.Price)~=pxStrInfo.blks
        error('You have entered a different number of prices and block upper limits')
    end

    endogPrices = csArray{jj,arrayCol.endogPr}; endogUlims = csArray{jj,arrayCol.endogUL}; endogFixed = csArray{jj,arrayCol.endogFC};
    pxStrInfo.endog = [endogUlims endogPrices+pxStrInfo.blks endogFixed+2*pxStrInfo.blks];

    [baseRev, baseCons, baseDemand] = computeDemand(demandInfo,[basePX.Ulims basePX.Price basePX.FC]');
    %run the script whose name is 
    eval(csArray{jj,arrayCol.script})
    %new custom scripts must define -- consumptionTarget and/or
    %revenueTarget
    
%     pxStrInfo.base = [basePX.Ulims(1) basePX.Ulims(2:end)-basePX.Ulims(1:end-1) basePX.Price(1) basePX.Price(2:end)-basePX.Price(1:end-1) basePX.FC]';
    csIndexRaw = csArray{jj,arrayCol.csInds};
    csIndex = [csIndexRaw{1} csIndexRaw{2}+pxStrInfo.blks csIndexRaw{3}+2*pxStrInfo.blks];
    if numel(csIndex)>1
        error('You are trying to do comparative statics on two variables at the same time. Double loops haven''t been programmed.')
    end 
    csVals = csArray{jj,arrayCol.csVals};
    endogPS0 = pxStrInfo.base(pxStrInfo.endog);
    
    for ii=1:length(csVals)
        pxStrInfo.base(csIndex) = csVals(ii);

        switch csArray{jj,arrayCol.consType}
            case 'rev'
                if numel(endogPS0)~=1
                    error(['You are trying to solve a single constraint problem and have ' num2str(numel(endogPS0)) ' endogenous variables.'])
                end
                [optStr,fval,exitflag] = fsolve(@(endogPS) revenueConstraint(endogPS,pxStrInfo,revenueTarget,demandInfo),endogPS0);

            case 'dual'
                if numel(endogPS0)~=2
                    error(['You are trying to solve a dual constraint problem and have ' num2str(numel(endogPS0)) ' endogenous variables.'])
                end
                [optStr,fval,exitflag] = fsolve(@(endogPS) revConsConstraint(endogPS,pxStrInfo,consumptionTarget,demandInfo),endogPS0,solveOptions);
            otherwise
                error(['I don''t recognize the constraint type ' csArray{jj,arrayCol.consType}])
        end

         if exitflag<1;
             disp('I ran into trouble solving for the IBP price that meets your goals. I''m stopping to let you figure out why.')
             keyboard
         end

        pxOptInc = pxStrInfo.base;
        pxOptInc(pxStrInfo.endog) = optStr;

        pxOpt = convertPX(pxOptInc);
        [optRev, optCons, optHHInfo] =  computeDemand(demandInfo,pxOpt);

        optOutput(ii,jj).Cons = optCons;
        optOutput(ii,jj).Rev = optRev;
        optOutput(ii,jj).Prices = pxOpt(pxStrInfo.blks+1:2*pxStrInfo.blks);
        optOutput(ii,jj).Ulims = pxOpt(1:pxStrInfo.blks);
        optOutput(ii,jj).FCs = pxOpt(end);
        optOutput(ii,jj).hhInfo = optHHInfo;
    end

    csOutput.optOutput = optOutput;
    csOutput.uniform = uniformOutput;
end

function stop = outfun(x,optimValues,state)
    stop = false;

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
            plot(ptimValues.iteration,optimValues.fval(:,2))
            title('Consumption Diff')

            subplot(2,2,3)
            plot(ptimValues.iteration,optimValues.x(:,1))
            subtitle('Endogenous 1')

            subplot(2,2,4)
            plot(ptimValues.iteration,optimValues.x(:,2))
            subtitle('Endogenous 2')

        case 'done'
            hold off
        otherwise
    end
end

end
        
        
    