extends Node

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
	
static func startProgressBarAnimation(progressBar, tweener, animSpeed, newValue):
	
	var duration = getAnimationDuration(animSpeed, progressBar.value - newValue)
	tweener.stop(progressBar)
	tweener.interpolate_property(progressBar, "value", progressBar.value, newValue, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tweener.start()
	pass