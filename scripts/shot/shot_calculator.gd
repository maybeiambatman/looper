## Calculates shot outcomes based on recommendations, player skills, and conditions
class_name ShotCalculator
extends RefCounted


static func calculate_shot(
	recommendation: ShotRecommendation,
	player: GolferAttributes,
	conditions: HoleConditions,
	lie: Enums.LieType,
	trinkets: Array,
	tournament: TournamentState
) -> ShotOutcome:
	"""Main entry point for shot calculation"""

	# Special handling for putts
	if recommendation.shot_type == Enums.ShotType.PUTT:
		return _calculate_putt(recommendation, player, conditions, trinkets, tournament)

	# Base accuracy from player skill
	var base_accuracy := _get_base_accuracy(player, recommendation.shot_type)

	# Apply modifiers
	var club_mod := _evaluate_club_selection(recommendation, player)
	var target_mod := _evaluate_target(recommendation, conditions)
	var shape_mod := _evaluate_shot_shape(recommendation, lie, conditions)
	var wind_mod := _evaluate_wind_adjustment(recommendation, conditions)
	var lie_mod := _get_lie_modifier(lie)
	var pressure_mod := _evaluate_pressure(player, tournament, trinkets)
	var trinket_mod := _apply_trinket_bonuses(trinkets, recommendation)
	var consistency_mod := _get_consistency_modifier(player)

	var final_accuracy := base_accuracy + club_mod + target_mod + shape_mod + wind_mod + lie_mod + pressure_mod + trinket_mod + consistency_mod
	final_accuracy = clampf(final_accuracy, 5.0, 95.0)

	# Roll for outcome
	var roll := randf() * 100.0
	var outcome := _determine_outcome(roll, final_accuracy)

	# Calculate actual landing position
	outcome.landing_position = _calculate_landing_position(recommendation, outcome, conditions)
	outcome.final_position = _calculate_final_position(outcome.landing_position, recommendation, conditions)
	outcome.resulting_lie = _determine_resulting_lie(outcome.final_position, recommendation)

	return outcome


static func _get_base_accuracy(player: GolferAttributes, shot_type: Enums.ShotType) -> float:
	match shot_type:
		Enums.ShotType.DRIVE:
			return 50.0 + (player.accuracy * 2.0)
		Enums.ShotType.APPROACH:
			return 50.0 + (player.iron_play * 2.0)
		Enums.ShotType.SHORT_GAME:
			return 45.0 + (player.short_game * 2.5)
		Enums.ShotType.BUNKER:
			return 40.0 + (player.short_game * 2.0)
		Enums.ShotType.RECOVERY:
			return 35.0 + (player.recovery * 2.5)
		_:
			return 50.0


static func _evaluate_club_selection(rec: ShotRecommendation, player: GolferAttributes) -> float:
	var ideal_distance := rec.intended_distance
	var club_distance := player.get_club_distance(rec.club)
	var difference: float = absf(float(club_distance) - ideal_distance)

	if difference <= 3:
		return 10.0  # Perfect club
	elif difference <= 8:
		return 0.0   # Acceptable
	elif difference <= 15:
		return -10.0 # One club off
	else:
		return -25.0 # Way off


static func _evaluate_target(rec: ShotRecommendation, _conditions: HoleConditions) -> float:
	# Safe targets get a bonus, aggressive targets get a penalty
	# This would need more context about hazard positions in a full implementation
	return 0.0


static func _evaluate_shot_shape(rec: ShotRecommendation, lie: Enums.LieType, conditions: HoleConditions) -> float:
	var modifier := 0.0

	# Draw from rough is harder
	if rec.shot_shape == Enums.ShotShape.DRAW and lie in [Enums.LieType.LIGHT_ROUGH, Enums.LieType.HEAVY_ROUGH]:
		modifier -= 5.0

	# Check if shape fights or works with wind
	if conditions.wind_speed > 10:
		var wind_angle := atan2(conditions.wind_direction.x, conditions.wind_direction.z)
		var shot_angle := atan2(rec.target_direction.x, rec.target_direction.z)
		var angle_diff: float = absf(wind_angle - shot_angle)

		# Fade into left wind or draw into right wind is good
		if rec.shot_shape == Enums.ShotShape.FADE and angle_diff > PI * 0.5:
			modifier += 5.0  # Working with wind
		elif rec.shot_shape == Enums.ShotShape.DRAW and angle_diff < PI * 0.5:
			modifier += 5.0

	return modifier


static func _evaluate_wind_adjustment(rec: ShotRecommendation, conditions: HoleConditions) -> float:
	if conditions.wind_speed < 5:
		return 0.0  # Wind negligible

	# Evaluate how well the caddie accounted for wind
	var accuracy := rec.wind_adjustment_accuracy

	if accuracy > 0.8:
		return 5.0
	elif accuracy > 0.5:
		return 0.0
	elif accuracy > 0.2:
		return -10.0
	else:
		return -20.0


