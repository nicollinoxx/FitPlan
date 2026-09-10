# Ranking

## Fluxo existente

Conclusões manuais de fichas e conclusões automáticas dos itens de treino/dieta
criam `SheetCompletion`. Os callbacks de criação/remoção recalculam
`User#ranking_score` e `current_streak`; `User.refresh_rankings!` continua sendo
executado diariamente pelo Solid Queue em `config/recurring.yml`.
Não há cache específico do ranking.

## Ranking mensal

O cálculo usa `Time.current` no servidor e o timezone da aplicação,
`America/Sao_Paulo`. Considera conclusões entre o início do mês e o instante do
recálculo. Mantém a fórmula: dias distintos nos últimos 30 dias / 30 × 70,
mais sequência atual, limitada a 30 dias, / 30 × 30; arredondamento de duas casas.
Ambos os componentes ficam restritos ao mês atual.

`users.ranking_month` identifica o mês do agregado existente. Consultas e leitores
de pontuação/sequência tratam agregados de outros meses (ou sem mês) como zero,
inclusive antes da rotina diária. O reset é lógico, sem novo job ou exclusão de
histórico. `sheet_completions` continua sendo a fonte de reconstrução; não são
criadas cópias de pontuação nem snapshots de classificação mensal.

Na implantação, executar `bin/rails db:migrate` e
`bin/rails runner 'User.refresh_rankings!'` no ambiente correspondente para
reconstruir os agregados dos usuários existentes. Sem esse recálculo, agregados
legados ficam logicamente zerados até uma conclusão ou a rotina diária.
A atualização diária já existente continua responsável pelo decaimento da
sequência e da janela de 30 dias dentro do mês.

## Antifraude

- Os três endpoints de conclusão já determinam `completed_at` no backend e não
  aceitam timestamps, timezone ou pontuação enviados pelo cliente. Essa proteção
  foi mantida e coberta por testes de requisição.
- O ranking ignora conclusões futuras no momento do cálculo e de meses anteriores.
- O Groupdate já instalado agrupa dias no timezone da aplicação, evitando que
  a meia-noite UTC transforme um único dia local em dois dias pontuáveis.
- A pontuação continua contando dias distintos. Retries e múltiplas rodadas
  legítimas no mesmo dia não somam pontos extras. Não há deduplicação das rodadas:
  o domínio e os testes existentes permitem várias conclusões diárias.
- `with_lock` no usuário serializa leitura e gravação dos recálculos concorrentes,
  inclusive os disparados pelos callbacks e pela rotina diária.

O sistema registra conclusões declaradas pelo usuário; não verifica fisicamente
a realização do treino. Escritas internas em modelos podem preservar datas
históricas e devem continuar restritas a fontes confiáveis.

## Ranking entre amigos

Reutiliza `friends_ranking` e `User#friends`, já existentes: usuário atual mais
seguidores mútuos. Não existem estados de aprovação ou bloqueio neste modelo;
relações unilaterais e desfeitas ficam de fora. Amigos sem pontos e o próprio
usuário continuam aparecendo; o global continua exibindo apenas pontuação positiva.

Ambos usam `by_score`, ordenação SQL por pontuação decrescente e ID crescente.
`ranking_position` também respeita esse desempate. As rotas, paginação, carregamento
de avatares e templates existentes foram preservados.

## ORM e testes

Os filtros de mês, pontuação positiva e desempate usam relations ActiveRecord,
intervalos e `or`, sem strings SQL novas. `by_score` usa um `CASE` construído com
Arel para ordenar agregados antigos como zero sem atualizá-los; um `order` simples
sobre a coluna persistida não representa esse reset lógico. O Groupdate existente
cuida das datas e da ordem dos dias, sem conversão ou ordenação adicional em Ruby.

As regras de mês, pontuação, amizades e concorrência são testadas nos models.
Os testes de requisição verificam somente parâmetros controlados pelo cliente,
reutilização da conclusão de dieta em retries e apresentação do ranking. Não há
novos testes de navegador/E2E nem simulação de um treino inteiro para testar datas.

## Arquivos relevantes

- `app/models/user/rankable.rb`: agregado mensal, ordenação e recálculo com lock.
- `app/models/sheet_completion.rb`: histórico, callbacks e agrupamento diário.
- `app/models/user/followable.rb`: definição existente de amigos.
- `app/controllers/rankings_controller.rb`: endpoints global e amigos existentes.
- `db/migrate/20260909160000_add_ranking_month_to_users.rb`: coluna mensal reversível.
- `config/locales/{pt,en}.yml`: explicação do período nas telas.
- `test/models/{user/rankable,sheet_completion}_test.rb`: mês, timezone,
  duplicação, concorrência, histórico, amigos e desempate.
- `test/controllers/rankings_controller_test.rb` e
  `test/controllers/{sheets,workouts,diets}/completions_controller_test.rb`:
  consultas e tentativas de manipulação dos parâmetros.
