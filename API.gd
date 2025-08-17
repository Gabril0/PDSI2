extends Node

# Obrigatorio para comunicacao de Cenas 
signal ranking_received(ranking_data)
signal login_completed(success, player_data)
signal register_completed(success, response)
signal score_sent(success, response)

#Variaveis globais (vai ser importante não só para conexao mas também para armaenamento local do user)
var request: HTTPRequest
var current_request_type: String = ""

# Dados do jogador logado
var jogador_id: int = 0
var jogador_nickname: String = ""
var current_week_seed: int = 0

#Inicializacao
func _ready():
	# Criar e configurar HTTPRequest
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)
	
	# Carregar dados salvos do jogador
	carregar_dados_jogador()
	print("API.gd carregado com sucesso!")


# Funções base para comunicação HTTP com o backend
# post_json: Envia dados em JSON via POST (login, cadastro, scores)
# get_request: Busca dados via GET (ranking, seed)
func post_json(url: String, data: Dictionary, request_type: String = ""):
	current_request_type = request_type
	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(data)
	request.request(url, headers, HTTPClient.METHOD_POST, json_body)

func get_request(url: String, request_type: String = ""):
	current_request_type = request_type
	request.request(url)


# Funções de autenticação de cadastro e email
func login(email: String, senha: String):
	var data = {
		"email": email,
		"password": senha
	}
	post_json("http://localhost:8000/login", data, "login")

func cadastrar(email: String, senha: String, nickname: String):
	var data = {
		"email": email,
		"password": senha,
		"nickname": nickname
	}
	post_json("http://localhost:8000/register", data, "register")


#Funções para gerenciar os dados do jogador
func salvar_dados_jogador(id: int, nickname: String):
	var data = {
		"id": id,
		"nickname": nickname
	}
	var file = FileAccess.open("user://jogador.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func carregar_dados_jogador():
	if FileAccess.file_exists("user://jogador.json"):
		var file = FileAccess.open("user://jogador.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		# Carrega nas globais
		jogador_id = data["id"]
		jogador_nickname = data["nickname"]
		print("Jogador carregado:", jogador_nickname)


#Processamento de respostas HTTP
func _on_request_completed(result, response_code, headers, body):
	print("Resposta recebida! Código: ", response_code)
	print("Tipo da requisição: ", current_request_type)
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	print("Resposta JSON: ", json)
	
	match current_request_type:
		"login":
			_handle_login_response(result, response_code, headers, body, json)
		"register":
			_handle_register_response(result, response_code, headers, body, json)
		"seed":
			_handle_seed_response(result, response_code, headers, body, json)
		"score":
			_handle_score_response(result, response_code, headers, body, json)
		"ranking":
			_handle_ranking_response(result, response_code, headers, body, json)
		_:
			print("Tipo de requisição desconhecido: ", current_request_type)

func _handle_login_response(result, response_code, headers, body, json):
	if response_code == 200:
		# Armazenamento dos dados nas globais
		jogador_id = json["id"]
		jogador_nickname = json["nickname"]
		print("Login OK! Jogador:", jogador_nickname)
		# dados salvos locais
		salvar_dados_jogador(jogador_id, jogador_nickname)
		# Emite signal para outras cenas
		login_completed.emit(true, {"id": jogador_id, "nickname": jogador_nickname})
	else:
		print("Erro no login:", json.get("detail", "Erro desconhecido"))
		login_completed.emit(false, null)

func _handle_register_response(result, response_code, headers, body, json):
	if response_code == 200:
		print("Registro OK! Jogador criado:", json.get("nickname", ""))
		register_completed.emit(true, json)
	else:
		print("Erro no registro:", json.get("detail", "Erro desconhecido"))
		register_completed.emit(false, json)

func _handle_seed_response(result, response_code, headers, body, json):
	if response_code == 200:
		current_week_seed = int(json["seed"])  # Armazenar a seed
		print("Seed da semana:", json["seed"])
	else:
		print("Erro ao obter seed:", json.get("detail", "Erro desconhecido"))

func _handle_score_response(result, response_code, headers, body, json):
	if response_code == 200:
		print("Pontuação enviada com sucesso!")
		score_sent.emit(true, json)
	else:
		print("Erro ao enviar pontuação:", json)
		score_sent.emit(false, json)

func _handle_ranking_response(result, response_code, headers, body, json):
	if response_code == 200:
		print("=== RANKING SEMANAL ===")
		print("Semana: ", json["week"])
		print("Seed: ", json["seed"])
		print("Posições:")
		
		for entry in json["ranking"]:
			print(str(entry["position"]) + "º - " + entry["nickname"] + ": " + str(entry["time_seconds"]) + "s")
		
		ranking_received.emit(json)
	else:
		print("Erro ao buscar ranking:", json.get("detail", "Erro desconhecido"))
		ranking_received.emit(null)


#Funções para busca (nome de cada uma é explicativo)
func buscar_seed():
	get_request("http://localhost:8000/seed", "seed")

func buscar_ranking_atual():
	get_request("http://localhost:8000/ranking/current", "ranking")

func buscar_ranking_semana(semana: String):
	var url = "http://localhost:8000/ranking?week=" + semana
	get_request(url, "ranking")

func enviar_score(player_id: int, seed: int, tempo: int):
	var data = {
		"player_id": player_id,
		"seed": seed,
		"time_seconds": tempo
	}
	post_json("http://localhost:8000/ranking", data, "score")