static func _get_lie_modifier(lie: Enums.LieType) -> float:
	match lie:
		Enums.LieType.TEE:
			return 5.0  # Best lie
		Enums.LieType.FAIRWAY:
			return 0.0
		Enums.LieType.FRINGE:
			return -2.0
		Enums.LieType.LIGHT_ROUGH:
			return -5.0
		Enums.LieType.HEAVY_ROUGH:
			return -15.0
		Enums.LieType.FAIRWAY_BUNKER:
			return -10.0
		Enums.LieType.GREENSIDE_BUNKER:
			return -8.0
		Enums.LieType.HARDPAN:
			return -10.0
		Enums.LieType.DIVOT:
			return -12.0
		Enums.LieType.BURIED:
			return -25.0
		Enums.LieType.PINE_STRAW:
			return -8.0
		_:
			return 0.0


static func _evaluate_pressure(player: GolferAttributes, tournament: TournamentState, trinkets: Array) -> float:
	var pressure_level := tournament.get_pressure_level()
	var clutch_factor := player.clutch / 20.0  # 0.0 to 1.0

	var base_penalty := 0.0
	match pressure_level:
		Enums.PressureLevel.COMFORTABLE:
			base_penalty = 0.0
		Enums.PressureLevel.CLOSE:
			base_penalty = -5.0
		Enums.PressureLevel.MUST_PERFORM:
			base_penalty = -15.0
		Enums.PressureLevel.WIN_OR_LOSE:
			base_penalty = -25.0

	# Apply clutch factor
	base_penalty *= (1.0 - clutch_factor)

	# Apply pressure reduction trinket
	if TrinketManager.has_trinket_effect(trinkets, Enums.TrinketEffectType.PRESSURE_REDUCTION):
		var reduction := TrinketManager.get_trinket_effect_value(trinkets, Enums.TrinketEffectType.PRESSURE_REDUCTION)
		base_penalty *= (1.0 - reduction)

	# Choke/clutch tendency
	if player.pressure_tendency == "choke":
		base_penalty *= 1.3
	elif player.pressure_tendency == "clutch":
		base_penalty *= 0.7

	return base_penalty


static func _apply_trinket_bonuses(trinkets: Array, _rec: ShotRecommendation) -> float:
	var bonus := 0.0

	# Crowd boost for good momentum
	if TrinketManager.has_trinket_effect(trinkets, Enums.TrinketEffectType.CROWD_BOOST):
		bonus += 3.0

	return bonus


static func _get_consistency_modifier(player: GolferAttributes) -> float:
	# Low consistency adds variance, high consistency is more predictable
	var consistency_factor := (player.consistency - 10) / 10.0  # -0.9 to 1.0
	return consistency_factor * 5.0


static func _determine_outcome(roll: float, accuracy: float) -> ShotOutcome:
	var outcome := ShotOutcome.new()

	# Thresholds shift based on accuracy
	var perfect_threshold := accuracy * 0.1
	var good_threshold := accuracy * 0.4
	var acceptable_threshold := accuracy * 0.75
	var poor_threshold := accuracy * 0.9

	if roll <= perfect_threshold:
		outcome.result = Enums.ShotResult.PERFECT
		outcome.distance_error = randf_range(-2, 2)
		outcome.direction_error = randf_range(-3, 3)
	elif roll <= good_threshold:
		outcome.result = Enums.ShotResult.GOOD
		outcome.distance_error = randf_range(-8, 8)
		outcome.direction_error = randf_range(-10, 10)
	elif roll <= acceptable_threshold:
		outcome.result = Enums.ShotResult.ACCEPTABLE
		outcome.distance_error = randf_range(-15, 15)
		outcome.direction_error = randf_range(-20, 20)
	elif roll <= poor_threshold:
		outcome.result = Enums.ShotResult.POOR
		outcome.distance_error = randf_range(-25, 25)
		outcome.direction_error = randf_range(-35, 35)
	else:
		outcome.result = Enums.ShotResult.DISASTER
		outcome.distance_error = randf_range(-40, 40)
		outcome.direction_error = randf_range(-50, 50)

	return outcome


static func _calculate_landing_position(
	rec: ShotRecommendation,
	outcome: ShotOutcome,
	conditions: HoleConditions
) -> Vector3:
	var forward_dir := (rec.target_position - rec.start_position).normalized()
	var right_dir := forward_dir.cross(Vector3.UP).normalized()

	var actual_distance := rec.intended_distance + outcome.distance_error
	var lateral_error := outcome.direction_error * 0.3  # Convert to meters

	var landing := rec.start_position + forward_dir * actual_distance + right_dir * lateral_error

	# Apply wind effect
	var wind_effect := conditions.calculate_wind_effect(forward_dir, actual_distance)
	landing += wind_effect

	return landing


