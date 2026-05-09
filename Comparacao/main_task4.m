% =========================================================================
% main_task4.m — Comparação CBR vs Redes Neuronais (Tarefa 3.4)
% =========================================================================
% Objetivos:
%   - Comparar o melhor CBR sem normalização e com normalização
%   - Repetir experiências com as 3 melhores e 3 piores RN da tarefa 3.3
%     e comparar normalizado vs não normalizado
%   - Guardar `plotconfusion` e matrizes de confusão relevantes para o relatório
%   - Gerar tabelas e gráficos de apoio ao relatório
% =========================================================================

clear; close all;
script_dir = fileparts(mfilename('fullpath'));
proj_root = fileparts(script_dir);
results_dir = fullfile(proj_root, 'results');

addpath(proj_root);
addpath(fullfile(proj_root, 'CBR'));
addpath(fullfile(proj_root, 'RN'));
addpath(fullfile(proj_root, 'datasetfix'));

% Forçar defaults visuais mais legíveis em todas as figuras geradas
set(groot, 'defaultTextColor', 'k');
set(groot, 'defaultAxesXColor', 'k');
set(groot, 'defaultAxesYColor', 'k');
set(groot, 'defaultAxesZColor', 'k');

fprintf('=== TAREFA 3.4 — COMPARAÇÃO CBR vs RN ===\n\n');

% -------------------------------------------------------------------------
% 1. Carregar datasets tratados
% -------------------------------------------------------------------------
dataset_file = fullfile(results_dir, 'dataset_tratado.mat');
if ~isfile(dataset_file)
    error('Não foi encontrado %s. Execute a tarefa 3.1 primeiro.', dataset_file);
end

fprintf('A carregar dataset tratado...\n');
load(dataset_file); % variável: data

dados_teste = readtable(fullfile(proj_root, 'data', 'dataset_TP_test.csv'), 'TextType', 'string');
dados_teste = convert_categoricals(dados_teste);

classes = {'Normal', 'ElectricalFailure', 'MechanicalFailure'};

% Inputs para RN
X = build_inputs(data);
T = build_targets(data);
X_test = build_inputs(dados_teste);
T_test = build_targets(dados_teste);

% Normalização para CBR e para eventual reutilização
X_min = min(X, [], 2);
X_max = max(X, [], 2);
intervalo = X_max - X_min;
intervalo(intervalo == 0) = 1;
X_norm = (X - X_min) ./ intervalo;
X_test_norm = (X_test - X_min) ./ intervalo;

colunas_numericas = {'temperature', 'vibration', 'rotation_speed', 'voltage', ...
                     'current', 'pressure', 'noise_level', 'efficiency', ...
                     'load_val', 'torque'};

data_norm = data;
for i = 1:length(colunas_numericas)
    col = colunas_numericas{i};
    idx_col = find(strcmp(data.Properties.VariableNames, col), 1);
    data_norm.(col) = X_norm(idx_col, :)';
end

dados_teste_norm = dados_teste;
for i = 1:length(colunas_numericas)
    col = colunas_numericas{i};
    idx_col = find(strcmp(dados_teste.Properties.VariableNames, col), 1);
    dados_teste_norm.(col) = X_test_norm(idx_col, :)';
end

% -------------------------------------------------------------------------
% 2. Carregar resultados da análise de pesos do CBR
% -------------------------------------------------------------------------
cbr_weights_file = fullfile(results_dir, 'cbr_weights_analysis.mat');
pesos_default = [2.0, 3.0, 2.0, 3.0, 3.0, 1.5, 2.0, 2.0, 1.5, 2.0, 0.5, 0.5, 0.5, 1.0];

if isfile(cbr_weights_file)
    load(cbr_weights_file, 'resultados', 'configs_pesos', 'best_cbr'); %#ok<NASGU>
    [~, idx_best_nonnorm] = max(resultados.Taxa_NaoNorm);
    [~, idx_best_norm]    = max(resultados.Taxa_Norm);

    cbr_methods = {
        struct('nome', 'CBR melhor sem normalização', 'pesos', configs_pesos{idx_best_nonnorm, 1}, 'usa_norm', false),
        struct('nome', 'CBR melhor com normalização', 'pesos', configs_pesos{idx_best_norm, 1}, 'usa_norm', true)
    };
