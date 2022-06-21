local timetableHelper = require "celmi/timetables/timetable_helper"

--[[
timetable = {
    line = {
        stations = { stationinfo }
        hasTimetable = true
    }
}

stationInfo = {
    conditions = {condition :: Condition},
    inboundTime = 1 :: int
}

conditions = {
    type = "None"| "ArrDep" | "minWait" | "debounce" | "moreFancey"
    ArrDep = {}
    minWait = {}
    debaunce  = {}
    moreFancey = {}
}
--]]

--[[
currentlyWaiting = {
    line = {
        station = {
            vehiclesWaiting = { vehicleWaitingInfo }
            vehiclesDeparting = { vehicleDepartingInfo }
        }
    }
}

vehicleWaitingInfo = {
    arrivalTime = 1 :: int
    constraint = {}
    type = "ArrDep"
}

vehicleDepartingInfo = {
    outboundTime = 1 :: int
}
]]

local timetable = { }
local timetableObject = { }
local currentlyWaiting = { }


function timetable.getTimetableObject()
    return timetableObject
end

function timetable.setTimetableObject(t)
    if t then
        timetableObject = t
    end
end

function timetable.getCurrentlyWaiting()
    return currentlyWaiting
end

function timetable.setCurrentlyWaiting(t)
    if t then
        currentlyWaiting = t
    end
end

function timetable.setConditionType(line, stationNumber, type)
    local stationID = timetableHelper.getStationID(line, stationNumber)
    if not(line and stationNumber) then return -1 end
    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then
        timetableObject[tostring(line)].stations[stationNumber].conditions.type = type
        local conditionObject = timetableObject[tostring(line)].stations[stationNumber].conditions[type]
        if not conditionObject then  timetableObject[tostring(line)].stations[stationNumber].conditions[type] = {} end
        timetableObject[tostring(line)].stations[stationNumber].stationID = stationID
    else
        if not timetableObject[tostring(line)] then
            timetableObject[tostring(line)] = { hasTimetable = false, stations = {}}
        end

        timetableObject[tostring(line)].stations[stationNumber] = {
            inboundTime = 0,
            stationID = stationID,
            conditions = {type = type}
        }
        local conditionObject = timetableObject[tostring(line)].stations[stationNumber].conditions[type]
        if not conditionObject then  timetableObject[tostring(line)].stations[stationNumber].conditions[type] = {} end
    end
end

function timetable.getConditionType(line, stationNumber)
    if not(line and stationNumber) then return "ERROR" end
    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then
        if timetableObject[tostring(line)].stations[stationNumber].conditions.type then
            return timetableObject[tostring(line)].stations[stationNumber].conditions.type
        else
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "None"
            return "None"
        end
    else
        return "None"
    end
end


function timetable.getAllConditionsOfStaion(stationID)
    local res = { }
    for k,v in pairs(timetableObject) do
        for _,v2 in pairs(v.stations) do
            if v2.stationID
               and v2.conditions
               and  v2.conditions.type
               and not (v2.conditions.type == "None")
               and tostring(v2.stationID) == tostring(stationID+1) then
                res[k] = {
                    stationID = v2.stationID,
                    conditions = v2.conditions
                }
            end
        end
    end
    return res
end

function timetable.getAllConditionsOfAllStations()
    local res = { }
    for k,v in pairs(timetableObject) do
        for _,v2 in pairs(v.stations) do
            if v2.stationID and v2.conditions and  v2.conditions.type and not (v2.conditions.type == "None")  then
                if not res[v2.stationID] then res[v2.stationID] = {} end
                res[v2.stationID][k] = {
                    conditions = v2.conditions
                }
            end
        end
    end
    return res
end

