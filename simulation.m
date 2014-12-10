dbstop if error
createHouseholds

%coefmatrix = [constant coef.numpeople coef.hvalue coef.lawnsize coef.weather coef.income coef.price]
demandInfo.hh_coeff = [-0.157 0.291 0.312 0.0247 0.979]'; 
demandInfo.income = 0.15;
demandInfo.price = -0.5;
demandInfo.hhmatrix = hhmatrix;
demandInfo.hhIncome = hhIncome;

pxStrInfo.base = [2 7 18 50 75 100 1e6 [eps 2.22 2.27 2.32 2.37 2.52 2.67 40]*.61]';
pxStrInfo.blks = 7;
endogPrices = 2; endogUlims = []; endogFixed = [];
pxStrInfo.endog = [endogUlims endogPrices+pxStrInfo.blks endogFixed+2*pxStrInfo.blks];

% priceStructure is a column vector who first numBlks elements are the
% upper limits and whose second numBlks elements are the corresponding
% prices and whose last element is the fixed charge.

[baseRev, baseCons, baseDemand] = computeDemand(demandInfo,pxStrInfo.base);
pxStrU.blks = 1;
pxStrU.endog = 2;
uniformPriceGuess = 2.5;
pxStrU.base = [1e6 uniformPriceGuess 40*.61]';

[uniformPrice,fval,exitflag] = fsolve(@(uniformPrice) revenueConstraint(uniformPrice,pxStrU,baseRev,demandInfo),uniformPriceGuess);

if exitflag~=1
    keyboard
end
uniformPxStr = pxStrU.base;
uniformPxStr(2) = uniformPrice;

[goalRev, goalCons, goalHhdemand] = computeDemand(demandInfo, uniformPxStr)

endogPS = uniformPrice;

csPrices = []; csUlims = 1; csFixed =[]; %can only have one cs variable at a time
csIndices = [csUlims csPrices+pxStrInfo.blks csFixed+2*pxStrInfo.blks];
csUlimVals = [0 2 4];
for ii=1:length(csUlimVals)
    pxStrInfo.base(csIndices) = csUlimVals(ii);
    [optStr,fval,exitflag] = fsolve(@(endogPS) revenueConstraint(endogPS,pxStrInfo,goalRev,demandInfo),endogPS);

    optEndog(ii) = optStr;
    pxOpt = pxStrInfo.base;
    pxOpt(pxStrInfo.endog) = optStr;
     
    [optRev, optCons, optDemand] =  computeDemand(demandInfo,pxOpt);
    
    optOutput.Cons(ii) = optCons;
    optOutput.Demand(:,ii) = optDemand;
end
