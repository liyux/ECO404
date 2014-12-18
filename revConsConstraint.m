function [d] = revConsConstraint(endogPS,pxStrInfo,goals,demandInfo)
%goalRev = pre-determined number
%this function needs to reference computeDemand
%call computeDemand

pxIncreases = pxStrInfo.base;
pxIncreases(pxStrInfo.endog) = endogPS;

pxStructure = convertPX(pxIncreases);

[revenue,consumption,hhInfo] = computeDemand(demandInfo,pxStructure);

d = [revenue;consumption] - goals;
end