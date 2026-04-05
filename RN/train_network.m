function [media_global, media_teste, melhor_net, melhor_tr] = train_network(X, T, topologia, func_treino, func_ativacao, divisao)
% TRAIN_NETWORK Treina uma rede neuronal com uma dada configuração (10 repetições)
%
% Entradas:
%   X            — matriz de entrada [14 x N]
%   T            — matriz target (one-hot) [3 x N]
%   topologia    — vetor com nº de neurónios por camada (ex: [10] ou [20 10])
%   func_treino  — função de treino ('trainlm', 'trainbr', 'traingd', 'trainscg')
%   func_ativacao— função de ativação na camada de saída ('tansig', 'logsig', etc.)
%   divisao      — percentagem de divisão dos dados [treino validação teste]
%
% Saídas:
%   media_global — média da precisão global nas 10 execuções (%)
%   media_teste  — média da precisão no conjunto de teste (%)
%   melhor_net   — rede com melhor desempenho no teste
%   melhor_tr    — estrutura de treino associada à melhor rede

    % Número de repetições (para reduzir variabilidade)
    N_REP = 10;

    % Vetores para guardar as precisões em cada repetição
    precisoes_global = zeros(1, N_REP);
    precisoes_teste  = zeros(1, N_REP);

    % Variáveis para guardar a melhor rede encontrada
    melhor_net = [];
    melhor_tr  = [];
    melhor_acc = -1; % inicialização com valor baixo

    % Loop principal (treinar várias vezes a rede)
    for rep = 1:N_REP

        % --- Criar rede neuronal ---
        % patternnet → rede para classificação
        net = patternnet(topologia, func_treino);

        % --- Definir função de ativação na camada de saída ---
        % Por defeito é 'softmax', só altera se for diferente
        if ~strcmp(func_ativacao, 'softmax')
            net.layers{end}.transferFcn = func_ativacao;
        end

        % --- Divisão dos dados (treino / validação / teste) ---
        net.divideParam.trainRatio = divisao(1) / 100;
        net.divideParam.valRatio   = divisao(2) / 100;
        net.divideParam.testRatio  = divisao(3) / 100;

        % --- Parâmetros de treino ---
        net.trainParam.showWindow = false; % desativa interface gráfica
        net.trainParam.epochs     = 500;   % número máximo de épocas
        net.trainParam.max_fail   = 10;    % early stopping (validação)

        % --- Treinar a rede ---
        [net, tr] = train(net, X, T);

        % --- Avaliação GLOBAL (todo o dataset) ---
        Y = net(X); % saídas da rede
        [~, pred] = max(Y, [], 1); % classe prevista
        [~, real] = max(T, [], 1); % classe real

        % cálculo da precisão (%)
        acc_global = 100 * sum(pred == real) / length(real);
        precisoes_global(rep) = acc_global;

        % --- Avaliação no conjunto de TESTE ---
        % Nota: 'trainbr' não separa dados → testInd vazio
        idx_teste = tr.testInd;

        if isempty(idx_teste)
            % Caso especial (ex: trainbr)
            % Usa todo o dataset como aproximação
            Y_teste = net(X);
            T_teste = T;
        else
            % Usa apenas os índices de teste
            Y_teste = net(X(:, idx_teste));
            T_teste = T(:, idx_teste);
        end

        % classes previstas vs reais
        [~, pred_t] = max(Y_teste, [], 1);
        [~, real_t] = max(T_teste, [], 1);

        % precisão no teste (%)
        acc_teste = 100 * sum(pred_t == real_t) / length(real_t);
        precisoes_teste(rep) = acc_teste;

        % --- Guardar a melhor rede ---
        % Critério: maior precisão no conjunto de teste
        if acc_teste > melhor_acc
            melhor_acc = acc_teste;
            melhor_net = net;
            melhor_tr  = tr;
        end

    end

    % --- Resultados finais (médias) ---
    media_global = mean(precisoes_global);
    media_teste  = mean(precisoes_teste);

end