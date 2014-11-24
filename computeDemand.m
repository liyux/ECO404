function [revenue, consumption, hhdemand] = computeDemand(hhmatrix, demandFunc, pxstructure)

% obtain prices from each block in pxstructure
p1 = pxstructure(2,1);
p2 = pxstructure(2,2);
p3 = pxstructure(2,3);
x1 = pxstructure(1,1);
x2 = pxstructure(1,2);

% calculate adjusted income
d1 = 0;
d2 = 0.001 * (p2-p1) * x1;
d3 = d2 + (0.001 * (p3-p2) * x2);
y1 = hhmatrix(1:numhh,3) + d1;
y2 = hhmatrix(1:numhh,3) + d2;
y3 = hhmatrix(1:numhh,3) + d3;
adjIncome = [y1 y2 y3];

% calculate conditional demand
hhFactors = hhmatrix.^demandFunc(1,1:5); %how to take power?
priceFactor = pxstructure(2,1:3).^demandFunc(1,6); %make row vector into matrix?
incomeFactor = adjIncome.^demandFunc(1,7);

condd1 = %multiply every element in hhFactors * price & income factor
condd2
condd3

%6 add outputs from each block to get total household demand

%7 sum to obtain consumption

%8 multiply qty demanded in each block by appropriate MP

%9 sum to get expenditure per household

%10 sum to get total expenditure

hhdemand = 6;
revenue = 10;
consumption = 7;
end