function timetable.getConditions(line, stationNumber, type)
    if not(line and stationNumber) then return -1 end
    if timetableObject[tostring(line)]
       and timetableObject[tostring(line)].stations[stationNumber]
       and timetableObject[tostring(line)].stations[stationNumber].conditions[type]
       and timetableObject[tostring(line)].stations[stationNumber].conditions["type"] == type then
        return timetableObject[tostring(line)].stations[stationNumber].conditions[type]
    else
        return -1
    end
end


-- TEST: timetable.addCondition(1,1,{type = "ArrDep", ArrDep = {{12,14,14,14}}})
function timetable.addCondition(line, stationNumber, condition)
    local stationID = timetableHelper.getStationID(line, stationNumber)
    if not(line and stationNumber and condition) then return -1 end

    if timetableObject[tostring(line)] and timetableObject[tostring(line)].stations[stationNumber] then
        if condition.type == "ArrDep" or condition.type == "WaitDep" or condition.type == "NoDep" then
            timetable.setConditionType(line, stationNumber, condition.type)
            local arrDepCond = timetableObject[tostring(line)].stations[stationNumber].conditions[condition.type]
            local mergedArrays = timetableHelper.mergeArray(arrDepCond, condition[condition.type])
            timetableObject[tostring(line)].stations[stationNumber].conditions[condition.type] = mergedArrays
        elseif condition.type == "minWait" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "minWait"
            timetableObject[tostring(line)].stations[stationNumber].conditions.minWait = condition.minWait
        elseif condition.type == "debounce" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "debounce"
            timetableObject[tostring(line)].stations[stationNumber].conditions.debounce = condition.debounce
        elseif condition.type == "moreFancey" then
            timetableObject[tostring(line)].stations[stationNumber].conditions.type = "moreFancey"
            timetableObject[tostring(line)].stations[stationNumber].conditions.moreFancey = condition.moreFancey
        end
        timetableObject[tostring(line)].stations[stationNumber].stationID = stationID

    else
        if not timetableObject[tostring(line)] then
            timetableObject[tostring(line)] = {hasTimetable = false, stations = {}}
        end
        timetableObject[tostring(line)].stations[stationNumber] = {
            inboundTime = 0,
            stationID = stationID,
            conditions = condition
        }
    end
end

function timetable.updateFourValueCondition(line, station, indexKey, indexValue, value, type)
    if not (line and station and indexKey and indexValue and value and type) then return -1 end
    if timetableObject[tostring(line)] and
       timetableObject[tostring(line)].stations[station] and
       timetableObject[tostring(line)].stations[station].conditions and
       timetableObject[tostring(line)].stations[station].conditions[type] and
       timetableObject[tostring(line)].stations[station].conditions[type][indexKey] and
       timetableObject[tostring(line)].stations[station].conditions[type][indexKey][indexValue] then
       timetableObject[tostring(line)].stations[station].conditions[type][indexKey][indexValue] = value
        return 0
    else
        return -2
    end
end

function timetable.updateDebounce(line, station, indexKey, value)
    if not (line and station and indexKey and value) then return -1 end
    if timetableObject[tostring(line)] and
       timetableObject[tostring(line)].stations[station] and
       timetableObject[tostring(line)].stations[station].conditions and
       timetableObject[tostring(line)].stations[station].conditions.debounce then
       timetableObject[tostring(line)].stations[station].conditions.debounce[indexKey] = value
        return 0
    else
        return -2
    end
end

function timetable.removeCondition(line, station, type, index)
    if not(line and station and index) or (not (timetableObject[tostring(line)]
       and timetableObject[tostring(line)].stations[station])) then
        return -1
    end

    if type == "ArrDep" or type == "WaitDep" or type == "NoDep" then
        local tmpTable = timetableObject[tostring(line)].stations[station].conditions[type]
        if tmpTable and tmpTable[index] then return table.remove(tmpTable, index) end
    else
        -- just remove the whole condition
        local tmpTable = timetableObject[tostring(line)].stations[station].conditions[type]
        if tmpTable and tmpTable[index] then timetableObject[tostring(line)].stations[station].conditions[type] = {} end
        return 0
    end
    return -1
