function [classe, temp_sugerida] = cbr_reuse(caso_similar, novo_caso, rede, verbose)
% cbr_reuse — reutiliza informação do caso recuperado e aplica ajuste
%
% Descrição:
%   Esta função implementa a etapa "Reuse" do ciclo CBR. Copia a classe
%   (diagnóstico) do `caso_similar` recuperado e usa uma rede neuronal já
%   treinada para prever/sugerir um valor de temperatura para o `novo_caso`.
%
% Entradas:
%   caso_similar - linha/tabela com o caso histórico mais similar (inclui class_cat)
%   novo_caso    - struct/tabela com os atributos do novo caso (uma linha)
%   rede         - função/objeto de rede previamente treinado que aceita um
%                  vetor de entrada e devolve uma previsão (ex.: temperatura)
%   verbose      - (opcional) true/false para imprimir mensagens no ecrã
%
% Saídas:
%   classe         - etiqueta (`class_cat`) copiada do caso similar
%   temp_sugerida  - valor de temperatura sugerido pela rede para o novo caso

if nargin < 4 || isempty(verbose)
	verbose = true;
end

% Copia a classe/diagnóstico do caso recuperado
classe = caso_similar.class_cat;

% Preparar o vetor de entrada para a rede. IMPORTANTE: a ordem e seleção
% dos atributos devem corresponder ao que a rede espera (mesmo pré-processo).
% Aqui usamos um exemplo com três atributos (ajuste conforme a rede real).
novo_input = [novo_caso.vibration; novo_caso.rotation_speed; novo_caso.voltage];

% Obter previsão da rede para a temperatura (ou outro valor alvo)
temp_sugerida = rede(novo_input);

% Imprime resumo quando solicitado — útil para estudo e depuração
if verbose
	fprintf('\n--- REUSE ---\n');
	fprintf('  Classe sugerida:      %s\n', string(classe));
	fprintf('  Temperatura atual:    %.2f C\n', novo_caso.temperature);
	fprintf('  Temperatura sugerida: %.2f C\n', temp_sugerida);
end

end
