function [ d ] = findDiff( m )
Q1 = sum(m(1:0.2*size(m,1),:));
Q5 = sum(m(0.8*size(m,1):size(m,1),:));
d = Q5 - Q1;
end

