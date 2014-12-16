function [revenue, consumption, hhInfo] = computeDemand(demandInfo, pxstructure)

fixedCharge = pxstructure(end);
numBlks = (numel(pxstructure)-1)/2;
upperLimit = pxstructure(1:numBlks);
priceVector = pxstructure(numBlks+1:end-1);

hhmatrix = demandInfo.hhmatrix;
numhh = size(hhmatrix,1);

incAdjustment = -fixedCharge;
lowerLimit = [0; upperLimit(1:end-1)];
blockSize = upperLimit - lowerLimit;

%savings is a numBlks x numBlks matrix each row gives the savings that were
%realized by consuming previous blocks at a lower price. 
for ii=1:numBlks
    savings(:,ii) = (priceVector(ii) - priceVector).*blockSize;
end
if isnan(savings(end,end))
    savings(end,end) = 0;
end
incAdjustment = sum(triu(savings)); %"savings" from higher blocks don't matter

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

uLimMat = repmat(upperLimit',numhh,1);
lLimMat = repmat(lowerLimit',numhh,1);

consumedInLowerBlocks = repmat(blockSize',numhh,1).*(cond_demand>uLimMat);
consumedInLowerBlocks(:,end) = 0; %the last block can't be a lower block. This step removes NaNs created in the previous step by multiplying last block size (Inf) by logical 0

consumedInBlock =  consumedInLowerBlocks + (cond_demand-lLimMat).*(cond_demand<uLimMat).*(cond_demand>lLimMat);
hhBlock = sum(consumedInBlock>0,2); %identifies the largest block the consumer purchases in
hhdemand = sum(consumedInBlock,2);
hhexp = consumedInBlock*priceVector + fixedCharge;

%sum to get total expenditure and consumption
revenue = sum(hhexp);
consumption = sum(hhdemand);
hhInfo.demand = hhdemand;
hhInfo.hhexp = hhexp;
end