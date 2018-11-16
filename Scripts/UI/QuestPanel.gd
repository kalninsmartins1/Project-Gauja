extends Panel

class QuestEntry:
	var questId = null
	var label = null

onready var _questContainer = get_node("ScrollContainer/VBoxContainer")
onready var _playerParty = get_parent().get_parent()

var _questEntries = []

func toggle():
	set_visible(!is_visible())
	pass

func _getEntryText(index, quest):
	var collectedAmount = quest.getCollectedAmount()
	var requiredAmount = quest.getRequiredAmount()		
	return str(index + 1) + ". " + quest.getTitle() + " " + str(collectedAmount) + "/" + str(requiredAmount)	

func _ready():
	_playerParty.connect("onActiveQuestAdded", self, "_onActiveQuestAdded")
	_playerParty.connect("onActiveQuestUpdated", self, "_onActiveQuestUpdated")
	_playerParty.connect("onActiveQuestRemoved", self, "_onActiveQuestRemoved")
	pass

func _updateQuestNumbering():	
	var count = 0
	for entry in _questEntries:
		count += 1
		var curText = entry.label.get_text()
		var numberEndIndex = curText.find(".")
		var newText = curText.right(numberEndIndex)
		entry.label.set_text(str(count) + newText)
	pass

func _onActiveQuestUpdated(quest):
	var entry = _findQuestEntry(quest.getId())
	var entryIndex = _questEntries.find(entry)
	entry.label.set_text(_getEntryText(entryIndex, quest))	
	pass

func _onActiveQuestAdded(quest):	
	var label = Label.new()	
	label.set_autowrap(true)	
	label.set_text(_getEntryText(_questEntries.size(), quest))
	_questContainer.add_child(label)

	var entry = QuestEntry.new()
	entry.questId = quest.getId()
	entry.label = label
	_questEntries.append(entry)
	pass

func _onActiveQuestRemoved(quest):
	var entry = _findQuestEntry(quest.getId())	
	_questEntries.erase(entry)
	entry.label.queue_free()
	_updateQuestNumbering()
	pass

func _findQuestEntry(questId):
	var keyEntry = null
	for entry in _questEntries:
		if entry.questId == questId:
			keyEntry = entry
			break

	return keyEntry