-- Unity Importer Plugin for Unity (Aseprite extension)
-- Managed layer:
--   name: "Events" (enforced)
--   data: "UnityAnimationEventLayer" (enforced identifier)
-- Cels on the managed layer store event data as: "event:@NAME"

local PLUGIN_NAME = "Unity Importer Plugin for Unity"
local EVENT_NAME = "Unity Animation Event"
local PRODUCT_CREDITS = "Made by Soupmasters. Written by Martin Calander."
local UNITY_ASEPRITE_PACKAGE_ID = "com.unity.2d.aseprite"
local UNITY_IMPORTER_TIP_SECONDS = 8
local UNITY_IMPORTER_RETRY_SECONDS = 3

-- Managed-layer config (single place to change internal identifiers).
-- NOTE: `EVENT_LAYER_METADATA` is always enforced by code and is not user-editable.
local EVENT_LAYER_NAME = "Events"
local EVENT_LAYER_METADATA = "UnityAnimationEventLayer"
local LEGACY_EVENT_LAYER_METADATA = "MadeByMartinCalander"
local DONT_IMPORT_LAYER_METADATA = "DontImportToUnity"
local DONT_IMPORT_LAYER_COLOR = Color{ r=57, g=59, b=59, a=255 } -- ~#393B3B
local DONT_IMPORT_LAYER_OPACITY = 128
local DONT_IMPORT_LAYER_RESET_COLOR = Color{ r=0, g=0, b=0, a=0 }
local EVENT_PREFIX = "event:@"

local CMD_ADD = "UnityEvents_Add"
local CMD_EDIT = "UnityEvents_Edit"
local CMD_REMOVE = "UnityEvents_Remove"
local CMD_IMPORT_TAGS = "UnityEvents_ImportAtTags"
local CMD_UNIQUE_TAGS = "UnityEvents_UniqueTags"
local CMD_MIGRATE_LEGACY = "UnityEvents_MigrateLegacyEventFormat"
local CMD_DONT_IMPORT_LAYER = "UnityEvents_DontImportToUnity"
local CMD_DELETE_LAYER = "UnityEvents_DeleteLayer"
local CMD_SETTINGS = "UnityEvents_Settings"

local DEFAULT_EVENT_COLOR = Color{ r=255, g=0,   b=0,   a=255 }
local DEFAULT_EMPTY_COLOR = Color{ r=255, g=255, b=255, a=0 }
local DEFAULT_WARN_ON_OVERWRITE = true
local DEFAULT_OPEN_EDITOR_ON_DOUBLE_CLICK = true
local DEFAULT_REMOVE_SOURCE_AT_TAGS_ON_IMPORT = true
local DEFAULT_UI_LANGUAGE = "auto"