end

function timetable.hasTimetable(line)
    if timetableObject[tostring(line)] then
        return timetableObject[tostring(line)].hasTimetable
    else
        return false
    end
end

function timetable.waitingRequired(vehicle)
    local time = timetableHelper.getTime()
    local currentLine = timetableHelper.getCurrentLine(vehicle)
    local currentStop = timetableHelper.getCurrentStation(vehicle)
    local currentLineString = tostring(currentLine)
    if not timetableObject[currentLineString] then return false end
    if not timetableObject[currentLineString].stations[currentStop] then return false end
    if not timetableObject[currentLineString].stations[currentStop].conditions then return false end
    if not timetableObject[currentLineString].stations[currentStop].conditions.type then return false end

    if not currentlyWaiting[currentLineString] then currentlyWaiting[currentLineString] = {stations = {}} end
    if not currentlyWaiting[currentLineString].stations[currentStop] then
          currentlyWaiting[currentLineString].stations[currentStop] = { vehiclesWaiting = {}, vehiclesDeparting = {}}
    end
    local currentStopInTimetableObj = timetableObject[currentLineString].stations[currentStop]
    local currentStopInCurrentlyWaiting = currentlyWaiting[currentLineString].stations[currentStop]

    if currentStopInTimetableObj.conditions.type == "ArrDep" then
        return timetable.waitingRequiredArrDep(vehicle, currentStopInCurrentlyWaiting, currentStopInTimetableObj, time)

    elseif currentStopInTimetableObj.conditions.type == "debounce" then
        return timetable.waitingRequiredDebounce(vehicle, currentStopInCurrentlyWaiting, currentStopInTimetableObj, time)

    elseif currentStopInTimetableObj.conditions.type == "WaitDep" then
        return timetable.waitingRequiredWaitDep(vehicle, currentStopInCurrentlyWaiting, currentStopInTimetableObj, time)

    elseif currentStopInTimetableObj.conditions.type == "NoDep" then
        return timetable.waitingRequiredNoDep(vehicle, currentStopInCurrentlyWaiting, currentStopInTimetableObj, time)

    else
        -- no conditions set
        currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = nil
        return false
    end
end

---is waiting required for conditions of type ArrDep
---@param vehicle any
---@param currentStopInCurrentlyWaiting any
---@param currentStopInTimetableObj any
---@param time number in seconds game time
---@return boolean
function timetable.waitingRequiredArrDep(vehicle, currentStopInCurrentlyWaiting, currentStopInTimetableObj, time)

    -- am I currently waiting or just arrived?
    if not (currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle]) then
        -- check if is about to depart

        if currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle]
           and (currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle].outboundTime + 60) > time then
            return false
        end

        -- just arrived
        local nextConstraint = timetable.getNextConstraint(currentStopInTimetableObj.conditions.ArrDep, time, currentStopInCurrentlyWaiting.vehiclesWaiting)
        if not nextConstraint then
            -- no constraints set
            currentStopInCurrentlyWaiting.vehiclesWaiting = {}
            return false
        end
        if timetable.beforeDeparture(time, nextConstraint, time) then
            -- Constraint set and I need to wait
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = {
                type = "ArrDep",
                arrivalTime = time,
                constraint = nextConstraint
            }

            return true
        else
            -- Constraint set and its time to depart
            currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle] = {outboundTime = time}
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = nil
            return false
        end
    else
        -- already waiting
        if timetableHelper.getTimeUntilDeparture(vehicle) >= 5 then return false end

        local arrivalTime = currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle].arrivalTime
        local constraint = currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle].constraint
        if timetable.beforeDeparture(arrivalTime, constraint, time) then
            -- need to continue waiting
            return true
        else
            -- done waiting
            currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle] = {outboundTime = time}
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = nil
            return false
        end
    end
end

