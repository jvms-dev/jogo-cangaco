extends KinematicBody


#========== | INICIO - REFERÊNCIAS | ==========
#onready var camera = $Arfagem/Guinada/SpringArm/Camera
onready var arfagem = $Arfagem
onready var guinada = $Arfagem/Guinada
onready var spring_arm = $Arfagem/Guinada/SpringArm
onready var indicador_direcional_dano = $IndicadorDirecionalDano
#========== | FIM - REFERÊNCIAS | ==========

const GRAVIDADE = -24.8
const VELOCIDADE_MAXIMA = 15.0
const VELOCIDADE_CORRIDA_MAXIMA = 30.0
const PULO_MAXIMO = 8.0
const ACELERACAO = 4.5
const ACELERACAO_CORRIDA_MAXIMA = 18.0
const ANGULO_MAXIMO_DECLIVE = 40
const DESACELERACAO = 16.0

var velocidade = Vector3.ZERO
var direcao = Vector3.ZERO
var SENSIBILIDADE_MOUSE = 0.05

var estado_corrida:bool = false
var estado_mirar:bool = false
var estado_atirar:bool = false
var entrada_movimento:Vector3 = Vector3.ZERO
var movimento_mouse:bool = false


func _ready():
	arfagem.set_as_toplevel(true)
	spring_arm.add_exception_rid(get_rid())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	tp_processando_entrada()
	tp_processar_movimento(delta)
	atualizar_pos_camera()


func tp_processando_entrada():
	var rotacao_pivo = arfagem.global_transform.basis.get_euler().y

	entrada_movimento = Vector3(Input.get_action_strength("para_esquerda") - Input.get_action_strength("para_direita"), 0.0, Input.get_action_strength("para_frente") - Input.get_action_strength("para_tras"))
	direcao = entrada_movimento.rotated(Vector3.UP, rotacao_pivo).normalized()

	if is_on_floor() == true:
		if Input.is_action_just_pressed("pular") == true:
			velocidade.y = PULO_MAXIMO
	
	if Input.is_action_pressed("correr") == true:
		estado_corrida = true
	else:
		estado_corrida = false
		
	if Input.is_action_just_pressed("mirar") and estado_atirar == false:
		estado_atirar = true
		$Arfagem/AnimacoesCamera.play("mirar")
		$MalhaBase/robo/AnimationPlayer.play("ArmatureAction", -1, 5.0)
		$Mira.show()
	
	if Input.is_action_just_released("mirar") and estado_atirar == true:
		estado_atirar = false
		$Arfagem/AnimacoesCamera.play("padrao")
		$MalhaBase/robo/AnimationPlayer.play("ArmatureAction", -1, -5.0)
		$Mira.hide()
	
	if estado_atirar == true:
		if entrada_movimento.length() != 0.0: 
			$Mira.raio_minimo = 10
		else:
			$Mira.raio_minimo = 5
	
	if Input.is_action_just_pressed("atirar"):
		$Mira.raio *= 2
	
	

func tp_processar_movimento(ar_delta):

	velocidade.y += ar_delta * GRAVIDADE

	var nova_velocidade = velocidade
	nova_velocidade.y = 0.0

	var nova_direcao = direcao
	if estado_corrida == true:
		nova_direcao *= VELOCIDADE_CORRIDA_MAXIMA
	else:
		nova_direcao *= VELOCIDADE_MAXIMA
	
	var aceleracao
	if direcao.dot(nova_velocidade) > 0:
		if estado_corrida == true:
			aceleracao = ACELERACAO_CORRIDA_MAXIMA
		else:
			aceleracao = ACELERACAO
		
	else:
		aceleracao = DESACELERACAO
		
	nova_velocidade = nova_velocidade.linear_interpolate(nova_direcao, aceleracao * ar_delta)
	velocidade.x = nova_velocidade.x
	velocidade.z = nova_velocidade.z
	velocidade = move_and_slide(velocidade, Vector3(0.0, 1.0, 0.0), 0.05, 4, deg2rad(ANGULO_MAXIMO_DECLIVE))
	
	if estado_atirar == false:
		if entrada_movimento.x != 0 or entrada_movimento.z != 0:
			var angulo = atan2(nova_velocidade.x, nova_velocidade.z)
			var rotacao_jogador = rotation
			rotacao_jogador.y = lerp_angle(rotacao_jogador.y, angulo, aceleracao * ar_delta)
			rotation = rotacao_jogador
	else:
		rotation.y = arfagem.rotation.y


func _input(event):
	if event is InputEventMouseMotion:
		movimento_mouse = true
		
		arfagem.rotate_y(deg2rad(event.relative.x * SENSIBILIDADE_MOUSE * -1))
		guinada.rotate_x(deg2rad(event.relative.y * SENSIBILIDADE_MOUSE))

		var rotacao_guinada = guinada.rotation_degrees
		rotacao_guinada.x = clamp(rotacao_guinada.x, -70, 70)
		guinada.rotation_degrees = rotacao_guinada


func atualizar_pos_camera():
	arfagem.global_transform.origin = global_transform.origin


func direcao_dano(ar_direcao:Vector3): 
	# ar_direcao -> Vetor informando onde ocorreu a colisão no espaço 3D global
	# Vetor que parte do personagem e aponta para o ponto de colisão
	var nova_direcao = global_transform.origin.direction_to(ar_direcao)
	# Obtem a rotação
	var nova_rotacao = atan2(nova_direcao.x, nova_direcao.y)
	# Rotaciona a cena que contem a textura de dano
	indicador_direcional_dano.rotation = lerp_angle(indicador_direcional_dano.rotation, nova_rotacao, 0.5)
	
