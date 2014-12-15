consumptionTarget = .95*baseCons;
revenueTarget = baseRev;
%compute uniform price and fixed charge that matches revenue and reduces
%demand by 5%
pxStrU.blks = 1;
pxStrU.endog = [2 3]; %endog price and fixed charge
prU_0 = [mean(basePX.Price); basePX.FC]; %use the mean price and fixed charge of the original structure as the starting point guess
pxStrU.base = [1e6  prU_0]';

[uniformPrice,fval,exitflag] = fsolve(@(uniformPrice) revConsConstraint(uniformPrice,pxStrU,[revenueTarget; consumptionTarget],demandInfo),prU_0);

if exitflag<1
    disp('I ran into trouble computing the uniform price that matches revenue and reduce demand by 5%. I''m stopping to let you figure out why.')
    keyboard
end

uniformPxStr = pxStrU.base;
uniformPxStr(2) = uniformPrice;

[rev, cons, uniformHHOutput] = computeDemand(demandInfo, uniformPxStr);

csOutput(jj).Uniform.HHOutput = uniformHHOutput;
csOutput(jj).Uniform.price = uniformPrice(2);
csOutput(jj).Uniform.fixedCharge = uniformPrice(3);

