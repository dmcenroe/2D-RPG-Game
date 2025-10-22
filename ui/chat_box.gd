extends RichTextLabel

var last_message: String = ""
var last_message_time: float = 0.0
var message_cooldown: float = 3.0  # Seconds between duplicate messages

func _ready() -> void:
	UIEvents.chat_message.connect(_add_message)

func add_message(message: String) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Check if it's a duplicate message within cooldown period
	if message == last_message and current_time - last_message_time < message_cooldown:
		return  # Ignore duplicate
	
	append_text(message + "\n")
	last_message = message
	last_message_time = current_time

func _add_message(message: String, color: Color) -> void:
	append_text(message + "\n")
