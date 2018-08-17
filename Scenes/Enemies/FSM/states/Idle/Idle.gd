extends "res://addons/net.kivano.fsm/content/FSMState.gd";
################################### R E A D M E ##################################
# For more informations check script attached to FSM node
#
#

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
var _gameConsts = preload("res://Scripts/Utility/GameConsts.gd")
var _animationTree = null
var _rigidBody = null;

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
	pass

#when entering state, usually you will want to reset internal state here somehow
func enter(fromStateID=null, fromTransitionID=null, inArg0=null,inArg1=null, inArg2=null):
	setupAnimations()
	_rigidBody = getLogicRoot()
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
func setupAnimations():
	_animationTree = getLogicRoot().get_node(_gameConsts.ANIMTION_TREE_PLAYER)
	_animationTree.set_active(true)
	_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_WALK_ID)	
	
	# Make the set animation looping
	var animName = _animationTree.node_get_input_source(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_WALK_ID)
	var animation = _animationTree.animation_node_get_animation(animName)
	animation.set_loop(true)	
	
##################################################################################
#########                         Inner Classes                          #########
##################################################################################
