function pxStructure = convertPX(pxIncreases);

blocks = (numel(pxIncreases)-1)/2;

pxStructure(1) = pxIncreases(1); pxStructure(blocks+1) = pxIncreases(blocks+1);
for ii=2:blocks
    pxStructure(ii) = pxIncreases(ii) + pxStructure(ii-1);
    pxStructure(ii+blocks) = pxIncreases(ii+blocks) + pxStructure(ii+blocks-1);
end

pxStructure(end+1) = pxIncreases(end);
if isrow(pxStructure)
    pxStructure = pxStructure';
end