function timetable.waitingRequiredDebounce(vehicle, currentStopInCurrentlyWaiting, currentStopInTimetableObj, time)
    if timetableHelper.getTimeUntilDeparture(vehicle) >= 5 then return false end

    local previousDepartureTime = timetableHelper.getPreviousDepartureTime(tonumber(vehicle))
    local condition = currentStopInTimetableObj.conditions["debounce"]
    if not condition[1] then condition[1] = 0 end
    if not condition[2] then condition[2] = 0 end
    if time > previousDepartureTime + ((condition[1] * 60)  + condition[2]) then
        currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = nil
        return false
    else
        return true
    end
end

---is waiting required for conditions of type WaitDep
---@param vehicle any
---@param currentStopInCurrentlyWaiting any
---@param currentStopInTimetableObj any
---@param time number in seconds game time
---@return boolean
function timetable.waitingRequiredWaitDep(vehicle, currentStopInCurrentlyWaiting, currentStopInTimetableObj, time)

    -- am I currently waiting or just arrived?
    if not (currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle]) then
        -- check if is about to depart

        if currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle]
           and (currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle].outboundTime + 60) > time then
            return false
        end

        -- just arrived
        local maxDelay = 90
        local nextDepTime = timetable.getNextDepTime(currentStopInTimetableObj.conditions.WaitDep, time - maxDelay, currentStopInCurrentlyWaiting.vehiclesWaiting)
        if not nextDepTime then
            -- no constraints set
            currentStopInCurrentlyWaiting.vehiclesWaiting = {}
            return false
        end
        if time < nextDepTime then
            -- Constraint set and I need to wait
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = {
                type = "WaitDep",
                arrivalTime = time,
                departureTime = nextDepTime
            }

            return true
        else
            -- Constraint set and its time to depart
            currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle] = {outboundTime = time}
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = nil
            return false
        end
    else
        -- already waiting
        if timetableHelper.getTimeUntilDeparture(vehicle) >= 5 then return false end

        local departureTime = currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle].departureTime
        if time < departureTime then
            -- need to continue waiting
            return true
        else
            -- done waiting
            currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle] = {outboundTime = time}
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = nil
            return false
        end
    end
end

---Is waiting required for condition type NoDep
---@param vehicle any
---@param currentStopInCurrentlyWaiting any
---@param currentStopInTimetableObj any
---@param time number in seconds game time
---@return boolean
function timetable.waitingRequiredNoDep(vehicle, currentStopInCurrentlyWaiting, currentStopInTimetableObj, time)

    -- am I currently waiting or just arrived?
    if not (currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle]) then

        -- check if is about to depart
        if currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle]
        and (currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle].outboundTime + 60) > time then
            return false
        end
        local depNotBefore = timetable.getAcceptedDepTime(currentStopInTimetableObj.conditions.NoDep, time)

        if depNotBefore <= time then
            currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle] = {outboundTime = time}
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = nil
            return false
        else
            -- Constraint set and I need to wait
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = {
                type = "NoDep",
                arrivalTime = time,
                departureTime = depNotBefore
            }
            return true
        end
    else
        -- already waiting

        if timetableHelper.getTimeUntilDeparture(vehicle) >= 5 then return false end

        local departureTime = currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle].departureTime
        if time < departureTime then
            -- need to continue waiting
            return true
        else
            -- done waiting
            currentStopInCurrentlyWaiting.vehiclesDeparting[vehicle] = {outboundTime = time}
            currentStopInCurrentlyWaiting.vehiclesWaiting[vehicle] = nil
            return false
        end
    end
end

function timetable.setHasTimetable(line, bool)
    if timetableObject[tostring(line)] then
        timetableObject[tostring(line)].hasTimetable = bool
    else
        timetableObject[tostring(line)] = {stations = {} , hasTimetable = bool}
    end
    return bool
end

