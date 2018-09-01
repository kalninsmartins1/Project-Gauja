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
	pass
	
	return angleDegrees