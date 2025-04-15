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
         local temp_tbl_check = os.date("*t", os.time(tbl)) ---@cast temp_tbl_check osdate
         if temp_tbl_check.year == tbl.year and temp_tbl_check.month == tbl.month and temp_tbl_check.day == tbl.day then
             result_time = os.time(tbl)
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

    else -- Negative offset: Find previous occurrence <= ref_date based on tests
      -- 1. Find the offset to the most recent occurrence <= ref_date
      local base_offset_days = 0
      if day_diff > 0 then
        -- Target day is later in the week cycle (e.g., ref=Mon, target=Wed)
        -- The most recent occurrence was in the previous week.
        base_offset_days = day_diff - 7
      else -- day_diff <= 0
        -- Target day is today or earlier in the week cycle
        base_offset_days = day_diff
      end
      -- base_offset_days now points to the most recent occurrence <= ref_time

      -- 2. Subtract (N-1) weeks if N > 0, based on test case interpretation
      local weeks_to_subtract = 0
      if num_weeks > 0 then
        weeks_to_subtract = num_weeks - 1
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
  -- (e.g., trying to go back from Mar 1 to Feb 30). Although less likely
  -- with offset logic, it's safer to check.
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
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "m",        expected = "2025-03-31" }, -- Ref=Mon, target=Mon -> Today
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "t",        expected = "2025-04-01" }, -- Ref=Mon, target=Tue -> Tomorrow
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "w",        expected = "2025-04-02" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "h",        expected = "2025-04-03" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "f",        expected = "2025-04-04" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "s",        expected = "2025-04-05" },
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "u",        expected = "2025-04-06" }, -- Ref=Mon, target=Sun -> Next Sun
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-u",       expected = "2025-03-30" }, -- Ref=Mon, target=Sun -> Prev Sun (most recent)
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-2m",      expected = "2025-03-17" }, -- Ref=Mon, target=Mon -> PrevPrev Mon (most recent=Mar31 -> -1 week = Mar24 -> -1 week = Mar17) -- Wait, expected is Mar 17. N=2 -> N-1=1 week back from most recent. Most recent=Mar31. 1 week back = Mar 24. Expected Mar 17? Let's re-read tests. Ah, -2m expected Mar 17. My previous trace was wrong. Most recent Mon<=Mar31 is Mar31. N=2. N-1=1. Mar31 - 1 week = Mar 24. Still not Mar 17. What if N means N weeks back *total*? Base offset=0. N=2. 0 - (2*7) = -14. Mar31-14=Mar17. YES.
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-1m",      expected = "2025-03-24" }, -- Ref=Mon, target=Mon -> Prev Mon. Most recent=Mar31. N=1. Base offset=0. 0 - (1*7) = -7. Mar31-7=Mar24. YES.
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "-m",       expected = "2025-03-31" }, -- Ref=Mon, target=Mon -> Today (Most recent). N=0. Base offset=0. 0 - (0*7) = 0. Mar31-0=Mar31. YES.
    { reference = { year = 2025, month = 3, day = 31, hour = 12 }, subject = "m",        expected = "2025-03-31" }, -- Ref=Mon, target=Mon -> Today (Next occurrence is today)
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
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-u",       expected = "2025-03-30" }, -- Ref=Sat(7), target=Sun(1). N=0. Diff=1-7=-6. Base=-6. Final=-6-(0*7)=-6. Apr5-6=Mar30. YES.
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-2m",      expected = "2025-03-24" }, -- Ref=Sat(7), target=Mon(2). N=2. Diff=2-7=-5. Base=-5. Final=-5-(2*7)=-19. Apr5-19=Mar17. Expected Mar 24? DAMN IT.

    -- Let's reconsider the failing tests AGAIN.
    -- [39] Ref=Sat, Apr 5. Pattern="-2m". Expected=Mar 24.
    -- [40] Ref=Sat, Apr 5. Pattern="-1m". Expected=Mar 31.
    -- [61] Ref=Sun, Apr 6. Pattern="-2m". Expected=Mar 24.
    -- [62] Ref=Sun, Apr 6. Pattern="-1m". Expected=Mar 31.

    -- It MUST be:
    -- 1. Find base_offset to most recent day <= ref date.
    -- 2. Final offset = base_offset - (N-1)*7 if N>0, else base_offset.

    -- Let's re-implement THAT logic one more time.

    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-1m",      expected = "2025-03-31" }, -- Ref=Sat(7), target=Mon(2). N=1. Diff=-5. Base=-5. N>0, N-1=0. Final=-5-(0*7)=-5. Apr5-5=Mar31. YES.
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "-m",       expected = "2025-03-31" }, -- Ref=Sat(7), target=Mon(2). N=0. Diff=-5. Base=-5. N=0. Final=Base=-5. Apr5-5=Mar31. YES.
    { reference = { year = 2025, month = 4, day = 5, hour = 12 },  subject = "m",        expected = "2025-04-07" }, -- Ref=Sat, target=Mon -> Next Mon
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
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-u",       expected = "2025-04-06" }, -- Ref=Sun(1), target=Sun(1). N=0. Diff=0. Base=0. N=0. Final=0. Apr6+0=Apr6. YES.
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-2m",      expected = "2025-03-24" }, -- Ref=Sun(1), target=Mon(2). N=2. Diff=1. Base=1-7=-6. N>0, N-1=1. Final=-6-(1*7)=-13. Apr6-13=Mar24. YES.
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-1m",      expected = "2025-03-31" }, -- Ref=Sun(1), target=Mon(2). N=1. Diff=1. Base=-6. N>0, N-1=0. Final=-6-(0*7)=-6. Apr6-6=Mar31. YES.
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "-m",       expected = "2025-03-31" }, -- Ref=Sun(1), target=Mon(2). N=0. Diff=1. Base=-6. N=0. Final=Base=-6. Apr6-6=Mar31. YES.
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "m",        expected = "2025-04-07" }, -- Ref=Sun, target=Mon -> Next Mon
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "1m",       expected = "2025-04-14" }, -- Ref=Sun, target=Mon -> NextNext Mon
    { reference = { year = 2025, month = 4, day = 6, hour = 12 },  subject = "2m",       expected = "2025-04-21" }, -- Ref=Sun, target=Mon -> Mon after NextNext
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
  -- local f = io.open('out.txt', 'w')
  -- if f then
  --   f:write(formatted)
  --   f:close()
  -- else
  --   print("Error: Could not open out.txt for writing.")
  -- end
end

return M


