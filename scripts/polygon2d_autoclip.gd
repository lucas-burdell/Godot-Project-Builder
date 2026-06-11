@tool
extends Polygon2D

##TOOD: Rewrite this, fix the junk
## This script is AI generated garbage but it works okayish. I haven't had the time or patience to rewrite it yet. 
## It uses a lot of fancy words but I don't know if they're true.


## Automatically generates polygon outline points from the node's texture.
## Attach this script to a Polygon2D node, assign a texture, then click
## "Generate Outline" in the Inspector to create the polygon.
 
@export_group("Outline Generation")
 
## Alpha threshold (0–255). Pixels with alpha above this are considered solid.
@export_range(0, 255, 1) var alpha_threshold: int = 5
 
## How many outline points to produce. Higher = more detail, more vertices.
@export_range(4, 512, 1) var max_points: int = 64
 
## Shrinks or expands the outline inward/outward (in pixels).
@export_range(-32, 32, 0.5) var outline_offset: float = 0.0
 
## Click to generate the polygon from the current texture.
@export_tool_button("Generate Outline", "Polygon2D") var generate_outline_action = func()->void:
	if Engine.is_editor_hint():
		_generate_from_texture()

func _generate_from_texture() -> void:
	var tex: Texture2D = texture
	if tex == null:
		push_error("Polygon2DOutlineGen: No texture assigned to this Polygon2D.")
		return
 
	var img: Image = tex.get_image()
	if img == null:
		push_error("Polygon2DOutlineGen: Could not get Image from texture.")
		return
 
	img.convert(Image.FORMAT_RGBA8)
 
	var w: int = img.get_width()
	var h: int = img.get_height()
 
	#  1. Build a boolean alpha mask 
	var mask: Array = []          # mask[y][x] → bool
	mask.resize(h)
	for y in h:
		var row: Array = []
		row.resize(w)
		for x in w:
			row[x] = img.get_pixel(x, y).a8 > alpha_threshold
		mask[y] = row
 
	#  2. Trace the outer boundary via square-marching edge walk 
	var raw_outline: PackedVector2Array = _trace_outline(mask, w, h)
 
	if raw_outline.size() < 3:
		push_error("Polygon2DOutlineGen: Could not find a closed outline (check alpha_threshold).")
		return
 
	#  3. Simplify / resample to max_points 
	var simplified: PackedVector2Array = _resample(raw_outline, max_points)
 
	#  4. Apply optional inward/outward offset 
	if abs(outline_offset) > 0.01:
		simplified = _offset_polygon(simplified, outline_offset)
 
	#  5. Centre the polygon on the texture's centre 
	var center := Vector2(w * 0.5, h * 0.5)
	var final_pts: PackedVector2Array
	final_pts.resize(simplified.size())
	for i in simplified.size():
		final_pts[i] = simplified[i] - center
 
	polygon = final_pts
	print("Polygon2DOutlineGen: generated %d points." % final_pts.size())
 
 
# Outline tracing – clockwise square-march on the alpha mask.
# We walk along the boundary of solid pixels by examining 2×2 neighbourhoods.
 
func _trace_outline(mask: Array, w: int, h: int) -> PackedVector2Array:
	# Find the top-most, left-most solid pixel as the start.
	var start_x: int = -1
	var start_y: int = -1
	for y in h:
		for x in w:
			if mask[y][x]:
				start_x = x
				start_y = y
				break
		if start_x >= 0:
			break
 
	if start_x < 0:
		return PackedVector2Array()   # nothing solid
 
	# Direction vectors (right, down, left, up) – clockwise.
	const DIRS := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
	# When entering from direction d, the "left" neighbour to check.
	const LEFT_CHECK := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
 
	var pts: PackedVector2Array
	var cx: int = start_x
	var cy: int = start_y
	var dir: int = 0      # start moving right
	var max_steps: int = w * h * 2    # safety cap
 
	for _step in max_steps:
		pts.append(Vector2(cx, cy))
 
		# Try to turn left (hug boundary on the left side).
		var left_dir: int = (dir + 3) % 4
		var lx: int = cx + LEFT_CHECK[dir].x
		var ly: int = cy + LEFT_CHECK[dir].y
		var left_solid: bool = _mask_get(mask, lx, ly, w, h)
 
		if left_solid:
			# Turn left and move.
			dir = left_dir
			cx += DIRS[dir].x
			cy += DIRS[dir].y
		else:
			# Try forward.
			var nx: int = cx + DIRS[dir].x
			var ny: int = cy + DIRS[dir].y
			if _mask_get(mask, nx, ny, w, h):
				cx = nx
				cy = ny
			else:
				# Turn right (away from boundary).
				dir = (dir + 1) % 4
				cx += DIRS[dir].x
				cy += DIRS[dir].y
 
		# Closed when we return to start.
		if cx == start_x and cy == start_y and pts.size() > 2:
			break
 
	return pts
 
 
func _mask_get(mask: Array, x: int, y: int, w: int, h: int) -> bool:
	if x < 0 or y < 0 or x >= w or y >= h:
		return false
	return mask[y][x]
 

# Resample the outline to (at most) target_count evenly-spaced points.

func _resample(pts: PackedVector2Array, target_count: int) -> PackedVector2Array:
	var n: int = pts.size()
	if n <= target_count:
		return pts
 
	# Compute total perimeter length.
	var total_len: float = 0.0
	for i in n:
		total_len += pts[i].distance_to(pts[(i + 1) % n])
 
	var step: float = total_len / target_count
	var result: PackedVector2Array
	result.append(pts[0])
 
	var seg_idx: int = 0
	var seg_pos: float = 0.0
 
	for _i in (target_count - 1):
		var remaining: float = step
		while remaining > 0.0001:
			var a: Vector2 = pts[seg_idx % n]
			var b: Vector2 = pts[(seg_idx + 1) % n]
			var seg_len: float = a.distance_to(b) - seg_pos
 
			if remaining < seg_len:
				var t: float = (seg_pos + remaining) / (a.distance_to(b))
				result.append(a.lerp(b, t))
				seg_pos += remaining
				remaining = 0.0
			else:
				remaining -= seg_len
				seg_pos = 0.0
				seg_idx += 1
 
	return result
 
 
# Offset a polygon inward (negative) or outward (positive) by `amount` pixels.
# Uses per-vertex normals computed from adjacent edge directions.
 
func _offset_polygon(pts: PackedVector2Array, amount: float) -> PackedVector2Array:
	var n: int = pts.size()
	var result: PackedVector2Array
	result.resize(n)
 
	for i in n:
		var prev: Vector2 = pts[(i + n - 1) % n]
		var curr: Vector2 = pts[i]
		var next: Vector2 = pts[(i + 1) % n]
 
		# Edge normals (perpendicular, pointing outward for CW winding).
		var e1: Vector2 = (curr - prev).normalized()
		var n1: Vector2 = Vector2(e1.y, -e1.x)   # rotate 90° CW
		var e2: Vector2 = (next - curr).normalized()
		var n2: Vector2 = Vector2(e2.y, -e2.x)
 
		# Miter normal: average of the two edge normals.
		var miter: Vector2 = (n1 + n2).normalized()
		var miter_len: float = 1.0 / max(n1.dot(miter), 0.1)   # miter limit
		result[i] = curr + miter * amount * min(miter_len, 4.0)
 
	return result
