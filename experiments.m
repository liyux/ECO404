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
'DentonSCutback'        DentonS             {[] [1] []}     [1.5 2 2.5]     'dual'          [2]    [1]       []      'consumptionDown5pct';
};

[numExp,csCols] = size(csArray);
for jj=1:numExp
    
    %extract base price structure and compute consumption, revenue, and household ouptuts
    basePX = csArray{jj,arrayCol.basePxStr};
    pxStrInfo.base = [basePX.Ulims(1) basePX.Ulims(2:end)-basePX.Ulims(1:end-1) basePX.Price(1) basePX.Price(2:end)-basePX.Price(1:end-1) basePX.FC]';
    pxStrInfo.blks = numel(basePX.Ulims);
    if numel(basePX.Price)~=pxStrInfo.blks
        error('You have entered a different number of prices and block upper limits')
    end

    endogPrices = csArray{jj,arrayCol.endogPr}; endogUlims = csArray{jj,arrayCol.endogUL}; endogFixed = csArray{jj,arrayCol.endogFC};
    pxStrInfo.endog = [endogUlims endogPrices+pxStrInfo.blks endogFixed+2*pxStrInfo.blks];

    [baseRev, baseCons, baseDemand] = computeDemand(demandInfo,[basePX.Ulims basePX.Price basePX.FC]');
    %run the script whose name is 
    eval(csArray{jj,arrayCol.script})
    %new custom scripts must define -- consumptionTarget and/or
    %revenueTarget
    
%     pxStrInfo.base = [basePX.Ulims(1) basePX.Ulims(2:end)-basePX.Ulims(1:end-1) basePX.Price(1) basePX.Price(2:end)-basePX.Price(1:end-1) basePX.FC]';
    csIndexRaw = csArray{jj,arrayCol.csInds};
    csIndex = [csIndexRaw{1} csIndexRaw{2}+pxStrInfo.blks csIndexRaw{3}+2*pxStrInfo.blks];
    if numel(csIndex)>1
        error('You are trying to do comparative statics on two variables at the same time. Double loops haven''t been programmed.')
    end 
    csVals = csArray{jj,arrayCol.csVals};
    endogPS0 = pxStrInfo.base(pxStrInfo.endog);
    
    for ii=1:length(csVals)
        pxStrInfo.base(csIndex) = csVals(ii);

        switch csArray{jj,arrayCol.consType}
            case 'rev'
                if numel(endogPS0)~=1
                    error(['You are trying to solve a single constraint problem and have ' num2str(numel(endogPS0)) ' endogenous variables.'])
                end
                [optStr,fval,exitflag] = fsolve(@(endogPS) revenueConstraint(endogPS,pxStrInfo,revenueTarget,demandInfo),endogPS0);

            case 'dual'
                if numel(endogPS0)~=2
                    error(['You are trying to solve a dual constraint problem and have ' num2str(numel(endogPS0)) ' endogenous variables.'])
                end
                [optStr,fval,exitflag] = fsolve(@(endogPS) revConsConstraint(endogPS,pxStrInfo,consumptionTarget,demandInfo),endogPS0);
            otherwise
                error(['I don''t recognize the constraint type ' csArray{jj,arrayCol.consType}])
        end

         if exitflag<1;
             disp('I ran into trouble solving for the IBP price that meets your goals. I''m stopping to let you figure out why.')
             keyboard
         end

        optEndog(ii) = optStr; %gives uniform price
        pxOptInc = pxStrInfo.base;
        pxOptInc(pxStrInfo.endog) = optStr;

        pxOpt = convertPX(pxOptInc);
        [optRev, optCons, optHHInfo] =  computeDemand(demandInfo,pxOpt);

        optOutput(ii,jj).Cons = optCons;
        optOutput(ii,jj).Rev = optRev;
        optOutput(ii,jj).Prices = pxOpt(pxStrInfo.blks+1:2*pxStrInfo.blks);
        optOutput(ii,jj).Ulims = pxOpt(1:pxStrInfo.blks);
        optOutput(ii,jj).FCs = pxOpt(end);
        optOutput(ii,jj).hhInfo = optHHInfo;
    end

end