function [d] = revenueConstraint(endogPS,pxStrInfo,goalRev,demandInfo)
%goalRev = pre-determined number
%this function needs to reference computeDemand
%call computeDemand

pxStructure = pxStrInfo.base;
pxStructure(pxStrInfo.endog) = endogPS;

revenue = computeDemand(demandInfo,pxStructure);

d = revenue - goalRev;
end