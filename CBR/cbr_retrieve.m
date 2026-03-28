function [best_idx, best_sim] = cbr_retrieve(novo_caso, data)

n = height(data);
sims = zeros(n,1);

for i = 1:n
    caso = data(i,:);
    
    sim_total = 0;
    count = 0;
    
    vars = data.Properties.VariableNames;
    
    for j = 1:length(vars)
        if strcmp(vars{j}, 'target')
            continue;
        end
        
        v1 = novo_caso.(vars{j});
        v2 = caso.(vars{j});
        
        if ismissing(v1) || ismissing(v2)
            continue;
        end
        
        sim = local_similarity(v1, v2);
        sim_total = sim_total + sim;
        count = count + 1;
    end
    
    sims(i) = sim_total / count;
end

[best_sim, best_idx] = max(sims);
end