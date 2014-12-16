dbstop if error
createHouseholds

%coefmatrix = [constant coef.numpeople coef.hvalue coef.lawnsize coef.weather coef.income coef.price]
demandInfo.hh_coeff = [-0.157 0.291 0.312 0.0247 0.979]'; 
demandInfo.income = 0.15;
demandInfo.price = -0.5;
demandInfo.hhmatrix = hhmatrix;
demandInfo.hhIncome = hhIncome;

%experiments to run
% vary first block price & size
% fixed price vs increasing prices in middle-high blocks
% Others: find essential household consumption & fix size of first block 
% based on that, then vary prices

%For Denton: summer & winter pricing IBP vs UP
%Summer: 
DentonS.Ulims = [15 30 50 Inf];
DentonS.Price = [3.8 5.5 7.4 9.75]*inflationAdj;
DentonS.FC = [0]*inflationAdj;
%Winter: 
DentonW.Ulims = [Inf];
DentonW.Price = [3.8*inflationAdj];
DentonW.FC = [0]*inflationAdj;

%Huntsville:
Huntsville.Ulims = [7.5 30 Inf];
Huntsville.Price = [eps 4.42 5.25]*inflationAdj;
Huntsville.FC = [28]*inflationAdj;

% Victoria:  many blocks with small differences in marginal price 
%(compare to lesser blocks with bigger difference in prices)
% base charge (first 2000gallons included in base charge according to meter size)
Victoria.Ulims = [2 7 18 50 75 100 Inf];
Victoria.Price = [eps 2.22 2.27 2.32 2.37 2.52 2.67]*inflationAdj;
Victoria.FC = 40*inflationAdj;

%array of experiments
arrayCol.name = 1;
arrayCol.basePxStr = 2;
arrayCol.csInds = 3;
arrayCol.csVals = 4;
arrayCol.consType = 5;
arrayCol.endogPr = 6;
arrayCol.endogUL = 7;
arrayCol.endogFC = 8;
arrayCol.script = 9;
%name                   basePriceStructure	csInds          csvals          consType        endPr  endUL    endFC   experimentSpecificScript
csArray = {
'DentonSCutback'        DentonS             {[] [1] []}     [3.8 4]*inflationAdj     'dual'          [2]    [1]       []      'consumptionDown5pct';
};
 experiments
 
