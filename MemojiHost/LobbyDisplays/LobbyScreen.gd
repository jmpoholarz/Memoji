extends Node2D

onready var player1 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P1
onready var player2 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P2
onready var player3 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P3
onready var player4 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P4
onready var player5 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P5
onready var player6 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P6
onready var player7 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P7
onready var player8 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P8

func _ready():
	player1.get_node("Name").text = "Octosquid" 
	player2.player_update("Asdf", null)
	player3.player_update("Asdf", null)
	player4.player_update("Asdf", null)
	player5.player_update("Asdf", null)
	player6.player_update("Asdf", null)
	player7.player_update("Asdf", null)
	player8.player_update("Eighth Player", null)
	pass

func _process(delta):
	
	pass
	

