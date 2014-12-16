clear all
dbstop if error
createHouseholds

%coefmatrix = [constant coef.numpeople coef.hvalue coef.lawnsize coef.weather coef.income coef.price]
demandInfo.hh_coeff = [-0.157 0.291 0.312 0.0247 0.979]'; 
demandInfo.income = 0.15;
demandInfo.price = -0.5;
demandInfo.hhmatrix = hhmatrix(1:10,:);
demandInfo.hhIncome = hhIncome(1:10,:);

baseUlims = [2 7 18 50 75 100 Inf];
basePrice = [eps 2.22 2.27 2.32 2.37 2.52 2.67]*inflationAdj;
baseFC = 40*inflationAdj;

pxStrInfo.base = [baseUlims(1) baseUlims(2:end)-baseUlims(1:end-1) basePrice(1) basePrice(2:end)-basePrice(1:end-1) baseFC]';
pxStrInfo.blks = 7;
endogPrices = 2; endogUlims = []; endogFixed = [];
pxStrInfo.endog = [endogUlims endogPrices+pxStrInfo.blks endogFixed+2*pxStrInfo.blks];

% priceStructure is a column vector who first numBlks elements are the
% upper limits and whose second numBlks elements are the corresponding
% prices and whose last element is the fixed charge.

[baseRev, baseCons, baseDemand] = computeDemand(demandInfo,[baseUlims basePrice baseFC]');
pxStrU.blks = 1;
pxStrU.endog = 2;
uniformPriceGuess = 2.5;
pxStrU.base = [1e6 uniformPriceGuess 40*inflationAdj]';

[uniformPrice,fval,exitflag] = fsolve(@(uniformPrice) revenueConstraint(uniformPrice,pxStrU,baseRev,demandInfo),uniformPriceGuess);

if exitflag<1
    keyboard
end
uniformPxStr = pxStrU.base;
uniformPxStr(2) = uniformPrice;

[goalRev, goalCons, goalHhdemand] = computeDemand(demandInfo, uniformPxStr)

endogPS = uniformPrice;

csPrices = []; csUlims = 1; csFixed =[]; %can only have one cs variable at a time
csIndices = [csUlims csPrices+pxStrInfo.blks csFixed+2*pxStrInfo.blks];
csUlimVals = [1.5 2 2.5];
for ii=1:length(csUlimVals)
    pxStrInfo.base(csIndices) = csUlimVals(ii);
    [optStr,fval,exitflag] = fsolve(@(endogPS) revenueConstraint(endogPS,pxStrInfo,goalRev,demandInfo),endogPS);
    if exitflag<1;
        keyboard
    end

    optEndog(ii) = optStr; %gives uniform price
    pxOptInc = pxStrInfo.base;
    pxOptInc(pxStrInfo.endog) = optStr;
    
    pxOpt = convertPX(pxOptInc);
    [optRev, optCons, optHHInfo] =  computeDemand(demandInfo,pxOpt);
    
    optOutput.Cons(ii) = optCons;
    optOutput.Rev(ii) = optRev;
    optOutput.PX(ii,:) = pxOpt;
    hhInfo{ii} = optHHInfo;
end

hhInfo{1}