else
    warning('Ficheiro %s não encontrado. A usar pesos default do CBR.', cbr_weights_file);
    cbr_methods = {
        struct('nome', 'CBR default sem normalização', 'pesos', pesos_default, 'usa_norm', false),
        struct('nome', 'CBR default com normalização', 'pesos', pesos_default, 'usa_norm', true)
    };
end

% -------------------------------------------------------------------------
% 3. Avaliar CBR
% -------------------------------------------------------------------------
fprintf('A avaliar o CBR...\n');

method_names = strings(0, 1);
familias = strings(0, 1);
normalizacoes = strings(0, 1);
acertos_vec = [];
acc_global_vec = [];
acc_normal_vec = [];
acc_electrical_vec = [];
acc_mechanical_vec = [];

predicoes_todas = struct();

for m = 1:numel(cbr_methods)
    cfg = cbr_methods{m};

    if cfg.usa_norm
        train_table = data_norm;
        test_table  = dados_teste_norm;
    else
        train_table = data;
        test_table  = dados_teste;
    end

    [classe_real, classe_prevista, sim_max] = avaliar_cbr_test(test_table, train_table, cfg.pesos);
    [acc_global, acc_classes, n_acertos] = calcular_metricas(classe_real, classe_prevista, classes);
    matriz_confusao = confusionmat(categorical(classe_real, classes), categorical(classe_prevista, classes));

    method_names(end+1, 1) = string(cfg.nome); %#ok<SAGROW>
    familias(end+1, 1) = "CBR";
    normalizacoes(end+1, 1) = string(bool2txt(cfg.usa_norm));
    acertos_vec(end+1, 1) = n_acertos; %#ok<SAGROW>
    acc_global_vec(end+1, 1) = acc_global; %#ok<SAGROW>
    acc_normal_vec(end+1, 1) = acc_classes(1); %#ok<SAGROW>
    acc_electrical_vec(end+1, 1) = acc_classes(2); %#ok<SAGROW>
    acc_mechanical_vec(end+1, 1) = acc_classes(3); %#ok<SAGROW>

    predicoes_todas.(matlab.lang.makeValidName(cfg.nome)) = struct( ...
        'real', classe_real, ...
        'prevista', classe_prevista, ...
        'similaridade_maxima', sim_max, ...
        'matriz_confusao', matriz_confusao);

    fig = figure('Name', cfg.nome, 'Color', 'w');
    imagesc(matriz_confusao);
    colormap(parula);
    colorbar;
    axis equal tight;
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
    xticks(1:numel(classes));
    yticks(1:numel(classes));
    xticklabels(classes);
    yticklabels(classes);
    xlabel('Classe prevista');
    ylabel('Classe real');
    title(cfg.nome);
    for r = 1:numel(classes)
        for c = 1:numel(classes)
            text(c, r, sprintf('%d', matriz_confusao(r, c)), ...
                'HorizontalAlignment', 'center', 'Color', 'k', 'FontWeight', 'bold');
        end
    end
    force_black_text(fig);
    saveas(fig, fullfile(results_dir, [matlab.lang.makeValidName(cfg.nome) '.fig']));
    print(fig, fullfile(results_dir, [matlab.lang.makeValidName(cfg.nome) '.png']), '-dpng', '-r150');
end

% -------------------------------------------------------------------------
% 4. Repetir experiências com as 3 melhores e 3 piores RN
% -------------------------------------------------------------------------
fprintf('A reexecutar as 3 melhores e as 3 piores RN com e sem normalização...\n');