--- Start all vehicles of given line.
---@param line table line id
function timetable.startAllLineVehicles(line)
    for _, vehicle in pairs(timetableHelper.getVehiclesOnLine(line)) do
        if timetableHelper.isInStation(vehicle) then
            local currentLine = tostring(timetableHelper.getCurrentLine(vehicle))
            local currentStop = timetableHelper.getCurrentStation(vehicle)
            if currentlyWaiting[currentLine] and currentlyWaiting[currentLine].stations[currentStop] then
                currentlyWaiting[currentLine].stations[currentStop].vehiclesWaiting[vehicle] = nil
            end
            timetableHelper.startVehicle(vehicle)
        end
    end
end


-------------- UTILS FUNCTIONS ----------

--- This function returns true if the train is before its departure time and after its arrival time
---@param arrivalTime number in seconds
---@param constraint table in format like: {9,0,59,0}
---@param currentTime number in seconds
function timetable.beforeDeparture(arrivalTime, constraint, currentTime)
    arrivalTime = arrivalTime % 3600
    currentTime = currentTime % 3600
    local departureTime = (60 * constraint[3]) + constraint[4]
    if arrivalTime < departureTime then
        -- Eg. the arrival time is 10:00 and the departure is 12:00
        return arrivalTime <= currentTime and currentTime < departureTime
    else
        -- Eg. the arrival time is 59:00 and the departure is 01:00
        return arrivalTime <= currentTime or currentTime < departureTime
    end
end

--- This function calcualtes the time from a given constraint to its closest next constraint
---@param constraint table in format like: {9,0,59,0}
---@param allConstraints number table in format like: {{30,0,59,0},{9,0,59,0},...}
---@return number timeUntilNextContraint: {30,0,59,0}
function timetable.getTimeUntilNextConstraint(constraint, allConstraints)
    local res = 60*60
    local constraintSec =((constraint[1] * 60) + constraint[2])
    for _,v in pairs(allConstraints) do
        local toCheckSec = ((v[1] * 60) + v[2])
        if constraintSec > toCheckSec then
            toCheckSec =  toCheckSec + (60*60)
        end
        local difference = toCheckSec - constraintSec
        if difference > 0 and difference < res then
            res = difference
        end
    end
    return res
end

