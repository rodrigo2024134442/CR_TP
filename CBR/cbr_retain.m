function data = cbr_retain(data, novo_caso, classe, temp_final, best_sim, verbose)
% cbr_retain — decide se o novo caso deve ser guardado na base de casos
%
% Descrição:
%   Implementa a etapa "Retain" do ciclo CBR. Se o `novo_caso` for
%   suficientemente diferente dos casos existentes (i.e., similaridade
%   máxima `best_sim` é menor que um limiar), actualiza o caso com a classe
%   final e guarda-o na tabela `data`.
%
% Entradas:
%   data        - tabela com os casos históricos
%   novo_caso   - struct/tabela com os atributos do novo caso (uma linha)
%   classe      - diagnóstico decidido/reutilizado para o novo caso
%   temp_final  - temperatura final aceite após revise
%   best_sim    - similaridade máxima encontrada entre novo_caso e o dataset
%   verbose     - (opcional) true/false para mensagens no ecrã
%
% Saída:
%   data        - tabela atualizada (com o novo caso adicionado se aplicável)

if nargin < 6 || isempty(verbose)
    verbose = true;
end

if verbose
    fprintf('\n--- RETAIN ---\n');
    fprintf('  Similaridade máxima encontrada: %.4f\n', best_sim);
end

% Polí­tica simples de retenção: se não houver um caso parecido (best_sim < 0.8)
% consideramos que este novo exemplo acrescenta informação e o guardamos.
% O limiar 0.8 é um valor comum, mas pode ser ajustado conforme necessidade.
if best_sim < 0.8

    % Atualizar o novo caso com o diagnóstico e temperatura final e anexar
    novo_caso.class_cat   = classe;
    novo_caso.temperature = temp_final;

    % Anexa a nova linha ao final da tabela `data`
    data = [data; novo_caso];

    if verbose
        fprintf('  Caso guardado no dataset (total: %d casos)\n', height(data));
    end

else
    % Caso muito parecido com um existente — não guarda para evitar ruído
    if verbose
        fprintf('  Caso não guardado — já existe caso suficientemente similar\n');
    end
end

end
