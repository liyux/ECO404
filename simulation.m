createHouseholds
%coefmatrix = [constant coef.numpeople coef.hvalue coef.lawnsize coef.weather coef.income coef.price]
demandFunc = [-0.157 0.291 0.312 0.0247 0.979 0.15 -0.5];

% priceStructure = [upper limits of blocks; price in corresponding block]
priceStructure = [7500 30000 1000000; 0 4.42 5.25];



revDiff = revenueConstraint(basePxStructure,upRev,hhmatrix,demandCoeff)