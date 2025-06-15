-- date_resolver.lua

--[[
SOURCE_THESE_VIMS_START
" lua
let @h="yoprint(string.format('\<c-r>\" = %s', vim.inspect(\<c-r>\")))\<esc>j"

nnoremap <leader>ne <cmd>lua R('jerry.date_resolver').run_tests()<cr>

echom 'Sourced'
SOURCE_THESE_VIMS_END timestamp
--]]

local M = {}

-- Helper map for weekday characters to os.date %w (1=Sun, 2=Mon, ..., 7=Sat)
local day_char_to_wday = {
  u = 1, m = 2, t = 3, w = 4, h = 5, f = 6, s = 7,
}
-- Seconds in a day
local seconds_per_day = 24 * 60 * 60

--- Resolves a date pattern relative to a reference timestamp.
---
---@param reference_time number | nil The reference Unix timestamp (seconds since epoch). Defaults to os.time().
---@param pattern string The date pattern string to resolve.
---@return string The resolved date as a 'YYYY-MM-DD' string, or '' if the pattern is invalid or resolution fails.
function M.resolve_date_pattern(reference_time, pattern)
  -- Default to current time if none provided
  reference_time = reference_time or os.time()
  pattern = tostring(pattern or "")

  -- Get reference date components table. Set time to noon to avoid DST issues.
  local ref_date_tbl = os.date("*t", reference_time)
  ref_date_tbl.hour = 12
  ref_date_tbl.min = 0
  ref_date_tbl.sec = 0
  -- Recalculate timestamp normalized to noon
  ---@cast ref_date_tbl osdate
  reference_time = os.time(ref_date_tbl)
  if not reference_time then
    return ''
  end

  local result_time = nil -- Store the calculated timestamp

  -- Declare pattern-matching variables *before* the conditional blocks
  local y, m, d
  local sign_mmdd, mm, dd
  local sign_days, num_days_str
  local sign_wd, num_weeks_str, day_char

  -- Pattern: YYYYMMDD (e.g., 20240505)
  y, m, d = pattern:match("^(%d%d%d%d)(%d%d)(%d%d)$")
  if y then
    local tbl = {
      year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12,
    }
    if tbl.month >= 1 and tbl.month <= 12 and tbl.day >= 1 and tbl.day <= 31 then
      result_time = os.time(tbl)
    end
    goto format_result
  end

  -- Pattern: [+-]MMDD (e.g., 0406, -0406)
  sign_mmdd, mm, dd = pattern:match("^([%+%-]?)(%d%d)(%d%d)$")
  if mm then
    local year_offset = (sign_mmdd == "-") and -1 or 0
    local target_mm = tonumber(mm)
    local target_dd = tonumber(dd)

    if target_mm >= 1 and target_mm <= 12 and target_dd >= 1 and target_dd <= 31 then
      local tbl = {
        year = ref_date_tbl.year + year_offset,
        month = target_mm,
        day = target_dd,
        hour = 12,
      }
      local initial_time = os.time(tbl)

      -- Handle ambiguity for MMDD without sign: if date is in the past, assume next year
      if sign_mmdd == "" and initial_time and initial_time < reference_time then
         tbl.year = tbl.year + 1
         -- Use a temp table to check validity without modifying tbl if os.time fails
         local temp_tbl = {year=tbl.year, month=tbl.month, day=tbl.day, hour=12}
         result_time = os.time(temp_tbl) -- Recalculate for next year
      else
         result_time = initial_time
      end
    end
    goto format_result
  end

  -- Pattern: [+-]N (days offset, 1-3 digits) (e.g., 1, -2, +15)
  sign_days, num_days_str = pattern:match("^([+-]?)(%d%d?%d?)$")
  if num_days_str then
    local multiplier = (sign_days == "-") and -1 or 1
    local offset_seconds = multiplier * tonumber(num_days_str) * seconds_per_day
    result_time = reference_time + offset_seconds
    goto format_result
  end

  -- Pattern: [+-][N]D (weekday offset) (e.g., m, -f, 2m, -1u)
  sign_wd, num_weeks_str, day_char =
    pattern:match("^([%+%-]?)(%d*)([mtwhfsu])$")
  if day_char then
    local target_wday = day_char_to_wday[day_char]
    if target_wday then -- Check if day_char was valid
      local ref_wday = ref_date_tbl.wday -- 1=Sun, 2=Mon, ..., 7=Sat
      local num_weeks = tonumber(num_weeks_str) or 0
      local multiplier = (sign_wd == "-") and -1 or 1
      local offset_days = 0
      local day_diff = target_wday - ref_wday

      if multiplier == 1 then -- Positive offset: Find next >= ref_date
        offset_days = (day_diff < 0) and (day_diff + 7) or day_diff
        offset_days = offset_days + (num_weeks * 7)
      else -- Negative offset: Find previous <= ref_date
        -- 1. Base offset to most recent occurrence <= ref_date
        local base_offset_days = (day_diff > 0) and (day_diff - 7) or day_diff
        -- 2. Weeks to subtract based on N and whether ref_wday == target_wday
        local weeks_to_subtract = 0
        if ref_wday == target_wday then
          weeks_to_subtract = num_weeks
        elseif num_weeks > 0 then
          weeks_to_subtract = num_weeks - 1
        end
        offset_days = base_offset_days - (weeks_to_subtract * 7)
      end
      result_time = reference_time + offset_days * seconds_per_day
    end
    -- No goto here, it's the last pattern check
  end

  ::format_result::
  -- Format the final result or return empty string
  if result_time then
    local formatted_date = os.date("%Y-%m-%d", result_time)
    -- formatted_date is string|nil. If nil, return ''. Otherwise return the string.
    --- @cast formatted_date string -- Tell linter to trust us here
    return formatted_date or ''
  else
    -- result_time was nil (pattern invalid or os.time failed)
    return ''
  end
