createHouseholds

%coefmatrix = [constant coef.numpeople coef.hvalue coef.lawnsize coef.weather coef.income coef.price]
demandInfo.hh_coeff = [-0.157 0.291 0.312 0.0247 0.979]'; 
demandInfo.income = 0.15;
demandInfo.price = -0.5;
demandInfo.hhmatrix = hhmatrix;
demandInfo.hhIncome = hhIncome;

pxStrInfo.blks = 3;
endogPrices = 2; endogUlims = []; endogFixed = [];
pxStrInfo.endog = [endogUlims endogPrices+pxStrInfo.blks endogFixed+2*pxStrInfo.blks];
pxStrInfo.base = [7500 30000 +Inf 0 4.42 5.25 10]';

% priceStructure is a column vector who first numBlks elements are the
% upper limits and whose second numBlks elements are the corresponding
% prices and whose last element is the fixed charge.
endogPS = 4.52;
goalRev = 10e7;

[goalRev, consumption, hhdemand] = computeDemand(demandInfo, [+Inf; 5;0]); %compute the demand under uniform pricing

revDiff = revenueConstraint(endogPS,pxStrInfo,goalRev,demandInfo);

%%%%%%%%%%%%%%%%%%%%%%%Don't write anything below here%%%%%%%%%%%%%%%
[optStr,fval,exitflag] = fsolve(@(endogPS) revenueConstraint(endogPS,pxStrInfo,goalRev,demandInfo),pxStrInfo.base(pxStrInfo.endog));

