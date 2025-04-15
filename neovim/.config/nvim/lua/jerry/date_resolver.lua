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
    if tbl.month < 1 or tbl.month > 12 or tbl.day < 1 or tbl.day > 31 then
      result_time = nil
    else
      result_time = os.time(tbl)
    end
    goto format_result
  end

  -- Pattern: [+-]MMDD (e.g., 0406, -0406)
  sign_mmdd, mm, dd = pattern:match("^([%+%-]?)(%d%d)(%d%d)$")
  if mm then
    local year_offset = 0
    local target_mm = tonumber(mm)
    local target_dd = tonumber(dd)

    if sign_mmdd == "-" then
      year_offset = -1
    end

    local tbl = {
      year = ref_date_tbl.year + year_offset,
      month = target_mm,
      day = target_dd,
      hour = 12,
    }
    if tbl.month < 1 or tbl.month > 12 or tbl.day < 1 or tbl.day > 31 then
      result_time = nil
    else
      result_time = os.time(tbl)
      -- Handle potential year wrap ambiguity for MMDD without sign
      if sign_mmdd == "" and result_time and result_time < reference_time then
         tbl.year = tbl.year + 1
         -- Re-validate potential invalid date after year increment (e.g., Feb 29)
         -- Use a temporary table to avoid modifying tbl if os.time fails
         local temp_tbl = {year=tbl.year, month=tbl.month, day=tbl.day, hour=12}
         local next_year_time = os.time(temp_tbl)
         if next_year_time then
             result_time = next_year_time
         else
             result_time = nil -- Date became invalid after year increment
         end
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
    if target_wday == nil then goto format_result end -- Invalid day char

    local ref_wday = ref_date_tbl.wday -- 1=Sun, 2=Mon, ..., 7=Sat
    local num_weeks = tonumber(num_weeks_str) or 0
    local multiplier = (sign_wd == "-") and -1 or 1
    local offset_days = 0
    local day_diff = target_wday - ref_wday

    if multiplier == 1 then -- Positive offset: Find next occurrence >= ref_date
      if day_diff < 0 then
        -- Target day is earlier in the week cycle (e.g., ref=Wed, target=Mon)
        offset_days = day_diff + 7
      else -- day_diff >= 0
        -- Target day is today or later in the week cycle
        offset_days = day_diff
      end
      -- Add the specified number of full weeks (N means N weeks *after* the next one)
      offset_days = offset_days + (num_weeks * 7)

    else -- Negative offset: Find previous occurrence <= ref_date
      -- 1. Calculate base offset to the most recent occurrence <= ref_date
      local base_offset_days = 0
      if day_diff > 0 then
        -- Target day is later in the week cycle (e.g., ref=Mon, target=Wed)
        -- The most recent occurrence was in the previous week.
        base_offset_days = day_diff - 7
      else -- day_diff <= 0
        -- Target day is today or earlier in the week cycle
        base_offset_days = day_diff
      end
      -- base_offset_days now points relative to ref_time

      -- 2. Determine how many weeks to subtract based on N and whether ref_wday == target_wday
      local weeks_to_subtract = 0
      if ref_wday == target_wday then
        -- If ref day IS the target day, N directly means N weeks back from ref day
        weeks_to_subtract = num_weeks
      else
        -- If ref day is NOT the target day, N=0 and N=1 mean the base offset date,
        -- N=2 means base - 1 week, N=3 means base - 2 weeks, etc.
        if num_weeks > 0 then
           weeks_to_subtract = num_weeks - 1
        end
        -- If num_weeks is 0, weeks_to_subtract remains 0.
      end

      offset_days = base_offset_days - (weeks_to_subtract * 7)
    end

    result_time = reference_time + offset_days * seconds_per_day
    goto format_result
  end

  ::format_result::
  if result_time == nil then
    return ''
  end

  -- Final check: os.time can return nil if the calculated date is invalid
  local formatted_date = os.date("%Y-%m-%d", result_time)
  if not formatted_date then
      return '' -- Return empty if formatting failed (likely invalid timestamp)
  end
  ---@cast formatted_date string
  return formatted_date
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
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-2m",      expected = "2025-03-17" }, -- Ref=Mon(2), Target=Mon(2). N=2. Ref==Target -> weeks_to_subtract=N=2. Base=0. Final=0-(2*7)=-14. Mar31-14=Mar17.
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-1m",      expected = "2025-03-24" }, -- Ref=Mon(2), Target=Mon(2). N=1. Ref==Target -> weeks_to_subtract=N=1. Base=0. Final=0-(1*7)=-7. Mar31-7=Mar24.
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-m",       expected = "2025-03-31" }, -- Ref=Mon(2), Target=Mon(2). N=0. Ref==Target -> weeks_to_subtract=N=0. Base=0. Final=0-(0*7)=0. Mar31+0=Mar31.
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
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-2m",      expected = "2025-03-24" }, -- Ref=Sat(7), Target=Mon(2). N=2. Ref!=Target -> weeks_to_subtract=N-1=1. Base=-5. Final=-5-(1*7)=-12. Apr5-12=Mar24.
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-1m",      expected = "2025-03-31" }, -- Ref=Sat(7), Target=Mon(2). N=1. Ref!=Target -> weeks_to_subtract=N-1=0. Base=-5. Final=-5-(0*7)=-5. Apr5-5=Mar31.
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-m",       expected = "2025-03-31" }, -- Ref=Sat(7), Target=Mon(2). N=0. Ref!=Target -> weeks_to_subtract=0. Base=-5. Final=-5-(0*7)=-5. Apr5-5=Mar31.
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
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-u",       expected = "2025-04-06" }, -- Ref=Sun(1), Target=Sun(1). N=0. Ref==Target -> weeks_to_subtract=N=0. Base=0. Final=0-(0*7)=0. Apr6+0=Apr6.
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-2m",      expected = "2025-03-24" }, -- Ref=Sun(1), Target=Mon(2). N=2. Ref!=Target -> weeks_to_subtract=N-1=1. Base=-6. Final=-6-(1*7)=-13. Apr6-13=Mar24.
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-1m",      expected = "2025-03-31" }, -- Ref=Sun(1), Target=Mon(2). N=1. Ref!=Target -> weeks_to_subtract=N-1=0. Base=-6. Final=-6-(0*7)=-6. Apr6-6=Mar31.
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-m",       expected = "2025-03-31" }, -- Ref=Sun(1), Target=Mon(2). N=0. Ref!=Target -> weeks_to_subtract=0. Base=-6. Final=-6-(0*7)=-6. Apr6-6=Mar31.
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
      goto continue_loop
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
      resolved_date or "nil",
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
  local f = io.open('out.txt', 'w')
  if f then
    f:write(formatted)
    f:close()
  else
    print("Error: Could not open out.txt for writing.")
  end
end

return M

