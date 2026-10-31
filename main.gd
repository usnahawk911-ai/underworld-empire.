extends Control

const SAVE_PATH := "user://underworld_empire_save.json"

var cash: int = 2500
var respect: int = 10
var hq_level: int = 1
var crew: int = 3
var heat: int = 0
var completed_missions: int = 0
var status_label: Label
var cash_label: Label
var stats_label: Label
var content: VBoxContainer
var mission_index: int = 0

var missions := [
    {"name": "Collect protection money", "cost": 0, "reward": 650, "respect": 3, "risk": 8},
    {"name": "Intercept a rival shipment", "cost": 250, "reward": 1050, "respect": 5, "risk": 18},
    {"name": "Take over a backstreet business", "cost": 500, "reward": 1700, "respect": 8, "risk": 28},
    {"name": "Secure the waterfront", "cost": 900, "reward": 2800, "respect": 12, "risk": 38}
]

func _ready() -> void:
    _load_game()
    _build_ui()
    _refresh()

func _build_ui() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var bg := ColorRect.new()
    bg.color = Color("#090f1c")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var scroll := ScrollContainer.new()
    scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scroll.offset_left = 18
    scroll.offset_top = 18
    scroll.offset_right = -18
    scroll.offset_bottom = -18
    add_child(scroll)

    var page := VBoxContainer.new()
    page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page.add_theme_constant_override("separation", 14)
    scroll.add_child(page)

    var header := PanelContainer.new()
    _panel_style(header, "#18263d", "#d9a441")
    page.add_child(header)
    var header_box := VBoxContainer.new()
    header_box.add_theme_constant_override("separation", 5)
    header.add_child(header_box)
    var title := Label.new()
    title.text = "UNDERWORLD EMPIRE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 27)
    title.add_theme_color_override("font_color", Color("#f6c65b"))
    header_box.add_child(title)
    var subtitle := Label.new()
    subtitle.text = "BUILD YOUR FAMILY. RULE THE CITY."
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 12)
    subtitle.add_theme_color_override("font_color", Color("#c4ccdc"))
    header_box.add_child(subtitle)

    var resources := PanelContainer.new()
    _panel_style(resources, "#111c2e", "#314663")
    page.add_child(resources)
    var resource_box := VBoxContainer.new()
    resource_box.add_theme_constant_override("separation", 6)
    resources.add_child(resource_box)
    cash_label = Label.new()
    cash_label.add_theme_font_size_override("font_size", 22)
    cash_label.add_theme_color_override("font_color", Color("#78e0a3"))
    resource_box.add_child(cash_label)
    stats_label = Label.new()
    stats_label.add_theme_font_size_override("font_size", 15)
    stats_label.add_theme_color_override("font_color", Color("#d7dfef"))
    resource_box.add_child(stats_label)

    _section(page, "YOUR HEADQUARTERS")
    var hq_panel := PanelContainer.new()
    _panel_style(hq_panel, "#15243a", "#314663")
    page.add_child(hq_panel)
    var hq_box := VBoxContainer.new()
    hq_box.add_theme_constant_override("separation", 8)
    hq_panel.add_child(hq_box)
    var hq_title := Label.new()
    hq_title.text = "THE FAMILY COMPOUND"
    hq_title.add_theme_font_size_override("font_size", 19)
    hq_title.add_theme_color_override("font_color", Color("#f0f3fa"))
    hq_box.add_child(hq_title)
    var hq_desc := Label.new()
    hq_desc.text = "A discreet base of operations. Upgrades increase your standing and unlock bigger scores."
    hq_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hq_desc.add_theme_color_override("font_color", Color("#b6c2d8"))
    hq_box.add_child(hq_desc)
    _button(hq_box, "UPGRADE HEADQUARTERS  •  $%s" % _hq_cost(), _upgrade_hq)

    _section(page, "RECRUIT YOUR CREW")
    var crew_panel := PanelContainer.new()
    _panel_style(crew_panel, "#15243a", "#314663")
    page.add_child(crew_panel)
    var crew_box := VBoxContainer.new()
    crew_box.add_theme_constant_override("separation", 8)
    crew_panel.add_child(crew_box)
    var crew_desc := Label.new()
    crew_desc.text = "Bring in loyal associates to improve your odds on dangerous jobs."
    crew_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    crew_desc.add_theme_color_override("font_color", Color("#b6c2d8"))
    crew_box.add_child(crew_desc)
    _button(crew_box, "RECRUIT A CREW MEMBER  •  $750", _recruit)

    _section(page, "CITY OPERATIONS")
    var mission_panel := PanelContainer.new()
    _panel_style(mission_panel, "#15243a", "#314663")
    page.add_child(mission_panel)
    var mission_box := VBoxContainer.new()
    mission_box.add_theme_constant_override("separation", 8)
    mission_panel.add_child(mission_box)
    var mission_title := Label.new()
    mission_title.text = "AVAILABLE JOB"
    mission_title.add_theme_font_size_override("font_size", 13)
    mission_title.add_theme_color_override("font_color", Color("#f6c65b"))
    mission_box.add_child(mission_title)
    var mission_name := Label.new()
    mission_name.name = "MissionName"
    mission_name.add_theme_font_size_override("font_size", 20)
    mission_name.add_theme_color_override("font_color", Color("#f0f3fa"))
    mission_box.add_child(mission_name)
    var mission_desc := Label.new()
    mission_desc.name = "MissionDesc"
    mission_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    mission_desc.add_theme_color_override("font_color", Color("#b6c2d8"))
    mission_box.add_child(mission_desc)
    _button(mission_box, "RUN THE OPERATION", _run_mission)
    _button(mission_box, "COLLECT PASSIVE INCOME  •  $300", _collect_income)

    _section(page, "FAMILY STATUS")
    var status_panel := PanelContainer.new()
    _panel_style(status_panel, "#111c2e", "#314663")
    page.add_child(status_panel)
    status_label = Label.new()
    status_label.text = "Your story starts here."
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_color_override("font_color", Color("#d7dfef"))
    status_panel.add_child(status_label)

    var footer := Label.new()
    footer.text = "SINGLE-PLAYER PROTOTYPE  •  YOUR PROGRESS SAVES ON THIS DEVICE"
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    footer.add_theme_font_size_override("font_size", 10)
    footer.add_theme_color_override("font_color", Color("#77859c"))
    page.add_child(footer)