static func _calculate_final_position(landing: Vector3, rec: ShotRecommendation, conditions: HoleConditions) -> Vector3:
	# Ball rolls after landing based on conditions
	var roll_distance := 0.0

	match rec.shot_type:
		Enums.ShotType.DRIVE:
			roll_distance = randf_range(10, 30)
		Enums.ShotType.APPROACH:
			roll_distance = randf_range(2, 10) * (1.0 / conditions.get_green_holding_modifier())
		Enums.ShotType.SHORT_GAME:
			if rec.shot_shape == Enums.ShotShape.BUMP_AND_RUN:
				roll_distance = randf_range(5, 15)
			elif rec.shot_shape == Enums.ShotShape.SPINNER:
				roll_distance = randf_range(-3, 3)  # Can spin back
			else:
				roll_distance = randf_range(2, 8)
		_:
			roll_distance = randf_range(0, 5)

	var roll_dir := (rec.target_position - rec.start_position).normalized()
	return landing + roll_dir * roll_distance


static func _determine_resulting_lie(position: Vector3, rec: ShotRecommendation) -> Enums.LieType:
	# In a full implementation, this would check the actual terrain
	# For now, use shot outcome to estimate
	if rec.shot_type == Enums.ShotType.APPROACH:
		return Enums.LieType.GREEN if randf() > 0.3 else Enums.LieType.FRINGE
	elif rec.shot_type == Enums.ShotType.SHORT_GAME:
		return Enums.LieType.GREEN if randf() > 0.2 else Enums.LieType.FRINGE

	# Default based on position
	return Enums.LieType.FAIRWAY


# === PUTTING ===

static func _calculate_putt(
	rec: ShotRecommendation,
	player: GolferAttributes,
	conditions: HoleConditions,
	trinkets: Array,
	tournament: TournamentState
) -> ShotOutcome:
	var outcome := ShotOutcome.new()

	# Get distance in feet (assuming rec.intended_distance is in yards for putts)
	var distance_feet := rec.intended_distance * 3.0

	# Base make percentage
	var make_pct := _get_putt_make_percentage(distance_feet, player.putting)

	# Apply pressure
	var pressure_mod := _evaluate_pressure(player, tournament, trinkets)
	make_pct += pressure_mod * 0.5  # Pressure has less effect on short putts

	# Apply green speed modifier for difficulty
	var speed_mod := conditions.get_green_speed_modifier()
	if speed_mod > 1.2:
		make_pct -= 5.0  # Fast greens are harder

	# Apply read accuracy
	var read_accuracy := rec.wind_adjustment_accuracy  # Reusing this for putt read
	if read_accuracy < 0.5:
		make_pct -= 15.0
	elif read_accuracy < 0.8:
		make_pct -= 5.0

	make_pct = clampf(make_pct, 1.0, 99.0)

	# Roll for make
	var roll := randf() * 100.0
	outcome.made_putt = roll <= make_pct

	if outcome.made_putt:
		outcome.result = Enums.ShotResult.PERFECT
		outcome.distance_error = 0
		outcome.direction_error = 0
	else:
		# Determine miss severity
		var miss_roll := randf()
		if miss_roll < 0.5:
			# Good miss - tap in
			outcome.result = Enums.ShotResult.GOOD
			outcome.distance_error = randf_range(1, 2)
		elif miss_roll < 0.8:
			# Okay miss
			outcome.result = Enums.ShotResult.ACCEPTABLE
			outcome.distance_error = randf_range(3, 5)
		else:
			# Bad miss
			outcome.result = Enums.ShotResult.POOR
			outcome.distance_error = randf_range(5, 10)

		outcome.direction_error = randf_range(-2, 2)

	outcome.resulting_lie = Enums.LieType.GREEN
	return outcome


static func _get_putt_make_percentage(distance_feet: float, putting_skill: int) -> float:
	# Base percentages (tour average)
	var base_pct := 0.0

	if distance_feet <= 3:
		base_pct = 96.0
	elif distance_feet <= 5:
		base_pct = 77.0
	elif distance_feet <= 10:
		base_pct = 40.0
	elif distance_feet <= 15:
		base_pct = 23.0
	elif distance_feet <= 20:
		base_pct = 15.0
	elif distance_feet <= 30:
		base_pct = 7.0
	else:
		base_pct = 3.0

	# Adjust for player skill (putting 1-20, 10 is average)
	var skill_modifier := (putting_skill - 10) * 2.0
	return base_pct + skill_modifier
