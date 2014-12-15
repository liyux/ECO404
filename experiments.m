%experiments to run
% vary first block price & size
% fixed price vs increasing prices in middle-high blocks
% Others: find essential household consumption & fix size of first block 
% based on that, then vary prices

%For Denton: summer & winter pricing IBP vs UP
%Summer: 
baseUlims = [15 30 50 1e6];
basePrice = [3.8 5.5 7.4 9.75]*inflationAdj;
baseFC = [0]*inflationAdj;
%Winter: 
baseUlims = [1e6];
basePrice = [3.8*inflationAdj];
baseFC = [0]*inflationAdj;

%Huntsville:
baseUlims = [7.5 30 1e6];
basePrice = [eps 4.42 5.25]*inflationAdj;
baseFC = [28]*inflationAdj;

% Victoria:  many blocks with small differences in marginal price 
%(compare to lesser blocks with bigger difference in prices)
% base charge (first 2000gallons included in base charge according to meter size)
baseUlims = [2 7 18 50 75 100 1e6];
basePrice = [eps 2.22 2.27 2.32 2.37 2.52 2.67]*inflationAdj;
baseFC = 40*inflationAdj;
