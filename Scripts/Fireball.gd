extends RigidBody

# A class just to convej damage information from the shooter 
# to the object which receives damage.

export var _damage = 20
export var _manaConsumption = 20
export var _shootSpeed = 20

signal onDestroyed

func getDamage():
	return _damage

func getManaConsumption():
	return _manaConsumption
	
func getShootSpeed():
	return _shootSpeed
	
func _on_fireball_tree_exited():	
	emit_signal("onDestroyed")	
	pass 