rn_cases = [
    struct('label', 'Melhor 1', 'file', fullfile(results_dir, 'best_net1.mat')),
    struct('label', 'Melhor 2', 'file', fullfile(results_dir, 'best_net2.mat')),
    struct('label', 'Melhor 3', 'file', fullfile(results_dir, 'best_net3.mat')),
    struct('label', 'Pior 1',   'file', fullfile(results_dir, 'worst_net1.mat')),
    struct('label', 'Pior 2',   'file', fullfile(results_dir, 'worst_net2.mat')),
    struct('label', 'Pior 3',   'file', fullfile(results_dir, 'worst_net3.mat'))
];

rn_names = strings(0, 1);
rn_grupo = strings(0, 1);
rn_norm  = strings(0, 1);
rn_acertos = [];
rn_acc_global = [];
rn_acc_normal = [];
rn_acc_electrical = [];
rn_acc_mechanical = [];

for k = 1:numel(rn_cases)
    if ~isfile(rn_cases(k).file)
        warning('Ficheiro %s não encontrado. A configuração %s será ignorada.', rn_cases(k).file, rn_cases(k).label);
        continue;
    end

    dados_cfg = load(rn_cases(k).file, 'net', 'config');
    cfg = dados_cfg.config;

    if isfield(cfg, 'learning_rate')
        params = struct('lr', cfg.learning_rate, 'epochs', cfg.epochs);
    else
        params = struct();
    end

    cfg_nome = rn_cases(k).label;

    for usa_norm = [false, true]
        if usa_norm
            trainX = X_norm;
            testX  = X_test_norm;
            train_table = data_norm;
            test_table  = dados_teste_norm;
            sufixo_norm = 'normalizado';
        else
            trainX = X;
            testX  = X_test;
            train_table = data;
            test_table  = dados_teste;
            sufixo_norm = 'nao_normalizado';
        end

        [media_global, media_teste, melhor_net, ~] = train_network( ...
            trainX, build_targets(train_table), cfg.topologia, cfg.func_treino, ...
            cfg.func_ativacao, cfg.divisao, params);

        % Avaliação no dataset de teste correspondente
        Y = melhor_net(testX);
        [~, idx_pred] = max(Y, [], 1);
        [~, idx_real] = max(T_test, [], 1);
        classe_prevista = string(classes(idx_pred));
        classe_real = string(classes(idx_real));

        [acc_global, acc_classes, n_acertos] = calcular_metricas(classe_real, classe_prevista, classes);
        matriz_confusao = confusionmat(categorical(classe_real, classes), categorical(classe_prevista, classes));

        rn_names(end+1, 1) = string(sprintf('%s - %s', cfg_nome, sufixo_norm)); %#ok<SAGROW>
        rn_grupo(end+1, 1) = string(cfg_nome); %#ok<SAGROW>
        rn_norm(end+1, 1) = string(bool2txt(usa_norm)); %#ok<SAGROW>
        rn_acertos(end+1, 1) = n_acertos; %#ok<SAGROW>
        rn_acc_global(end+1, 1) = acc_global; %#ok<SAGROW>
        rn_acc_normal(end+1, 1) = acc_classes(1); %#ok<SAGROW>
        rn_acc_electrical(end+1, 1) = acc_classes(2); %#ok<SAGROW>
        rn_acc_mechanical(end+1, 1) = acc_classes(3); %#ok<SAGROW>

        fig = figure('Name', sprintf('%s - %s', cfg_nome, sufixo_norm), 'Color', 'w');
        plotconfusion(build_targets(test_table), Y);
        force_black_text(fig);
        title(sprintf('%s — %s', cfg_nome, sufixo_norm));
        saveas(fig, fullfile(results_dir, sprintf('%s_plotconfusion_%s.fig', matlab.lang.makeValidName(cfg_nome), sufixo_norm)));
        print(fig, fullfile(results_dir, sprintf('%s_plotconfusion_%s.png', matlab.lang.makeValidName(cfg_nome), sufixo_norm)), '-dpng', '-r150');

        fig2 = figure('Name', sprintf('%s - %s matrix', cfg_nome, sufixo_norm), 'Color', 'w');
        imagesc(matriz_confusao);
        colormap(parula);
        colorbar;
        axis equal tight;
        set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
        xticks(1:numel(classes));
        yticks(1:numel(classes));
        xticklabels(classes);
        yticklabels(classes);
        xlabel('Classe prevista');
        ylabel('Classe real');
        title(sprintf('%s — %s', cfg_nome, sufixo_norm));
        for r = 1:numel(classes)
            for c = 1:numel(classes)
                text(c, r, sprintf('%d', matriz_confusao(r, c)), ...
                    'HorizontalAlignment', 'center', 'Color', 'k', 'FontWeight', 'bold');
            end
        end
        force_black_text(fig2);
        saveas(fig2, fullfile(results_dir, sprintf('%s_matrix_%s.fig', matlab.lang.makeValidName(cfg_nome), sufixo_norm)));
        print(fig2, fullfile(results_dir, sprintf('%s_matrix_%s.png', matlab.lang.makeValidName(cfg_nome), sufixo_norm)), '-dpng', '-r150');

        fprintf('  %s [%s] -> treino(media global %.2f%% / teste %.2f%%) | teste final %.2f%%\n', ...
            cfg_nome, sufixo_norm, media_global, media_teste, acc_global);
    end