local I18N = {
  en = {
    cmd_add = "Add Unity Animation Event",
    cmd_edit = "Edit Unity Animation Event",
    cmd_remove = "Remove Unity Animation Event",
    cmd_import_tags = "Import @Tags to Unity Animation Events",
    cmd_unique_tags = "Make Duplicate Tags Unique",
    cmd_migrate_legacy = "Migrate event:MyMethod to Current Format",
    cmd_dont_import_layer = "Dont Import to Unity",
    cmd_delete_layer = "Delete Unity Animation Event Layer",
    cmd_settings = "Unity Importer Plugin for Unity Settings",
    add_title = "Add {product}",
    add_label = "{product} name (stored as event:@NAME):",
    edit_title = "Edit {product}",
    edit_label = "{product} name for this frame:",
    overwrite_text = "One or more selected frames already have Unity Animation Events. Overwrite?",
    delete_layer_text = "Delete the managed Events layer and all stored Unity Animation Events for this sprite?",
    settings_title = "{plugin} Settings",
    settings_event_color = "Event marker color (timeline dot)",
    settings_empty_color = "Empty cel color",
    settings_warn_overwrite = "Warn before overwrite",
    settings_double_click = "Edit on cel double-click (Events layer)",
    settings_remove_tags_after_import = "Delete source @tags after import",
    settings_language = "Language",
    lang_auto = "Auto (Aseprite)",
    lang_en = "English",
    lang_es = "Spanish",
    lang_sv = "Swedish",
    lang_fr = "French",
    lang_de = "German",
    lang_pt = "Portuguese",
    btn_ok = "OK",
    btn_cancel = "Cancel",
    btn_save = "Save",
    btn_remove = "Remove",
    btn_delete = "Delete",
    btn_reset = "Reset Defaults",
    btn_yes = "Yes",
    btn_no = "No",
    managed_layer_info = "Managed by {plugin}.",
    managed_layer_info_count = "Animation events in file: {count}",
    unity_importer_active = "{filename} is imported by Unity's 2D Aseprite Importer.",
    dont_import_info = "This layer wont be imported into Unity.\nAllow import again?",
    import_no_tags = "No timeline tags starting with @ were found.",
    import_done = "Imported {count} @tags to Unity Animation Events.",
    import_done_removed = "Source @tags were deleted.",
    import_done_kept = "Source @tags were kept.",
    unique_no_duplicates = "No duplicate tag names were found.",
    unique_found = "Found {nameCount} duplicate names across {tagCount} tags.",
    unique_confirm = "Rename duplicates now and make all tag names unique?",
    unique_done = "Renamed {renamedCount} tags. All names are now unique.",
    migrate_no_layer = "No managed Events layer found in this sprite.",
    migrate_none = "No legacy event:MyMethod entries found to migrate.",
    migrate_done = "Migrated {count} legacy entries to event:@NAME format.",
    migrate_skipped = "{count} existing entries were already in current format.",
    unique_group_count_line = "{count} tags with this name",
    unique_tag_line = "  - copy {index}: frames {range}",
    unique_more_groups = "...and {count} more duplicate groups."
  },
  es = {
    cmd_add = "Agregar Unity Animation Event",
    cmd_edit = "Editar Unity Animation Event",
    cmd_remove = "Quitar Unity Animation Event",
    cmd_delete_layer = "Borrar capa Unity Animation Event",
    cmd_settings = "Configuracion de Unity Importer Plugin for Unity",
    add_title = "Agregar {product}",
    add_label = "Nombre de {product} (guardado como event:@NAME):",
    edit_title = "Editar {product}",
    edit_label = "Nombre de {product} para este frame:",
    overwrite_text = "Uno o mas frames seleccionados ya tienen Unity Animation Events. Sobrescribir?",
    delete_layer_text = "Borrar la capa Events administrada y todos los Unity Animation Events de este sprite?",
    settings_title = "Configuracion de {plugin}",
    settings_event_color = "Color del marcador de evento (punto en timeline)",
    settings_empty_color = "Color de cel vacia",
    settings_warn_overwrite = "Advertir antes de sobrescribir",
    settings_double_click = "Editar al doble clic en cel (capa Events)",
    settings_language = "Idioma",
    lang_auto = "Auto (Aseprite)",
    lang_en = "Ingles",
    lang_es = "Espanol",
    lang_sv = "Sueco",
    lang_fr = "Frances",
    lang_de = "Aleman",
    lang_pt = "Portugues",
    btn_ok = "OK",
    btn_cancel = "Cancelar",
    btn_save = "Guardar",
    btn_remove = "Quitar",
    btn_delete = "Borrar",
    btn_reset = "Restablecer",
    btn_yes = "Si",
    btn_no = "No",
    unity_importer_active = "{filename} se importa mediante 2D Aseprite Importer de Unity."
  },
  sv = {
    cmd_add = "Lagg till Unity Animation Event",
    cmd_edit = "Redigera Unity Animation Event",
    cmd_remove = "Ta bort Unity Animation Event",
    cmd_delete_layer = "Ta bort Unity Animation Event-lager",
    cmd_settings = "Unity Importer Plugin for Unity-installningar",
    add_title = "Lagg till {product}",
    add_label = "{product}-namn (sparas som event:@NAME):",
    edit_title = "Redigera {product}",
    edit_label = "{product}-namn for denna bildruta:",
    overwrite_text = "En eller flera valda bildrutor har redan Unity Animation Events. Skriv over?",
    delete_layer_text = "Ta bort det hanterade Events-lagret och alla Unity Animation Events i denna sprite?",
    settings_title = "{plugin} installningar",
    settings_event_color = "Farg for event-markor (punkt i tidslinjen)",
    settings_empty_color = "Farg for tom cel",
    settings_warn_overwrite = "Varna innan overskrivning",
    settings_double_click = "Redigera vid dubbelklick pa cel (Events-lager)",
    settings_language = "Sprak",
    lang_auto = "Auto (Aseprite)",
    lang_en = "Engelska",
    lang_es = "Spanska",
    lang_sv = "Svenska",
    lang_fr = "Franska",
    lang_de = "Tyska",
    lang_pt = "Portugisiska",
    btn_ok = "OK",
    btn_cancel = "Avbryt",
    btn_save = "Spara",
    btn_remove = "Ta bort",
    btn_delete = "Radera",
    btn_reset = "Aterstall standard",
    btn_yes = "Ja",
    btn_no = "Nej",
    unity_importer_active = "{filename} importeras av Unitys 2D Aseprite Importer."
  },
  fr = {
    cmd_add = "Ajouter Unity Animation Event",
    cmd_edit = "Modifier Unity Animation Event",
    cmd_remove = "Retirer Unity Animation Event",
    cmd_delete_layer = "Supprimer le calque Unity Animation Event",
    cmd_settings = "Parametres Unity Importer Plugin for Unity",
    add_title = "Ajouter {product}",
    add_label = "Nom {product} (stocke comme event:@NAME):",
    edit_title = "Modifier {product}",
    edit_label = "Nom {product} pour cette image:",
    overwrite_text = "Une ou plusieurs images selectionnees ont deja des Unity Animation Events. Ecraser?",
    delete_layer_text = "Supprimer le calque Events gere et tous les Unity Animation Events de ce sprite?",
    settings_title = "Parametres de {plugin}",
    settings_event_color = "Couleur du marqueur d'evenement (point timeline)",
    settings_empty_color = "Couleur du cel vide",
    settings_warn_overwrite = "Avertir avant ecrasement",
    settings_double_click = "Editer au double-clic sur le cel (calque Events)",
    settings_language = "Langue",
    lang_auto = "Auto (Aseprite)",
    lang_en = "Anglais",
    lang_es = "Espagnol",
    lang_sv = "Suedois",
    lang_fr = "Francais",
    lang_de = "Allemand",
    lang_pt = "Portugais",
    btn_ok = "OK",
    btn_cancel = "Annuler",
    btn_save = "Enregistrer",
    btn_remove = "Retirer",
    btn_delete = "Supprimer",
    btn_reset = "Reinitialiser",
    btn_yes = "Oui",
    btn_no = "Non",
    unity_importer_active = "{filename} est importe par le 2D Aseprite Importer de Unity."
  },
  de = {
    cmd_add = "Unity Animation Event hinzufugen",
    cmd_edit = "Unity Animation Event bearbeiten",
    cmd_remove = "Unity Animation Event entfernen",
    cmd_delete_layer = "Unity Animation Event-Ebene loschen",
    cmd_settings = "Unity Importer Plugin for Unity Einstellungen",
    add_title = "{product} hinzufugen",
    add_label = "{product}-Name (gespeichert als event:@NAME):",
    edit_title = "{product} bearbeiten",
    edit_label = "{product}-Name fur dieses Frame:",
    overwrite_text = "Ein oder mehrere ausgewahlte Frames haben bereits Unity Animation Events. Uberschreiben?",
    delete_layer_text = "Die verwaltete Events-Ebene und alle gespeicherten Unity Animation Events fur dieses Sprite loschen?",
    settings_title = "{plugin} Einstellungen",
    settings_event_color = "Event-Markierungsfarbe (Timeline-Punkt)",
    settings_empty_color = "Leere-Cel-Farbe",
    settings_warn_overwrite = "Vor dem Uberschreiben warnen",
    settings_double_click = "Bei Doppelklick auf Cel bearbeiten (Events-Ebene)",
    settings_language = "Sprache",
    lang_auto = "Auto (Aseprite)",
    lang_en = "Englisch",
    lang_es = "Spanisch",
    lang_sv = "Schwedisch",
    lang_fr = "Franzosisch",
    lang_de = "Deutsch",
    lang_pt = "Portugiesisch",
    btn_ok = "OK",
    btn_cancel = "Abbrechen",
    btn_save = "Speichern",
    btn_remove = "Entfernen",
    btn_delete = "Loschen",
    btn_reset = "Standard wiederherstellen",
    btn_yes = "Ja",
    btn_no = "Nein",
    unity_importer_active = "{filename} wird von Unitys 2D Aseprite Importer importiert."
  },
  pt = {
    cmd_add = "Adicionar Unity Animation Event",
    cmd_edit = "Editar Unity Animation Event",
    cmd_remove = "Remover Unity Animation Event",
    cmd_delete_layer = "Excluir camada Unity Animation Event",
    cmd_settings = "Configuracoes de Unity Importer Plugin for Unity",
    add_title = "Adicionar {product}",
    add_label = "Nome de {product} (salvo como event:@NAME):",
    edit_title = "Editar {product}",
    edit_label = "Nome de {product} para este frame:",
    overwrite_text = "Um ou mais frames selecionados ja tem Unity Animation Events. Sobrescrever?",
    delete_layer_text = "Excluir a camada Events gerenciada e todos os Unity Animation Events deste sprite?",
    settings_title = "Configuracoes de {plugin}",
    settings_event_color = "Cor do marcador de evento (ponto na timeline)",
    settings_empty_color = "Cor do cel vazio",
    settings_warn_overwrite = "Avisar antes de sobrescrever",
    settings_double_click = "Editar com duplo clique no cel (camada Events)",
    settings_language = "Idioma",
    lang_auto = "Auto (Aseprite)",
    lang_en = "Ingles",
    lang_es = "Espanhol",
    lang_sv = "Sueco",
    lang_fr = "Frances",
    lang_de = "Alemao",
    lang_pt = "Portugues",
    btn_ok = "OK",
    btn_cancel = "Cancelar",
    btn_save = "Salvar",
    btn_remove = "Remover",
    btn_delete = "Excluir",
    btn_reset = "Redefinir padrao",
    btn_yes = "Sim",
    btn_no = "Nao",
    unity_importer_active = "{filename} e importado pelo 2D Aseprite Importer da Unity."
  }
}

local LANGUAGE_OPTIONS = { "auto", "en", "es", "sv", "fr", "de", "pt" }
local LANGUAGE_NATIVE_LABELS = {
  auto = "Auto (Aseprite)",
  en = "English",
  es = "Espanol",
  sv = "Svenska",
  fr = "Francais",
  de = "Deutsch",
  pt = "Portugues"
}

local pluginRef = nil
local prevSprite = nil
local inEnforce = false
local settingsPanel = nil
local settingsPanelBounds = nil
local enforceManagedLayer
local lastUnityImporterNoticeKey = nil
local spriteEventListeners = {}
local unityProjectImporterCache = {}
local unityImporterRetryTimer = nil

-- --------------------------
-- Preferences
-- --------------------------

local function clampByte(n)
  n = tonumber(n) or 0
  if n < 0 then return 0 end
  if n > 255 then return 255 end
  return math.floor(n + 0.5)
end

local function colorToRGBA(c)
  if not c then return nil end
  local ok, r, g, b, a = pcall(function()
    local rr = c.red or c.r
    local gg = c.green or c.g
    local bb = c.blue or c.b
    local aa = c.alpha or c.a
    return clampByte(rr), clampByte(gg), clampByte(bb), clampByte(aa)
  end)
  if not ok then return nil end
  return r, g, b, a
end

local function colorEquals(a, b)
  local ar, ag, ab, aa = colorToRGBA(a)
  local br, bg, bb, ba = colorToRGBA(b)
  if ar == nil or br == nil then return false end
  return ar == br and ag == bg and ab == bb and aa == ba
end

local function prefs()
  return pluginRef and pluginRef.preferences or {}