func _section(parent: VBoxContainer, text: String) -> void:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 16)
    label.add_theme_color_override("font_color", Color("#f6c65b"))
    parent.add_child(label)

func _panel_style(panel: PanelContainer, fill: String, border: String) -> void:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(fill)
    style.border_color = Color(border)
    style.set_border_width_all(1)
    style.set_corner_radius_all(12)
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    panel.add_theme_stylebox_override("panel", style)

func _button(parent: Node, text: String, action: Callable) -> void:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(0, 52)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 15)
    button.add_theme_color_override("font_color", Color("#101827"))
    button.add_theme_color_override("font_hover_color", Color("#101827"))
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#e8b84e")
    normal.set_corner_radius_all(8)
    normal.content_margin_left = 10
    normal.content_margin_right = 10
    button.add_theme_stylebox_override("normal", normal)
    var hover := normal.duplicate()
    hover.bg_color = Color("#ffd978")
    button.add_theme_stylebox_override("hover", hover)
    var pressed := normal.duplicate()
    pressed.bg_color = Color("#c9932e")
    button.add_theme_stylebox_override("pressed", pressed)
    button.pressed.connect(action)
    parent.add_child(button)

func _hq_cost() -> int:
    return 1500 * hq_level

func _upgrade_hq() -> void:
    var cost := _hq_cost()
    if cash < cost:
        _notify("Not enough cash. Run an operation or collect income first.")
        return
    cash -= cost
    hq_level += 1
    respect += 5
    _notify("Headquarters upgraded! Respect +5.")
    _refresh()
    _save_game()

func _recruit() -> void:
    if cash < 750:
        _notify("You need $750 to recruit another crew member.")
        return
    cash -= 750
    crew += 1
    _notify("New associate recruited. Your crew is stronger.")
    _refresh()
    _save_game()

func _run_mission() -> void:
    var mission: Dictionary = missions[mission_index % missions.size()]
    var cost: int = int(mission["cost"])
    if cash < cost:
        _notify("Not enough cash to prepare for this operation.")
        return
    cash -= cost
    var chance := clampf(0.58 + (crew * 0.055) + (hq_level * 0.035) - (float(mission["risk"]) / 100.0), 0.15, 0.95)
    if randf() <= chance:
        var reward := int(mission["reward"]) + crew * 90 + hq_level * 120
        cash += reward
        respect += int(mission["respect"])
        completed_missions += 1
        heat = mini(100, heat + int(mission["risk"]) / 2)
        _notify("SUCCESS: %s. You earned $%s and respect +%s." % [mission["name"], _money(reward), mission["respect"]])
        mission_index += 1
    else:
        var loss := mini(cash, 350 + int(mission["risk"]) * 8)
        cash -= loss
        heat = mini(100, heat + int(mission["risk"]))
        _notify("THE JOB WENT BAD. Lost $%s. Recruit crew and upgrade your HQ before trying tougher jobs." % _money(loss))
    _refresh()
    _save_game()

func _collect_income() -> void:
    var amount := 300 + hq_level * 125
    cash += amount
    _notify("Your businesses brought in $%s." % _money(amount))
    _refresh()
    _save_game()

func _refresh() -> void:
    if not is_node_ready():
        return
    if cash_label:
        cash_label.text = "CASH  $%s" % _money(cash)
    if stats_label:
        stats_label.text = "Respect: %d     HQ Level: %d\nCrew: %d members     Heat: %d/100" % [respect, hq_level, crew, heat]
    var mission: Dictionary = missions[mission_index % missions.size()]
    var title_node := find_child("MissionName", true, false) as Label
    var desc_node := find_child("MissionDesc", true, false) as Label
    if title_node:
        title_node.text = str(mission["name"])
    if desc_node:
        desc_node.text = "Preparation: $%s  •  Risk: %d%%\nSuccess reward: $%s + %d respect" % [_money(int(mission["cost"])), int(mission["risk"]), _money(int(mission["reward"])), int(mission["respect"])]
    if status_label:
        status_label.text = "Operations completed: %d\nYour family controls a small foothold in the city. Grow your crew, invest in your compound, and take calculated risks." % completed_missions

func _notify(message: String) -> void:
    if status_label:
        status_label.text = message
    else:
        print(message)

func _money(value: int) -> String:
    return "%s" % value

func _save_game() -> void:
    var data := {
        "cash": cash, "respect": respect, "hq_level": hq_level,
        "crew": crew, "heat": heat, "completed_missions": completed_missions,
        "mission_index": mission_index
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))

func _load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return
    cash = int(parsed.get("cash", cash))
    respect = int(parsed.get("respect", respect))
    hq_level = int(parsed.get("hq_level", hq_level))
    crew = int(parsed.get("crew", crew))
    heat = int(parsed.get("heat", heat))
    completed_missions = int(parsed.get("completed_missions", completed_missions))
    mission_index = int(parsed.get("mission_index", mission_index))
