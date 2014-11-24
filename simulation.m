createHouseholds
%coefmatrix = [constant coef.numpeople coef.hvalue coef.lawnsize coef.weather coef.income coef.price]
demandFunc.hh_coeff = [-0.157 0.291 0.312 0.0247 0.979]'; 
demandFunc.income = 0.15;
demandFunc.price = -0.5;

% priceStructure is a column vector who first numBlks elements are the
% upper limits and whose second numBlks elements are the corresponding
% prices and whose last element is the fixed charge.
priceStructure = [7500 30000 +Inf 0 4.42 5.25 ]';



revDiff = revenueConstraint(basePxStructure,upRev,hhmatrix,demandCoeff);

%%%%%%%%%%%%%%%%%%%%%%%Don't write anything below here%%%%%%%%%%%%%%%
optimizePxStrucutre %susan will create a script that solves for the price structure that sets revDiff to zero