end

local function normalizeLanguageCode(code)
  if type(code) ~= "string" then return "" end
  code = code:lower()
  code = code:gsub("_", "-")
  code = code:gsub("%s+", "")
  return code
end

local function resolveLanguageCode(code)
  code = normalizeLanguageCode(code)
  if code == "" then return "en" end
  if I18N[code] then return code end
  local short = code:match("^([a-z][a-z])")
  if short and I18N[short] then return short end
  return "en"
end

local function readAsepriteLanguageCode()
  local ok, value = pcall(function()
    return app and app.preferences and app.preferences.general and app.preferences.general.language
  end)
  if ok and type(value) == "string" and value ~= "" then
    return value
  end
  return "en"
end

local function configuredLanguageCode()
  local code = normalizeLanguageCode(prefs().uiLanguage or DEFAULT_UI_LANGUAGE)
  if code == "" then return DEFAULT_UI_LANGUAGE end
  return code
end

local function activeLanguageCode()
  local code = configuredLanguageCode()
  if code == "auto" then
    code = readAsepriteLanguageCode()
  end
  return resolveLanguageCode(code)
end

local function formatTemplate(template, vars)
  if type(template) ~= "string" then return "" end
  if type(vars) ~= "table" then return template end
  return (template:gsub("{([%w_]+)}", function(key)
    local value = vars[key]
    if value == nil then return "{" .. key .. "}" end
    return tostring(value)
  end))
end

local function tr(key, vars)
  local lang = activeLanguageCode()
  local dict = I18N[lang] or I18N.en
  local text = dict[key] or I18N.en[key] or key
  local allVars = { product = EVENT_NAME, plugin = PLUGIN_NAME }
  if type(vars) == "table" then
    for k, v in pairs(vars) do
      allVars[k] = v
    end
  end
  return formatTemplate(text, allVars)
end

local function languageLabelForCode(code)
  code = normalizeLanguageCode(code)
  for _, optionCode in ipairs(LANGUAGE_OPTIONS) do
    if optionCode == code then
      return LANGUAGE_NATIVE_LABELS[optionCode] or LANGUAGE_NATIVE_LABELS.auto
    end
  end
  return LANGUAGE_NATIVE_LABELS.auto
end

local function languageCodeForLabel(label)
  if type(label) ~= "string" then return DEFAULT_UI_LANGUAGE end
  for _, optionCode in ipairs(LANGUAGE_OPTIONS) do
    if label == LANGUAGE_NATIVE_LABELS[optionCode] then
      return optionCode
    end
  end
  return DEFAULT_UI_LANGUAGE
end

