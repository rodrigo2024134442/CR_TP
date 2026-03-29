function [casos_similares, best_idx, best_sim] = cbr_retrieve(novo_caso, data, limiar)
% Retrieve do CBR — encontra os casos mais similares ao novo caso
%
% Entradas:
%   novo_caso  — linha com o novo caso a diagnosticar
%   data       — dataset completo
%   limiar     — similaridade mínima para considerar um caso relevante
%                (valor entre 0 e 1, recomendado: 0.8)
%
% Saídas:
%   casos_similares — tabela com os casos acima do limiar
%   best_idx        — índice do caso mais similar
%   best_sim        — similaridade do caso mais similar



% Definir colunas e pesos de cada atributo

% colunas usadas para calcular similaridade (todas exceto class_cat)
colunas = {'temperature', 'vibration', 'rotation_speed', 'voltage', ...
           'current', 'pressure', 'noise_level', 'efficiency', ...
           'load_val', 'torque', 'maintenance_level', 'operating_mode', ...
           'cooling_type', 'sensor_status'};

% pesos de cada atributo — valores mais altos = mais importante
% justificação: pesos refletem a relevância de cada atributo para
% identificar o tipo de falha (elétrica ou mecânica)
pesos = [2.0, ... % temperature    — indicador geral de qualquer falha
         3.0, ... % vibration      — principal indicador de falha mecânica
         2.0, ... % rotation_speed — indicador forte de falha mecânica
         3.0, ... % voltage        — principal indicador de falha elétrica
         3.0, ... % current        — principal indicador de falha elétrica
         1.5, ... % pressure       — relevante mas menos específico
         2.0, ... % noise_level    — indicador forte de falha mecânica
         2.0, ... % efficiency     — indicador geral de qualquer falha
         1.5, ... % load_val       — relevante mas menos específico
         2.0, ... % torque         — indicador forte de falha mecânica
         0.5, ... % maintenance_level — contexto, não diagnóstico
         0.5, ... % operating_mode    — contexto, não diagnóstico
         0.5, ... % cooling_type      — contexto, não diagnóstico
         1.0];    % sensor_status     — contexto útil mas indireto


% Calcular min e max de cada coluna
n_colunas = length(colunas);
col_min = zeros(1, n_colunas);  % mínimo de cada coluna
col_max = zeros(1, n_colunas);  % máximo de cada coluna

% Itera sobre as colunas selecionadas para calcular 
% os limites (mínimo e máximo) de cada variável
for j = 1:n_colunas
    col = colunas{j};
    col_min(j) = min(data.(col));
    col_max(j) = max(data.(col));
end


% Calcular similaridade global com cada caso do dataset

% vetor para guardar a similaridade com cada caso
n = height(data);
similaridades = zeros(n, 1);

for i = 1:n

    % ignorar casos sem classe — não são válidos para comparação
    if ismissing(data.class_cat(i))
        similaridades(i) = 0;
        continue;
    end

    % inicializar acumuladores para a média ponderada
    sim_total  = 0;  % soma das similaridades locais ponderadas
    peso_total = 0;  % soma dos pesos usados

    for j = 1:n_colunas

        % nome da coluna atual
        col = colunas{j};

        % obter os valores dos dois casos para este atributo
        v1 = novo_caso.(col);
        v2 = data.(col)(i);

        % calcular similaridade local normalizada entre 0 e 1
        sim_local = local_similarity(v1, v2, col_min(j), col_max(j));

        % acumular com o peso do atributo
        % atributos com peso maior contribuem mais para a similaridade global
        sim_total  = sim_total  + pesos(j) * sim_local;
        peso_total = peso_total + pesos(j);

    end

    % similaridade global = média ponderada das similaridades locais
    similaridades(i) = sim_total / peso_total;

end

% Encontrar o caso mais similar e filtrar pelo limiar

% encontrar o índice e similaridade do caso mais similar
[best_sim, best_idx] = max(similaridades);

% filtrar os casos com similaridade acima do limiar
indices_acima = find(similaridades >= limiar);

% extrair esses casos da tabela
casos_similares = data(indices_acima, :);

% adicionar coluna de similaridade à tabela de resultados
% para facilitar a análise
casos_similares.similaridade = similaridades(indices_acima);

% Mostrar resultados no ecrã

fprintf('\n--- RETRIEVE ---\n');
fprintf('  Limiar usado:               %.2f\n', limiar);
fprintf('  Casos acima do limiar:      %d\n', height(casos_similares));
fprintf('  Caso mais similar:          índice %d\n', best_idx);
fprintf('  Similaridade máxima:        %.4f\n', best_sim);
fprintf('  Classe do caso mais similar: %s\n', string(data.class_cat(best_idx)));

end
