function test_best_nets(X_test, T_test, classes)
% Carrega as 3 melhores redes gravadas e testa-as no dataset de teste
%
% Entradas:
%   X_test  — matriz de entrada do dataset de teste [14 x N]
%   T_test  — target binário do dataset de teste [3 x N]
%   classes — cell array com os nomes das classes {'Normal', 'ElectricalFailure', 'MechanicalFailure'}

fprintf('\n========= TESTE DAS 3 MELHORES REDES =========\n\n');

nomes = {'results/best_net1.mat', 'results/best_net2.mat', 'results/best_net3.mat'};

for k = 1:3

    fprintf('--- Rede %d ---\n', k);

    % carregar rede
    if ~isfile(nomes{k})
        fprintf('  Ficheiro %s não encontrado. Ignorar.\n\n', nomes{k});
        continue;
    end

    dados = load(nomes{k});
    net   = dados.net;
    cfg   = dados.config; % configuração guardada com a rede

    fprintf('  Topologia:      %s\n', mat2str(cfg.topologia));
    fprintf('  Func. treino:   %s\n', cfg.func_treino);
    fprintf('  Func. ativação: %s\n', cfg.func_ativacao);
    fprintf('  Divisão:        %s\n', mat2str(cfg.divisao));

    % classificar
    Y = net(X_test);
    [~, pred] = max(Y, [], 1);
    [~, real] = max(T_test, [], 1);

    % precisão global
    acc_global = 100 * sum(pred == real) / length(real);
    fprintf('  Precisão global no teste: %.2f%%\n', acc_global);

    % precisão por classe
    fprintf('  Precisão por classe:\n');
    for c = 1:3
        idx_classe = (real == c);
        if sum(idx_classe) == 0
            fprintf('    %-22s: sem amostras\n', classes{c});
        else
            acc_c = 100 * sum(pred(idx_classe) == c) / sum(idx_classe);
            fprintf('    %-22s: %.2f%%\n', classes{c}, acc_c);
        end
    end

    % plotconfusion
    figure;
    plotconfusion(T_test, Y);
    title(sprintf('Rede %d — Teste', k));

    fprintf('\n');
end

end
