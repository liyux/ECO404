numhh = 10;
correlationmatrix=[1 0.4926 -0.0189 0.1842 ; 0.4926 1 0.1503 0.1009 ; -0.0189 0.1503 1 -0.012 ; 0.1842 0.1009 -0.012 1];

genNumHH = 3*numhh;
numpeople=normrnd(3.467,1.46,[genNumHH,1]); 
income=normrnd(132.242,98.786,[genNumHH,1]);
hvalue=normrnd(255.514,212.76,[genNumHH,1]);
lawnsize=normrnd(0.3590,1.026,[genNumHH,1]);

weather = 10; 
constant = 1;

correlatedhh=[numpeople income hvalue lawnsize]*chol(correlationmatrix);
correlatedhh=sortrows(correlatedhh,1);

numpeople = correlatedhh(1:genNumHH,1);
nsubset=numpeople(find((numpeople>=1)&(numpeople<=9)));
numpeople = nsubset(1:numhh);
income = correlatedhh(1:genNumHH,2);
isubset=income(find((income>=0)&(income<=890)));
income = isubset(1:numhh);
hvalue = correlatedhh(1:genNumHH,3);
hvsubset=hvalue(find((hvalue>=0.1)&(hvalue<=1925)));
hvalue = hvsubset(1:numhh);
lawnsize = correlatedhh(1:genNumHH,4);
lsubset=lawnsize(find((lawnsize>=0.0014)&(lawnsize<=22.263)));
lawnsize = lsubset(1:numhh);

hhmatrix = [exp(1)*ones(numhh,1) numpeople hvalue lawnsize weather*ones(numhh,1)];
hhIncome = income;
%hhmatrix [constant numpeople hvalue lawnsize weather]
%hhmatrix is hhsizex5




%generate values on normal distribution, correlate it, then extract those
%that fall within the min & max


%adjust coefficients for inflation.

