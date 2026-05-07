% =========================================================================
% main_task2_weights_analysis.m — Análise de diferentes pesos no CBR
% Testa o sistema CBR com várias configurações de pesos
% =========================================================================

clear; close all;
script_dir = fileparts(mfilename('fullpath'));
proj_root = fileparts(script_dir);

addpath(proj_root);
addpath(script_dir)
addpath(fullfile(proj_root, 'datasetfix'))

results_dir = fullfile(proj_root, 'results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

fprintf('=== TAREFA 3.2b — ANÁLISE DE PESOS NO CBR ===\n\n');

% -------------------------------------------------------------------------
% 1. Carregar datasets
% -------------------------------------------------------------------------
fprintf('A carregar datasets...\n');
load(fullfile(proj_root, 'results', 'dataset_tratado.mat'));
data_original = data; % guardar para depois

% Normalizar dataset para testes
X = build_inputs(data);
X_min  = min(X, [], 2);
X_max  = max(X, [], 2);
intervalo = X_max - X_min;
intervalo(intervalo == 0) = 1;
X_norm = (X - X_min) ./ intervalo;

% Reconstruir tabela normalizada
data_norm = data;
colunas_numericas = {'temperature', 'vibration', 'rotation_speed', 'voltage', ...
                     'current', 'pressure', 'noise_level', 'efficiency', ...
                     'load_val', 'torque'};
for i = 1:length(colunas_numericas)
    col = colunas_numericas{i};
    idx_col = find(strcmp(data.Properties.VariableNames, col), 1);
    data_norm.(col) = X_norm(idx_col, :)';
end

% Carregar e preparar ficheiro de teste
dados_teste = readtable(fullfile(proj_root, 'data', 'dataset_TP_test.csv'), 'TextType', 'string');
dados_teste = convert_categoricals(dados_teste);

% Normalizar dados de teste com os mesmos limites do treino
X_test = build_inputs(dados_teste);
X_test_norm = (X_test - X_min) ./ intervalo;
dados_teste_norm = dados_teste;
for i = 1:length(colunas_numericas)
    col = colunas_numericas{i};
    idx_col = find(strcmp(dados_teste.Properties.VariableNames, col), 1);
    dados_teste_norm.(col) = X_test_norm(idx_col, :)';
end

fprintf('Dataset de treino: %d casos\n', height(data_original));
fprintf('Dataset de teste:  %d casos\n\n', height(dados_teste));

% Treinar rede neuronal uma única vez
fprintf('A treinar a rede neuronal para prever temperature...\n');
rede = treinar_rede_temperature(data_original);
fprintf('Rede treinada!\n\n');

% -------------------------------------------------------------------------
% 2. Definir diferentes configurações de pesos
% -------------------------------------------------------------------------
fprintf('Definindo configurações de pesos...\n\n');

% Pesos por defeito
pesos_default = [2.0, 3.0, 2.0, 3.0, 3.0, 1.5, 2.0, 2.0, 1.5, 2.0, 0.5, 0.5, 0.5, 1.0];

% Pesos alternativos:
% Config 1: Iguais (todos com peso 1.0)
pesos_iguais = ones(1, 14);

% Config 2: Sensor-heavy (enfatiza sensores principais: vibration, voltage, current)
pesos_sensors = [1.0, 5.0, 1.0, 5.0, 5.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 0.5, 0.5, 1.0];

% Config 3: Mechanical focus (vibration, rotation_speed, noise_level, torque)
pesos_mechanical = [1.0, 5.0, 4.0, 1.0, 1.0, 1.0, 4.0, 1.0, 1.0, 4.0, 0.5, 0.5, 0.5, 1.0];

% Config 4: Electrical focus (voltage, current, efficiency, temperature)
pesos_electrical = [4.0, 1.0, 1.0, 5.0, 5.0, 1.0, 1.0, 3.0, 1.0, 1.0, 0.5, 0.5, 0.5, 1.0];

% Config 5: Sem contexto (ignora maintenance_level, operating_mode, cooling_type)
pesos_no_context = [2.0, 3.0, 2.0, 3.0, 3.0, 1.5, 2.0, 2.0, 1.5, 2.0, 0.0, 0.0, 0.0, 1.0];

% Guardar todas as configurações
configs_pesos = {
    pesos_default,      'Default (Balanceado)';
    pesos_iguais,       'Pesos Iguais';
    pesos_sensors,      'Sensores Principais';
    pesos_mechanical,   'Foco Mecânico';
    pesos_electrical,   'Foco Elétrico';
    pesos_no_context,   'Sem Contexto';
};

n_configs = size(configs_pesos, 1);

% -------------------------------------------------------------------------
% 3. Testar cada configuração
% -------------------------------------------------------------------------
fprintf('Testando %d configurações de pesos...\n\n', n_configs);

% Tabelas para armazenar resultados
resultados = table();
resultados.Configuracao = strings(n_configs, 1);
resultados.Acertos_NaoNorm = zeros(n_configs, 1);
resultados.Taxa_NaoNorm = zeros(n_configs, 1);
resultados.Acertos_Norm = zeros(n_configs, 1);
resultados.Taxa_Norm = zeros(n_configs, 1);

for c = 1:n_configs
    
    pesos_atual = configs_pesos{c, 1};
    nome_config = configs_pesos{c, 2};
    
    fprintf('--- Config %d/%d: %s ---\n', c, n_configs, nome_config);
    
    % =====================================================================
    % Teste SEM normalização
    % =====================================================================
    fprintf('  Testando SEM normalização...\n');
    
    n_testes = height(dados_teste);
    acertos_nn = 0;
    
    for i = 1:n_testes
        
        novo_caso = dados_teste(i, :);
        classe_correta = novo_caso.class_cat;
        novo_caso.class_cat = missing;
        
        % CBR com pesos customizados
        [~, best_idx, ~] = cbr_retrieve(novo_caso, data_original, 0.8, pesos_atual, false);
        classe = data_original.class_cat(best_idx);
        
        if strcmp(string(classe), string(classe_correta))
            acertos_nn = acertos_nn + 1;
        end
    end
    
    taxa_nn = 100 * acertos_nn / n_testes;
    
    % =====================================================================
    % Teste COM normalização
    % =====================================================================
    fprintf('  Testando COM normalização...\n');
    
    acertos_n = 0;
    
    for i = 1:n_testes
        
        novo_caso = dados_teste_norm(i, :);
        classe_correta = novo_caso.class_cat;
        novo_caso.class_cat = missing;
        
        % CBR com pesos customizados
        [~, best_idx, ~] = cbr_retrieve(novo_caso, data_norm, 0.8, pesos_atual, false);
        classe = data_norm.class_cat(best_idx);
        
        if strcmp(string(classe), string(classe_correta))
            acertos_n = acertos_n + 1;
        end
    end
    
    taxa_n = 100 * acertos_n / n_testes;
    
    % Guardar resultados
    resultados.Configuracao(c) = string(nome_config);
    resultados.Acertos_NaoNorm(c) = acertos_nn;
    resultados.Taxa_NaoNorm(c) = taxa_nn;
    resultados.Acertos_Norm(c) = acertos_n;
    resultados.Taxa_Norm(c) = taxa_n;
    
    fprintf('    Sem normalização: %d/%d (%.1f%%)\n', acertos_nn, n_testes, taxa_nn);
    fprintf('    Com normalização: %d/%d (%.1f%%)\n', acertos_n, n_testes, taxa_n);
    fprintf('\n');
end

% -------------------------------------------------------------------------
% 4. Resultados finais
% -------------------------------------------------------------------------
fprintf('\n========= RESUMO DOS RESULTADOS =========\n\n');
disp(resultados);

% Encontrar melhor configuração
    [~, idx_melhor_nn] = max(resultados.Taxa_NaoNorm);
    [~, idx_melhor_n] = max(resultados.Taxa_Norm);

fprintf('\nMelhor configuração (SEM normalização):  %s (%.1f%%)\n', ...
    string(resultados.Configuracao(idx_melhor_nn)), resultados.Taxa_NaoNorm(idx_melhor_nn));

fprintf('Melhor configuração (COM normalização): %s (%.1f%%)\n', ...
    string(resultados.Configuracao(idx_melhor_n)), resultados.Taxa_Norm(idx_melhor_n));

fprintf('\n=== ANÁLISE DE PESOS CONCLUÍDA ===\n');

% -------------------------------------------------------------------------
% 5. Criar gráfico comparativo
% -------------------------------------------------------------------------
figure('Name', 'Análise de Pesos - CBR');
set(gcf, 'Color', 'w');

% Gráfico comparativo
subplot(1, 2, 1);
bar(1:n_configs, [resultados.Taxa_NaoNorm, resultados.Taxa_Norm]);
xlabel('Configuração de Pesos');
ylabel('Taxa de Acerto (%)');
title('Comparação: Normalizado vs Não Normalizado');
legend('Sem Normalização', 'Com Normalização');
set(gca, 'XTickLabel', resultados.Configuracao);
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
xtickangle(45);
grid on;

% Diferença entre normalizado e não normalizado
subplot(1, 2, 2);
diferenca = resultados.Taxa_Norm - resultados.Taxa_NaoNorm;
bar(1:n_configs, diferenca);
xlabel('Configuração de Pesos');
ylabel('Diferença (Normalizado - Sem Normalização) %');
title('Impacto da Normalização por Configuração');
set(gca, 'XTickLabel', resultados.Configuracao);
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
xtickangle(45);
grid on;
% Evitar usar axline (nem sempre disponível em todas as versões do MATLAB)
% Desenha uma linha horizontal em y=0 como referência
hold on;
line([0.5, n_configs+0.5], [0, 0], 'LineStyle', '--', 'Color', 'k');
hold off;

% Guardar figura
saveas(gcf, fullfile(results_dir, 'cbr_weights_analysis.fig'));
print(gcf, fullfile(results_dir, 'cbr_weights_analysis.png'), '-dpng', '-r150');

fprintf('Gráficos guardados em %s e .png\n', fullfile('results', 'cbr_weights_analysis.fig'));

% Guardar também um resumo para reutilização na tarefa 3.4
[~, idx_best_nonnorm] = max(resultados.Taxa_NaoNorm);
[~, idx_best_norm]    = max(resultados.Taxa_Norm);

best_cbr = struct();
best_cbr.idx_best_nonnorm = idx_best_nonnorm;
best_cbr.idx_best_norm    = idx_best_norm;
best_cbr.nome_best_nonnorm = string(configs_pesos{idx_best_nonnorm, 2});
best_cbr.nome_best_norm    = string(configs_pesos{idx_best_norm, 2});
best_cbr.pesos_best_nonnorm = configs_pesos{idx_best_nonnorm, 1};
best_cbr.pesos_best_norm    = configs_pesos{idx_best_norm, 1};

save(fullfile(results_dir, 'cbr_weights_analysis.mat'), 'resultados', 'configs_pesos', 'best_cbr');
writetable(resultados, fullfile(results_dir, 'cbr_weights_analysis.csv'));

fprintf('Resumo guardado em results/cbr_weights_analysis.mat e .csv\n');
