json.extract! treino, :id, :exercicio, :series, :repeticoes, :carga, :created_at, :updated_at
json.url treino_url(treino, format: :json)
