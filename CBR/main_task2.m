% =========================================================================
% main_task2.m — Sistema CBR completo
% Testa o sistema com os 30 casos do dataset_TP_test.csv
% =========================================================================

clc; clear; close all;
addpath(genpath(pwd));
addpath("results\")
addpath("CBR\")
% -------------------------------------------------------------------------
% 1. Carregar datasets
% -------------------------------------------------------------------------
fprintf('A carregar datasets...\n');
load('results/dataset_tratado.mat');

% carregar e preparar ficheiro de teste
dados_teste = readtable('data/dataset_TP_test.csv', 'TextType', 'string');
dados_teste = convert_categoricals(dados_teste);
fprintf('Dataset de treino: %d casos\n', height(data));
fprintf('Dataset de teste:  %d casos\n\n', height(dados_teste));

% -------------------------------------------------------------------------
% 2. Treinar a rede neuronal UMA vez antes do ciclo
% -------------------------------------------------------------------------
fprintf('A treinar a rede neuronal para prever temperature...\n');
rede = treinar_rede_temperature(data);
fprintf('\n');

% -------------------------------------------------------------------------
% 3. Ciclo CBR — testar cada um dos 30 casos
% -------------------------------------------------------------------------
n_testes   = height(dados_teste);
resultados = strings(n_testes, 2); % col 1 = previsto, col 2 = correto
acertos    = 0;

for i = 1:n_testes

    fprintf('\n========= CASO %d/%d =========\n', i, n_testes);

    % extrair o novo caso
    novo_caso = dados_teste(i, :);

    % guardar a classe correta e remover do novo caso
    % simula um caso real sem diagnóstico
    classe_correta      = novo_caso.class_cat;
    novo_caso.class_cat = missing;

    % 1. RETRIEVE — encontrar casos mais similares
    [casos_similares, best_idx, best_sim] = cbr_retrieve(novo_caso, data, 0.8);

    % 2. REUSE — copiar classe e sugerir temperature
    [classe, temp_sugerida] = cbr_reuse(data(best_idx,:), novo_caso, rede);

    % 3. REVISE — utilizador aceita ou rejeita a temperature sugerida
    temp_final = cbr_revise(novo_caso.temperature, temp_sugerida);

    % 4. RETAIN — guardar o caso se for suficientemente diferente
    data = cbr_retain(data, novo_caso, classe, temp_final, best_sim);

    % registar resultado
    resultados(i, 1) = string(classe);
    resultados(i, 2) = string(classe_correta);

    % verificar se acertou
    if strcmp(string(classe), string(classe_correta))
        acertos = acertos + 1;
        fprintf('  Resultado: CORRETO\n');
    else
        fprintf('  Resultado: ERRADO (previsto: %s | correto: %s)\n', ...
                string(classe), string(classe_correta));
    end

end

% -------------------------------------------------------------------------
% 4. Resultados finais
% -------------------------------------------------------------------------
fprintf('\n========= RESULTADOS FINAIS =========\n');
fprintf('  Casos testados:  %d\n', n_testes);
fprintf('  Acertos:         %d\n', acertos);
fprintf('  Taxa de acerto:  %.1f%%\n', 100 * acertos / n_testes);

% tabela de detalhe por caso
fprintf('\n--- Detalhe por caso ---\n');
fprintf('  %-5s %-25s %-25s %s\n', 'Caso', 'Previsto', 'Correto', 'Resultado');
fprintf('  %s\n', repmat('-', 1, 65));
for i = 1:n_testes
    if strcmp(resultados(i,1), resultados(i,2))
        resultado_txt = 'CORRETO';
    else
        resultado_txt = 'ERRADO';
    end
    fprintf('  %-5d %-25s %-25s %s\n', i, ...
            resultados(i,1), resultados(i,2), resultado_txt);
end
