--PCR prototype
--local wait = task.wait
--CONFIG
local CELL_AMBIENT = 23
local CHAMBER_AMBIENT = 23
local COMBUSTION_TEMP = 300
local COMBUSTION_TEMP_RANGE = 5
local COMBUSTION_TEMP_LOW = COMBUSTION_TEMP-COMBUSTION_TEMP_RANGE
local COMBUSTION_HIGH = COMBUSTION_TEMP+COMBUSTION_TEMP_RANGE
local PLASMA_REACTION_TEMP = 700
local PLASMA_REACTION_TEMP_RANGE = 30
local PLASMA_COMBUSTION_POWER = 0.7
local PLASMA_REACTION_POWER = 12
local PLASMA_DISIPATION_RATE = 0.01
local PLASMA_IDEAL_DISAPATION_TEMP = 750
local PI_INITIATION_TEMP = 150
local PI_INITIATION_TEMP_RANGE = 5
local PI_FUEL_TEMP = 19
local CELL_PLASMA_DIVIDER = 5
--RUNNING DATA
local piTemp = {}
local combustionTemp = {}
local plasmaTemp = {{CHAMBER_AMBIENT}}
local piFuelInput = {0}
local cellPD = {}--Cell plasma density
local cellTemp = {}
local plasmaOutput = {}
--vars
local temp
local item
------------
for x=1,4 do
    item = {}
    for y=1,6 do
        table.insert(item, CHAMBER_AMBIENT)
    end
    table.insert(piTemp, item)
end
for x=1,4 do
    table.insert(combustionTemp, CHAMBER_AMBIENT)
end
for x=1,4 do
    table.insert(plasmaTemp, CHAMBER_AMBIENT)
end
for x=1,4 do
    table.insert(piFuelInput, CHAMBER_AMBIENT)
end
for x=1,4 do
    table.insert(cellPD, 0)
end
for x=1,4 do
    table.insert(plasmaOutput, 0)
end
for x=1,4 do
    table.insert(cellTemp, CHAMBER_AMBIENT)
end
--MAIN
function  wait(sec)
    os.execute("sleep "..tostring(sec))
end
function getPiTempIncrease(num)
    return (piFuelInput[num]*PLASMA_COMBUSTION_POWER) + math.random(0-COMBUSTION_TEMP_RANGE, COMBUSTION_TEMP_RANGE)/100*piFuelInput[num]
end
function getFuelTempInfluence(num)
    return (PI_FUEL_TEMP/100)*piFuelInput[num]
end
function updatePiTemps()
    for x=1,4 do
        temp = 0
        for i,v in pairs(piTemp[x]) do
            temp = temp + v
        end
        temp = temp + combustionTemp[x]
        piTemp[x][6] = piTemp[x][5]
        piTemp[x][5] = piTemp[x][4]
        piTemp[x][4] = piTemp[x][3]
        piTemp[x][3] = piTemp[x][2]
        piTemp[x][2] = piTemp[x][1]
        piTemp[x][1] = temp/7
    end
end
function updateCombustionTemps()
    for x=1,4 do
        combustionTemp[x] = piTemp[x][1] + getPiTempIncrease(x)
        if combustionTemp[x]>COMBUSTION_TEMP then
            combustionTemp[x] = (combustionTemp[x] + COMBUSTION_TEMP)/2
        end
    end
end
function updatePlamaOutput()
    for x=1,4 do
        plasmaOutput[x] = (piFuelInput[x]*PLASMA_COMBUSTION_POWER/9)/100
    end
end
function updateCellPlasma()
    for x=1,4 do
        cellPD[x] = cellPD[x] + plasmaOutput[x]/CELL_PLASMA_DIVIDER
    end
end
function piUpdate()
    updateCombustionTemps()
    updatePiTemps()
    updatePlamaOutput()
end
function cellUpdate()
    updateCellPlasma()
end

piFuelInput[1] = 80
while true do
    piUpdate()
    cellUpdate()
    print(cellPD[1])
    wait(0.1)
end