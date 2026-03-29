% verificar_dataset.m
% Carrega dataset tratado e valida resultados

clc;
clear;

fprintf('=== VERIFICAÇÃO DO DATASET TRATADO ===\n\n');

% Carregar dataset
fprintf('A carregar dataset_tratado.mat...\n');
load('results/dataset_tratado.mat');
fprintf('Carregado: %d linhas, %d colunas\n\n', height(data), width(data));

% Verificar NaN nos inputs
fprintf('--- NaN nos inputs ---\n');
nan_total = 0;
colunas = data.Properties.VariableNames;

for i = 1:length(colunas)
    col = colunas{i};

    if isnumeric(data.(col))
        n = sum(isnan(data.(col)));

        if n > 0
            fprintf('  %-20s : %d NaN\n', col, n);
            nan_total = nan_total + n;
        end
    end
end

if nan_total == 0
    fprintf('  Nenhum NaN nos inputs!\n');
end
fprintf('\n');

% Verificar target
n_missing_target = sum(ismissing(data.class_cat));
fprintf('--- Target (class_cat) ---\n');
fprintf('  Missing values: %d\n\n', n_missing_target);

% Distribuição das classes
fprintf('--- Distribuição das classes ---\n');
classes = {'Normal', 'ElectricalFailure', 'MechanicalFailure'};

for i = 1:length(classes)
    n = sum(data.class_cat == classes{i});
    fprintf('  %-25s : %d registos (%.1f%%)\n', ...
            classes{i}, n, 100*n/height(data));
end
fprintf('\n');

% Mostrar primeiras linhas
fprintf('--- Primeiras 10 linhas ---\n');
disp(data(1:10, :));

% Resumo final
fprintf('=== RESUMO ===\n');

if nan_total == 0 && n_missing_target == 0
    fprintf('  Dataset tratado e pronto a usar!\n');
else
    fprintf('  ATENCAO: ainda existem valores em falta!\n');
    fprintf('  NaN nos inputs:    %d\n', nan_total);
    fprintf('  Missing no target: %d\n', n_missing_target);
end