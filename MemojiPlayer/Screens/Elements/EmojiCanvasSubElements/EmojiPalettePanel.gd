extends Panel

onready var _TabContainer = $VBoxContainer/TabContainer


func _on_PeopleButton_pressed():
	_TabContainer.current_tab = 0

func _on_NatureButton_pressed():
	_TabContainer.current_tab = 1

func _on_FoodButton_pressed():
	_TabContainer.current_tab = 2

func _on_ActivityButton_pressed():
	_TabContainer.current_tab = 3

func _on_TravelButton_pressed():
	_TabContainer.current_tab = 4

func _on_ObjectButton_pressed():
	_TabContainer.current_tab = 5

func _on_SymbolButton_pressed():
	_TabContainer.current_tab = 6

func _on_FlagButton_pressed():
	_TabContainer.current_tab = 7