local function languageOptionLabels()
  local labels = {}
  for _, optionCode in ipairs(LANGUAGE_OPTIONS) do
    labels[#labels+1] = LANGUAGE_NATIVE_LABELS[optionCode] or optionCode
  end
  return labels
end

local function saveColor(prefix, c)
  local p = prefs()
  p[prefix.."R"] = clampByte(c.red)
  p[prefix.."G"] = clampByte(c.green)
  p[prefix.."B"] = clampByte(c.blue)
  p[prefix.."A"] = clampByte(c.alpha)
end

local function loadColor(prefix, fallback)
  local p = prefs()
  local r, g, b, a = p[prefix.."R"], p[prefix.."G"], p[prefix.."B"], p[prefix.."A"]
  if r == nil or g == nil or b == nil or a == nil then return fallback end
  return Color{ r=clampByte(r), g=clampByte(g), b=clampByte(b), a=clampByte(a) }
end

local function eventColor() return loadColor("eventColor", DEFAULT_EVENT_COLOR) end
local function emptyColor() return loadColor("emptyColor", DEFAULT_EMPTY_COLOR) end

local function loadBool(key, fallback)
  local p = prefs()
  local value = p[key]
  if value == nil then return fallback end
  return value and true or false
end

local function warnOnOverwrite()
  return loadBool("warnOnOverwrite", DEFAULT_WARN_ON_OVERWRITE)
end

local function openEditorOnDoubleClick()
  return loadBool("openEditorOnDoubleClick", DEFAULT_OPEN_EDITOR_ON_DOUBLE_CLICK)
end

local function removeSourceAtTagsOnImport()
  return loadBool("removeSourceAtTagsOnImport", DEFAULT_REMOVE_SOURCE_AT_TAGS_ON_IMPORT)
end

local function ensurePreferenceDefaults()
  local p = prefs()
  if p.eventColorR == nil then saveColor("eventColor", DEFAULT_EVENT_COLOR) end
  if p.emptyColorR == nil then saveColor("emptyColor", DEFAULT_EMPTY_COLOR) end
  if p.warnOnOverwrite == nil then p.warnOnOverwrite = DEFAULT_WARN_ON_OVERWRITE end
  if p.openEditorOnDoubleClick == nil then p.openEditorOnDoubleClick = DEFAULT_OPEN_EDITOR_ON_DOUBLE_CLICK end
  if p.removeSourceAtTagsOnImport == nil then p.removeSourceAtTagsOnImport = DEFAULT_REMOVE_SOURCE_AT_TAGS_ON_IMPORT end
  if p.uiLanguage == nil then p.uiLanguage = DEFAULT_UI_LANGUAGE end
end

local function applySettingsValues(values)
  ensurePreferenceDefaults()
  local p = prefs()
  if not values then return configuredLanguageCode() end

  saveColor("eventColor", values.event or eventColor())

  local warnValue = values.warnOnOverwrite
  if warnValue == nil then
    p.warnOnOverwrite = warnOnOverwrite()
  else
    p.warnOnOverwrite = warnValue and true or false
  end

  local doubleClickValue = values.openEditorOnDoubleClick
  if doubleClickValue == nil then
    p.openEditorOnDoubleClick = openEditorOnDoubleClick()
  else
    p.openEditorOnDoubleClick = doubleClickValue and true or false
  end

  local removeTagsValue = values.removeSourceAtTagsOnImport
  if removeTagsValue == nil then
    p.removeSourceAtTagsOnImport = removeSourceAtTagsOnImport()
  else
    p.removeSourceAtTagsOnImport = removeTagsValue and true or false
  end

  local uiLabel = values.uiLanguage
  if uiLabel == nil then
    uiLabel = languageLabelForCode(configuredLanguageCode())
  end
  p.uiLanguage = languageCodeForLabel(uiLabel)

  enforceManagedLayer(app.activeSprite)
  return configuredLanguageCode()
end

-- --------------------------
-- Layer discovery (safe)
-- --------------------------

local function iterLayersRecursive(layerList, out)
  for _, layer in ipairs(layerList) do
    out[#out+1] = layer
    if layer.isGroup and layer.layers then
      iterLayersRecursive(layer.layers, out)
    end
  end
end

local function findManagedLayer(sprite)
  if not sprite then return nil end
  local all = {}
  iterLayersRecursive(sprite.layers, all)

  local legacyMatch = nil
  for _, layer in ipairs(all) do
    if layer.data == EVENT_LAYER_METADATA then
      return layer
    end
    if not legacyMatch and layer.data == LEGACY_EVENT_LAYER_METADATA then
      legacyMatch = layer
    end
  end
  return legacyMatch
end

-- --------------------------
-- Cel helpers
-- --------------------------

local function startsWith(s, prefix)
  return type(s) == "string" and string.sub(s, 1, #prefix) == prefix
end

local function normalizeEventText(s)
  s = s or ""
  if s == "" then return "" end
  if startsWith(s, EVENT_PREFIX) then return s end
  return EVENT_PREFIX .. s
end

local function eventNameFromCelData(s)
  s = s or ""
  if s == "" then return "" end
  if startsWith(s, EVENT_PREFIX) then
    return string.sub(s, #EVENT_PREFIX + 1)
  end
  return s
end

local function applyCelStyle(cel)
  if not cel then return end
  local d = cel.data or ""
  if d == "" then
    cel.color = emptyColor()
  else
    cel.data = normalizeEventText(d)
    cel.color = eventColor()
  end
end

local function makeMarkerImage(sprite)
  local spec = ImageSpec(sprite.spec)
  spec.width, spec.height = 1, 1
  local img = Image(spec)
  -- Clears using img.spec.transparentColor by default (safe for indexed mode too)
  img:clear()
  return img
end

local function ensureMarkerCel(sprite, layer, frameNumber)
  local cel = layer:cel(frameNumber)
  if cel then return cel end
  sprite:newCel(layer, frameNumber, makeMarkerImage(sprite), Point(0, 0))
  cel = layer:cel(frameNumber)
  if cel and cel.data == nil then cel.data = "" end
  return cel
end

local function getSelectedFrameNumbers()
  local frames, seen = {}, {}

  local function addFn(fn)
    fn = tonumber(fn)
    if fn and fn >= 1 and not seen[fn] then
      seen[fn] = true
      frames[#frames+1] = fn
    end
  end

  local r = app.range
  if r and r.type and RangeType then
    if r.type == RangeType.FRAMES and r.frames then
      for _, fr in ipairs(r.frames) do addFn(fr.frameNumber) end
    elseif r.type == RangeType.CELS and r.cels then
      for _, cel in ipairs(r.cels) do
        if cel and cel.frameNumber then addFn(cel.frameNumber) end
      end
    end
  end

  if #frames == 0 and app.frame then addFn(app.frame.frameNumber) end
  table.sort(frames)
  return frames
end

local function anyEventsOnFrames(layer, frameNumbers)
  if not layer then return false end
  for _, fn in ipairs(frameNumbers) do
    local cel = layer:cel(fn)
    if cel and cel.data and cel.data ~= "" then return true end
  end
  return false
end

-- --------------------------
-- Managed layer creation + enforcement
-- --------------------------

local function createManagedLayer(sprite)
  local layer = sprite:newLayer()
  layer.data = EVENT_LAYER_METADATA
  layer.name = EVENT_LAYER_NAME

  -- REQUIRED: always visible for export/import paths that ignore hidden layers
  layer.isVisible = true

  -- Always locked
  layer.isEditable = false

  -- Force top-most and top-level
  layer.parent = sprite
  layer.stackIndex = #sprite.layers
  return layer
end

enforceManagedLayer = function(sprite)
  if inEnforce then return end
  if not sprite then return end

  local layer = findManagedLayer(sprite)
  if not layer then return end

  local needTxn = false

  -- Only touch the layer that has our identifier data.
  if layer.data ~= EVENT_LAYER_METADATA then needTxn = true end
  if layer.name ~= EVENT_LAYER_NAME then needTxn = true end
  if layer.isVisible ~= true then needTxn = true end
  if layer.isEditable ~= false then needTxn = true end
  if layer.parent ~= sprite then needTxn = true end
  if layer.parent == sprite and layer.stackIndex ~= #sprite.layers then needTxn = true end

  -- Normalize cel data + colors
  local needCelPass = false
  for _, cel in ipairs(layer.cels) do
    local d = cel.data or ""
    if d == "" then
      needCelPass = true
      break
    end
    if not startsWith(d, EVENT_PREFIX) then
      needCelPass = true
      break
    end
  end
  if needCelPass then needTxn = true end

  if not needTxn then return end

  inEnforce = true
  app.transaction(function()
    if layer.data ~= EVENT_LAYER_METADATA then layer.data = EVENT_LAYER_METADATA end
    if layer.name ~= EVENT_LAYER_NAME then layer.name = EVENT_LAYER_NAME end
    if layer.isVisible ~= true then layer.isVisible = true end
    if layer.isEditable ~= false then layer.isEditable = false end

    if layer.parent ~= sprite then
      layer.parent = sprite
    end

    local top = #sprite.layers
    if layer.stackIndex ~= top then
      layer.stackIndex = top
    end

    local toDelete = {}
    for _, cel in ipairs(layer.cels) do
      local d = cel.data or ""
      if d == "" then
        toDelete[#toDelete+1] = cel
      end
    end

    for _, cel in ipairs(toDelete) do
      sprite:deleteCel(cel)
    end

    for _, cel in ipairs(layer.cels) do
      applyCelStyle(cel)
    end
  end)
  inEnforce = false
end

-- --------------------------
-- Commands
-- --------------------------

local function promptEventName()
  local p = prefs()
  local last = p.lastEventName or ""

  local dlg = Dialog(tr("add_title"))
  dlg:label{ text=tr("add_label") }
  dlg:entry{ id="name", text=last, focus=true }
  dlg:button{ id="ok", text=tr("btn_ok") }
  dlg:button{ id="cancel", text=tr("btn_cancel") }
  dlg:show()

  local d = dlg.data
  if not d.ok then return nil end

  local name = (d.name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then return nil end

  p.lastEventName = name
  return name
end

local function promptEditEventName(currentName)
  local p = prefs()
  local initial = currentName or p.lastEventName or ""

  local dlg = Dialog(tr("edit_title"))
  dlg:label{ text=tr("edit_label") }
  dlg:entry{ id="name", text=initial, focus=true }
  dlg:button{ id="save", text=tr("btn_save"), focus=true }
  dlg:button{ id="remove", text=tr("btn_remove") }
  dlg:button{ id="cancel", text=tr("btn_cancel") }
  dlg:show()

  local d = dlg.data
  if d.remove then
    return "remove", nil
  end
  if not d.save then
    return nil, nil
  end

  local name = (d.name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then
    return "remove", nil
  end

  p.lastEventName = name
  return "save", name
end

local function cmdEditActiveCelEvent()
  local sprite = app.activeSprite
  if not sprite then return false end

  local layer = findManagedLayer(sprite)
  if not layer or app.activeLayer ~= layer then return false end

  local frame = app.frame
  if not frame then return false end

  local frameNumber = frame.frameNumber
  local cel = layer:cel(frameNumber)
  local currentName = eventNameFromCelData(cel and cel.data or "")
  local action, name = promptEditEventName(currentName)
  if not action then return true end

  app.transaction(function()
    local target = layer:cel(frameNumber)
    if action == "remove" then
      if target then
        sprite:deleteCel(target)
      end
      return
    end

    target = ensureMarkerCel(sprite, layer, frameNumber)
    target.data = normalizeEventText(name)
    applyCelStyle(target)
  end)

  enforceManagedLayer(sprite)
  return true
end

local function cmdAdd()
  local sprite = app.activeSprite
  if not sprite then return end

  local frames = getSelectedFrameNumbers()
  if #frames == 0 then return end

  local raw = promptEventName()
  if not raw then return end
  local evText = normalizeEventText(raw)

  app.transaction(function()
    local layer = findManagedLayer(sprite)
    if not layer then
      layer = createManagedLayer(sprite) -- create only on first Add
    end

    if warnOnOverwrite() and anyEventsOnFrames(layer, frames) then
      local res = app.alert{
        title=PLUGIN_NAME,
        text=tr("overwrite_text"),
        buttons={ tr("btn_yes"), tr("btn_no") }
      }
      if res ~= 1 then return end
    end

    for _, fn in ipairs(frames) do
      local cel = ensureMarkerCel(sprite, layer, fn)
      cel.data = evText
      applyCelStyle(cel)
    end
  end)

  enforceManagedLayer(sprite)
end

local function cmdRemove()
  local sprite = app.activeSprite
  if not sprite then return end

  local layer = findManagedLayer(sprite)
  if not layer then return end

  local frames = getSelectedFrameNumbers()
  if #frames == 0 then return end

  enforceManagedLayer(sprite)

  app.transaction(function()
    for _, fn in ipairs(frames) do
      local cel = layer:cel(fn)
      if cel then
        sprite:deleteCel(cel)
      end
    end
  end)

  enforceManagedLayer(sprite)
end

local function tagStartFrameNumber(tag)
  if not tag then return nil end
  if type(tag.fromFrame) == "number" then
    return tonumber(tag.fromFrame)
  end
  if tag.fromFrame and tag.fromFrame.frameNumber then
    return tonumber(tag.fromFrame.frameNumber)
  end
  return nil
end

local function tagEndFrameNumber(tag)
  if not tag then return nil end
  if type(tag.toFrame) == "number" then
    return tonumber(tag.toFrame)
  end
  if tag.toFrame and tag.toFrame.frameNumber then
    return tonumber(tag.toFrame.frameNumber)
  end
  return nil
end

local function trimSpaces(s)
  s = tostring(s or "")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function legacyEventNameFromData(data)
  if type(data) ~= "string" or data == "" then return nil end

  local payload = nil
  if startsWith(data, "event:@event:") then
    payload = string.sub(data, #"event:@event:" + 1)
  elseif startsWith(data, "event:") and not startsWith(data, EVENT_PREFIX) then
    payload = string.sub(data, #"event:" + 1)
  else
    return nil
  end

  payload = trimSpaces(payload)
  if startsWith(payload, "@") then
    payload = string.sub(payload, 2)
  end
  payload = trimSpaces(payload)

  if payload == "" then return nil end
  return payload
end

local function cmdImportAtTags()
  local sprite = app.activeSprite
  if not sprite then return end

  local tags = sprite.tags
  local count = (tags and #tags) or 0
  if count == 0 then
    app.alert{ title=PLUGIN_NAME, text=tr("import_no_tags"), buttons={ tr("btn_ok") } }
    return
  end

  local imports = {}
  for i = 1, count do
    local tag = tags[i]
    local tagName = (tag and tag.name) or ""
    if startsWith(tagName, "@") then
      local eventName = tagName:sub(2):gsub("^%s+", ""):gsub("%s+$", "")
      local frameNumber = tagStartFrameNumber(tag)
      if eventName ~= "" and frameNumber and frameNumber >= 1 then
        imports[#imports+1] = {
          frameNumber = frameNumber,
          eventName = eventName,
          tag = tag
        }
      end
    end
  end

  if #imports == 0 then
    app.alert{ title=PLUGIN_NAME, text=tr("import_no_tags"), buttons={ tr("btn_ok") } }
    return
  end

  local deleteSourceTags = removeSourceAtTagsOnImport()

  app.transaction(function()
    local layer = findManagedLayer(sprite)
    if not layer then
      layer = createManagedLayer(sprite)
    end

    for _, item in ipairs(imports) do
      local cel = ensureMarkerCel(sprite, layer, item.frameNumber)
      cel.data = normalizeEventText(item.eventName)
      applyCelStyle(cel)
    end

    if deleteSourceTags then
      for _, item in ipairs(imports) do
        if item.tag then
          if sprite.deleteTag then
            sprite:deleteTag(item.tag)
          elseif item.tag.delete then
            item.tag:delete()
          end
        end
      end
    end
  end)

  enforceManagedLayer(sprite)

  app.alert{
    title=PLUGIN_NAME,
    text=tr("import_done", { count=#imports }) .. "\n" ..
         (deleteSourceTags and tr("import_done_removed") or tr("import_done_kept")),
    buttons={ tr("btn_ok") }
  }
end

local function cmdMigrateLegacyEventFormat()
  local sprite = app.activeSprite
  if not sprite then return end

  local layer = findManagedLayer(sprite)
  if not layer then
    app.alert{ title=PLUGIN_NAME, text=tr("migrate_no_layer"), buttons={ tr("btn_ok") } }
    return
  end

  local migrated = 0
  local alreadyCurrent = 0

  app.transaction(function()
    for _, cel in ipairs(layer.cels) do
      local data = cel.data or ""
      if data ~= "" then
        local legacyName = legacyEventNameFromData(data)
        if legacyName then
          cel.data = normalizeEventText(legacyName)
          applyCelStyle(cel)
          migrated = migrated + 1
        elseif startsWith(data, EVENT_PREFIX) then
          alreadyCurrent = alreadyCurrent + 1
        end
      end
    end
  end)

  enforceManagedLayer(sprite)

  if migrated == 0 then
    app.alert{ title=PLUGIN_NAME, text=tr("migrate_none"), buttons={ tr("btn_ok") } }
    return
  end

  local msg = tr("migrate_done", { count=migrated })
  if alreadyCurrent > 0 then
    msg = msg .. "\n" .. tr("migrate_skipped", { count=alreadyCurrent })
  end

  app.alert{ title=PLUGIN_NAME, text=msg, buttons={ tr("btn_ok") } }
end

local function collectDuplicateTagGroups(sprite)
  local tags = sprite and sprite.tags or nil
  local count = (tags and #tags) or 0
  local byName = {}

  for i = 1, count do
    local tag = tags[i]
    local name = (tag and tag.name) or ""
    byName[name] = byName[name] or {}
    byName[name][#byName[name] + 1] = tag
  end

  local groups = {}
  local duplicateNameCount = 0
  local duplicateTagCount = 0

  for name, tagList in pairs(byName) do
    if #tagList > 1 then
      duplicateNameCount = duplicateNameCount + 1
      duplicateTagCount = duplicateTagCount + #tagList
      groups[#groups + 1] = { name=name, tags=tagList }
    end
  end

  table.sort(groups, function(a, b)
    local an = string.lower(a.name or "")
    local bn = string.lower(b.name or "")
    if an == bn then return (a.name or "") < (b.name or "") end
    return an < bn
  end)

  return groups, duplicateNameCount, duplicateTagCount
end

local function makeTagNameUnique(baseName, used)
  local suffix = 1
  while true do
    local candidate = string.format("%s (%d)", baseName, suffix)
    if not used[candidate] then
      used[candidate] = true
      return candidate
    end
    suffix = suffix + 1
  end
end

local function confirmUniqueTagsDialog(duplicateNameCount, duplicateTagCount)
  local dlg = Dialog(PLUGIN_NAME)
  dlg:label{ text=tr("unique_found", { nameCount=duplicateNameCount, tagCount=duplicateTagCount }) }

  dlg:separator()
  dlg:label{ text=tr("unique_confirm") }
  dlg:button{ id="yes", text=tr("btn_yes") }
  dlg:button{ id="no", text=tr("btn_no") }
  dlg:show()
  local d = dlg.data
  return d and d.yes
end

local function cmdUniqueTags()
  local sprite = app.activeSprite
  if not sprite then return end

  local groups, duplicateNameCount, duplicateTagCount = collectDuplicateTagGroups(sprite)
  if duplicateNameCount == 0 then
    app.alert{ title=PLUGIN_NAME, text=tr("unique_no_duplicates"), buttons={ tr("btn_ok") } }
    return
  end

  if not confirmUniqueTagsDialog(duplicateNameCount, duplicateTagCount) then return end

  local renamedCount = 0

  app.transaction(function()
    local tags = sprite.tags
    local total = (tags and #tags) or 0
    local used = {}
    for i = 1, total do
      local t = tags[i]
      local name = (t and t.name) or ""
      used[name] = true
    end

    for _, group in ipairs(groups) do
      local baseName = group.name or ""
      for i = 2, #group.tags do
        local tag = group.tags[i]
        if tag then
          tag.name = makeTagNameUnique(baseName, used)
          renamedCount = renamedCount + 1
        end
      end
    end
  end)

  app.alert{
    title=PLUGIN_NAME,
    text=tr("unique_done", { renamedCount=renamedCount }),
    buttons={ tr("btn_ok") }
  }
end

local function cmdDeleteLayer()
  local sprite = app.activeSprite
  if not sprite then return end

  local layer = findManagedLayer(sprite)
  if not layer then return end

  local res = app.alert{
    title=PLUGIN_NAME,
    text=tr("delete_layer_text"),
    buttons={ tr("btn_delete"), tr("btn_cancel") }
  }
  if res ~= 1 then return end

  app.transaction(function()
    sprite:deleteLayer(layer)
  end)
end

local function closeSettingsPanel()
  if not settingsPanel then return end
  pcall(function() settingsPanelBounds = settingsPanel.bounds end)
  pcall(function() settingsPanel:close() end)
  settingsPanel = nil
end

local function openSettingsPanel()
  ensurePreferenceDefaults()
  local p = prefs()
  local configuredLanguage = configuredLanguageCode()
  if configuredLanguage ~= DEFAULT_UI_LANGUAGE then
    configuredLanguage = resolveLanguageCode(configuredLanguage)
  end

  local dlg = Dialog(tr("settings_title"))
  settingsPanel = dlg

  local function applyLive(shouldRebuildForLanguage)
    local beforeLanguage = configuredLanguageCode()
    local afterLanguage = applySettingsValues(dlg.data)
    if shouldRebuildForLanguage and normalizeLanguageCode(beforeLanguage) ~= normalizeLanguageCode(afterLanguage) then
      closeSettingsPanel()
      openSettingsPanel()
      return
    end
  end

  dlg:color{
    id="event",
    label=tr("settings_event_color"),
    color=eventColor(),
    onchange=function() applyLive(false) end
  }
  dlg:check{
    id="warnOnOverwrite",
    label=tr("settings_warn_overwrite"),
    selected=warnOnOverwrite(),
    onclick=function() applyLive(false) end
  }
  dlg:check{
    id="openEditorOnDoubleClick",
    label=tr("settings_double_click"),
    selected=openEditorOnDoubleClick(),
    onclick=function() applyLive(false) end
  }
  dlg:check{
    id="removeSourceAtTagsOnImport",
    label=tr("settings_remove_tags_after_import"),
    selected=removeSourceAtTagsOnImport(),
    onclick=function() applyLive(false) end
  }
  dlg:combobox{
    id="uiLanguage",
    label=tr("settings_language"),
    options=languageOptionLabels(),
    option=languageLabelForCode(configuredLanguage),
    onchange=function() applyLive(true) end
  }
  dlg:separator()
  dlg:label{ text=PRODUCT_CREDITS }
  dlg:button{
    id="reset",
    text=tr("btn_reset"),
    onclick=function()
      saveColor("eventColor", DEFAULT_EVENT_COLOR)
      p.warnOnOverwrite = DEFAULT_WARN_ON_OVERWRITE
      p.openEditorOnDoubleClick = DEFAULT_OPEN_EDITOR_ON_DOUBLE_CLICK
      p.removeSourceAtTagsOnImport = DEFAULT_REMOVE_SOURCE_AT_TAGS_ON_IMPORT
      p.uiLanguage = DEFAULT_UI_LANGUAGE
      enforceManagedLayer(app.activeSprite)
      closeSettingsPanel()
      openSettingsPanel()
    end
  }

  dlg:show{ wait=false }
  if settingsPanelBounds then
    pcall(function() dlg.bounds = settingsPanelBounds end)
  end
end

local function cmdSettings()
  closeSettingsPanel()
  openSettingsPanel()
end

local function countAnimationEventsInSprite(sprite)
  local layer = findManagedLayer(sprite)
  if not layer then return 0 end

  local count = 0
  for _, cel in ipairs(layer.cels) do
    local d = cel.data or ""
    if d ~= "" then
      count = count + 1
    end
  end
  return count
end

local function isDontImportLayer(layer)
  return layer and layer.data == DONT_IMPORT_LAYER_METADATA
end

local function applyDontImportLayerVisual(layer, enabled)
  if not layer then return end
  pcall(function()
    local targetOpacity = enabled and DONT_IMPORT_LAYER_OPACITY or 255
    if layer.opacity ~= targetOpacity then
      layer.opacity = targetOpacity
    end
  end)
  pcall(function()
    local targetColor = enabled and DONT_IMPORT_LAYER_COLOR or DONT_IMPORT_LAYER_RESET_COLOR
    if not colorEquals(layer.color, targetColor) then
      layer.color = targetColor
    end
  end)
end

local function enforceDontImportLayerVisuals(sprite)
  if not sprite then return end
  local all = {}
  iterLayersRecursive(sprite.layers, all)
  for _, layer in ipairs(all) do
    if isDontImportLayer(layer) then
      applyDontImportLayerVisual(layer, true)
    end
  end
end

local function cmdDontImportActiveLayer()
  local sprite = app.activeSprite
  local layer = app.activeLayer
  if not sprite or not layer then return end

  local managed = findManagedLayer(sprite)
  if layer == managed then return end

  app.transaction(function()
    layer.data = DONT_IMPORT_LAYER_METADATA
    applyDontImportLayerVisual(layer, true)
  end)
end

local function promptAllowImportAgain(layer)
  local res = app.alert{
    title=PLUGIN_NAME,
    text=tr("dont_import_info"),
    buttons={ tr("btn_yes"), tr("btn_no") }
  }
  if res ~= 1 then return end

  app.transaction(function()
    if layer.data == DONT_IMPORT_LAYER_METADATA then
      layer.data = ""
    end
    applyDontImportLayerVisual(layer, false)
  end)
end

local function cmdManagedLayerInfo()
  local eventCount = countAnimationEventsInSprite(app.activeSprite)
  app.alert{
    title=PLUGIN_NAME,
    text=tr("managed_layer_info") .. "\n" .. tr("managed_layer_info_count", { count=eventCount }),
    buttons={ tr("btn_ok") }
  }
end

-- --------------------------
-- Unity Aseprite Importer detection
-- --------------------------

local function fsIsFile(path)
  if type(path) ~= "string" or path == "" or not app or not app.fs then return false end
  local ok, result = pcall(function() return app.fs.isFile(path) end)
  return ok and result == true
end

local function fsIsDirectory(path)
  if type(path) ~= "string" or path == "" or not app or not app.fs then return false end
  local ok, result = pcall(function() return app.fs.isDirectory(path) end)
  return ok and result == true
end

local function fsFileSize(path)
  if not fsIsFile(path) then return nil end
  local ok, result = pcall(function() return app.fs.fileSize(path) end)
  if not ok then return nil end
  return tonumber(result)
end

local function fsNormalizePath(path)
  if type(path) ~= "string" or path == "" or not app or not app.fs then return nil end
  local ok, result = pcall(function() return app.fs.normalizePath(path) end)
  if not ok or type(result) ~= "string" or result == "" then return nil end
  return result
end

local function fsJoinPath(...)
  if not app or not app.fs then return nil end
  local parts = { ... }
  local result = parts[1]
  if type(result) ~= "string" or result == "" then return nil end
  for index = 2, #parts do
    local base = result
    local part = parts[index]
    local ok, joined = pcall(function() return app.fs.joinPath(base, part) end)
    if not ok or type(joined) ~= "string" or joined == "" then return nil end
    result = joined
  end
  return fsNormalizePath(result) or result
end

local function fsFilePath(path)
  local ok, result = pcall(function() return app.fs.filePath(path) end)
  if not ok then return nil end
  return fsNormalizePath(result)
end

local function fsFileExtension(path)
  local ok, result = pcall(function() return app.fs.fileExtension(path) end)
  if not ok or type(result) ~= "string" then return "" end
  return result:lower()
end

local function fsFileName(path)
  local ok, result = pcall(function() return app.fs.fileName(path) end)
  if not ok or type(result) ~= "string" or result == "" then return path end
  return result
end

local function comparablePath(path)
  local normalized = fsNormalizePath(path)
  if not normalized then return nil end
  if app.fs.pathSeparator == "\\" then
    return normalized:lower()
  end
  return normalized
end

local function pathIsInside(path, directory)
  local candidate = comparablePath(path)
  local parent = comparablePath(directory)
  if not candidate or not parent then return false end
  if candidate == parent then return true end
  local separator = app.fs.pathSeparator or "/"
  return candidate:sub(1, #parent + 1) == parent .. separator
end

local function isUnityProjectRoot(directory)
  return fsIsDirectory(fsJoinPath(directory, "Assets"))
    and fsIsFile(fsJoinPath(directory, "Packages", "manifest.json"))
    and fsIsFile(fsJoinPath(directory, "ProjectSettings", "ProjectVersion.txt"))
end

local function findUnityProjectRoot(filename)
  local normalizedFilename = fsNormalizePath(filename)
  local directory = normalizedFilename and fsFilePath(normalizedFilename) or nil
  local steps = 0

  while directory and steps < 256 do
    if isUnityProjectRoot(directory) then
      local assetsDirectory = fsJoinPath(directory, "Assets")
      local packagesDirectory = fsJoinPath(directory, "Packages")
      if pathIsInside(normalizedFilename, assetsDirectory)
        or pathIsInside(normalizedFilename, packagesDirectory)
      then
        return directory
      end
    end

    local parent = fsFilePath(directory)
    if not parent or comparablePath(parent) == comparablePath(directory) then break end
    directory = parent
    steps = steps + 1
  end

  return nil
end

local function readTextFile(path)
  if not fsIsFile(path) then return nil, "missing" end
  if not io or type(io.open) ~= "function" then return nil, "unavailable" end
  local opened, file = pcall(function() return io.open(path, "rb") end)
  if not opened or not file then return nil, "unreadable" end
  local readOk, contents = pcall(function() return file:read("*a") end)
  pcall(function() file:close() end)
  if not readOk or type(contents) ~= "string" then return nil, "unreadable" end
  return contents, "ok"
end

local function decodeJson(contents)
  if not json or type(json.decode) ~= "function" then return nil, false end
  local ok, decoded = pcall(function() return json.decode(contents) end)
  if not ok or decoded == nil then return nil, true end
  return decoded, true
end

local function jsonFileHasDependency(path)
  local contents, readStatus = readTextFile(path)
  if not contents then return false, readStatus end

  local decoded, decoderAvailable = decodeJson(contents)
  if decoderAvailable then
    if not decoded then return false, "invalid" end
    local ok, found = pcall(function()
      return decoded.dependencies[UNITY_ASEPRITE_PACKAGE_ID] ~= nil
    end)
    if not ok then return false, "invalid" end
    return found == true, "ok"
  end

  return contents:find('"' .. UNITY_ASEPRITE_PACKAGE_ID .. '"', 1, true) ~= nil, "ok"
end

local function jsonFileHasPackageName(path)
  local contents, readStatus = readTextFile(path)
  if not contents then return false, readStatus end

  local decoded, decoderAvailable = decodeJson(contents)
  if decoderAvailable then
    if not decoded then return false, "invalid" end
    local ok, found = pcall(function()
      return decoded.name == UNITY_ASEPRITE_PACKAGE_ID
    end)
    if not ok then return false, "invalid" end
    return found == true, "ok"
  end

  local escapedId = UNITY_ASEPRITE_PACKAGE_ID:gsub("([^%w])", "%%%1")
  return contents:match('"name"%s*:%s*"' .. escapedId .. '"') ~= nil, "ok"
end

local function unityProjectHasAsepriteImporter(projectRoot)
  local projectKey = comparablePath(projectRoot) or projectRoot
  local packagesDirectory = fsJoinPath(projectRoot, "Packages")
  local embeddedPackage = fsJoinPath(
    packagesDirectory,
    UNITY_ASEPRITE_PACKAGE_ID,
    "package.json"
  )
  local lockFile = fsJoinPath(packagesDirectory, "packages-lock.json")
  local manifestFile = fsJoinPath(packagesDirectory, "manifest.json")

  local sourcePath = manifestFile
  local sourceKind = "dependencies"
  if fsIsFile(embeddedPackage) then
    sourcePath = embeddedPackage
    sourceKind = "package"
  elseif fsIsFile(lockFile) then
    sourcePath = lockFile
  end

  local sourceKey = comparablePath(sourcePath) or sourcePath
  local sourceSize = fsFileSize(sourcePath)
  local cached = unityProjectImporterCache[projectKey]
  if cached
    and cached.sourceKey == sourceKey
    and cached.sourceSize == sourceSize
  then
    return cached.installed
  end

  local installed, readStatus
  if sourceKind == "package" then
    installed, readStatus = jsonFileHasPackageName(sourcePath)
  else
    installed, readStatus = jsonFileHasDependency(sourcePath)
  end
  if readStatus ~= "invalid" then
    unityProjectImporterCache[projectKey] = {
      installed = installed,
      sourceKey = sourceKey,
      sourceSize = sourceSize,
    }
  end
  return installed
end

local function unityImporterContext(sprite)
  if not sprite then return nil, "not_candidate" end
  local ok, filename = pcall(function() return sprite.filename end)
  if not ok or type(filename) ~= "string" or filename == "" then
    return nil, "not_candidate"
  end

  filename = fsNormalizePath(filename)
  if not filename then return nil, "not_candidate" end
  local extension = fsFileExtension(filename)
  if extension ~= "ase" and extension ~= "aseprite" then
    return nil, "not_candidate"
  end
  if not fsIsFile(filename) then return nil, "missing_file" end
  if not fsIsFile(filename .. ".meta") then return nil, "missing_meta" end

  local projectRoot = findUnityProjectRoot(filename)
  if not projectRoot then return nil, "not_candidate" end
  if not unityProjectHasAsepriteImporter(projectRoot) then
    return nil, "importer_missing"
  end
  return {
    filename = filename,
    displayFilename = fsFileName(filename),
    projectRoot = projectRoot,
  }, nil
end

local function updateUnityImporterNotice(sprite)
  if sprite ~= app.sprite then return false, "inactive" end
  local context, reason = unityImporterContext(sprite)
  if not context then
    lastUnityImporterNoticeKey = nil
    return false, reason
  end

  local key = context.filename .. "\0" .. context.projectRoot
  if lastUnityImporterNoticeKey == key then return true, nil end

  if app.isUIAvailable == false or type(app.tip) ~= "function" then
    return false, "notice_unavailable"
  end
  local shown = pcall(function()
    app.tip(
      tr("unity_importer_active", { filename=context.displayFilename }),
      UNITY_IMPORTER_TIP_SECONDS
    )
  end)
  if shown then
    lastUnityImporterNoticeKey = key
    return true, nil
  end
  return false, "notice_failed"
end

local function stopUnityImporterRetry()
  if not unityImporterRetryTimer then return end
  pcall(function() unityImporterRetryTimer:stop() end)
  unityImporterRetryTimer = nil
end

local function scheduleUnityImporterRetry(sprite, reason)
  stopUnityImporterRetry()
  if reason ~= "missing_file"
    and reason ~= "missing_meta"
    and reason ~= "importer_missing"
  then
    return
  end
  if Timer == nil then return end

  local ok, timer = pcall(function()
    return Timer{
      interval=UNITY_IMPORTER_RETRY_SECONDS,
      ontick=function()
        stopUnityImporterRetry()
        if pluginRef and sprite == app.sprite then
          updateUnityImporterNotice(sprite)
        end
      end
    }
  end)
  if not ok or not timer then return end
  unityImporterRetryTimer = timer
  pcall(function() unityImporterRetryTimer:start() end)
end

-- --------------------------
-- Event wiring
-- --------------------------

local function onBeforeCommand(ev)
  -- If user tries to delete the managed layer through the normal command, intercept and show the same confirmation.
  local sprite = app.activeSprite
  if not sprite then return end
  local activeLayer = app.activeLayer

  if activeLayer and isDontImportLayer(activeLayer) and ev and ev.name == "LayerProperties" and ev.stopPropagation then
    ev:stopPropagation()
    promptAllowImportAgain(activeLayer)
    return
  end

  local managed = findManagedLayer(sprite)

  if managed and activeLayer == managed and ev and ev.name == "RemoveLayer" and ev.stopPropagation then
    ev:stopPropagation()
    cmdDeleteLayer()
    return
  end

  if managed and activeLayer == managed and ev and ev.name == "LayerProperties" and ev.stopPropagation then
    ev:stopPropagation()
    cmdManagedLayerInfo()
    return
  end

  if managed and openEditorOnDoubleClick() and activeLayer == managed and ev and ev.name == "CelProperties" and ev.stopPropagation then
    ev:stopPropagation()
    cmdEditActiveCelEvent()
  end
end

local function onAfterCommand(ev)
  enforceManagedLayer(app.activeSprite)
end

local function findSpriteEventEntry(sprite)
  for _, entry in ipairs(spriteEventListeners) do
    if entry.sprite == sprite then return entry end
  end
  return nil
end

local function addSpriteEventListener(entry, eventName, callback)
  local ok, code = pcall(function()
    return entry.events:on(eventName, callback)
  end)
  if not ok then return end
  entry.listeners[#entry.listeners+1] = {
    code = code,
    callback = callback,
  }
end

local function attachSpriteEvents(sprite)
  if not sprite or not sprite.events or findSpriteEventEntry(sprite) then return end
  local entry = {
    sprite = sprite,
    events = sprite.events,
    listeners = {},
  }
  spriteEventListeners[#spriteEventListeners+1] = entry

  addSpriteEventListener(entry, "change", function(ev)
    if pluginRef then enforceManagedLayer(sprite) end
  end)
  addSpriteEventListener(entry, "layervisibility", function(ev)
    if pluginRef then enforceManagedLayer(sprite) end
  end)
  addSpriteEventListener(entry, "layername", function(ev)
    if pluginRef then enforceManagedLayer(sprite) end
  end)
  addSpriteEventListener(entry, "filenamechange", function(ev)
    if pluginRef and sprite == app.sprite then
      local _, reason = updateUnityImporterNotice(sprite)
      scheduleUnityImporterRetry(sprite, reason)
    end
  end)
end

local function detachSpriteEvents()
  for _, entry in ipairs(spriteEventListeners) do
    for _, listener in ipairs(entry.listeners) do
      pcall(function()
        entry.events:off(listener.code or listener.callback)
      end)
    end
  end
  spriteEventListeners = {}
end

local function onSiteChange()
  if prevSprite ~= app.sprite then
    stopUnityImporterRetry()
    detachSpriteEvents()
    prevSprite = app.sprite
    if prevSprite then
      attachSpriteEvents(prevSprite)
      enforceManagedLayer(prevSprite)
    end
    local _, reason = updateUnityImporterNotice(prevSprite)
    scheduleUnityImporterRetry(prevSprite, reason)
  end
end

-- --------------------------
-- Plugin lifecycle + menus
-- --------------------------

function init(plugin)
  stopUnityImporterRetry()
  detachSpriteEvents()
  pluginRef = plugin
  prevSprite = nil
  lastUnityImporterNoticeKey = nil
  unityProjectImporterCache = {}

  ensurePreferenceDefaults()

  plugin:newCommand{
    id=CMD_ADD,
    title=tr("cmd_add"),
    group="cel_popup_properties",
    onclick=cmdAdd,
    onenabled=function() return app.activeSprite ~= nil end
  }

  plugin:newCommand{
    id=CMD_EDIT,
    title=tr("cmd_edit"),
    group="cel_popup_properties",
    onclick=cmdEditActiveCelEvent,
    onenabled=function()
      local s = app.activeSprite
      local managed = findManagedLayer(s)
      return s ~= nil and managed ~= nil and app.activeLayer == managed and app.frame ~= nil
    end
  }

  plugin:newCommand{
    id=CMD_REMOVE,
    title=tr("cmd_remove"),
    group="cel_popup_properties",
    onclick=cmdRemove,
    onenabled=function()
      local s = app.activeSprite
      local layer = findManagedLayer(s)
      return s ~= nil and layer ~= nil and anyEventsOnFrames(layer, getSelectedFrameNumbers())
    end
  }

  plugin:newCommand{
    id=CMD_ADD.."_Frame",
    title=tr("cmd_add"),
    group="frame_popup_properties",
    onclick=cmdAdd,
    onenabled=function() return app.activeSprite ~= nil end
  }

  plugin:newCommand{
    id=CMD_EDIT.."_Frame",
    title=tr("cmd_edit"),
    group="frame_popup_properties",
    onclick=cmdEditActiveCelEvent,
    onenabled=function()
      local s = app.activeSprite
      local managed = findManagedLayer(s)
      return s ~= nil and managed ~= nil and app.activeLayer == managed and app.frame ~= nil
    end
  }

  plugin:newCommand{
    id=CMD_REMOVE.."_Frame",
    title=tr("cmd_remove"),
    group="frame_popup_properties",
    onclick=cmdRemove,
    onenabled=function()
      local s = app.activeSprite
      local layer = findManagedLayer(s)
      return s ~= nil and layer ~= nil and anyEventsOnFrames(layer, getSelectedFrameNumbers())
    end
  }

  plugin:newCommand{
    id=CMD_DELETE_LAYER,
    title=tr("cmd_delete_layer"),
    group="layer_popup_properties",
    onclick=cmdDeleteLayer,
    onenabled=function()
      local s = app.activeSprite
      local managed = findManagedLayer(s)
      return managed ~= nil and app.activeLayer == managed
    end
  }

  plugin:newCommand{
    id=CMD_DONT_IMPORT_LAYER,
    title=tr("cmd_dont_import_layer"),
    group="layer_popup_properties",
    onclick=cmdDontImportActiveLayer,
    onenabled=function()
      local s = app.activeSprite
      local layer = app.activeLayer
      if not s or not layer then return false end
      local managed = findManagedLayer(s)
      if layer == managed then return false end
      return not isDontImportLayer(layer)
    end
  }

  plugin:newCommand{
    id=CMD_DELETE_LAYER.."_File",
    title=tr("cmd_delete_layer"),
    group="file_scripts",
    onclick=cmdDeleteLayer,
    onenabled=function()
      return findManagedLayer(app.activeSprite) ~= nil
    end
  }

  plugin:newCommand{
    id=CMD_EDIT.."_File",
    title=tr("cmd_edit"),
    group="file_scripts",
    onclick=cmdEditActiveCelEvent,
    onenabled=function()
      local s = app.activeSprite
      local managed = findManagedLayer(s)
      return s ~= nil and managed ~= nil and app.activeLayer == managed and app.frame ~= nil
    end
  }

  plugin:newCommand{
    id=CMD_IMPORT_TAGS,
    title=tr("cmd_import_tags"),
    group="file_scripts",
    onclick=cmdImportAtTags,
    onenabled=function() return app.activeSprite ~= nil end
  }

  plugin:newCommand{
    id=CMD_UNIQUE_TAGS,
    title=tr("cmd_unique_tags"),
    group="file_scripts",
    onclick=cmdUniqueTags,
    onenabled=function() return app.activeSprite ~= nil end
  }

  plugin:newCommand{
    id=CMD_MIGRATE_LEGACY,
    title=tr("cmd_migrate_legacy"),
    group="file_scripts",
    onclick=cmdMigrateLegacyEventFormat,
    onenabled=function()
      local s = app.activeSprite
      return s ~= nil and findManagedLayer(s) ~= nil
    end
  }

  plugin:newCommand{
    id=CMD_SETTINGS,
    title=tr("cmd_settings"),
    group="file_scripts",
    onclick=cmdSettings
  }

  plugin:newCommand{
    id=CMD_SETTINGS.."_Cel",
    title=tr("cmd_settings"),
    group="cel_popup_properties",
    onclick=cmdSettings,
    onenabled=function() return app.activeSprite ~= nil end
  }

  plugin:newCommand{
    id=CMD_SETTINGS.."_Frame",
    title=tr("cmd_settings"),
    group="frame_popup_properties",
    onclick=cmdSettings,
    onenabled=function() return app.activeSprite ~= nil end
  }

  plugin:newCommand{
    id=CMD_SETTINGS.."_Layer",
    title=tr("cmd_settings"),
    group="layer_popup_properties",
    onclick=cmdSettings,
    onenabled=function() return app.activeSprite ~= nil end
  }

  if app and app.events then
    pcall(function() app.events:off(onSiteChange) end)
    pcall(function() app.events:off(onBeforeCommand) end)
    app.events:on("sitechange", onSiteChange)
    app.events:on("beforecommand", onBeforeCommand)
  end

  if app.sprite then onSiteChange() end
end

function exit(plugin)
  closeSettingsPanel()
  stopUnityImporterRetry()
  detachSpriteEvents()
  if app and app.events then
    pcall(function() app.events:off(onSiteChange) end)
    pcall(function() app.events:off(onBeforeCommand) end)
  end
  prevSprite = nil
  lastUnityImporterNoticeKey = nil
  unityProjectImporterCache = {}
  pluginRef = nil
end
