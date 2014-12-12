%draw a set of households from an empirical multivariate distribution
%following Richardson et al

A = importdata('inputData.csv',',');
X=[A.data];

bathroomsIndex = 1;

[numOb,numVar] = size(X);
%add uncorrelated random lawn size
lawnSize = random('lognormal',.3590,1.026,numOb,1);
numVar = numVar+1;
X = [X lawnSize];

numCont = numVar - 1;
meanX = mean(X);
devX = X - repmat(meanX,numOb,1);
relDevX = devX./repmat(meanX,numOb,1);
corrMat = corr(devX);

%prob dist
smallDev = 1e-6;
sortedDev = sort(relDevX);
sortedDev = [sortedDev(1,:)*(1+smallDev); sortedDev; sortedDev(end,:)*(1+smallDev)];
sortedDev(1,bathroomsIndex) = sortedDev(2,bathroomsIndex);
sortedDev(end,bathroomsIndex) = sortedDev(end-1,bathroomsIndex);
dataCDF = 1/numOb*[0; (0:numOb-1)'; numOb-1]+0.5/numOb*[0; ones(numOb,1); 2]; 
  
sampleSize = 20;
indStdNormDev = randn(sampleSize,numVar);
corrStdNormDev = indStdNormDev*chol(corrMat);

corrUniDev = cdf('norm',corrStdNormDev,0,1);

%interpolate continous variables using linear interpolation
contInds =[1:bathroomsIndex-1 bathroomsIndex+1:numVar];
contSortedDev = sortedDev(:,contInds);
contCorrUniDev = corrUniDev(:,contInds);
numCont = numVar-1;

Fcont = griddedInterpolant({dataCDF, 1:numCont},contSortedDev)
corrRelDev(:,contInds) = Fcont(corrUniDev(:,contInds),repmat(1:numCont,sampleSize,1));

%interpolate discrete variables using nearest neighbor interpolation
discreteSortedDev = sortedDev(:,bathroomsIndex);
corrRelDev(:,bathroomsIndex) = interp1(dataCDF,discreteSortedDev,corrUniDev(:,bathroomsIndex),'nearest');

corrDev = corrRelDev.*repmat(meanX,sampleSize,1);
sampleHHMat = corrDev + repmat(meanX,sampleSize,1);
