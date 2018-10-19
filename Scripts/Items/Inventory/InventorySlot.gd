extends Control

onready var _viewport = get_node("/root")

var _item = null
var _clickCount = 0
var _lastClickTime = 0
var _isFirstClick = true

signal onEquipItem

func getItem():
	return _item

func spawnItem(itemTemplate, itemId):
	_item = itemTemplate.instance()
	_item.setId(itemId)
	_item.rect_min_size = rect_min_size
	_item.rect_size = rect_size	
	add_child(_item)
	pass

func _on_Control_gui_input(event):
	if event is InputEventMouseButton and !event.pressed:
		if _item != null and (!_hasClickTimeExpired() or _isFirstClick):
			_clickCount += 1
			_lastClickTime = OS.get_system_time_secs()
			_isFirstClick = false
		else:
			_reset()
					
		if _clickCount > 1:
			_reset()			
			emit_signal("onEquipItem", _item)
			_item.queue_free()
			_item = null
	pass
	
func _reset():
	_clickCount = 0
	_isFirstClick = true
	pass
	
func _hasClickTimeExpired():
	var diff = OS.get_system_time_secs() - _lastClickTime
	return diff > GameConsts.TIME_BETWEEN_CLICKS
