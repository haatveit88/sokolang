-- utility for running the included Sokolang test cases
local termcol = require("utils.termcol")
local colors, wrap = termcol.colors, termcol.wrap
local printf = require("utils/printf")
local sokolang = require("sokolang")

local ResultType = {
    Success = wrap("Success", colors.green),
    Failure = wrap("Failure", colors.red)
}

local test_path = "tests/"
local test_files = {
    "basic_add",
    "basic_sub",
    "basic_mul",
    "basic_div",
}


-- load all the test cases
local test_collection = {}

for _, tests in ipairs(test_files) do
    local test = require(test_path .. tests)

    if test and type(test) == "table" then
        table.insert(test_collection, test)
    end
end


local function run_all(hardfail)
    for _, test_module in ipairs(test_collection) do
        printf("Testing '%s'", test_module.name)

        for i, case in ipairs(test_module.cases) do
            local case_n = i
            local case_name = case.name
            local case_expect = tostring(case.result) -- Always compare result vs expected as strings.
            local case_success

            local result = sokolang.run(case.code)
            local case_result = tostring(result[#result])

            if case_result == case_expect then
                case_success = ResultType.Success
            else
                case_success = ResultType.Failure
            end

            -- local result_string = string.format("Case [%i: %s]: %s (Expected: %s; Got: %s)", case_n, case_name, case_success, case_expect, case_result)
            local result_string = string.format("%s Case %i: %s -> (Expected: %s; Got: %s)", case_success, case_n,
                case_name, case_expect, case_result)
            print(result_string)

            if case_success == ResultType.Failure and hardfail then
                error(string.format("Failed test case #%i \"%s\"! Ending run.", case_n, case_name))
            end
        end

        print()
    end

    print(wrap("ALL TEST MODULES PASSED!", colors.cyan))
    print()
    print()
end

run_all(true)