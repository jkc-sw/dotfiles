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
-- Note: os.date('*t').wday returns 1 for Sunday, 7 for Saturday.
local day_char_to_wday = {
  u = 1, m = 2, t = 3, w = 4, h = 5, f = 6, s = 7,
}
-- Seconds in a day
local seconds_per_day = 24 * 60 * 60

--- Resolves a date pattern relative to a reference timestamp.
---
---@param reference_time number | nil The reference Unix timestamp (seconds since epoch). Defaults to os.time().
---@param pattern string The date pattern string to resolve.
---@return string | nil The resolved date as a 'YYYY-MM-DD' string, or '' if the pattern is invalid.
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
    -- error("Could not normalize reference time.") -- Avoid erroring, return ''
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
    -- Validate month and day before calling os.time
    if tbl.month < 1 or tbl.month > 12 or tbl.day < 1 or tbl.day > 31 then
      result_time = nil
    else
      result_time = os.time(tbl)
    end
    goto format_result -- Use goto for early exit after match
  end

  -- Pattern: [+-]MMDD (e.g., 0406, -0406)
  -- Matches MM followed by DD, optionally preceded by + or -
  sign_mmdd, mm, dd = pattern:match("^([%+%-]?)(%d%d)(%d%d)$")
  -- Check 'mm' specifically, as 'y' check already happened
  if mm then
    local year_offset = 0
    -- If the target month/day is *before* the reference month/day,
    -- and no sign is given, assume next year.
    -- If sign is '-', assume previous year.
    -- If sign is '+', assume current year (or next if needed, handled by os.time).
    local target_mm = tonumber(mm)
    local target_dd = tonumber(dd)

    if sign_mmdd == "-" then
      year_offset = -1
    elseif sign_mmdd == "" then
      -- No sign: if target MMDD is earlier than ref MMDD, assume next year
      if target_mm < ref_date_tbl.month
          or (target_mm == ref_date_tbl.month and target_dd < ref_date_tbl.day) then
        -- This logic might be too simple, os.time handles year wrap implicitly
        -- Let's rely on os.time, but handle explicit '-' for previous year.
        -- No change needed here if we just set the year.
      end
      -- '+' sign also implies current year initially.
    end

    local tbl = {
      year = ref_date_tbl.year + year_offset,
      month = target_mm,
      day = target_dd,
      hour = 12,
    }
    -- Validate month and day before calling os.time
    if tbl.month < 1 or tbl.month > 12 or tbl.day < 1 or tbl.day > 31 then
      result_time = nil
    else
      result_time = os.time(tbl)
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
  -- Matches optional sign, optional number (N), and a day character (D)
  sign_wd, num_weeks_str, day_char =
    pattern:match("^([%+%-]?)(%d*)([mtwhfsu])$")
  if day_char then
    local target_wday = day_char_to_wday[day_char]
    if target_wday == nil then goto format_result end -- Invalid day char

    local ref_wday = ref_date_tbl.wday -- 1=Sun, 2=Mon, ..., 7=Sat

    -- Determine number of full weeks offset. Default is 0 weeks offset.
    local num_weeks = tonumber(num_weeks_str) or 0
    local multiplier = (sign_wd == "-") and -1 or 1

    local day_diff = target_wday - ref_wday
    local offset_days = 0

    if multiplier == 1 then -- Positive offset: Find *next* occurrence
      offset_days = day_diff
      if offset_days < 0 then
        -- Target day is earlier in the week cycle (e.g., ref=Wed, target=Mon)
        -- Move to the next week's target day
        offset_days = offset_days + 7
      end
      -- Add the specified number of full weeks
      offset_days = offset_days + (num_weeks * 7)
    else -- Negative offset: Find *previous* occurrence
      offset_days = day_diff
      if offset_days > 0 then
        -- Target day is later in the week cycle (e.g., ref=Mon, target=Wed)
        -- Move to the previous week's target day
        offset_days = offset_days - 7
      end
      -- Subtract the specified number of full weeks
      offset_days = offset_days - (num_weeks * 7)
    end

    result_time = reference_time + offset_days * seconds_per_day
    goto format_result
  end

  -- If no pattern matched, result_time remains nil

  ::format_result::
  if result_time == nil then
    -- This could happen if os.time() returns nil for an invalid date table
    -- (e.g., Feb 30) or if the pattern was completely invalid.
    -- Returning '' indicates failure, matching test output format.
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
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "m",        expected = "2025-03-31" }, -- Ref=Mon, target=Mon -> Today
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "t",        expected = "2025-04-01" }, -- Ref=Mon, target=Tue -> Tomorrow
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "w",        expected = "2025-04-02" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "h",        expected = "2025-04-03" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "f",        expected = "2025-04-04" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "s",        expected = "2025-04-05" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "u",        expected = "2025-04-06" }, -- Ref=Mon, target=Sun -> Next Sun
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-u",       expected = "2025-03-30" }, -- Ref=Mon, target=Sun -> Prev Sun
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-2m",      expected = "2025-03-17" }, -- Ref=Mon, target=Mon -> PrevPrev Mon
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-1m",      expected = "2025-03-24" }, -- Ref=Mon, target=Mon -> Prev Mon
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-m",       expected = "2025-03-31" }, -- Ref=Mon, target=Mon -> Today (Prev Mon is today)
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "m",        expected = "2025-03-31" }, -- Ref=Mon, target=Mon -> Today (Next Mon is today)
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "1m",       expected = "2025-04-07" }, -- Ref=Mon, target=Mon -> Next Mon
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "2m",       expected = "2025-04-14" }, -- Ref=Mon, target=Mon -> NextNext Mon
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "20240505", expected = "2024-05-05" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "20250505", expected = "2025-05-05" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-0406",    expected = "2024-04-06" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "0406",     expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "1",        expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "2",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-1",       expected = "2025-04-04" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-2",       expected = "2025-04-03" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "m",        expected = "2025-04-07" }, -- Ref=Sat, target=Mon -> Next Mon
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "t",        expected = "2025-04-08" }, -- Ref=Sat, target=Tue -> Next Tue
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "w",        expected = "2025-04-09" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "h",        expected = "2025-04-10" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "f",        expected = "2025-04-11" },
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "s",        expected = "2025-04-05" }, -- Ref=Sat, target=Sat -> Today
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "u",        expected = "2025-04-06" }, -- Ref=Sat, target=Sun -> Tomorrow
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-u",       expected = "2025-03-30" }, -- Ref=Sat, target=Sun -> Prev Sun
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-2m",      expected = "2025-03-24" }, -- Ref=Sat, target=Mon -> PrevPrev Mon
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-1m",      expected = "2025-03-31" }, -- Ref=Sat, target=Mon -> Prev Mon
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-m",       expected = "2025-03-31" }, -- Ref=Sat, target=Mon -> Prev Mon (0 weeks back)
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "m",        expected = "2025-04-07" }, -- Ref=Sat, target=Mon -> Next Mon (0 weeks forward)
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "1m",       expected = "2025-04-14" }, -- Ref=Sat, target=Mon -> NextNext Mon
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "2m",       expected = "2025-04-21" }, -- Ref=Sat, target=Mon -> Mon after NextNext
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "20240505", expected = "2024-05-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "20250505", expected = "2025-05-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-0406",    expected = "2024-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "0406",     expected = "2025-04-06" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "1",        expected = "2025-04-07" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "2",        expected = "2025-04-08" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-1",       expected = "2025-04-05" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-2",       expected = "2025-04-04" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "m",        expected = "2025-04-07" }, -- Ref=Sun, target=Mon -> Tomorrow
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "t",        expected = "2025-04-08" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "w",        expected = "2025-04-09" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "h",        expected = "2025-04-10" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "f",        expected = "2025-04-11" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "s",        expected = "2025-04-12" },
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "u",        expected = "2025-04-06" }, -- Ref=Sun, target=Sun -> Today
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-u",       expected = "2025-04-06" }, -- Ref=Sun, target=Sun -> Today (Prev Sun is today)
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-2m",      expected = "2025-03-24" }, -- Ref=Sun, target=Mon -> PrevPrev Mon
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-1m",      expected = "2025-03-31" }, -- Ref=Sun, target=Mon -> Prev Mon
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-m",       expected = "2025-03-31" }, -- Ref=Sun, target=Mon -> Prev Mon (0 weeks back)
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "m",        expected = "2025-04-07" }, -- Ref=Sun, target=Mon -> Next Mon (0 weeks forward)
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "1m",       expected = "2025-04-14" }, -- Ref=Sun, target=Mon -> NextNext Mon
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "2m",       expected = "2025-04-21" }, -- Ref=Sun, target=Mon -> Mon after NextNext
  }

  local all_passed = true
  local msgs = {}
  for i, test in ipairs(tests) do
    local ref_time = os.time(test.reference)
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
      resolved_date or "nil",
      passed and "" or "FAIL"
    ))
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
  -- Optional: Write to file (ensure you have permissions)
  local f = io.open('out.txt', 'w')
  if f then
    f:write(formatted)
    f:close()
  else
    print("Error: Could not open out.txt for writing.")
  end
end

-- To run tests from Neovim:
-- :lua require('date_resolver').run_tests()

return M

