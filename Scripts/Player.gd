extends KinematicBody

# Member variables
export var _maxSpeed = 10
export var _shootSpeed = 20
export var _manaConsumptionForFireball = 20
export var _manaReloadSpeed = 20

var _gameConsts = preload("res://Scripts/Utility/GameConsts.gd")
var _animationTree;
var _isInBattle = false
var _upVector = Vector3(0, 1, 0)
var _health = 100
var _mana = 100
var _maxMana = 100
var _tween = null

# Signals
signal onHealthChanged
signal onManaChanged

# Public functions
func battleStarted(enemy):
	_isInBattle = true
	look_at(enemy.translation, _upVector)
	pass

func isInBattle():
	return _isInBattle
	pass

func attack(target, skill):
	if(_hasEnoughMana()):
		match(skill):
			_gameConsts.Skill.FIRE_BALL:
				_shootFireball(target)
				_consumeMana(_manaConsumptionForFireball)
	pass

func takeDamage(damage):
	_health -= damage;
	if(_health < 0):
		_health = 0
	emit_signal("onHealthChanged", _health)
	pass

func _hasEnoughMana():
	return _mana >= _manaConsumptionForFireball

func _consumeMana(amount):
	_mana -= amount
	if(_mana < 0):
		_mana = 0
	emit_signal("onManaChanged", _mana)
	pass

func _shootFireball(target):
	_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_ATTACK_ID)

	var fireball = preload("res://Scenes/fireball.scn").instance()
	var shootPosition = get_node("Armature/shootPosition").get_global_transform()
	fireball.set_transform(shootPosition.orthonormalized())
	get_parent().add_child(fireball)

	var toTarget = target.translation - shootPosition.origin
	fireball.set_linear_velocity(toTarget.normalized() * _shootSpeed)
	fireball.add_collision_exception_with(self)
	pass

func _isMoving(direction):
	return direction.length_squared() > 0;

func _ready():
	_animationTree = get_node(_gameConsts.ANIMTION_TREE_PLAYER);
	_animationTree.set_active(true)
	pass

func _physics_process(delta):
	var direction = Vector3() # Where does the player intend to walk to
	var forward = Vector3(0, 0, 1)

	# Get input
	if (Input.is_action_pressed("move_forward")):
		direction += -forward
	if (Input.is_action_pressed("move_backwards")):
		direction += forward
	if (Input.is_action_pressed("move_left")):
		direction += Vector3(-1, 0, 0)
	if (Input.is_action_pressed("move_right")):
		direction += Vector3(1, 0, 0)

	var currentAnim = _animationTree.transition_node_get_current(_gameConsts.ANIM_TRANSITION_NODE)

	if(_isMoving(direction) and !_isInBattle):
		# Face the movement direction
		look_at(translation + direction, _upVector)

		# Move player in direction and collide
		move_and_collide(direction.normalized() * _maxSpeed * delta)

		if(currentAnim != _gameConsts.ANIM_WALK_ID):
			_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_WALK_ID)
	elif(currentAnim != _gameConsts.ANIM_IDLE_ID):
		# Play animation
		_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_IDLE_ID)
		
	_handleManaRecharge(delta)
	pass
		
func _handleManaRecharge(deltaTime):
	if(_mana < _maxMana):
		_mana += _manaReloadSpeed * deltaTime
		if(_mana > _maxMana):
			_mana = _maxMana
		emit_signal("onManaChanged", _mana)
	pass