end

% -------------------------------------------------------------------------
% 5. Resumo comparativo
% -------------------------------------------------------------------------
comparison = table(method_names, familias, normalizacoes, acertos_vec, acc_global_vec, ...
    acc_normal_vec, acc_electrical_vec, acc_mechanical_vec, ...
    'VariableNames', {'Metodo', 'Familia', 'Normalizacao', 'Acertos', 'Acc_Global', ...
    'Acc_Normal', 'Acc_Electrical', 'Acc_Mechanical'});

comparison_rn = table(rn_names, rn_grupo, rn_norm, rn_acertos, rn_acc_global, ...
    rn_acc_normal, rn_acc_electrical, rn_acc_mechanical, ...
    'VariableNames', {'Metodo', 'Grupo', 'Normalizacao', 'Acertos', 'Acc_Global', ...
    'Acc_Normal', 'Acc_Electrical', 'Acc_Mechanical'});

disp(comparison);

[~, idx_best] = max(comparison.Acc_Global);
fprintf('\nMelhor resultado global (CBR vs RN base): %s (%.2f%%)\n', comparison.Metodo(idx_best), comparison.Acc_Global(idx_best));

[~, idx_best_rn] = max(comparison_rn.Acc_Global);
fprintf('Melhor resultado global nas RN comparadas: %s (%.2f%%)\n', comparison_rn.Metodo(idx_best_rn), comparison_rn.Acc_Global(idx_best_rn));

% Gráfico comparativo global
fig_global = figure('Name', 'Comparação CBR vs RN', 'Color', 'w');
bar(categorical(comparison.Metodo), comparison.Acc_Global);
ylabel('Taxa de acerto global (%)');
title('CBR vs Redes Neuronais — desempenho global no dataset de teste');
grid on;
xtickangle(35);
force_black_text(fig_global);
save_figure_pair(fig_global, fullfile(results_dir, 'comparacao_global.fig'), fullfile(results_dir, 'comparacao_global.png'));

% Gráfico por classe
fig_classes = figure('Name', 'Comparação por classe', 'Color', 'w');
mat_classes = [comparison.Acc_Normal, comparison.Acc_Electrical, comparison.Acc_Mechanical];
bar(mat_classes, 'grouped');
set(gca, 'XTickLabel', comparison.Metodo);
xtickangle(35);
ylabel('Taxa de acerto por classe (%)');
legend(classes, 'Location', 'best');
title('CBR vs Redes Neuronais — desempenho por classe');
grid on;
force_black_text(fig_classes);
save_figure_pair(fig_classes, fullfile(results_dir, 'comparacao_classes.fig'), fullfile(results_dir, 'comparacao_classes.png'));

