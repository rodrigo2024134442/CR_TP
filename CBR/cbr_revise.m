function temp_final = cbr_revise(temp_atual, temp_sugerida, modo_interativo, verbose)
% cbr_revise — revisa e confirma a solução sugerida (fase humana/automática)
%
% Descrição:
%   Implementa a etapa "Revise" do ciclo CBR. Dá ao utilizador a opção de
%   aceitar ou rejeitar a temperatura sugerida pela rede. Existe também um
%   modo não-interativo para aceitar automaticamente (útil para testes).
%
% Entradas:
%   temp_atual      - temperatura atual registada no novo caso
%   temp_sugerida   - temperatura sugerida pela fase de reuse (rede)
%   modo_interativo - (opcional) true = perguntar ao utilizador; false = aceitar automático
%   verbose         - (opcional) true/false para imprimir mensagens
%
% Saída:
%   temp_final      - temperatura final aceite (pode ser temp_atual ou temp_sugerida)

if nargin < 3 || isempty(modo_interativo)
    modo_interativo = true;
end

if nargin < 4 || isempty(verbose)
    verbose = true;
end

if verbose
    fprintf('\n--- REVISE ---\n');
    fprintf('  Temperatura atual:    %.2f C\n', temp_atual);
    fprintf('  Temperatura sugerida: %.2f C\n', temp_sugerida);
end

if modo_interativo
    % Pergunta ao utilizador se aceita a sugestão. A função `input` devolve
    % uma string quando usamos o segundo argumento 's'. O utilizador deve
    % responder 's' para aceitar, qualquer outra coisa é interpretada como rejeição.
    resposta = input('  Aceita a temperatura sugerida? (s/n): ', 's');
    
    if strcmp(resposta, 's')
        % Aceite: usa a temperatura sugerida
        temp_final = temp_sugerida;
        if verbose
            fprintf('  Temperatura atualizada para %.2f C\n', temp_final);
        end
    else
        % Rejeitado: mantém a temperatura original do caso
        temp_final = temp_atual;
        if verbose
            fprintf('  Temperatura mantida em %.2f C\n', temp_final);
        end
    end
else
    % Modo não-interativo: automaticamente aceita a sugestão (útil em testes)
    temp_final = temp_sugerida;
    if verbose
        fprintf('  Temperatura atualizada para %.2f C (automático)\n', temp_final);
    end
end

end
