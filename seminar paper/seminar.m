clear all
close all

%keep constants as scalars, make into vectors only when needed

%coefficients
%coef matrix is 1x6
coef.constant=0.5184;
coef.lawnsize=0.0231;
coef.weather=1.5945;
coef.bath=0.1336;
coef.hsize=0.0046;
coef.billing=0.034;
coef.p1=-1.8989;
coef.yd=0.1782;
coefmatrix=[coef.constant coef.lawnsize coef.weather coef.bath coef.hsize coef.billing];

%fixed variables
numhh=1000;
constant=1;
billing=30;
weather=0.464;
p11=1.2;
p12=1.4;
x11=12;
d1=0;
d2=0.001*(p12-p11)*x11;

correlationmatrix=[1 0.6 0.7 0.7 ; 0.6 1 0.5 0.5 ; 0.7 0.5 1 0.9 ; 0.7 0.5 0.9 1];

%household characteristics
%to keep values inside a range, generate more than needed, remove those
%outside, and keep top 1000 numbers. csubset=condd1*find(condd1>x11) is subset,
%keep csubset(1:1000,1)
rng(1)

income=normrnd(1.156,0.485,[1.5*numhh,1]); %$1000
isubset=income(find((income>=0.137)&(income<=2.967)));
income = isubset(1:numhh);
hsize=normrnd(18.337,5.288,[1.5*numhh,1]); %100sqft
hsubset=hsize(find((hsize>=4.44)&(hsize<=36.11)));
hsize = hsubset(1:numhh);
lawnsize=normrnd(9.877,3.383,[1.5*numhh,1]); %1000sqft
lsubset=lawnsize(find((lawnsize>=4.61)&(lawnsize<=25.96)));
lawnsize = lsubset(1:numhh);
bath=normrnd(1.635,0.52,[1.5*numhh,1]);
bsubset=bath(find((bath>=1)&(bath<=3)));
bath = bsubset(1:numhh);


correlatedhh=[income lawnsize bath hsize]*chol(correlationmatrix);
correlatedhh=sortrows(correlatedhh,1);
income=correlatedhh(1:numhh,1);
hhmatrix=[constant*ones(numhh,1) correlatedhh(1:numhh,2) weather*ones(numhh,1) correlatedhh(1:numhh,3) correlatedhh(1:numhh,4) billing*ones(numhh,1)];
%hhmatrix is hhsizex6


%calculations to get IBP demand
d.hh=exp(hhmatrix*coefmatrix'); %size numhhx1
d.p11=p11.^coef.p1;
d.p12=p12.^coef.p1;
d.y1=(income+d1).^coef.yd;
d.y2=(income+d2).^coef.yd;
%for UP demand
d.y = income.^coef.yd;

condd1=d.hh.*d.p11.*d.y1; %size numhhx1
condd2=d.hh.*d.p12.*d.y2; %size numhhx1
condd = [condd1 ones(numhh,1)*x11 condd2];

% changing p1
p11exp = 1.1:0.01:1.3;
numIterp1 = numel(p11exp);
qtydIBPi = zeros(numhh,numIterp1);
totalConsumptionIBPi = zeros(1,numIterp1);
expIBPi= zeros(numhh,numIterp1);
totalRevenueIBPi = zeros(1,numIterp1);
UPsameRevi = zeros(1,numIterp1);
UPsameConsumptioni = zeros(1,numIterp1);
numhhblocki = zeros(3,numIterp1);

for i = 1:numIterp1;
    
    p12i = p12;
    p11i = p11exp(i); 
    x11i = x11;
    
    computeQandExp
end

qtydIBPp1 = qtydIBPi;
totalConsumptionIBPp1 = totalConsumptionIBPi;
expIBPp1 = expIBPi;
totalRevenueIBPp1 = totalRevenueIBPi;
UPsameRevp1 = UPsameRevi;
UPsameConsumptionp1 = UPsameConsumptioni;
numhhBlockp1 = numhhBlocki;

%for UP price corresponding to same revenue
qtydUPp1 = zeros(numhh,numIterp1);
expUPp1 = zeros(numhh,numIterp1);

for i = 1:numIterp1;

    qtydUPp1(:,i) = d.hh.*d.y.*(UPsameRevp1(1,i)^coef.p1);
    expUPp1(:,i) = qtydUPp1(:,i).*UPsameRevp1(1,i);
    
end


%making graphs
diffqtydIBPp1 = findDiff(qtydIBPp1);
diffexpIBPp1 = findDiff(expIBPp1);
diffqtydUPp1 = findDiff(qtydUPp1);
diffexpUPp1 = findDiff(expUPp1);

%changing x11
x11exp = 10:1:20;
numIterx1 = numel(x11exp);
qtydIBPi = zeros(numhh,numIterx1);
totalConsumptionIBPi = zeros(1,numIterx1);
expIBPi= zeros(numhh,numIterx1);
totalRevenueIBPi = zeros(1,numIterx1);
UPsameRevi = zeros(1,numIterx1);
UPsameConsumptioni = zeros(1,numIterx1);
numhhBlocki = zeros(numIterx1,3);

for i = 1:numIterx1;
    
    p12i = p12;
    p11i = p11; 
    x11i = x11exp(i);
    
    computeQandExp
end

qtydIBPx1 = qtydIBPi;
totalConsumptionIBPx1 = totalConsumptionIBPi;
expIBPx1 = expIBPi;
totalRevenueIBPx1 = totalRevenueIBPi;
UPsameRevx1 = UPsameRevi;
UPsameConsumptionx1 = UPsameConsumptioni;
numhhBlockx1 = numhhBlocki;

%for UP price corresponding to same revenue
qtydUPx1 = zeros(numhh,numIterx1);
expUPx1 = zeros(numhh,numIterx1);

for i = 1:numIterx1;

    qtydUPx1(:,i) = d.hh.*d.y.*(UPsameRevp1(1,i)^coef.p1);
    expUPx1(:,i) = qtydUPp1(:,i).*UPsameRevp1(1,i);
    
end

%making graphs
diffqtydIBPx1 = findDiff(qtydIBPx1);
diffexpIBPx1 = findDiff(expIBPx1);
diffqtydUPx1 = findDiff(qtydUPx1);
diffexpUPx1 = findDiff(expUPx1);

%consumption level difference, change in kink point
plot(x11exp, diffqtydIBPx1, x11exp, diffqtydUPx1)
title('Consumption level differences between 1st and 5th quintile with change in x1')
xlabel('x1') 
ylabel('difference in consumption') 
legend('IBP','UP')

%distribution of households in blocks, change in p1
bar(p11exp, numhhBlockp1, 'stacked')
title('Distribution of households in blocks')
xlabel('p1') 
ylabel('households') 
legend('block 1','kink', 'block 2')

%consumption level difference, change in price in first block
plot(p11exp, diffqtydIBPp1, p11exp, diffqtydUPp1)
title('Consumption level differences between 1st and 5th quintile with change in p1')
xlabel('p1') 
ylabel('difference in consumption') 
legend('IBP','UP')

%distribution of households in blocks, change in x1
bar(x11exp, numhhBlockx1, 'stacked')
title('Distribution of households in blocks')
xlabel('x1') 
ylabel('households') 
legend('block 1','kink', 'block 2')