% Guardar resultados
save(fullfile(results_dir, 'comparacao_cbr_vs_rn.mat'), 'comparison', 'comparison_rn', 'predicoes_todas');
writetable(comparison, fullfile(results_dir, 'comparacao_cbr_vs_rn.csv'));
writetable(comparison_rn, fullfile(results_dir, 'comparacao_rn_3best_3worst_norm.csv'));

fprintf('\nResultados guardados em results/comparacao_cbr_vs_rn.mat e .csv\n');
fprintf('Resultados RN guardados em results/comparacao_rn_3best_3worst_norm.csv\n');
fprintf('=== TAREFA 3.4 CONCLUÍDA ===\n');

% =========================================================================
% Funções auxiliares
% =========================================================================

function [classe_real, classe_prevista, sim_max] = avaliar_cbr_test(test_table, train_table, pesos)
    n_testes = height(test_table);
    classe_real = strings(n_testes, 1);
    classe_prevista = strings(n_testes, 1);
    sim_max = zeros(n_testes, 1);

    for i = 1:n_testes
        novo_caso = test_table(i, :);
        classe_real(i) = string(novo_caso.class_cat);
        novo_caso.class_cat = missing;

        [~, best_idx, best_sim] = cbr_retrieve(novo_caso, train_table, 0.8, pesos, false);
        classe_prevista(i) = string(train_table.class_cat(best_idx));
        sim_max(i) = best_sim;
    end
end

function [acc_global, acc_classes, n_acertos] = calcular_metricas(classe_real, classe_prevista, classes)
    classe_real = string(classe_real);
    classe_prevista = string(classe_prevista);

    n_total = numel(classe_real);
    n_acertos = sum(classe_real == classe_prevista);
    acc_global = 100 * n_acertos / n_total;

    acc_classes = zeros(1, numel(classes));
    for c = 1:numel(classes)
        idx = classe_real == classes{c};
        if any(idx)
            acc_classes(c) = 100 * sum(classe_prevista(idx) == classes{c}) / sum(idx);
        else
            acc_classes(c) = NaN;
        end
    end
end

function txt = bool2txt(flag)
    if flag
        txt = 'sim';
    else
        txt = 'não';
    end
end

function force_black_text(fig)
    if nargin < 1 || ~isgraphics(fig)
        return;
    end

    ax = findall(fig, 'Type', 'Axes');
    for i = 1:numel(ax)
        try
            set(ax(i), 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k', 'Color', 'w');
        catch
        end
    end

    txt = findall(fig, 'Type', 'Text');
    for i = 1:numel(txt)
        try
            set(txt(i), 'Color', 'k');
        catch
        end
    end

    lgd = findall(fig, 'Type', 'Legend');
    for i = 1:numel(lgd)
        try
            set(lgd(i), 'TextColor', 'k', 'Color', 'w');
        catch
            try
                set(lgd(i), 'Color', 'w');
            catch
            end
        end
    end

    cbar = findall(fig, 'Type', 'ColorBar');
    for i = 1:numel(cbar)
        try
            set(cbar(i), 'Color', 'k');
        catch
        end
    end

    lineObjs = findall(fig, 'Type', 'Line');
    for i = 1:numel(lineObjs)
        try
            if isprop(lineObjs(i), 'Color') && isempty(get(lineObjs(i), 'DisplayName'))
                % não alterar linhas de dados; apenas garantir contraste nos contornos
            end
        catch
        end
    end
end

function save_figure_pair(fig_handle, fig_path, png_path)
    if ~isgraphics(fig_handle, 'figure')
        warning('Handle de figura inválido ao guardar: %s', fig_path);
        return;
    end

    try
        saveas(fig_handle, fig_path);
    catch ME
        warning('Falha ao guardar .fig (%s): %s', fig_path, ME.message);
    end

    try
        print(fig_handle, png_path, '-dpng', '-r150');
    catch ME
        warning('Falha ao guardar .png (%s): %s', png_path, ME.message);
    end
end