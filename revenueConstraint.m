function [d] = revenueConstraint(endogPS,pxStrInfo,goalRev,demandInfo)
%goalRev = pre-determined number
%this function needs to reference computeDemand
%call computeDemand

pxIncreases = pxStrInfo.base;
pxIncreases(pxStrInfo.endog) = endogPS;

pxStructure(1) = pxIncreases(1); pxStructure(pxStrInfo.blks+1) = pxIncreases(pxStrInfo.blks+1);
for ii=2:pxStrInfo.blks
    pxStructure(ii) = pxIncreases(ii) + pxStructure(ii-1);
    pxStructure(ii+pxStrInfo.blks) = pxIncreases(ii+pxStrInfo.blks) + pxStructure(ii+pxStrInfo.blks-1);
end

pxStructure(end+1) = pxIncreases(end);
if isrow(pxStructure)
    pxStructure = pxStructure';
end

[revenue,consumption,demand] = computeDemand(demandInfo,pxStructure);

d = revenue - goalRev;
end