end


--- Helper function to run tests similar to the PowerShell examples.
function M.run_tests()
  print("------------------------------------------")
  local tests = {
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "20240505", expected = "2024-05-05" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "20250505", expected = "2025-05-05" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-0406",    expected = "2024-04-06" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "0406",     expected = "2025-04-06" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "1",        expected = "2025-04-01" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "2",        expected = "2025-04-02" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-1",       expected = "2025-03-30" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-2",       expected = "2025-03-29" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "m",        expected = "2025-03-31" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "t",        expected = "2025-04-01" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "w",        expected = "2025-04-02" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "h",        expected = "2025-04-03" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "f",        expected = "2025-04-04" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "s",        expected = "2025-04-05" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "u",        expected = "2025-04-06" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-u",       expected = "2025-03-30" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-2m",      expected = "2025-03-17" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-1m",      expected = "2025-03-24" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-m",       expected = "2025-03-31" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "m",        expected = "2025-03-31" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "1m",       expected = "2025-04-07" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "2m",       expected = "2025-04-14" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "20240505", expected = "2024-05-05" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "20250505", expected = "2025-05-05" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-0406",    expected = "2024-04-06" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "0406",     expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "1",        expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "2",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-1",       expected = "2025-04-04" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-2",       expected = "2025-04-03" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "m",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "t",        expected = "2025-04-08" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "w",        expected = "2025-04-09" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "h",        expected = "2025-04-10" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "f",        expected = "2025-04-11" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "s",        expected = "2025-04-05" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "u",        expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-u",       expected = "2025-03-30" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-2m",      expected = "2025-03-24" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-1m",      expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-m",       expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "m",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "1m",       expected = "2025-04-14" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "2m",       expected = "2025-04-21" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "20240505", expected = "2024-05-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "20250505", expected = "2025-05-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-0406",    expected = "2024-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "0406",     expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "1",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "2",        expected = "2025-04-08" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-1",       expected = "2025-04-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-2",       expected = "2025-04-04" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "m",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "t",        expected = "2025-04-08" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "w",        expected = "2025-04-09" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "h",        expected = "2025-04-10" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "f",        expected = "2025-04-11" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "s",        expected = "2025-04-12" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "u",        expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-u",       expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-2m",      expected = "2025-03-24" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-1m",      expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-m",       expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "m",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "1m",       expected = "2025-04-14" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "2m",       expected = "2025-04-21" },
  }

  local all_passed = true
  local msgs = {}
  for i, test in ipairs(tests) do
    local ref_time = os.time(test.reference)
    if not ref_time then
      table.insert(msgs, string.format("[%02d] Reference: INVALID    | Pattern: %-10s | FAILED (Invalid Ref Date)", i, test.subject))
      all_passed = false
      goto continue_loop -- Using goto just within the test runner is fine
    end
    local ref_date_str = os.date("%Y-%m-%d", ref_time)
    local resolved_date = M.resolve_date_pattern(ref_time, test.subject)
    local passed = resolved_date == test.expected
    if not passed then
      all_passed = false
    end
    table.insert(msgs, string.format(
      "[%02d] Reference: %-10s | Pattern: %-10s | Expected: %-10s | Resolved: %-10s | %s",
      i,
      ref_date_str,
      test.subject,
      test.expected,
      resolved_date or "nil", -- Use 'nil' here for display if somehow it happens
      passed and "" or "FAIL"
    ))
    ::continue_loop::
  end

  table.insert(msgs, "------------------------------------------")
  if all_passed then
    table.insert(msgs, "All tests passed.")
  else
    table.insert(msgs, "Some tests failed.")
  end
  table.insert(msgs, "------------------------------------------")

  local formatted = table.concat(msgs, "\n")
  print(formatted)
  -- Optional: Write to file
  local f = io.open('./result', 'w')
  if f then
    f:write(formatted)
    f:close()
  else
    print("Error: Could not open out.txt for writing.")
  end
end

return M

