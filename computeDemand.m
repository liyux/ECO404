function [revenue, consumption, hhdemand] = computeDemand(demandInfo, pxstructure)

fixedCharge = pxstructure(end);
numBlks = (numel(pxstructure)-1)/2;
upperLimits = pxstructure(1:numBlks);
priceVector = pxstructure(numBlks+1:end);

hhmatrix = demandInfo.hhmatrix;
numhh = size(hhmatrix,1);

incAdjustment = -fixedCharge;
lowerLimit = [0 upperLimit(1:end-1)];
for i=2:numBlks
    incAdjustment(i) = (priceVector(i) - priceVector(i-1))*(upperLimit(i-1)-lowerLimit(i-1)) + incAdjustment(i-1);
end
incAdjustment = incAdjust*.001; %scaling factor

adjIncome = repmat(hhIncome,1,numBlks)+repmat(incAdjustment,numhh,1);

% calculate conditional demand
priceFactor = pxstructure(2,1:3).^demandInfo.price; %make row vector into matrix?
hhFactors = hhmatrix*demandInfo.coeff; %how to take power?
cond_demand = repmat(priceFactor,numhh,1)+repmat(hhFactors,1,numBlks)+ adjIncome*demandInfo.income;

%6 add outputs from each block to get total household demand

%7 sum to obtain consumption

%8 multiply qty demanded in each block by appropriate MP

%9 sum to get expenditure per household

%10 sum to get total expenditure

hhdemand = 6;
revenue = 10;
consumption = 7;
end