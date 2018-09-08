extends "res://addons/net.kivano.fsm/content/FSMState.gd";
################################### R E A D M E ##################################
# For more informations check script attached to FSM node
#
#

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
var _enemy = null
var _basePosition = null

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
#you will want to use those
func getFSM(): return fsm; #defined in parent class
func getLogicRoot(): return logicRoot; #defined in parent class

##################################################################################
#########                 Implement those below ancestor                 #########
##################################################################################
#you can transmit parameters if fsm is initialized manually
func stateInit(inParam1=null,inParam2=null,inParam3=null,inParam4=null, inParam5=null):	
	_enemy = getLogicRoot()
	_basePosition = _enemy.translation
	pass

#when entering state, usually you will want to reset internal state here somehow
func enter(fromStateID=null, fromTransitionID=null, inArg0=null,inArg1=null, inArg2=null):	
	_enemy.set_sleeping(false)
	_enemy.setDestination(_getRandomPosition())
	pass

#when updating state, paramx can be used only if updating fsm manually
func update(deltaTime, param0=null, param1=null, param2=null, param3=null, param4=null):
	pass

#when exiting state
func exit(toState=null):
	pass

##################################################################################
#########                       Connected Signals                        #########
##################################################################################

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################


##################################################################################
#########                         Inner Methods                          #########
##################################################################################
func _getRandomPosition():
	var radius = _enemy.getActiveRadius()
	var newX = _basePosition.x + radius * cos(rand_range(0, 2 * PI))
	var newZ = _basePosition.z + radius * sin(rand_range(0, 2 * PI))
	
	return Vector3(newX, _basePosition.y, newZ)	
	pass
##################################################################################
#########                         Inner Classes                          #########
##################################################################################
