numhh = 10;
correlationmatrix=[1 0.6 0.7 0.7 ; 0.6 1 0.5 0.5 ; 0.7 0.5 1 0.9 ; 0.7 0.5 0.9 1];


numpeople=normrnd(2.85,1.32,[1.5*numhh,1]); 
nsubset=numpeople(find((numpeople>=1)&(numpeople<=8)));
numpeople = nsubset(1:numhh);
income=normrnd(57.86,34.36,[1.5*numhh,1]);
isubset=income(find((income>=15)&(income<=125)));
income = isubset(1:numhh);
hvalue=normrnd(94.75,62.01,[1.5*numhh,1]);
hvsubset=hvalue(find((hvalue>=4.95)&(hvalue<=1166.71)));
hvalue = hvsubset(1:numhh);
lawnsize=normrnd(0.3590,1.026,[2.5*numhh,1]);
lsubset=lawnsize(find((lawnsize>=0.0014)&(lawnsize<=22.263)));
lawnsize = lsubset(1:numhh);

weather = 10; 
constant = 1;

correlatedhh=[numpeople income hvalue lawnsize]*chol(correlationmatrix);
correlatedhh=sortrows(correlatedhh,1);
income=correlatedhh(1:numhh,2);
%hhmatrix [constant numpeople hvalue lawnsize weather]
hhmatrix=[exp(1)*ones(numhh,1) correlatedhh(1:numhh,1) correlatedhh(1:numhh,3) correlatedhh(1:numhh,4) weather*ones(numhh,1)];
%hhmatrix is hhsizex5