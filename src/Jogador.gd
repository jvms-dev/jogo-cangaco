extends KinematicBody


#========== | INICIO - REFERÊNCIAS | ==========
onready var camera = $BaseCamera/Arfagem/Guinada/ClippedCamera
onready var arfagem = $BaseCamera/Arfagem
onready var guinada = $BaseCamera/Arfagem/Guinada
onready var malha_base = $MalhaBase
onready var animacoes_jogador = $MalhaBase/AnimationTree
#========== | FIM - REFERÊNCIAS | ==========

const GRAVIDADE = -24.8
const VELOCIDADE_MAXIMA = 15.0
const VELOCIDADE_CORRIDA_MAXIMA = 30.0
const PULO_MAXIMO = 8.0
const ACELERACAO = 4.5
const ACELERACAO_CORRIDA_MAXIMA = 18.0
const ANGULO_MAXIMO_DECLIVE = 40
const DESACELERACAO = 16.0

var _velocidade = Vector3.ZERO
var _direcao = Vector3.ZERO
var SENSIBILIDADE_MOUSE = 0.05

var modo_camera_atual = "visao_terceira_pessoa_0"
var estado_corrida:bool = false
var estado_mirar = false
var estado_atirar = false
var entrada_movimento:Vector3 = Vector3.ZERO


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	tp_processando_entrada()
	tp_processar_movimento(delta)
	tp_config_animacao()


func tp_processando_entrada():
	var rotacao_pivo = arfagem.global_transform.basis.get_euler().y

	entrada_movimento = Vector3(Input.get_action_strength("oeste") - Input.get_action_strength("leste"), 0.0, Input.get_action_strength("norte") - Input.get_action_strength("sul"))
	_direcao = entrada_movimento.rotated(Vector3.UP, rotacao_pivo).normalized()

	if is_on_floor() == true:
		if Input.is_action_just_pressed("pular") == true:
			_velocidade.y = PULO_MAXIMO
			#$MalhaBase/personagem4/AnimationPlayer.play("jump-loop")
	
	if Input.is_action_pressed("correr") == true:
		estado_corrida = true
	else:
		estado_corrida = false
	

func tp_processar_movimento(ar_delta):

	_velocidade.y += ar_delta * GRAVIDADE

	var nova_velocidade = _velocidade
	nova_velocidade.y = 0.0

	var nova_direcao = _direcao
	if estado_corrida == true:
		nova_direcao *= VELOCIDADE_CORRIDA_MAXIMA
	else:
		nova_direcao *= VELOCIDADE_MAXIMA
	
	var aceleracao
	if _direcao.dot(nova_velocidade) > 0:
		if estado_corrida == true:
			aceleracao = ACELERACAO_CORRIDA_MAXIMA
		else:
			aceleracao = ACELERACAO
		
	else:
		aceleracao = DESACELERACAO
	
	if _direcao.length() != 0:
		malha_base.rotation.y = lerp_angle(malha_base.rotation.y, atan2(_direcao.x, _direcao.z) - rotation.y, aceleracao * ar_delta)
	
	nova_velocidade = nova_velocidade.linear_interpolate(nova_direcao, aceleracao * ar_delta)
	_velocidade.x = nova_velocidade.x
	_velocidade.z = nova_velocidade.z
	_velocidade = move_and_slide(_velocidade, Vector3(0.0, 1.0, 0.0), 0.05, 4, deg2rad(ANGULO_MAXIMO_DECLIVE))


func _input(event):
	if event is InputEventMouseMotion:
		
		arfagem.rotate_y(deg2rad(event.relative.x * SENSIBILIDADE_MOUSE * -1))
		guinada.rotate_x(deg2rad(event.relative.y * SENSIBILIDADE_MOUSE))

		var rotacao_guinada = guinada.rotation_degrees
		rotacao_guinada.x = clamp(rotacao_guinada.x, -70, 70)
		guinada.rotation_degrees = rotacao_guinada


func tp_config_animacao():
	
	if is_on_floor():
		if entrada_movimento.length() == 0:
			animacoes_jogador.set("parameters/anim_base/blend_amount", 0)
		else:
			animacoes_jogador.set("parameters/anim_base/blend_amount", 1)
			
	else:
		animacoes_jogador.set("parameters/pular/active", true)
