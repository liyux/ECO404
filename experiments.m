%experiments to run
% vary first block price & size
% fixed price vs increasing prices in middle-high blocks
% Others: find essential household consumption & fix size of first block 
% based on that, then vary prices

%For Denton: summer & winter pricing IBP vs UP
%Summer: 
DentonS.Ulims = [15 30 50 1e6];
DentonS.Price = [3.8 5.5 7.4 9.75]*inflationAdj;
DentonS.FC = [0]*inflationAdj;
%Winter: 
DentonW.Ulims = [1e6];
DentonW.Price = [3.8*inflationAdj];
DentonW.FC = [0]*inflationAdj;

%Huntsville:
Huntsville.Ulims = [7.5 30 1e6];
Huntsville.Price = [eps 4.42 5.25]*inflationAdj;
Huntsville.FC = [28]*inflationAdj;

% Victoria:  many blocks with small differences in marginal price 
%(compare to lesser blocks with bigger difference in prices)
% base charge (first 2000gallons included in base charge according to meter size)
Victoria.Ulims = [2 7 18 50 75 100 1e6];
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
'DentonSCutback'        DentonS             {[] [1] []}     [1.5 2 2.5]     'dual'          [2]    []       []      'consumptionDown5pct';
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

    endogPrices = csArray{jj,arrayCol.endogPr}; endogUlims = csArray{jj,arrayCol.endogUL};; endogFixed = csArray{jj,arrayCol.endogFC};;
    pxStrInfo.endog = [endogUlims endogPrices+pxStrInfo.blks endogFixed+2*pxStrInfo.blks];

    [baseRev, baseCons, baseDemand] = computeDemand(demandInfo,[basePX.Ulims basePX.Price basePX.FC]');
    %run the script whose name is 
    eval(csArray{jj,arrayCol.script})
    
    pxStrInfo.base = [basePX.Ulims(1) basePX.Ulims(2:end)-basePX.Ulims(1:end-1) basePX.Price(1) basePX.Price(2:end)-basePX.Price(1:end-1) basePX.FC]';
    csIndexRaw = csArray{jj,arrayCol.csIndices};
    csIndices = [csIndexRaw{1} csIndexRaw{2}+pxStrInfo.blks csIndexRaw{3}+2*pxStrInfo.blks];
    csUlimVals = csArray{jj,arrayCol.csVals};
for ii=1:length(csUlimVals)
    pxStrInfo.base(csIndices) = csUlimVals(ii);
    
    switch csArray{jj,arrayCol.consType}
        case 'rev'
            [optStr,fval,exitflag] = fsolve(@(endogPS) revenueConstraint(endogPS,pxStrInfo,goalRev,demandInfo),endogPS);
    
        case 'dual'
            [optStr,fval,exitflag] = fsolve(@(endogPS) revConsConstraint(endogPS,pxStrInfo,goalRev,demandInfo),endogPS);
        otherwise
            error(['I don''t recognize the constraint type ' csArray{jj,arrayCol.consType}])
    end
    
     if exitflag<1;
        keyboard
     end
     
    optEndog(ii) = optStr; %gives uniform price
    pxOptInc = pxStrInfo.base;
    pxOptInc(pxStrInfo.endog) = optStr;
    
    pxOpt = convertPX(pxOptInc);
    [optRev, optCons, optHHInfo] =  computeDemand(demandInfo,pxOpt);
    
    optOutput.Cons(ii) = optCons;
    optOutput.Rev(ii) = optRev;
    optOutput.PX(ii,:) = pxOpt;
    hhInfo{ii} = optHHInfo;
end

end