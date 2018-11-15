extends Panel

onready var _dialogText = get_node("VBoxContainer/HBoxContainer/RichTextLabel")
onready var _okButton = get_node("VBoxContainer/Button")

var _dialog = null
var _curDialogIndex = 0

func startDialog(dialog):
	_reset()
	_dialog = dialog
	if _dialog != null and _dialog.size() > 0:
		_dialogText.text = _dialog[_curDialogIndex]
		_show()
	pass

func _ready():
	_okButton.connect("pressed", self, "_showNextDialogEntry")
	pass

func _show():
	set_visible(true)
	pass

func _hide():
	set_visible(false)
	pass

func _showNextDialogEntry():
	if  _curDialogIndex + 1 < _dialog.size():
		_curDialogIndex += 1
		_dialogText.text = _dialog[_curDialogIndex]
	else:
		_reset()
		_hide()
	pass

func _reset():
	_curDialogIndex = 0
	pass
