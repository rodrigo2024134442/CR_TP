function [casos_similares, best_idx, best_sim] = cbr_retrieve(novo_caso, data, limiar, pesos_customizados, verbose)
% cbr_retrieve — encontra casos semelhantes a um novo caso usando CBR
%
% Uso:
%   [casos_similares, best_idx, best_sim] = cbr_retrieve(novo_caso, data, limiar, pesos_customizados, verbose)
%
% Descrição:
%   Compara um `novo_caso` com todos os casos da tabela `data` e calcula uma
%   similaridade global para cada caso. A similaridade global é a média
%   ponderada das similaridades locais por atributo (cada atributo tem um
%   peso que indica a sua importância). Retorna os casos cuja similaridade é
%   maior ou igual a `limiar`, além do índice e valor da melhor similaridade.
%
% Entradas:
%   novo_caso         - struct/tabela com os valores do caso a avaliar (1 linha)
%   data              - tabela com o dataset (cada linha é um caso histórico)
%   limiar            - limiar de similaridade (0..1). Casos com similaridade
%                       >= limiar são considerados relevantes (ex.: 0.8)
%   pesos_customizados- (opcional) vetor com pesos por atributo; se vazio usa
%                       `pesos_default` definidos abaixo
%   verbose           - (opcional) true/false; quando true imprime resumo no ecrã
%
% Saídas:
%   casos_similares   - tabela com os casos que passaram o limiar e uma coluna
%                       adicional `similaridade` com o valor calculado
%   best_idx          - índice em `data` do caso com maior similaridade
%   best_sim          - valor da maior similaridade encontrada (0..1)
%
% Exemplo rápido:
%   [res, idx, sim] = cbr_retrieve(novo, dataset, 0.8);
%   se `sim` = 0.95 então `dataset(idx,:)` é muito parecido com `novo`.



% Selecionar as colunas que participam no cálculo de similaridade.
% Estas são as variáveis de sensor/estado que usamos para comparar casos.
% (Excluímos a coluna de classe, porque essa é a etiqueta que queremos prever.)
colunas = {'temperature', 'vibration', 'rotation_speed', 'voltage', ...
           'current', 'pressure', 'noise_level', 'efficiency', ...
           'load_val', 'torque', 'maintenance_level', 'operating_mode', ...
           'cooling_type', 'sensor_status'};

% Pesos atribuídos a cada atributo: números maiores significam que o
% atributo tem mais influência na similaridade global. Os comentários
% abaixo explicam a motivação para cada peso (roteiro intuitivo, não uma
% regra fixa).
pesos_default = [2.0, ... % temperature    — indicador geral de qualquer falha
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

% usar pesos customizados se fornecidos, caso contrário usar os pesos por defeito
if nargin < 4 || isempty(pesos_customizados)
    pesos = pesos_default;
else
    pesos = pesos_customizados;
end

if nargin < 5 || isempty(verbose)
    verbose = true;
end


% Vamos normalizar cada atributo entre 0 e 1 para que a comparação seja
% consistente entre variáveis com escalas diferentes. Para isso calculamos
% o mínimo e máximo observados de cada coluna no dataset.
n_colunas = length(colunas);
col_min = zeros(1, n_colunas);  % mínimo observado de cada coluna
col_max = zeros(1, n_colunas);  % máximo observado de cada coluna

% Percorre cada coluna para extrair os extremos usados na normalização
for j = 1:n_colunas
    col = colunas{j};
    col_min(j) = min(data.(col));
    col_max(j) = max(data.(col));
end


n = height(data);
% Prealoca um vetor para guardar a similaridade global entre `novo_caso`
% e cada caso do dataset.
similaridades = zeros(n, 1);

for i = 1:n

    % Se o caso histórico não tiver classe (etiqueta), ignoramos porque
    % não é útil para recuperar exemplos rotulados.
    if ismissing(data.class_cat(i))
        similaridades(i) = 0;
        continue;
    end

    % Calcula a média ponderada das similaridades locais (uma por atributo)
    sim_total  = 0;  % soma das similaridades locais ponderadas
    peso_total = 0;  % soma dos pesos aplicados (normalização)

    for j = 1:n_colunas
        col = colunas{j};
        v1 = novo_caso.(col);       % valor do novo caso para este atributo
        v2 = data.(col)(i);         % valor do caso histórico

        % A função `local_similarity` normaliza a diferença entre v1 e v2
        % usando os limites (min/max) e devolve um valor entre 0 e 1.
        sim_local = local_similarity(v1, v2, col_min(j), col_max(j));

        % Acumula a contribuição ponderada deste atributo
        sim_total  = sim_total  + pesos(j) * sim_local;
        peso_total = peso_total + pesos(j);
    end

    % Similaridade global é a média ponderada (soma dos produtos / soma dos
    % pesos). Resultado numérico entre 0 (nada parecido) e 1 (idêntico).
    similaridades(i) = sim_total / peso_total;

end

% Identificar o melhor caso e montar a tabela de resultados filtrada
[best_sim, best_idx] = max(similaridades);

% Seleciona os índices dos casos cujo valor de similaridade é >= limiar
indices_acima = find(similaridades >= limiar);

% Extrai esses casos do dataset original para devolver ao utilizador
casos_similares = data(indices_acima, :);

% Anexa uma coluna com os valores de similaridade correspondentes para
% que seja mais simples analisar e ordenar o resultado fora desta função.
casos_similares.similaridade = similaridades(indices_acima);

% Mostrar resultados no ecrã

if verbose
    fprintf('\n--- RETRIEVE ---\n');
    fprintf('  Limiar usado:               %.2f\n', limiar);
    fprintf('  Casos acima do limiar:      %d\n', height(casos_similares));
    fprintf('  Caso mais similar:          índice %d\n', best_idx);
    fprintf('  Similaridade máxima:        %.4f\n', best_sim);
    fprintf('  Classe do caso mais similar: %s\n', string(data.class_cat(best_idx)));
end

end
