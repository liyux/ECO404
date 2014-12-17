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
    
    %compare aggregate expenditures by different quintiles
    hhExpendMat{jj} = [baseDemand.hhexp uniformHHBase.hhexp uniformHHOutput.hhexp];
    hhConsumeMat{jj} = [baseDemand.demand uniformHHBase.demand uniformHHOutput.demand];

    for ii=1:length(csVals)
        pxStrInfo.base(csIndex) = csVals(ii);
        
        [optStr,fval,exitflag] = optimizePX(csArray{jj,arrayCol.consType},pxStrInfo,target,demandInfo,endogPS0);
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
        optOutput(ii,jj).PriceIncs = pxOptInc(pxStrInfo.blks+1:2*pxStrInfo.blks);
        optOutput(ii,jj).Ulims = pxOpt(1:pxStrInfo.blks);
        optOutput(ii,jj).BlkSizes = pxOptInc(1:pxStrInfo.blks);
        optOutput(ii,jj).FCs = pxOpt(end);  
        optOutput(ii,jj).hhInfo = optHHInfo;
        
        hhExpendMat{jj} = [hhExpendMat{jj} optHHInfo.hhexp];
        hhConsumeMat{jj} = [hhConsumeMat{jj} optHHInfo.demand];
    end

end
        
        
    