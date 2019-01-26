extends Node

static func getRandIntegerValInRange(a, b, excludingVal):
	var value = excludingVal
	var safetyCounter = 0
	var maxIterations = 100

	while value == excludingVal and safetyCounter < maxIterations:
		value = a + randi() % b
		safetyCounter += 1

	if safetyCounter >= maxIterations:
		printerr("Utils: Could not randomly find value in range (" + str(a) + "," + str(b) + ")")
	return value

static func getAngleDegreesBetweenVectors(a, b):
	var dot = a.dot(b)
	var magnitudeA = a.length()
	var magnitudeB = b.length()

	var angleDegrees = 0;
	if magnitudeA > 0 and magnitudeB > 0:
		var cosAngleRad = dot/(magnitudeA*magnitudeB)
		var angleRad = acos(cosAngleRad)
		angleDegrees = rad2deg(angleRad)
	return angleDegrees

static func getAnimationDuration(animationSpeed, deltaValue):
	var duration = 0
	if(animationSpeed > 0):
		duration = abs(deltaValue)/animationSpeed

	return duration

static func isChanceHit(chance):
	return rand_range(0.0, 1.0) <= chance

static func startProgressBarAnimation(progressBar, tweener, animSpeed, newValue):

	var duration = getAnimationDuration(animSpeed, progressBar.value - newValue)
	tweener.stop(progressBar)
	tweener.interpolate_property(progressBar, "value", progressBar.value, newValue, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tweener.start()
	pass

static func setAnimationLooping(animationTree, animId):
	var animName = animationTree.node_get_input_source(GameConsts.ANIM_TRANSITION_NODE, animId)
	var animation = animationTree.animation_node_get_animation(animName)
	animation.set_loop(true)
	pass
