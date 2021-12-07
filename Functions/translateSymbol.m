function [Symbol]=translateSymbol(SymbolIn)
%% This function translate the type of the symbol of each figure to the matalb symbol 

if strcmp(SymbolIn,'line')
    Symbol='-';
elseif strcmp(SymbolIn,'dash')
    Symbol='--';       
elseif strcmp(SymbolIn,'circle')
    Symbol='o';
elseif strcmp(SymbolIn,'plus')
    Symbol='+';
elseif strcmp(SymbolIn,'dash dott')
    Symbol='-.';    
else 
    
    error('undifined symbol for the graph')
end 

end 

