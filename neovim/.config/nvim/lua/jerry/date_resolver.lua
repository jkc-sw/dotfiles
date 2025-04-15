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

-- Helper map for weekday characters to os.date %w (0=Sun, 1=Mon, ..., 6=Sat)
local day_char_to_wday = {
  m = 2, t = 3, w = 4, h = 5, f = 6, s = 7, u = 1,
}
-- Seconds in a day
local seconds_per_day = 24 * 60 * 60

--- Resolves a date pattern relative to a reference timestamp.
---
---@param reference_time number | nil The reference Unix timestamp (seconds since epoch). Defaults to os.time().
---@param pattern string The date pattern string to resolve.
---@return string | nil The resolved date as a 'YYYY-MM-DD' string, or nil if the pattern is invalid.
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
    error("Could not normalize reference time.")
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
    result_time = os.time(tbl)
    goto format_result -- Use goto for early exit after match
  end

  -- Pattern: [+-]MMDD (e.g., 0406, -0406)
  -- Matches MM followed by DD, optionally preceded by + or -
  sign_mmdd, mm, dd = pattern:match("^([%+%-]?)(%d%d)(%d%d)$")
  -- Check 'mm' specifically, as 'y' check already happened
  if mm then
    local year_offset = 0
    if sign_mmdd == "-" then
      year_offset = -1
    end
    local tbl = {
      year = ref_date_tbl.year + year_offset,
      month = tonumber(mm),
      day = tonumber(dd),
      hour = 12,
    }
    result_time = os.time(tbl)
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
  -- Matches optional sign, optional number (N), and a day character (D)
  sign_wd, num_weeks_str, day_char =
    pattern:match("^([%+%-]?)(%d*)([mtwhfsu])$")
  if day_char then
    local target_wday = day_char_to_wday[day_char]
    if target_wday == nil then goto format_result end -- Invalid day char

    local ref_wday = ref_date_tbl.wday -- 0=Sun, 1=Mon, ..., 6=Sat

    -- Determine number of full weeks offset. Default is 1 cycle.
    local num_weeks = 0
    if num_weeks_str ~= "" then
      local maybe_num_weeks = tonumber(num_weeks_str)
      if maybe_num_weeks then
        num_weeks = maybe_num_weeks
      end
    end

    local day_diff = target_wday - ref_wday
    local offset_days = 0
    local multiplier = (sign_wd == "-") and -1 or 1

    if multiplier == 1 then
      if day_diff <= 0 then
        offset_days = day_diff + 7
      else
        offset_days = day_diff
      end
      offset_days = offset_days + (num_weeks - 1) * 7
    else
      if day_diff >= 0 then
        offset_days = day_diff - 7
      else
        offset_days = day_diff
      end
      offset_days = day_diff
      offset_days = offset_days + (num_weeks + 1) * -7
    end

    result_time = reference_time + offset_days * seconds_per_day
    goto format_result
  end

  -- If no pattern matched, result_time remains nil

  ::format_result::
  if result_time == nil then
    -- This could happen if os.time() returns nil for an invalid date table
    -- (e.g., Feb 30) or if the pattern was completely invalid.
    -- Returning nil indicates failure.
    return ''
  end

  -- Format the final calculated timestamp
  local result_timestamp = os.date("%Y-%m-%d", result_time)
  ---@cast result_timestamp string
  return result_timestamp
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
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "m",        expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "t",        expected = "2025-04-01" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "w",        expected = "2025-04-02" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "h",        expected = "2025-04-03" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "f",        expected = "2025-04-04" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "s",        expected = "2025-04-05" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "u",        expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-u",       expected = "2025-03-30" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-2m",      expected = "2025-03-17" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-1m",      expected = "2025-03-24" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-m",       expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "m",        expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "1m",       expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "2m",       expected = "2025-04-14" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "20240505", expected = "2024-05-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "20250505", expected = "2025-05-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-0406",    expected = "2024-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "0406",     expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "1",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "2",        expected = "2025-04-08" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-1",       expected = "2025-04-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-2",       expected = "2025-04-04" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "m",        expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "t",        expected = "2025-04-01" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "w",        expected = "2025-04-02" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "h",        expected = "2025-04-03" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "f",        expected = "2025-04-04" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "s",        expected = "2025-04-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "u",        expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-u",       expected = "2025-03-30" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-2m",      expected = "2025-03-17" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-1m",      expected = "2025-03-24" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-m",       expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "m",        expected = "2025-03-31" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "1m",       expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "2m",       expected = "2025-04-14" },
  }

  local all_passed = true
  local msgs = {}
  for _, test in ipairs(tests) do
    local ref_time = os.time(test.reference)
    local ref_date_str = os.date("%Y-%m-%d", ref_time)
    local resolved_date = M.resolve_date_pattern(ref_time, test.subject)
    local passed = resolved_date == test.expected
    if not passed then
      all_passed = false
    end
    table.insert(msgs, string.format(
      "Reference: %-10s | Pattern: %-10s | Expected: %-10s | Resolved: %-10s | %s",
      ref_date_str,
      test.subject,
      test.expected,
      resolved_date or "nil",
      passed and "" or "FAIL"
    ))
  end

  table.insert(msgs, "------------------------------------------")
  if all_passed then
    table.insert(msgs, "All tests passed (based on implemented logic).")
  else
    table.insert(msgs, "Some tests failed.")
  end
  table.insert(msgs, "------------------------------------------")

  local formatted = table.concat(msgs, "\n")
  print(formatted)
  local f = io.open('out.txt', 'w')
  if not f then
    error('cannot open file out.txt to write the output')
  end
  f:write(formatted)
  f:flush()
  f:close()
end

-- To run tests from Neovim:
-- :lua require('date_resolver').run_tests()

return M
