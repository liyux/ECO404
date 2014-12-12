function [revenue, consumption, hhInfo] = computeDemand(demandInfo, pxstructure)

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
priceFactor(1,:) = (priceVectorlog.*demandInfo.price); %force row vector
hhFactors = hhmatrixlog*demandInfo.hh_coeff;
incomeFactor = adjIncomelog.*demandInfo.income;
cond_demand_log = repmat(priceFactor,numhh,1) + repmat(hhFactors,1,numBlks) + incomeFactor;
cond_demand = exp(cond_demand_log);

%get actual demandprice
if numBlks>1

    for i = 1:numBlks
        checkCondd(:,i) = (cond_demand(:,i) < upperLimit(i)) & (cond_demand(:,i) > lowerLimit(i)); 
    end

    for i = 1:(numBlks-1)
        checkKink(:,i) = (cond_demand(:,i) > upperLimit(i)) & (cond_demand(:,i+1) < lowerLimit(i+1));  
    end

    isBlock = checkCondd.*cond_demand;
    isBlock(isnan(isBlock)) = 0;
    hhdemand = sum(isBlock,2) + sum(checkKink.*repmat(upperLimit(1:numBlks-1)',numhh,1),2);

    %multiply qty demanded in each block by appropriate MP
    for i = 1:numBlks
        demandInBlock(:,i) = (hhdemand>upperLimit(i)).*(upperLimit(i)-lowerLimit(i))+ ...
                (hhdemand>lowerLimit(i)).*(hhdemand<=upperLimit(i)).*(hhdemand-lowerLimit(i));
    end

    hhexpBlocks = demandInBlock.*repmat(priceVector',numhh,1);

    %sum to get expenditure per household
    hhexp = sum(hhexpBlocks,2) + fixedCharge;

else
    hhdemand = cond_demand;
    hhexp = hhdemand*priceVector + fixedCharge;
end

%sum to get total expenditure and consumption
revenue = sum(hhexp);
consumption = sum(hhdemand);
hhInfo.demand = hhdemand;
hhInfo.hhexp = hhexp;
end