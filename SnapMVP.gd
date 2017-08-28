extends Node2D

# Constants
const MIN_BALL_SPEED = 80
const MAX_BALL_SPEED = 200
const ACCEL_RATE = 50
var minSpeedThreshold
var maxSpeedThreshold

# Mouse and ball vars
var mousePos = Vector2(0.0, 0.0)
var ballPos = Vector2(0.0, 0.0)
var ballDir = Vector2(1.0, 0.0)
var ballSpeed = 0

# Save trail of the mouse cursor
var mouseTrail = Vector2Array()
var lastPoint = null
var lastMousePoint = null
var lastBallPoint = null
var totalTrailSize = 0

func _ready():
	var ballSize = get_node("MouseBall").get_texture().get_size().x
	minSpeedThreshold = ballSize * 15
	#maxSpeedThreshold = ballSize * 5
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process(true)
	
func _process(delta):
	updateBallPos(delta)
	update()
	
func updateBallPos(delta):
	mousePos = get_global_mouse_pos()
	ballPos = get_node("MouseBall").get_pos()
	
	# Simple attempt at chasing the mouse cursor
#	if (mousePos != ballPos):
#		ballDir = (mousePos - ballPos).normalized()
#		if (ballSpeed > MAX_BALL_SPEED):
#			ballSpeed = MAX_BALL_SPEED
#		elif (ballSpeed != 150):
#			ballSpeed += ACCEL_RATE * delta
#	else:
#		ballSpeed = 0
#		
#	get_node("Debug").set_text("Ball Direction: " + String(ballSpeed))
#		
	
	# Maintain the saved mouse projectory
	if (mouseTrail.size() != 0 and mouseTrail.size() < 100):
		# TODO: make sure this if statement works correctly
		if (lastMousePoint != mousePos):
			mouseTrail.append(mousePos)
			lastMousePoint = mousePos
	elif (mouseTrail.size() == 0 and ballPos != mousePos):
		mouseTrail.append(mousePos)
		lastMousePoint = mousePos

	# Calculate trail line length
	lastPoint = null
	totalTrailSize = 0
	for point in mouseTrail:
		var xDiff
		var yDiff
		
		if (lastPoint == null):		
			xDiff = point.x - ballPos.x
			yDiff = point.y - ballPos.y
		else:
			xDiff = point.x - lastPoint.x
			yDiff = point.y - lastPoint.y
			
		totalTrailSize += sqrt((xDiff * xDiff) + (yDiff * yDiff))
		lastPoint = point
		
	print(totalTrailSize)
	
	# Set speed based on trail size
#	var targetSpeed = 0
#	if (totalTrailSize > maxSpeedThreshold):
#		targetSpeed = MAX_BALL_SPEED
#	elif (totalTrailSize < minSpeedThreshold):
#		targetSpeed = MIN_BALL_SPEED
#	else:
#		targetSpeed = (maxSpeedThreshold - totalTrailSize) / 5
#		
#	if (ballSpeed * delta > targetSpeed * delta):
#		if (ballSpeed * delta - targetSpeed < ACCEL_RATE):
#			ballSpeed -= ballSpeed * delta - targetSpeed
#		else:
#			ballSpeed -= ACCEL_RATE * delta
#	elif (ballSpeed * delta < targetSpeed * delta):
#		if (targetSpeed - ballSpeed * delta < ACCEL_RATE):
#			ballSpeed += targetSpeed + ballSpeed * delta
#		else:
#			ballSpeed += ACCEL_RATE * delta
	if (ballPos == mousePos):
		ballSpeed = 0
	elif (totalTrailSize < minSpeedThreshold && ballSpeed > MIN_BALL_SPEED):
		if (ballSpeed - ACCEL_RATE < MIN_BALL_SPEED):
			ballSpeed = MIN_BALL_SPEED
		else:
			ballSpeed -= ACCEL_RATE
	elif (ballSpeed < MAX_BALL_SPEED):# && totalTrailSize > minSpeedThreshold):
		if (ballSpeed + ACCEL_RATE > MAX_BALL_SPEED):
			ballSpeed = MAX_BALL_SPEED
		else:
			ballSpeed += ACCEL_RATE
	
	get_node("Debug").set_text("Ball Speed: " + String(ballSpeed))# + " Target Speed: " + String(targetSpeed) + " Trail Size: " + String(totalTrailSize))
	
	# Move towards the closes point, and keep track of distance traveled.
	# Follow the trail without going over max speed!
	var distanceTraveled = 0
	while mouseTrail.size() != 0 and distanceTraveled < ballSpeed * delta:
		var oldestPoint = mouseTrail[0]
		var xDiff = (ballPos.x - oldestPoint.x)
		var yDiff = (ballPos.y - oldestPoint.y)
		
		var length = sqrt((xDiff * xDiff) + (yDiff * yDiff))
		#print(length)
		var direction = (oldestPoint - ballPos).normalized()
		# If distance is farther than speed, just move as far as possible...
		if ((length - distanceTraveled) >= ballSpeed * delta):
			ballPos += ballSpeed * direction * delta
			distanceTraveled = ballSpeed * delta
		# ...else move to the saved point and update
		elif (mouseTrail.size() != 0):
			distanceTraveled += length
			ballPos = oldestPoint
			mouseTrail.remove(0)
			# If this wasn't the last point in the trail, update
			if (mouseTrail.size() != 0):
				oldestPoint = mouseTrail[0]
			else:
				break
		else:
			print("HIT LOOP FAILSAFE")
			#break
	
	# Update position
	get_node("MouseBall").set_pos(ballPos)
	
#func _draw():
#	for pos in redTrail:
#		print("hi")
#		draw_texture(get_node("RedX1").get_texture(), pos)
