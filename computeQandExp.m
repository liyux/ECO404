%calculate quantity demanded and expenditure within a loop

    %redefining all variables containing p11
    d2 = 0.001*(p12i-p11i)*x11i;
    pricematrix = [p11i*ones(numhh,1) p11i*ones(numhh,1) p12i*ones(numhh,1)];
    d.p11i = p11i.^coef.p1;
    d.p12i=p12i.^coef.p1;
    d.y2=(income+d2).^coef.yd;
    condd1 = d.hh.*d.p11i.*d.y1;
    condd2 = d.hh.*d.p12i.*d.y2;
    condd = [condd1 ones(numhh,1)*x11i condd2];
    
    % creating a matrix of binary variables that has the value 1 if the
    %household belongs in that block, and 0 otherwise. 
    
    checkCondd1 = condd1<x11i;
    checkCondd2 = condd2>x11i;
    checkAtKink = ones(numhh,1) - checkCondd1 - checkCondd2;
    hhBlock = [checkCondd1 checkAtKink checkCondd2];
    numhhBlocki(i,:) = sum(hhBlock);
    qtydIBPi(:,i) = sum(hhBlock.*condd,2);
    totalConsumptionIBPi(1,i) = sum(qtydIBPi(:,i));
    
    % finding total expenditure per household by multiplying prices with
    % quantity demanded in each block. Total revenue is obtained by summing
    % the column of household expenditures.
    
    expIBPi(:,i) = sum(hhBlock.*condd.*pricematrix,2);
    totalRevenueIBPi(1,i) = sum(expIBPi(:,i));
    UPsameRevi(1,i) = (totalRevenueIBPi(1,i)/sum(d.hh.*d.y))^(1/(coef.p1+1));
    UPsameConsumptioni(1,i) = (sum(d.hh.*d.y)/totalConsumptionIBPi(1,i))^(-1/coef.p1);
    
    