---Find the next valid constraint for given constraints and time
---@param constraints table in format like: {{30,0,59,0},{9,0,59,0}}
---@param time number in seconds
---@param used_constraints table in format like: {constraint={30,0,59,0},constraint={9,0,59,0}}
---@return table closestConstraint example: {30,0,59,0}
function timetable.getNextConstraint(constraints, time, used_constraints)
    -- Put the constraints in chronological order by arrival time
    table.sort(constraints, function(a, b)
        local aTime = timetable.getArrivalTimeFrom(a)
        local bTime = timetable.getArrivalTimeFrom(b)
        return aTime < bTime
    end)

    -- Find the constraint with the closest arrival time
    local res = {diff = 40000, value = nil}
    for index, constraint in pairs(constraints) do
        local arrTime = timetable.getArrivalTimeFrom(constraint)
        local diff = timetable.getTimeDifference(arrTime, time % 3600)

        if (diff < res.diff) then
            res = {diff = diff, index = index}
        end
    end

    -- Return nil when there are no contraints
    if not res.index then return nil end

    -- Find if the constraint with the closest arrival time is currently being used
    -- If true, find the next consecutive available constraint
    for i = res.index, #constraints + res.index - 1 do
        -- Need to make sure that 2 mod 2 returns 2 rather than 0
        local normalisedIndex = ((i - 1) % #constraints) + 1 

        local constraint = constraints[normalisedIndex]
        local found = false
        for _, used_constraint in pairs(used_constraints) do
            if constraint == used_constraint.constraint then
                found = true
            end
        end

        if not found then
            return constraint
        end
    end

    -- If all constraints are being used, still return the closest constraint anyway.
    return constraints[res.index]
end

---Find the next valid departure time for given constraints and time
---@param constraints table in format like: {{30,0,59,0},{9,0,59,0}}
---@param curTime number in seconds game time
---@param used_constraints table in format like: {constraint={30,0,59,0},constraint={9,0,59,0}}
---@return number nextDepTime  in seconds game time
function timetable.getNextDepTime(constraints, curTime, used_constraints)
    -- Put the constraints in chronological order by arrival time

	local possibleTimes = {}
	for i=1, #constraints do
		possibleTimes[i]= timetable.getNextDepTimeAfter(constraints[i], curTime)

	end
	if not possibleTimes[1] then return nil end

	table.sort(possibleTimes, function(a,b)
		return a < b
		end)

	local nextDepTime
	local j = 1
	local h = 0
	local used
	repeat
		nextDepTime = possibleTimes[j] + h * 3600
		if (j % #possibleTimes) == 0 then h = h + 1 end
		used = false
		for _, used_constraint in pairs(used_constraints) do
			if nextDepTime == used_constraint.departureTime then
				used = true
			end
		end
		j = j + 1
	until not used

    return nextDepTime
end

---get the next acceptable departure time, if no condition applys, this is the current time
---@param constraints any
---@param curTime number current time in seconds game time
---@return integer acceptedTime for departure in seconds game time
function timetable.getAcceptedDepTime(constraints, curTime)
	local acceptedTime = curTime
	local timeInDay = curTime % 3600
	for i=1, #constraints do
		local conStartTime = constraints[i][1]*60 + constraints[i][2]
		local conEndTime = constraints[i][3]*60 + constraints[i][4]
        local endGameTime = acceptedTime
		if conStartTime > conEndTime then
			--constaint crosses hour border
			if timeInDay > conStartTime or timeInDay < conEndTime then
                --curTime in constraint
				if timeInDay > conStartTime then
                    endGameTime = conEndTime + (math.floor(curTime/3600)+1)*3600
				else
					endGameTime =  conEndTime + (math.floor(curTime/3600))*3600
				end
			end
		else
			-- constraint in same hour
			if timeInDay > conStartTime and timeInDay < conEndTime then
                --curTime in constraint
				endGameTime =  conEndTime + math.floor(curTime/3600)*3600
			end
		end
        if acceptedTime<endGameTime then
            --constraint lasts longer than known before
            acceptedTime = endGameTime
        end
	end
    --call recursive in case acceptedTime is within another constraint
    if acceptedTime ~= curTime then
        --curTime was within a constraint
        acceptedTime = timetable.getAcceptedDepTime(constraints, acceptedTime)
    end
	return acceptedTime
end

---Gets the arrival time in seconds from the constraint
---@param constraint table in format like: {9,0,59,0}
function timetable.getArrivalTimeFrom(constraint)
    local arrMin = constraint[1]
    local arrSec = constraint[2]
    return arrMin * 60 + arrSec
end


---Gets the next departure time for the constraint after the specified time
---@param constraint table in format like: {9,0,59,0}
---@param time number in seconds game time
---@return number depTime in seconds game time
function timetable.getNextDepTimeAfter(constraint, time)
    local waitSec = constraint[1]*60 + constraint[2]
    time = time + waitSec
	local hours = math.floor(time/3600)*3600
    local depSecSinceH = constraint[3]*60 + constraint[4]
	local depTime = hours + depSecSinceH
	if depTime < time then depTime = depTime + 3600 end
    return depTime
end

---Calculates the time difference between two timestamps in seconds.
---Considers that 59 mins is close to 0 mins.
---@param a number in seconds between in range of 0-3599 (inclusive)
---@param b number in seconds between in range of 0-3599 (inclusive)
---@return number
function timetable.getTimeDifference(a, b)
    local absDiff = math.abs(a - b)
    if absDiff > 1800 then
        return 3600 - absDiff
    else
        return absDiff
    end
end


return timetable

