function [revenue, consumption, hhdemand] = computeDemand(demandInfo, pxstructure)

fixedCharge = pxstructure(end);
numBlks = (numel(pxstructure)-1)/2;
upperLimit = pxstructure(1:numBlks);
priceVector = pxstructure(numBlks+1:end-1);

hhmatrix = demandInfo.hhmatrix;
numhh = size(hhmatrix,1);

incAdjustment = -fixedCharge;
lowerLimit = [0; upperLimit(1:end-1)];

for i=2:numBlks
    incAdjustment(i) = (priceVector(i) - priceVector(i-1))*(upperLimit(i-1)-lowerLimit(i-1)) + incAdjustment(i-1);
end

incAdjustment = incAdjustment*.001; %scaling factor
adjIncome = repmat(demandInfo.hhIncome,1,numBlks)+repmat(incAdjustment,numhh,1);

hhmatrixlog = log(hhmatrix);
adjIncomelog = log(adjIncome);
priceVectorlog = log(priceVector); %log of 0 --> inf

% calculate conditional demand
priceFactor = (priceVectorlog.*demandInfo.price)';
hhFactors = hhmatrixlog*demandInfo.hh_coeff;
incomeFactor = adjIncomelog.*demandInfo.income;
cond_demand_log = repmat(priceFactor,numhh,1) + repmat(hhFactors,1,numBlks) + incomeFactor;
cond_demand = exp(cond_demand_log);

%get actual demand
for i = 1:numBlks
    checkCondd(1:numhh,i) = (cond_demand(1:numhh,i) < upperLimit(i)*0.001) & (cond_demand(1:numhh,i) > lowerLimit(i)*0.001); 
end

for i = 1:(numBlks-1)
    checkKink(1:numhh,i) = (cond_demand(1:numhh,i) > upperLimit(i)*0.001) & (cond_demand(1:numhh,i+1) < lowerLimit(i+1)*0.001);  
end

isBlock = checkCondd.*cond_demand;
isBlock(isnan(isBlock)) = 0;
hhdemand = sum(isBlock,2) + sum(checkKink.*repmat(upperLimit(1:numBlks-1)',numhh,1),2)*0.001;
aggdemand = sum(hhdemand);

%multiply qty demanded in each block by appropriate MP
for i = 1:numBlks
    demandInBlock(:,i) = .001*(hhdemand>.001*upperLimit(i)).*(upperLimit(i)-lowerLimit(i))+ ...
            (hhdemand>.001*lowerLimit(i)).*(hhdemand<=.001*upperLimit(i)).*(hhdemand-.001*lowerLimit(i));
end

hhexpBlocks = demandInBlock.*repmat(priceVector',numhh,1);

%sum to get expenditure per household
hhexp = sum(hhexpBlocks,2) + fixedCharge;

%sum to get total expenditure
aggexp = sum(hhexp);

hhdemand;
revenue = aggexp;
consumption = aggdemand;
end