-- Course-note apparatus shared by the standalone session PDFs and handbook.
-- HTML keeps the authored spans: notes-chapter.html uses them for accessible
-- glossary and footnote popovers. LaTeX turns glossary terms bold and writes
-- both glossary and explanatory-footnote terms to the handbook index.

local function has_class(el, wanted)
  for _, class in ipairs(el.classes) do
    if class == wanted then return true end
  end
  return false
end

local function index_text(el)
  local authored = el.attributes["data-index"]
  if authored and authored ~= "" then return authored end
  return pandoc.utils.stringify(el.content)
end

local glossary_targets_seen = {}

local function glossary_key(el)
  local key = el.attributes["data-term"]
  if not key or key == "" then return nil end
  return key:gsub("[^%w%-]", "-"):lower()
end

local function latex_index_escape(value)
  -- Index terms in these notes are prose, not math. These replacements cover
  -- the characters that makeidx treats specially while preserving en dashes
  -- and accented names for the Unicode LaTeX engine used by Quarto.
  return value
    :gsub("\\", "\\textbackslash{}")
    :gsub("([%%#$&_{}])", "\\%1")
    :gsub("!", '"!')
    :gsub("@", '"@')
    :gsub("|", '"|')
end

local solutions_document = false
local solutions_companion = false
local course_handbook = false

local function read_metadata(meta)
  solutions_document = meta["solutions-document"] ~= nil
  solutions_companion = meta["solutions-companion"] ~= nil
  course_handbook = meta["course-handbook"] ~= nil
  return nil
end

local function transform_div(el)
  -- The website keeps the collapsible hints and solutions beside each
  -- exercise. The main notes and course handbook PDFs omit those blocks; the
  -- same source is expanded only in the dedicated solutions PDF.
  if FORMAT:match("latex") and has_class(el, "solution-material")
      and not solutions_document then
    return {}
  end

  -- The companion-PDF notice belongs in the standalone session notes, not in
  -- the aggregated handbook or in the companion itself.
  if has_class(el, "solutions-companion") and not solutions_companion then
    return {}
  end

  -- A term introduced in an earlier session keeps its fuller definition in
  -- the later standalone session glossary. In the handbook, the earlier
  -- course definition is already present, so omit only the repeated entry.
  -- This lets glossary.qmd remain the single authored source for Session 2.
  if course_handbook and has_class(el, "course-glossary-duplicate") then
    return {}
  end

  return nil
end

-- Hints and solutions are Quarto callouts so that the website can collapse
-- them. In LaTeX a callout becomes a breakable tcolorbox, and a code listing
-- or long table nested inside it cannot break with the box: the listing is
-- clipped at the foot of the page and a table is pushed to the next one,
-- leaving half-empty pages. The solutions PDF therefore prints each hint and
-- solution as ordinary text under its label.
local exercise_callout_classes = {
  ["exercise-hint"] = true,
  ["exercise-solution"] = true
}

local function unwrap_exercise_callout(el)
  if not (FORMAT:match("latex") and solutions_document) then return nil end
  local classes = (el.attr and el.attr.classes) or el.classes or {}
  local is_exercise = false
  for _, class in ipairs(classes) do
    if exercise_callout_classes[class] then is_exercise = true end
  end
  if not is_exercise then return nil end

  local label = el.title and pandoc.utils.stringify(el.title) or ""
  local blocks = {
    pandoc.RawBlock("latex",
      "\\par\\addvspace{\\medskipamount}\\noindent " ..
      label:gsub("([%%#$&_{}])", "\\%1") .. "\\par\\nopagebreak")
  }
  -- Quarto 1.10 stores a callout's body as one Div block; older versions
  -- used a list of blocks.
  if pandoc.utils.type(el.content) == "Block" then
    table.insert(blocks, el.content)
  else
    for _, block in ipairs(el.content) do table.insert(blocks, block) end
  end
  return pandoc.Div(blocks, pandoc.Attr("", { "exercise-printed" }))
end

local function transform_span(el)
  if not FORMAT:match("latex") then return nil end

  local is_glossary = has_class(el, "glossary-term")
  local is_glossary_head = has_class(el, "glossary-head")
  local is_footnote = has_class(el, "footnote-term")
  if not is_glossary and not is_glossary_head and not is_footnote then
    return nil
  end

  local key = glossary_key(el)

  if is_glossary_head then
    if not key or glossary_targets_seen[key] then return nil end
    glossary_targets_seen[key] = true
    local target = pandoc.RawInline(
      "latex", "\\hypertarget{glossary-" .. key .. "}{}"
    )
    local content = { target }
    for _, inline in ipairs(el.content) do table.insert(content, inline) end
    return content
  end

  local content = el.content
  if is_glossary then
    local linked = {}
    if key then
      table.insert(linked, pandoc.RawInline(
        "latex", "\\hyperlink{glossary-" .. key .. "}{"
      ))
    end
    table.insert(linked, pandoc.Strong(content))
    if key then table.insert(linked, pandoc.RawInline("latex", "}")) end
    content = linked
  end

  table.insert(content, pandoc.RawInline(
    "latex",
    "\\index{" .. latex_index_escape(index_text(el)) .. "}"
  ))
  return content
end

return {
  { Meta = read_metadata },
  { Div = transform_div, Span = transform_span,
    Callout = unwrap_exercise_callout }
}
