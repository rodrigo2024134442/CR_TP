function data = fill_missing_target(data)
% Preenche NaN em class_cat usando CBR (linha mais similar)
% Entrada: tabela com inputs já tratados
% Saída:   tabela com class_cat completo

% Índices das linhas sem classe
indices_missing = find(ismissing(data.class_cat));

fprintf('  Linhas sem classe a preencher: %d\n', length(indices_missing));

% Colunas usadas para calcular similaridade (exceto class_cat)
colunas = {'temperature', 'vibration', 'rotation_speed', 'voltage', ...
           'current', 'pressure', 'noise_level', 'efficiency', ...
           'load_val', 'torque', 'maintenance_level', 'operating_mode', ...
           'cooling_type', 'sensor_status'};

% Calcular mínimo e máximo de cada coluna (para normalização)
n_colunas = length(colunas);
col_min = zeros(1, n_colunas);
col_max = zeros(1, n_colunas);

for j = 1:n_colunas
    col = colunas{j};
    col_min(j) = min(data.(col));
    col_max(j) = max(data.(col));
end

% Para cada linha sem classe, encontrar a mais similar
for i = 1:length(indices_missing)

    idx_missing = indices_missing(i);     % índice da linha sem classe
    linha_sem_classe = data(idx_missing,:);

    melhor_sim = -1;   % melhor similaridade encontrada
    melhor_idx = -1;   % índice da linha mais similar

    % Comparar com todas as linhas com classe conhecida
    for k = 1:height(data)

        if ismissing(data.class_cat(k))
            continue; % ignora linhas sem classe
        end

        sim = calcular_similaridade(linha_sem_classe, data(k,:), ...
                                   colunas, col_min, col_max);

        if sim > melhor_sim
            melhor_sim = sim;
            melhor_idx = k;
        end
    end

    % Copiar classe da linha mais similar
    data.class_cat(idx_missing) = data.class_cat(melhor_idx);
end

fprintf('  Preenchimento do target concluído!\n');

end

% Função auxiliar: similaridade entre duas linhas
function sim = calcular_similaridade(linha1, linha2, colunas, col_min, col_max)
% Média das similaridades locais normalizadas

    sim_total = 0;
    n_validos = 0;

    for j = 1:length(colunas)

        col = colunas{j};
        v1 = linha1.(col);
        v2 = linha2.(col);

        intervalo = col_max(j) - col_min(j);

        if intervalo == 0
            sim_local = 1; % valores iguais
        else
            sim_local = 1 - (abs(v1 - v2) / intervalo); % normalização
        end

        sim_total = sim_total + sim_local;
        n_validos = n_validos + 1;
    end

    sim = sim_total / n_validos; % média final
end