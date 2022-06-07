-- FoundForces & idontthinkofacool --

-- Big thanks to idontthinkofacool for helping to test the functions and his 1e1e308 limit bignum
-- Note if you get as awnser back {1, -1, 1} then either math domain error or no solution.
-- Example: logx(50 , 1) = {1, -1, 1} because 1^x = always 1 

-------------------------------------------

-- List of functions: 
--[[
	.add(x, y) -- add x with y
	.sub(x, y) -- subtract x with y
	.mul(x, y) -- multiply x with y
	.div(x, y) -- divide x with y
	.abs(x) -- absolute value x
	.le(x, y) -- is x < y ?
	.me(x, y) -- is x > y ?
	.eq(x, y) -- is x = y ?
	.leeq(x, y) -- is x <= y ?
	.meeq(x, y) -- is x >= y ?
	.convert(x) -- convert x to eternitynum (x)
	.floattobnum(x) -- convert x to eternitynum (x)
	.errorcorrect(x) -- corrects a eternitynum (x)
	.nocorrect(x) -- doesnt correct a eternitynum (x)
	.log(x) -- gets log of x
	.neg(x) -- negates x
	.exp(x) -- exp x
	.maxabs(x, y) -- gets the biggest abs of x , y
	.bnumtoeternity(x) -- convert bnum to eternitynum
	.eternitytobnum(x) -- convert eternitynum to bnum
	.recip(x) -- reciprocate x
	.pow(x,y) -- x ^ y
	.pow10(x) -- 10 ^ x
	.abslog10(x) -- log10(abs(x))
	.log10(x) -- log10(x)
	.logx(x, y) -- log[y](x)
	.tentetration(str) -- input: ^^x , = 10^^x or input: = ^^x;y = (10^^x)^y
	.short(x) -- Convert x to suffix when possible else convert it to {X}E#X1
	.strtobnum(x) -- inputs: XeN  = X * 10^N, XptY = 10^10..^10 ^ Y (X 10's),  X;YeZ = eee...eeeYeZ                                    
	.root(x, y) -- y√(x)
	.sqrt(x) -- √(x)
	.gamma(x) -- (x-1)!
	.fact(x) -- x!
	.floor(x) -- if decimal round down
	.ceil(x) -- if decimal roundd up
	.engineer(x) -- if > 1e1e308 convert to engineers notation
	.totet(x) -- converts bnum to tet
	.bnumtostr(x) -- converts bnum to string
	.bnumtoe(x) -- for notation converts to ee...eeeX
	.shift(x, y) -- rounds to y-1 amount of digits
	.rand(min, max) -- random number
	.bnumtoes(value) -- bnum to E(x)y = ee...eey (x e's)
	.bnumtoscientific(value) -- convert bnum to XeN
	.bnumtotet(value) -- Bnum to 10^^x;y
	.globalshort(value, nota) -- shorts bnum (nota = string with notation name)
	.lbencode(enum) -- encode a bnum to be used for leaderboards
	.lbdecode(enum) -- decode a bnum to b used for leaderboards
	.mod(x,y) -- x mod y
	.hyperpow(val) -- x^(10^x!)
	.cos(val) -- cos(val)
]]

-------------------------------------------

--[[
	How to use:
	
	Every function accepts all types of inputs, Example: add(1, 1) , add({1,0,1},1) ect.
	If you want to convert a Bignum ( {X, y} ) to Eternitynum ( {x,y,z} ) use function .bnumtoeternity(bnum)
	
	Examples:
	(Spaces are just to make it better readable)
	
	-- How do i multiply 1 + 5 by 3? :
	.mul( .add (1, 5), 3 )
	
	-- How do i do 10 ^ log6(10) ?
	.pow10( .logx( 10, 6 ) )
	
	-- How do i do 14 ^ log(3)  * 3 ?
	.mul( .pow( 14, .log(3) ), 3)
]]

-------------------------------------------

local msd = 17 -- max sig digits
local expl = 1e10 -- exponent limit
local ldown = math.log10(1e10) -- value of layerdown
local fnl = 1/1e10 -- stuff
local nema = 308 -- largest exponent
local nemi = -324 -- smallest exponent
local maxe = 5 -- max e's in a row
local breakpointe = 10 -- breaking point of bnumtoe (when does it switch over to E(x)x1)
local suffixlim = '1e9E15' -- where suffixes convert to E(x)x1
local digitsdisplay = 3 -- amount of digits when you convert bnum to notation
local breakpointsuffixe = 3006 -- when it should turn into scientific on EN.abbreviate
local ZERO = {1, {0}} -- Zero constant
local ONE = {1,{1}}
local NAN = 0/0 -- NAN constant.
local INF = 2e308 -- INF constant.
local maxInt = 2^53-1

-----------------------------------------

-- BigNum Functions --

function copytab(v)
	local new = {}
	new[1] = v[1]
	new[2] = {}
	for i,v in next, v[2] do
		new[2][i] = v
	end
	return new
end 

function commas(Value)
	if Value < 1e3 then 
		return Value
	end
	local Number
	local Formatted = math.floor(Value * 100) / 100
	if Value < 10^13 then
		while (Number ~= 0) do
			Formatted, Number = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		end 
		return Formatted
	elseif Value < 10^26 then
		local Formatted2 = math.floor(Value / 10^12)
		Formatted = math.fmod(Value, 10^12)
		while Number ~= 0 do  
			Formatted2, Number = string.gsub(Formatted2, "^(-?%d+)(%d%d%d)", '%1,%2')
		end 
		Number = nil
		while Number ~= 0 do   
			Formatted, Number = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		end 
		local TpFormatted = math.fmod(Value, 10^12)
		local String = Formatted2 .. ","
		if TpFormatted == 0 then
			String ..= "000,000,000,000"
		elseif TpFormatted < 10 then
			String ..= "000,000,000,00"
		elseif TpFormatted < 100 then
			String ..= "000,000,000,0"
		elseif TpFormatted < 1000 then
			String ..= "000,000,000,"
		elseif TpFormatted < 10000 then
			String ..= "000,000,00"
		elseif TpFormatted < 100000 then
			String ..= "000,000,0"
		elseif TpFormatted < 1000000 then
			String ..= "000,000,"
		elseif TpFormatted < 10000000 then
			String ..= "000,00"
		elseif TpFormatted < 100000000 then
			String ..= "000,0"
		elseif TpFormatted < 1000000000 then
			String ..= "000,"
		elseif TpFormatted < 10000000000 then
			String ..= "00"
		elseif TpFormatted < 100000000000 then
			String ..= "0"
		end
		if TpFormatted > 0 then
			String ..= Formatted
		end
		return String
	else
		return "9,999,999,999,999,999,999,999,999,999+"
	end
end

function short(bnum)
	bnum = errorcorrection(bnum)
	local SNumber = bnum[2]
	local SNumber1 = bnum[1]
	local leftover = math.fmod(SNumber, 3)
	SNumber = math.floor(SNumber / 3)
	SNumber = SNumber - 1
	if SNumber <= -1 then
		return math.floor(bnumtofloat(bnum)*100)/100	
	end
	local FirstOnes = {"", "U","D","T","q","Q","s","S","O","N"}
    local SecondOnes = {"", "d","v","t","qg","Qg","sg","Sg","o","n"}
    local ThirdOnes = {"", "C", "Du","Tr","Qa","Qi","Se","Si","Ot","Ni"}
    local MultOnes = {"", "Mi","Mc","Na","Pi","Fm","At","Zp","Yc", "Xo", "Ve", "Me", "Due", "Tre", "Te", "Pt", "He", "Hp", "Oct", "En", "Ic", "Mei", "Dui", "Tri", "Teti", "Pti", "Hei", "Hp", "Oci", "Eni", "Tra","TeC","MTc","DTc","TrTc","TeTc","PeTc","HTc","HpT","OcT","EnT","TetC","MTetc","DTetc","TrTetc","TeTetc","PeTetc","HTetc","HpTetc","OcTetc","EnTetc","PcT","MPcT","DPcT","TPCt","TePCt","PePCt","HePCt","HpPct","OcPct","EnPct","HCt","MHcT","DHcT","THCt","TeHCt","PeHCt","HeHCt","HpHct","OcHct","EnHct","HpCt","MHpcT","DHpcT","THpCt","TeHpCt","PeHpCt","HeHpCt","HpHpct","OcHpct","EnHpct","OCt","MOcT","DOcT","TOCt","TeOCt","PeOCt","HeOCt","HpOct","OcOct","EnOct","Ent","MEnT","DEnT","TEnt","TeEnt","PeEnt","HeEnt","HpEnt","OcEnt","EnEnt","Hect", "MeHect"}
	if bnum[2] == 1/0 then
		if bnum[1] < 0 then
			return "-Infinity"
		else
			return "Infinity"
		end
	end
	-- suffix part
	if SNumber == 0 then
		return commas(bnumtofloat(bnum))
	elseif SNumber == 1 then
		return math.floor(SNumber1 * 10^leftover * 100)/100 .. "M"
	elseif SNumber == 2 then
		return math.floor(SNumber1 * 10^leftover * 100)/100 .. "B"
	end
	local txt = ""	
	local function suffixpart(n)		
		local Hundreds = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n/1)		
		txt = txt .. FirstOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]		
	end
	local function suffixpart2(n)
		if n > 0 then
			n = n + 1
		end
		if n > 1000 then
			n = math.fmod(n, 1000)
		end
		local Hundreds = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n/1)		
		txt = txt .. FirstOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]		
	end	
	if SNumber < 1000 then
		suffixpart(SNumber)
		return math.floor(SNumber1 * 10^leftover * 100)/100 .. txt
	end	
	for i = #MultOnes,0,-1 do
		if SNumber >= 10^(i*3) then
			suffixpart2(math.floor(SNumber / 10^(i*3))- 1)
			txt = txt .. MultOnes[i+1]			
			SNumber = math.fmod(SNumber, 10^(i*3))
		end
	end
	return math.floor(SNumber1 * 10^leftover * 100)/100 .. txt
end

function othershort(bnum)
	local function addComas(str)
		local str = tostring(str)
		return #str % 3 == 0 and str:reverse():gsub("(%d%d%d)", "%1,"):reverse():sub(2) or str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	end
	bnum = errorcorrection(bnum)
	local SNumber = bnum[2]
	local SNumber1 = bnum[1]
	SNumber = SNumber - 2
	local leftover = math.fmod(SNumber, 3)
	SNumber = math.floor(SNumber / 3)
	SNumber = SNumber - 1
	if SNumber <= -1 then
		return addComas(math.floor(bnumtofloat(bnum)+0.5))
	end
	local FirstOnes = {"", "U","D","T","q","Q","s","S","O","N"}
    local SecondOnes = {"", "d","v","t","qg","Qg","sg","Sg","o","n"}
    local ThirdOnes = {"", "C", "Du","Tr","Qa","Qi","Se","Si","Ot","Ni"}
    local MultOnes = {"", "Mi","Mc","Na","Pi","Fm","At","Zp","Yc", "Xo", "Ve", "Me", "Due", "Tre", "Te", "Pt", "He", "Hp", "Oct", "En", "Ic", "Mei", "Dui", "Tri", "Teti", "Pti", "Hei", "Hp", "Oci", "Eni", "Tra","TeC","MTc","DTc","TrTc","TeTc","PeTc","HTc","HpT","OcT","EnT","TetC","MTetc","DTetc","TrTetc","TeTetc","PeTetc","HTetc","HpTetc","OcTetc","EnTetc","PcT","MPcT","DPcT","TPCt","TePCt","PePCt","HePCt","HpPct","OcPct","EnPct","HCt","MHcT","DHcT","THCt","TeHCt","PeHCt","HeHCt","HpHct","OcHct","EnHct","HpCt","MHpcT","DHpcT","THpCt","TeHpCt","PeHpCt","HeHpCt","HpHpct","OcHpct","EnHpct","OCt","MOcT","DOcT","TOCt","TeOCt","PeOCt","HeOCt","HpOct","OcOct","EnOct","Ent","MEnT","DEnT","TEnt","TeEnt","PeEnt","HeEnt","HpEnt","OcEnt","EnEnt","Hect", "MeHect"}
	if bnum[2] == 1/0 then
		if bnum[1] < 0 then
			return "-Infinity"
		else
			return "Infinity"
		end
	end
	-- suffix part
	if SNumber == 0 then
		return addComas(math.floor(SNumber1 * 10^leftover * 100)) .. "k"
	elseif SNumber == 1 then
		return addComas(math.floor(SNumber1 * 10^leftover * 100)) .. "M"
	elseif SNumber == 2 then
		return addComas(math.floor(SNumber1 * 10^leftover * 100)) .. "B"
	end
	local txt = ""	
	local function suffixpart(n)		
		local Hundreds = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n/1)		
		txt = txt .. FirstOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]		
	end
	local function suffixpart2(n)
		if n > 0 then
			n = n + 1
		end
		if n > 1000 then
			n = math.fmod(n, 1000)
		end
		local Hundreds = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n/1)		
		txt = txt .. FirstOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]		
	end	
	if SNumber < 1000 then
		suffixpart(SNumber)
		return addComas(math.floor(SNumber1 * 10^leftover * 100)) .. txt
	end	
	for i = #MultOnes,0,-1 do
		if SNumber >= 10^(i*3) then
			suffixpart2(math.floor(SNumber / 10^(i*3))- 1)
			txt = txt .. MultOnes[i+1]			
			SNumber = math.fmod(SNumber, 10^(i*3))
		end
	end
	return addComas(math.floor(SNumber1 * 10^leftover * 100)) .. txt
end

function suffix(bnum)
	bnum = errorcorrection(bnum)
	local SNumber = bnum[2]
	local SNumber1 = bnum[1]
	local leftover = math.fmod(SNumber, 3)
	SNumber = math.floor(SNumber / 3)
	SNumber = SNumber - 1
	if SNumber <= -1 then
		return ""
	end
	local FirstOnes = {"", "Un","Duo","Tre","Quattor","Quin","Sext","Septen","Octo","Novem"}
    local SecondOnes = {"", "Deci","Viginti","Triginti","Quadraginti","Quinquaginti","Sexagi","Septuaginti","Octogenti","Nonaginti"}
    local ThirdOnes = {"", "Centi","Ducenti","Tricenti","Quadrigenti","Quigenti","Sexticenti","Septengi","Octicenti","Noncenti"}
    local MultOnes = {"", "Millini","Micri","Nani","Pici","Femti","Atti","Zepti","Yocti","Xoni","Veci","Meci","Dueci","Treci","Tetreci","Penteci","Hecteci","Hepteci","Octeci","Eneci","Icoci", "Mei", "Dui", "Tri", "Teti", "Pti", "Hei", "Hp", "Oci", "Eni", "Tra","TeC","MTc","DTc","TrTc","TeTc","PeTc","HTc","HpT","OcT","EnT","TetC","MTetc","DTetc","TrTetc","TeTetc","PeTetc","HTetc","HpTetc","OcTetc","EnTetc","PcT","MPcT","DPcT","TPCt","TePCt","PePCt","HePCt","HpPct","OcPct","EnPct","HCt","MHcT","DHcT","THCt","TeHCt","PeHCt","HeHCt","HpHct","OcHct","EnHct","HpCt","MHpcT","DHpcT","THpCt","TeHpCt","PeHpCt","HeHpCt","HpHpct","OcHpct","EnHpct","OCt","MOcT","DOcT","TOCt","TeOCt","PeOCt","HeOCt","HpOct","OcOct","EnOct","Ent","MEnT","DEnT","TEnt","TeEnt","PeEnt","HeEnt","HpEnt","OcEnt","EnEnt","Hect", "MeHect"}
	if bnum[2] == 1/0 then
		if bnum[1] < 0 then
			return "-Infinity"
		else
			return "Infinity"
		end
	end
	-- suffix part
	if SNumber == 0 then
		return "Thousand"
	elseif SNumber == 1 then
		return "Million"
	elseif SNumber == 2 then
		return "Billion"
	elseif SNumber == 3 then
		return "Trillion"
	elseif SNumber == 4 then
		return "Quadrillion"
	elseif SNumber == 5 then
		return "Quintillion"
	elseif SNumber == 6 then
		return "Sextillion"
	elseif SNumber == 7 then
		return "Septillion"
	elseif SNumber == 8 then
		return "Octillion"
	elseif SNumber == 9 then
		return "Nonillion"
	end
	local txt = ""	
	local function suffixpart(n)		
		local Hundreds = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n/1)		
		txt = txt .. FirstOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]		
	end
	local function suffixpart2(n)
		if n > 0 then
			n = n + 1
		end
		if n > 1000 then
			n = math.fmod(n, 1000)
		end
		local Hundreds = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n/1)		
		txt = txt .. FirstOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]		
	end	
	if SNumber < 1000 then
		suffixpart(SNumber)
		return txt .. "llion"
	end	
	for i = #MultOnes,0,-1 do
		if SNumber >= 10^(i*3) then
			suffixpart2(math.floor(SNumber / 10^(i*3))- 1)
			txt = txt .. MultOnes[i+1]			
			SNumber = math.fmod(SNumber, 10^(i*3))
		end
	end
	return txt .. "llion"
end

function scinot(bnum)
	local bnum0 = errorcorrection(bnum)
	if bnum0[1] == 0 and bnum0[2] == 0 then
		return "0"
	end
	return tostring(math.floor(bnum0[1] * 1000) / 1000 .. "e" .. bnum0[2])
end

function abbreviate(bnum)
	if bnum[2] > 3005 then
		return scinot(bnum)
	else
		return short(bnum)
	end
end

function strtobnum(str)
	local Synapse = string.find(str, "e")
	return {tonumber(string.sub(str, 1, Synapse-1)), tonumber(string.sub(str, Synapse+1))}
end

function bnumtofloat(bnum)	
	return tonumber(bnumtostr(bnum))
end

function convert(str)	
	if type(str) == "table" then
		return str
	end		
	if tonumber(str) == nil then
		local V,Uw = pcall(function()
			return strtobnum(str) 
		end)
		if V then
			return strtobnum(str)
		else
			return "0"
		end
	end
	if type(str) == "number" then
		if tonumber(str) == 1/0 or  tonumber(str) == -1/0 then
			return {1, 1.797693e308}
		end
	end
	if tonumber(str) == 1/0 or  tonumber(str) == -1/0 then
		return strtobnum(str)		
	elseif tostring(tonumber(str)) == "nil" then
		return strtobnum(str)
	else		
		return floattobnum(tonumber(str))
	end	
end

function new(man,exp)	
	return {man, exp}
end

function floattobnum(float)
	local ZeN = tostring(float)
	local Synapse = string.find(ZeN, "+")	
	if Synapse then
		return strtobnum(string.sub(ZeN, 1, Synapse-1) .. string.sub(ZeN, Synapse+1))
	elseif string.find(ZeN, "e") then
		return strtobnum(ZeN)
	else
		return errorcorrection(strtobnum(ZeN .. "e0")	)
	end	
end

function bnumtostr(bnum)	
	return tostring(bnum[1]) .. "e" .. tostring(bnum[2])
end

function errorcorrection(bnum)	
	local signal = "+"
	if bnum[1] == 0 then
		return {0, 0}
	end
	if bnum[1] < 0 then
		signal = "-"
	end
	if signal == "-" then
		bnum[1] = bnum[1] * -1
	end
	local signal2 = "+"
	if bnum[2] < 0 then
		signal2 = "-"
		bnum[2] = bnum[2] * -1
	end
	if math.fmod(bnum[2], 1) > 0 and signal2 == "-" then
		bnum[1] = bnum[1] * (10^ (1 - math.fmod(bnum[2], 1)))
		bnum[2] = math.floor(bnum[2]) + 1
	elseif math.fmod(bnum[2], 1) > 0 and signal2 == "+"  then
		bnum[1] = bnum[1] * (10^  math.fmod(bnum[2], 1))
		bnum[2] = math.floor(bnum[2])
	end
	if signal2 == "-" then
		bnum[2] = bnum[2] * -1		
	end
	local DgAmo = math.log10(bnum[1])
	DgAmo = math.floor(DgAmo)
	bnum[1] = bnum[1] / 10^DgAmo
	bnum[2] = bnum[2] + DgAmo	
	bnum[2] = math.floor(bnum[2])
	if signal == "-" then
		bnum[1] = bnum[1] * -1		
	end
	return bnum
end	

function engineer(bnum)    
    if math.fmod(bnum[2], 3) ~= 0 then        
        local ree = bnum[2]       
        bnum[2] = bnum[2] - math.fmod(bnum[2], 3)       
        bnum[1] = bnum[1] * 10 ^ math.fmod(ree, 3)                
        return bnumtostr(shift(bnum,4))
        
    end
    
    return bnumtostr(shift(bnum,4))
end

function div(bnum1, bnum2)	
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)
	local bnum3 = new(0, 0)
	bnum3[1] = bnum1[1] / bnum2[1]
	bnum3[2] = bnum1[2] - bnum2[2]
	bnum3 = errorcorrection(bnum3)
	return bnum3
end
	
function mul(bnum1, bnum2)
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)
	local bnum3 = new(0, 0)
	bnum3[1] = bnum1[1] * bnum2[1]
	bnum3[2] = bnum1[2] + bnum2[2]
	bnum3 = errorcorrection(bnum3)
	return bnum3
end
	
function log10(bnum)
	local LogTen = bnum[2] + math.log10(bnum[1])
	return errorcorrection(new(LogTen, 0))
end
	
function eq(bnum1, bnum2)
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)
	if bnum1[1] == bnum2[1] then
		if bnum1[2] == bnum2[2] then
			return true
		end
	end
	return false
end
	
function le(bnum1, bnum2)
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)
	local signal = "+"
	local signal2 = "+"
	if bnum1[1] < 0 then
		signal = "-"
	end
	if bnum2[1] < 0 then
		signal2 = "-"
	end
	if signal == "+" and signal2 == "-" then
		return false
	elseif signal == "-" and signal2 == "+" then
		return true
	elseif signal == "-" and signal2 == "-" then
		if bnum1[2] > bnum2[2] then
			-- passed test 1.
			return true
		end
		if bnum1[2] < bnum2[2] then
			-- passed test 1.			
			return false
		end
		if bnum1[1] < bnum2[1] then
			-- passed test 2.
			return true
		end	
	elseif signal == "+" and signal2 == "+" then
		if bnum1[2] < bnum2[2] then
			-- passed test 1.
			return true
		end
		if bnum1[2] > bnum2[2] then
			-- passed test 1.			
			return false
		end
		if bnum1[1] < bnum2[1] then
			-- passed test 2.
			return true
		end	
	end	
	return false
end

function me(bnum1, bnum2)
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)
	local signal = "+"
	local signal2 = "+"
	if bnum1[1] < 0 then
		signal = "-"
	end
	if bnum2[1] < 0 then
		signal2 = "-"
	end
	if signal == "+" and signal2 == "-" then
		return true
	elseif signal == "-" and signal2 == "+" then
		return false
	elseif signal == "-" and signal2 == "-" then
		if bnum1[2] < bnum2[2] then
			-- passed test 1.
			return true
		end 
		if bnum1[2] < bnum2[2] then
			-- passed test 1.			
			return false
		end
		if bnum1[1] > bnum2[1] then
			-- passed test 2.
			return true
		end	
	elseif signal == "+" and signal2 == "+" then			
		if bnum1[2] > bnum2[2] then
			-- passed test 1.			
			return true
		end
		if bnum1[2] < bnum2[2] then
			-- passed test 1.			
			return false
		end		
		if bnum1[1] > bnum2[1] then
			-- passed test 2.			
			return true		
		end		
	end
	return false
end

function leeq(bnum1, bnum2)
	local Se1 = eq(bnum1,bnum2)
	local Se2 = le(bnum1,bnum2)
	if Se1 or Se2 then
		return true
	end
	return false
end

function meeq(bnum1, bnum2)
	local Se1 = eq(bnum1,bnum2)
	local Se2 = me(bnum1,bnum2)
	if Se1 or Se2 then
		return true
	end
	return false
end

function add(bnum1, bnum2)
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)
	local bnum3 = new(0,0)
	local Diff = bnum2[2] - bnum1[2]
	if Diff > 20 then
		return bnum2
	elseif Diff < - 20 then
		return bnum1
	else
		bnum3[2] = bnum1[2]
		bnum3[1] = bnum1[1] + (bnum2[1] * 10^Diff)
	end
	bnum3 = errorcorrection(bnum3)
	return bnum3
end

function sub(bnum1, bnum2)
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)
	local bnum3 = new(0,0)
	local Diff = bnum2[2] - bnum1[2]
	if Diff > 20 then
		bnum3 = new(bnum1[1] * -1, bnum2[2])
	elseif Diff < - 20 then
		return bnum1
	else
		bnum3[2] = bnum1[2]
		bnum3[1] = bnum1[1] - (bnum2[1] * 10^Diff)
	end
	bnum3 = errorcorrection(bnum3)
	return bnum3
end

function pow(bnum1, bnum2)
	if bnum1[1] < 0 then
		return {1, "Unsupported"}
	end
	if bnum1[1] == 0 and bnum2[2] == 0 then
		warn("I agree that 0 ^ 0 is 0.5")
		return {0.5, 0}
	elseif bnum2[1] == 0 then
		return {1, 0}
	elseif bnum1[1] == 0 then
		return {0, 0}	
	end	
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)
	local bnum3 = {0, 0}
	local N = log10(bnum1)
	N = bnumtofloat(N)	
	N = N * bnumtofloat(bnum2)
	bnum3[2] = N
	bnum3[1] = 1
	return errorcorrection(bnum3)
end

function doublepow(bnum1, bnum2)
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)	
	return pow(bnum1, pow(bnum2, bnum2))
end

function sqrt(bnum1)
	bnum1 = errorcorrection(bnum1)	
	return pow(bnum1, {5, -1})
end

function pi()
	return {3.141592653589793238462643383279502884197169399375105820974, 0}
end

function e()
	return {2.718281828459045235360287471352662497757247093699959574966, 0}
end

function gr()
	return {1.618033988749894848204586834365638117720309179805762862135, 0}
end

function two()
	return {2, 0}
end

function ten()
	return {1, 1}
end

function logx(bnum1, bnum2)
	local b = bnumtofloat(bnum2)
	local LogTen = bnum1[2] + math.log10(bnum1[1])
	LogTen = LogTen / math.log10(b)	
	return errorcorrection(new(LogTen, 0))
end

function log(bnum)
	local b = bnumtofloat(e())
	local LogTen = bnum[2] + math.log10(bnum[1])
	LogTen = LogTen / math.log10(b)	
	return errorcorrection(new(LogTen, 0))
end

function fact(bnum)
	-- Estimated Error: (n+1) ^ 5
	-- Computing LogTwo...	
	-- Currently In Beta
	local TwoPin = mul(pi(), two())
	local res2 = div({1/12, 0}, bnum)
	local res3 =  div({1/360, 0}, pow(bnum, {3, 0}))	
	-- Computing Res...
	TwoPin = mul(TwoPin, bnum)
	TwoPin = sqrt(TwoPin)
	res2 = sub(res2, res3)
	res2 = pow(e(), res2)
	res3 = div(bnum, e())
	res3 = pow(res3, bnum)
	res3 = mul(res3, TwoPin)	
	local Final = mul(res2, res3)
	if Final[2] <= -1 and Final[1] > 9.99 then
		Final[2] = -1
	elseif Final[2] <= -1 then
		Final[2] = 0	
	end	
	return Final
end

function gamma(bnum)
	-- Estimated Error: (n+1) ^ 5
	-- Computing LogTwo...	
	-- Currently In Beta
	return fact(sub(bnum, {1, 0}))
end

function doublefactOdd(bnum)
	-- Estimated Error: (n+1) ^ 5
	-- Computing LogTwo...	
	-- Currently In Beta
	-- If Even then
	if eq(bnum, {1, 0}) then
		return {1, 0}
	end
	return mul(sqrt(div(pow({2, 0}, add(bnum, {1, 0})), pi())), fact(div(bnum, two())))
end

function doublefactEven(bnum)
	-- Estimated Error: (n+1) ^ 5
	-- Computing LogTwo...	
	-- Currently In Beta
	-- If Even then
	local Num =  fact(div(bnum, {2, 0}))
	return mul(pow{2, div(bnum, {2, 0})}, Num)
end

function rand(bnum1, bnum2)
	--print(bnumtostr(bnum1), bnumtostr(bnum2))
	local Ye = convert(math.random())	
	local bnum3 = mul(Ye, sub(bnum1, bnum2))
	bnum3 = add(bnum3, bnum2)
	return bnum3
end

function fmod(bnum1, bnum2)	
	-- To precisely do mod, you must get 64 things:
	-- 1.
	bnum1 = errorcorrection(bnum1)
	bnum2 = errorcorrection(bnum2)	
	local MultiplyBy = bnum2
	local origexp = bnum2[1]
	local origtet = bnum2[2]
	bnum2[2] = bnum1[2]
	if bnum1[2] > bnum2[2] then
		bnum2[2] = bnum1[2] - 1
	end
	local M = 0
	repeat
		local VT = div(bnum1, bnum2)
		VT = floor(VT)
		VT = mul(VT, bnum2)
		bnum1 = sub(bnum1, VT)		
		bnum2[2] = bnum2[2] - 1
	until le(bnum1, {origexp, origtet})
	if eq(bnum1, abs(bnum1)) then
	else
		return fmod(abs(bnum1), {origexp, origtet})
	end	
	return bnum1
end

function expoRand(bnum1, bnum2)	
	local Ye = convert(rand(log10(bnum1),log10(bnum2)))	
	local bnum3 = pow(ten(), Ye)
	return bnum3
end

function abs(bnum1)	
	return {math.abs(bnum1[1]), bnum1[2]}
end

function between(bnum1, bnum2, bnum3)	
	return leeq(bnum1, bnum3) and meeq(bnum1, bnum2)	
end

function floor(bnum1)
	if meeq(bnum1, {1, 16}) or  leeq(bnum1, {-1, 16}) then
		return bnum1
	end
	return convert(math.floor(bnumtofloat(bnum1)))
end

function ceil(bnum2)
	if meeq(bnum2, {1, 16}) or  leeq(bnum2, {-1, 16}) then
		return bnum2
	end
	return convert(math.ceil(bnumtofloat(bnum2)))
end

function round(bnum2)	
	return floor(add(bnum2, {5, -1}))
end

function shift(bnum2, digits)
	--- digits must be float ---	
	return {math.floor(bnum2[1] * 10^digits) / 10^digits, bnum2[2]}
end

-- Other Functions --

trunc = function(n)
	if math.ceil(n) == n then 
		return n 
	end
	if n < 0 then
		return -(math.floor(n))
	end
	return math.floor(n)
end

function fgamma(n)	
	if n > 1.79e308 then 
		return n 
	end -- check if inf	
	if n < -50 then
		if n == trunc(n) then -- no
			return -(1.8e308)
		end
		return 0
	end	
	local scal1 = 1
	while n < 10 do		
		scal1 = scal1*n		
		n = n+1		
	end	
	n = n - 1	
	local l = 0.9189385332046727
	l = l + (n+0.5)*math.log(n)
	l = l - n	
	local n2 = n * n
	local np = n	
	l = l+1/(12*np)
	np = np*n2	
	l = l+1/(360*np)
	np = np*n2
	l = l+1/(1260*np)
	np = np*n2
	l = l+1/(1680*np)
    np = np*n2
    l = l+1/(1188*np)
    np = np*n2
    l = l+691/(360360*np)
    np = np*n2
    l = l+7/(1092*np)
    np = np*n2
    l = l+3617/(122400*np)
    return math.exp(l)/scal1
end

local twopi = 6.2831853071795864769252842  --2*pi
local EXPN1 = 0.36787944117144232159553  --exp(-1)
local OMEGA = 0.56714329040978387299997  --W(1, 0)

function f_lambertw(z)	
	local tol = 1e-10
	local w,wn = nil	
	if z > 1.79e308 then 
		return z		
	end	
	if z == 0 then
		return z
	end	
	if z == 1 then
		return OMEGA
	end	
	if z < 10 then
		w = 0
	else
		w = math.log(z)-math.log(math.log(z))
	end	
	for i=1,100 do		
		wn = (z * math.exp(-w) + w * w)/(w + 1)		
		if math.abs(wn - w) < tol*math.abs(wn) then			
			return wn			
		else
			w = wn
		end		
	end
	error('Failed to itterate z.... at function: f_lambertw, line = ?')
end

-- EternityNum Functions --

local ree = {}

function ree.convert(input)
	return ree.floattobnum(input)
end

function ree.floattobnum(value)	
	if type(value) == 'number' then 		
		local num = {}		
		num[1] = math.sign(value)
		num[2] = 0
		num[3] = math.abs(value)
		return ree.errorcorrect(num)
	end	
	if type(value) == 'string' then		
		return ree.strtobnum(value)		
	end	
	if type(value) == 'table' then		
		if #value == 2 then			
			return ree.bnumtoeternity(value)			
		end		
		return ree.errorcorrect(value)		
	end	
	return {1, -1, 1}	
end

function ree.strtobnum(value) -- first input = XeN, -- XptY = 10^10..^10 ^ Y (X 10's), X;YeZ = eee...eeeYeZ	
	local lol = nil	
	lol = string.split(value, 'e')	
	if #lol == 2 then
		if string.find(lol[1], ';') or string.find(lol[2], ';') then			 
		else			
			return ree.bnumtoeternity(convert(value))				
		end		
	end	
	lol = string.split(value, 'pt')	
	if #lol == 2 then		
		local str = '^^'.. lol[1] .. ';' .. lol[2]		
		return ree.tentetration(str)		
	end	
	lol = string.split(value, ';')	
	if #lol == 2 then	
		local idk = tonumber(lol[2])	
		local sign = 1	
		if tonumber(lol[1]) < 0 then						
			lol[1] = math.abs(lol[1])
			sign = -1		
		end		
		return ree.errorcorrect({sign, tonumber(lol[1]), idk})				
	end		
	lol = string.split(value, '^^')	
	if #lol == 2 then		
		return ree.tentetration(value)		
	end
	return ree.floattobnum(tonumber(value))
end

function ree.errorcorrect(bnum)	
	local first = bnum[1]
	local layers = bnum[2]
	local last = bnum[3]	
	if first == 0 or (last == 0 and layers == 0) then		
		return {0,0,0}		
	end	
	if layers == 0 and last < 0 then		
		last = -last
		first = -first		
	end	
	if layers == 0 and last < fnl then		
		layers = layers + 1		
		last = math.log10(last)
		return {first, layers, last}	
	end	
	local absm = math.abs(last)
	local signm = math.sign(last)	
	if absm >= expl then		
		layers = layers + 1		
		last = signm * math.log10(absm)		
		return {first, layers, last}		
	else		
		while absm < ldown and layers > 0 do		
			layers = layers - 1		
			if layers == 0 then
				last = math.pow(10, last)						
			else			
				last = signm*math.pow(10, absm)
				absm = math.abs(last)
				signm = math.sign(last)				
			end		
		end	
		if layers == 0 then			
			if last < 0 then				
				last = -last
				first = -first				
			end			
		elseif last == 0 then				
			first = 0			
		end		
	end
	return {first, layers, last}
end

function ree.nocorrect(first, layers , last)	
	return {first, layers, last}	
end

function ree.log(value)	
	value = ree.floattobnum(value)	
	if ree.le(value, 0) then		
		return {1, -1, 1}		
	end	
	if ree.eq(value, 0) then		
		return {1, -1, 1}		
	end	
	if value[1] <= 0 then		
		return 0		
	elseif value[2] == 0 then		
		return ree.errorcorrect({value[1], 0, math.log(value[3])})		
	elseif value[2]	== 1 then				
		return ree.errorcorrect({math.sign(value[3]), 0, math.abs(value[3])*2.302585092994046})		
	elseif value[2] == 2 then				
		return ree.errorcorrect({math.sign(value[3]), 1, math.abs(value[3])+0.36221568869946325})
	else	
		return ree.errorcorrect({math.sign(value[3]), value[2]-1, math.abs(value[3])})	
	end		
end

function ree.neg(value)
	return {-value[1], value[2], value[3]}
end

function ree.le(value, value2)	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	if cmp(value, value2) == -1 then
		return true
	end
	return false
end

function ree.me(value, value2)	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	if cmp(value, value2) == 1 then
		return true
	end
	return false
end

function ree.eq(value, value2)	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	if cmp(value, value2) == 0 then
		return true
	end
	return false
end

function ree.leeq(value, value2)	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	if cmp(value, value2) == -1 or cmp(value, value2) == 0 then
		return true
	end
	return false
end

function ree.meeq(value, value2)	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	if cmp(value, value2) == 1 or cmp(value, value2) == 0 then
		return true
	end
	return false
end

function cmp(value, value2)	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	if value[1] > value2[1] then  
		return 1 
	end
    if value[1] < value2[1] then 
		return -1 
	end
    return value[1]*cmpabs(value, value2)	
end

function cmpabs(value, value2) -- finish this then move back to lambertw	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	local layera = nil
	if value[3]  > 0 then		
		 layera = value[2]
	else
		layera = -value[2]
	end	
	local layerb = nil
	if value2[3]  > 0 then		
		 layerb = value2[2]
	else
		layerb = -value2[2]
	end	
	if layera > layerb then 
		return 1 
	end	
	if layera < layerb then 
		return -1 
	end	
	if value[3] > value2[3] then 
		return 1 
	end	
	if value[3] < value2[3] then 
		return -1 
	end	
	return 0	
end

function ree.bnumtofloat(value)
	value = ree.floattobnum(value)	
	if value[2] > 1.79e308 then		
		return 1.8e309		
	end	
	if value[2] == 0 then				
		return value[1] * value[3]		
	elseif value[2] == 1 then			
		return value[1] * math.pow(10, value[3])		
	else			
		return 1.8e309		
	end	
end

function ree.abs(value)	
	value = ree.floattobnum(value)	
	if value[1] == 0 then		
		return 0		
	else			
		return {1, value[2], value[3]}				
	end	
end

function ree.exp(value)	
	value = ree.floattobnum(value)	
	if value[3] < 0 then 
		return {1, 0, 1} 
	end	
	if value[2] == 0 and value[3] <= 709.7 then		
		return ree.floattobnum(math.exp(value[1]*value[3]))	
	elseif value[2] == 0 then		
		return {1,1, value[1]*math.log10(2.718281828459045)*value[3]}	
	elseif value[2] == 1 then		
		return {1, 2, value[1]*(math.log10(0.4342944819032518)+value[3])}	
	else		
		return {1, value[2]+1, value[1]*value[3]}																																																							
	end	
end

function ree.sub(value, value2)	
	value = ree.floattobnum(value)	
	value2 = ree.floattobnum(value2)
	return ree.add(value, ree.neg(value2))	
end

function ree.add(value, value2)  
    value = ree.floattobnum(value)    
    value2 = ree.floattobnum(value2)        
    if value[2] > 1.79e308 then 
		return value 
	end   
    if value2[2] > 1.79e308 then 
		return value2 
	end    
    if value[1] == 0 then 
		return value2 
	end   
    if value2[1] == 0 then 
		return value 
	end        
    if value[1] == -(value2[1]) and value[2] == value2[2] and value[3] == value2[3] then
        return {0,0,0}
    end        
    local a,b = nil        
    if value[2] >= 2 or value2[2] >=2 then        
        return ree.maxabs(value, value2)       
    end        
    if cmpabs(value, value2) > 0 then        
        a = value
        b = value2
    else       
        a = value2
        b = value                    
    end   
    if a[2] == 0 and b[2] == 0 then        
        return ree.floattobnum(a[1]*a[3]+b[1]*b[3])        
    end                
    local layera = a[2]*math.sign(a[3])                                                                        
    local layerb = b[2]*math.sign(b[3])        
    if layera - layerb >= 2 then 
		return a
	end    
    if layera == 0 and layerb == -1 then        
        if math.abs(b[3]-math.log10(a[3])) > msd then            
        	return a           
        else            
	        local magdif = math.pow(10, math.log10(a[3])-b[3])
	        local mantissa = (b[1]) + (a[1]*magdif)	        
	        return ree.errorcorrect({math.sign(mantissa), 1, b[3]+math.log10(math.abs(mantissa))})	                                
        end       
    end
    if layera == 1 and layerb == 0 then                
        if math.abs(a[3]-math.log10(b[3])) > msd then            
            return a            
        else	                
	        local magdif = math.pow(10, a[3]-math.log10(b[3]))	        
	        local mantissa = (b[1]) + (a[1]*magdif)	            
	        return ree.errorcorrect({math.sign(mantissa), 1, math.log10(b[3])+math.log10(math.abs(mantissa))})	            
        end       
    end   
    if math.abs(a[3]- b[3]) > msd then        
        return a        
    else                              
        local magdif = math.pow(10, a[3]-b[3])       
        local mantissa = (b[1]) + (a[1]*magdif)           
        return ree.errorcorrect({math.sign(mantissa), 1, b[3]+math.log10(math.abs(mantissa))})        
    end               
end

function ree.maxabs(value, value2) 	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	if cmpabs(value, value2) < 0 then		
		return value2		
	end	
	return value	
end	

function ree.bnumtoeternity(bnum)
    if bnum[2] == 0 then
        return {1, 0, bnum[1]}
    end
    bnum = errorcorrection(bnum)
    local numbaa = nil
    local layers = nil
    local sign = nil
    local rees = 1
    sign = math.sign(bnum[1])
    if bnum[1] == 0 then
        return {0,0,0}
    end
    if bnum[1] < 0 then
        bnum[1] = bnum[1] * -1
    end
    if bnum[2] < 0 then
        local idkdk =  bnumtofloat(log10(mul( floattobnum(bnum[1]) , pow({1,1}, floattobnum(bnum[2])))))         
        return {sign, 1, idkdk}
    end
    numbaa = bnum[2] + math.log10(bnum[1])
    layers = math.log10(numbaa)-(math.log10(numbaa)-1)
    numbaa = numbaa * rees
    return ree.errorcorrect({sign, layers, numbaa})
end

function ree.eternitytobnum(value)	
	value = ree.errorcorrect(value)	
	local sign = value[1]
	local layer = value[2]
	local mag = value[3]	
	if sign == 0 then		
		return {0,0}		
	end	
	if layer >= 2 and mag > 307.99 then		
		return {sign*1, 1.79e308}		
	end	
	if layer > 2 and mag > math.log10(308) then		
		return {sign*1, 1.79e308}		
	end
	if layer == 0 then		
		return floattobnum(sign*mag)		
	end	
	if layer == 1 then -- 10^n * x		
		local big = mul(pow({1,1}, floattobnum(mag)), floattobnum(sign))
		return big
	end	
	if layer == 2 and mag <= 308 then -- 10^(10^n)*x		
		local big = mul(pow({1,1}, pow({1,1}, floattobnum(mag))), floattobnum(sign))
		return big
	end	
	if layer == 3 and mag <= math.log10(308) then -- 10^(10^(10^n))*x		
		local big = mul(pow({1,1}, pow({1,1}, pow({1,1}, floattobnum(mag ))), floattobnum(sign)))
		return big		
	end	
	return {1, 1.79e308}	
end

function ree.mul(value, value2)	
	value = ree.floattobnum(value)	
	value2 = ree.floattobnum(value2)	
	if value[2] > 1.79e308 then 
		return value 
	end	
	if value2[2] > 1.79e308 then 
		return value 
	end	
	if value[1] == 0 or value2[1] == 0 then
		return {0,0,0}		
	end	
	if ree.eq(value, 0) then		
		return 0		
	end	
	if value[2] == value2[2] and value[3] == -value2[3] then		
		return {value[1]*value2[1], 0, 1}		
	end	
	local a,b = nil	
	if (value[2] > value2[2]) or (value[2] == value2[2] and math.abs(value[3]) > math.abs(value2[3])) then		
		a = value
		b = value2		
	else			
		a = value2
		b = value			
	end	
	if a[2] == 0 and b[2] == 0 then		
		return ree.floattobnum(a[1]*b[1]*a[3]*b[3])		
	end	
	if a[2] >= 3 or (a[2] - b[2] >= 2) then		
		return ree.errorcorrect({a[1]*b[1], a[2], a[3]})		
	end	
	if a[2] == 1 and b[2] == 0 then		
		return ree.errorcorrect({a[1]*b[1], 1, a[3]+math.log10(b[3])})		
	end	
	if a[2] == 1 and b[2] == 1 then		
		return ree.errorcorrect({a[1]*b[1], 1, a[3]+b[3]})		
	end	
	if (a[2] == 2 and b[2] == 1) or ((a[2] == 2 and b[2] == 2)) then		
		local nmag = ree.add(ree.errorcorrect({math.sign(a[3]), a[2]-1, math.abs(a[3])}), ree.errorcorrect({math.sign(b[3]),b[2]-1, math.abs(b[3])}))
		return ree.errorcorrect({a[1]*b[1], nmag[2]+1, nmag[1]*nmag[3]})		
	end	
	return {1, -1, 1} 	
end

function ree.div(value, value2) 	
	value = ree.floattobnum(value)	
	value2 = ree.floattobnum(value2)	
	local x = ree.recip(value2)
	return ree.mul(value, ree.recip(value2))	
end

function ree.recip(value)	
	value = ree.floattobnum(value)	
	if value[3] == 0 then 
		return {1, -1, 1} 	
	elseif value[2] == 0 then		
		return ree.errorcorrect({value[1], 0, 1/value[3]})		
	else			
		return ree.errorcorrect({value[1], value[2], -value[3]})		
	end	
end

function ree.pow(value, value2)    
    value = ree.floattobnum(value)   
    value2 = ree.floattobnum(value2)    
    local a = value
    local b = value2   
    if a[1] == 0 then -- cuz ya know 0^x = 0
		return {0,0,0} 
	end    
    if a[1] == 1 and a[2] == 0 and a[3] == 1 then -- cuz 1^x = 1        
        return {1,0,1}       
    end   
    if b[1] == 0 then -- x^0 = 1   
		return {1,0,1}
	end
    if b[1] == 1 and b[2] == 0 and b[3] == 1 then -- cuz x^1 = x        
        return a        
    end    
    local calc = ree.pow10(ree.mul(ree.abslog10(a), b))     
    if value[1] == -1 and ree.bnumtofloat(b) % 2 == 1 then        
        return ree.neg(calc)        
	elseif value[1] == -1 and ree.bnumtofloat(b) < 1e20 then
		local shit = ree.floattobnum(math.cos(ree.bnumtofloat(b) * math.pi))
    	return ree.mul(calc, shit)
    end    
    return calc   
end

function ree.tetrate(x,y)
	return x
end

function ree.pentate(x,y)
	return x
end

function ree.abslog10(value)	
	value = ree.floattobnum(value)	
	if value[1] == 0 then 
		return {1 , -1, 1}		
	elseif value[2] > 0 then
		return ree.errorcorrect({math.sign(value[3]), value[2]-1, math.abs(value[3])})	
	else		
		return ree.errorcorrect({1, 0, math.log10(math.abs(value[3]))})		
	end
end

function ree.pow10(value)	
	value = ree.floattobnum(value)	
	if value[2] > 1.79e308 or value[3] > 1.79e308 then		
		return {1, -1 ,1}		
	end	
	local a = value	
	if a[2] == 0 then	
		local nmag = math.pow(10, a[1]*a[3])		
		if nmag < 1.8e308 and math.abs(nmag) > 0.1 then			
			return ree.errorcorrect({1, 0, nmag})
		else				
			if a[1] == 0 then 
				return {1, 0 ,1}					
			else						
				a = {a[1], a[2]+1, math.log10(a[3])} 
			end				
		end	
	end		
	if a[1] > 0 and a[3] > 0 then	
		return {a[1], a[2]+1, a[3]}							
	end
	if a[1] < 0 and a[3] > 0 then		
		return {-a[1], a[2]+1, -a[3]}			
	end	
	return {1,0,1}	
end

function ree.log10(value)	
	value = ree.floattobnum(value)	
	if value[1] <= 0 then		
		return {1, -1, 1}			
	elseif value[2]	> 0 then				
		return ree.errorcorrect({math.sign(value[3]), value[2]-1, math.abs(value[3])})
	else		
		return ree.errorcorrect({value[1], 0 , math.log10(value[3])})		
	end	
end

function ree.logx(value , base)	
	value = ree.floattobnum(value)	
	base = ree.floattobnum(base)
	if value[1] <= 0 then	
		return {1 ,-1, 1}	
	end	
	if base[1] <= 0 then	
		return {1, -1, 1}	
	end
	if base[1] == 1 and base[2] == 0 and base[3] == 1 then	
		return {1, -1, 1}	
	elseif value[2] == 0 and base[2] == 0 then		
		return ree.errorcorrect({value[1], 0, math.log(value[3])/math.log(base[3])})	
	end
    return ree.div(ree.log10(value), ree.log10(base))
end

function ree.short(value,typ) -- {X}E#X1	
	value = ree.shift(ree.floattobnum(value), digitsdisplay)
	if ree.me(value, 0) and ree.le(value, 1) then			
		return "1 / " .. ree.short(ree.div(1, value))	
	end		
	if ree.meeq(value, suffixlim) then		
		return ree.bnumtoe(value)		
	end				
	if typ and typ == "other" then
		if value[1] == 1 and ree.le(value, {1, 2, 308}) then		
			return othershort(ree.eternitytobnum(value))		
		end
		if value[1] == -1 and ree.me(value, {-1, 2, 308}) then		
			return othershort(ree.eternitytobnum(value))		
		end	
	else	
		if value[1] == 1 and ree.le(value, {1, 2, 308}) then		
			return short(ree.eternitytobnum(value))		
		end
		if value[1] == -1 and ree.me(value, {-1, 2, 308}) then		
			return short(ree.eternitytobnum(value))		
		end	
	end
	return ree.bnumtoe(value)	
end

function ree.suffix(value) -- Suffix	
	value = ree.shift(ree.floattobnum(value), digitsdisplay)
	if ree.me(value, 0) and ree.le(value, 1) then			
		return "1 / " .. ree.suffix(ree.div(1, value))	
	end			
	if ree.meeq(value, suffixlim) then		
		return ree.bnumtoe(value)		
	end
	if value[1] == 1 and ree.le(value, {1, 2, 308}) then	
		return suffix(ree.eternitytobnum(value))
	end
	if value[1] == -1 and ree.me(value, {-1, 2, 308}) then		
		return suffix(ree.eternitytobnum(value))		
	end	
	return ree.bnumtoe(value)	
end

function ree.display(value)	
	value = ree.shift(ree.floattobnum(value), digitsdisplay)	
	local es,sign,x1 = nil	
	es = value[2]	
	sign = value[1]	
	x1 = value[3]	
	if sign == 1 then		
		return '{' .. es .. '}E#' .. x1		
	end	
	if sign == 0 then		
		return '{0}E#0'		
	end	
	if sign == -1 then		
		return '-{' .. es .. '}E#' .. x1				
	end
	return '{X}E#X1'	
end

function ree.totet(value) -- x*((10^^y)^z)
	value = ree.shift(ree.floattobnum(value), digitsdisplay)
	return value[1] ..'((10^^'.. value[2] .. ')'.. value[3] ..')'
end

function ree.tentetration(str) -- 10^^x;y = {math.sign(x),math.abs(x),y}	
	local lol = string.split(str, '^^')		
	local hieght, pay = nil	
	if #lol == 2 then		
		local lol2 = string.split(lol[2], ';')		
		if #lol2 == 2 then			
			pay = lol2[2]
			hieght = lol2[1]
		else
			pay = 1
			hieght = lol[2]
		end				
		return ree.errorcorrect({math.sign(hieght), math.abs(hieght), pay})		
	end	
	return {1, -1, 1}	
end

function ree.root(value, value2)	
	value = ree.floattobnum(value)
	value2 = ree.floattobnum(value2)	
	return ree.pow(value, ree.recip(value2))	
end

function ree.sqrt(value)	
	value = ree.floattobnum(value)	
	return ree.root(value, 2)	
end

function ree.gamma(value)	
	value = ree.floattobnum(value)	
	if ree.leeq(value, 0) then		
		return {1, -1, 1}		
	end	
	if value[3] < 0 then		
		return ree.recip(value)	
	elseif value[2] == 0 then		
		if ree.le(value, {1, 0, 24}) then			
			return ree.floattobnum( fgamma(value[1]*value[3]) )
		end		
		local t = value[3] - 1		
		local l = 0.9189385332046727
        l = (l+((t+0.5)*math.log(t)))
        l = l-t
        local n2 = t*t
        local np = t
        local lm = 12*np
        local adj = 1/lm
        local l2 = l+adj		
		if (l2 == l) then
			return ree.exp(l)			
		end		
		l = l2
        np = np*n2
        lm = 360*np
        adj = 1/lm
        l2 = l-adj
		if l2 == l then			
			return ree.exp(l)			
		end		
		l = l2
        np = np*n2
        lm = 1260*np
        local lt = 1/lm
        l = l+lt
        np = np*n2
        lm = 1680*np
        lt = 1/lm
        l = l-lt
		return ree.exp(l)	
	elseif value[2] == 1 then 		
		return ree.exp( ree.mul( value, ree.sub( ree.log(value), 1  )   )   )	
	else		
		return ree.exp(value)										
	end			
end

function ree.fact(value)	
	value = ree.floattobnum(value)
	return ree.gamma(  ree.add(value, 1) )	
end

function ree.floor(value)	
	value = ree.floattobnum(value)
	if value[3] < 0 then 		
		return {0,0,0}		
	end	
	if ree.le(value, 0) then		
		local lols = ree.ceil( {1, value[2], value[3]} )		
		return {-1, lols[2], lols[3]}		
	end	
	if ree.le(value, 1e16) and ree.me(value, -1e16) then		
		if value[2] > 0 then
			for i = 1,5 do			
				value[2] = value[2] -1
				value[3] = 10 ^ value[3]
				if value[2] == 0 then
					break
				end				
			end	
		end		
		return ree.errorcorrect({value[1], value[2], math.floor(value[3])})				
	end	
	return value		
end

function ree.ceil(value)	
	value = ree.floattobnum(value)	
	if value[3] < 0 then 		
		return {0,0,0}		
	end	
	if ree.le(value, 0) then		
		local lols = ree.floor( {1, value[2], value[3]} )		
		return {-1, lols[2], lols[3]}		
	end	
	if ree.le(value, 1e16) and ree.me(value, -1e16) then		
		if value[2] > 0 then
			for i = 1,5 do		
				value[2] = value[2] -1			
				value[3] = 10 ^ value[3]
				if value[2] == 0 then
					break
				end				
			end	
		end		
		return ree.errorcorrect({value[1], value[2], math.ceil(value[3])})				
	end	
	return value		
end

function ree.engineer(value)	
	value = ree.floattobnum(value)	
	if ree.le(value, {1, 2, 308}) then				
		return engineer(ree.eternitytobnum(value))		
	end	
	return ree.bnumtoe(value)	
end

function es(amo)	
	if amo  < 1 then		
		return ''		
	end	
	local lol = 'e'	
	for i = 1,amo-1 do				
		lol = lol .. 'e'		
	end	
	return lol	
end

function ree.bnumtostr(value) -- X;YeZ	
	value = ree.shift(ree.floattobnum(value), 16)	
	if value[1] == 1 then				
		return value[2] .. ';' .. value[3]		
	end		
	if value[1] == 0 then				
		return '0;0e0'		
	end		
	if value[1] == -1 then				
		return -value[2] .. ';' .. value[3]		
	end	
	return 'INVALID;INVALID'		
end

function ree.bnumtoe(value)		
	value = ree.shift(ree.floattobnum(value), digitsdisplay)	
	local e = value[2]	
	if e > breakpointe then				
		return ree.bnumtoes(value)		
	end	
	local isneg = value[1]	
	local numbaa = value[3]	
	if isneg == 1 then		
		local p1 = es(e)		
		return p1 .. tostring(numbaa)		
	end
	if isneg == 0 then		
		return '0'			
	end	
	if isneg == -1 then				
		local p1 = es(e-1)		
		return 'e-' .. p1 .. tostring(numbaa)		
	end	
	return ree.short(value)	
end

function ree.shift(value , digits)	
	value = ree.floattobnum(value)	
	if ree.me(value, {1, 2, 20}) then		
		return value
	end	
	if digits > 20 then		
		return value		
	end	
	if ree.le(value, {1, 2, -20}) then		
		return value
	end
	if value[1] == -1 and ree.me(value, {-1, 2, -20}) then		
		return value		
	end
	if value[1] == -1 and ree.le(value, {-1, 2, 20}) then		
		return value		
	end			
	if ree.le(value, 0) then		
		--convert it o negative
		value[1] = 1
		local Z = ree.eternitytobnum(value)
		Z = shift(Z, digits)
		Z = ree.bnumtoeternity(Z)
		Z[1] = -1
		return Z
	end
	local Z = ree.eternitytobnum(value)
	Z = shift(Z, digits)
	Z = ree.bnumtoeternity(Z)
	return Z
end

function shift2(value, digits)
	value = ree.floattobnum(value)
	local numbaa = math.floor(value[3] * 10^digits) / 10^digits 	
	return {value[1], value[2], numbaa}	
end

function ree.rand(min, max)
	local seed = math.random()
	local even = ree.sub(max, min)
	even = ree.mul(even, seed)
	return ree.add(even, min)
end

function ree.bnumtoes(value) -- E(x)y = ee...eey (x e's)	
	value = ree.shift(ree.floattobnum(value), digitsdisplay)
	local ess = value[2]	
	local sign = value[1]	
	local numbaa = value[3]	
	if sign == 1 then		
    	if numbaa < 0 then	
			return 'E(' .. ess .. '-' ..  ')' .. math.abs(numbaa)	
		end
		if ess == 1 then
			return "e"..math.floor(numbaa)
		elseif ess == 2 then
			return "ee"..math.floor(numbaa)
		elseif ess == 3 then
			return "eee"..math.floor(numbaa)
		elseif ess == 4 then
			return "eeee"..math.floor(numbaa)
		elseif ess == 5 then
			return "eeeee"..math.floor(numbaa)
		elseif ess > 5 then
			return 'E(' .. ess ..  ')' .. numbaa	
		end
	end	
	if sign == 0 then		
		return 'E(0)0'		
	end	
	if sign == -1 then				
		return '-' .. ree.bnumtoes({-value[1], value[2], value[3]})		
	end	
	return 'E(INVALID)INVALID)'		
end

function ree.bnumtoshortes(value) -- E(x)y = ee...eey (x e's)	
	value = ree.shift(ree.floattobnum(value), digitsdisplay)
	local ess = value[2]	
	local sign = value[1]	
	local numbaa = value[3]	
	if sign == 1 then		
		if numbaa < 0 then	
			return 'E(' .. ess .. '-' ..  ')' .. math.abs(numbaa)	
		end
		if ess > 1 and numbaa <= 306 then
			ess -= 1
			numbaa = 10^numbaa
		end
		if ess == 1 then
			return "e"..short({numbaa,0})
		elseif ess == 2 then
			return "ee"..short({numbaa,0})
		elseif ess == 3 then
			return "eee"..short({numbaa,0})
		elseif ess == 4 then
			return "eeee"..short({numbaa,0})
		elseif ess == 5 then
			return "eeeee"..short({numbaa,0})
		elseif ess > 5 then
			return 'E(' .. ess ..  ')' .. numbaa	
		end
	end	
	if sign == 0 then		
		return 'E(0)0'		
	end	
	if sign == -1 then				
		return '-' .. ree.bnumtoes({-value[1], value[2], value[3]})		
	end	
	return 'E(INVALID)INVALID)'		
end

function ree.bnumtoscientific(value)
	value = ree.floattobnum(value)
	if ree.me(value, {1, 2, 14}) then		
		return ree.bnumtoe(value)		
	end
	return bnumtostr(shift(ree.eternitytobnum(value), digitsdisplay))
end

function ree.bnumtoshortscientific(value)
	value = ree.floattobnum(value)
	if ree.me(value, {1, 2, 14}) then		
		return ree.bnumtoe(value)		
	end
	value = ree.eternitytobnum(value)
	return math.floor(value[1]*100)/100 .."e"..short({value[2],0})
end

function ree.bnumtotet(value)	
	value = ree.shift(ree.floattobnum(value), digitsdisplay)
	if value[2] == 0 then		
		return tostring(value[1]*value[3])		
	end	
	if value[1] == 1 then		
		return '10^^' .. value[2] .. ';' .. value[3]		
	end	
	if value[1] == 0 then		
		return '10^^0;0'		
	end	
	if value[1] == -1 then		
		return '-10^^' .. value[2] .. ';' .. value[3]		
	end	
	return 'INVALID^^INVALID;INVALID'	
end

function ree.globalshort(value, nota)	
	value = ree.shift(ree.floattobnum(value), digitsdisplay)		
	if nota == 'Suffix' then				
	    return ree.short(value)		
	end	
	if nota == 'OtherSuffix' then				
	    return ree.short(value,"other")		
	end	
	if nota == 'Scientific' then				
		return ree.bnumtoscientific(value)		
	end	
	if nota == 'Short Scientific' then				
		return ree.bnumtoshortscientific(value)		
	end	
	if nota == 'E Notation' then				
		return ree.bnumtoes(value)		
	end	
	if nota == 'Short E Notation' then				
		return ree.bnumtoshortes(value)		
	end	
	if nota == 'Row of E' then				
		return ree.bnumtoe(value)		
	end	
	if nota == 'X;YeZ' then				
		return ree.bnumtostr(value)		
	end	
	if nota == '{x}E#x1' then		
		return ree.display(value)
	end	
	if nota == 'Tetrated Math' then				
		return ree.totet(value)		
	end	
	if nota == 'Tentetrated' then				
		return ree.bnumtotet(value)		
	end	
	return ree.short(value)		
end

function ree.lbencode(enum)
	enum = ree.floattobnum(enum)
	local mode = 0
	if enum[1] == -1 and enum[2] > 9999  and math.sign(enum[3]) == 1 then
		mode = 0
	elseif enum[1] == -1 and enum[2] < 9999 and math.sign(enum[3]) == 1 then
		mode = 1
	elseif enum[1] == -1 and enum[2] > 9999 and math.sign(enum[3]) == -1 then
		mode = 2
	elseif enum[1] == -1 and enum[2] < 9999 and math.sign(enum[3]) == -1 then
		mode = 3
	elseif enum[1] == 0 then
		return 4E18		
	elseif enum[1] == 1 and enum[2] < 9999 and math.sign(enum[3]) == -1 then
		mode = 5
	elseif enum[1] == 1 and enum[2] > 9999 and math.sign(enum[3]) == -1 then
		mode = 6
	elseif enum[1] == 1 and enum[2] < 9999 and math.sign(enum[3]) == 1 then
		mode = 7
	elseif enum[1] == 1 and enum[2] > 9999 and math.sign(enum[3]) == 1 then
		mode = 8	
	end
	local VAL = mode*1E18
	if mode == 8 then
		VAL = VAL + ((math.log10(enum[2] + (math.log10(enum[3]) / 10))) * 3.2440674117208e+15)
	elseif mode == 7 then
		VAL = VAL + (enum[2]*1e14)
		VAL = VAL + (math.log10(enum[3])*1e13)
	elseif mode == 6 then
		VAL = VAL + 1e18
		VAL = VAL - ((math.log10(enum[2] + (math.log10(math.abs(enum[3])) / 10))) * 3.2440674117208e+15)
	elseif mode == 5 then
		VAL = VAL + (enum[2]*1e14) + 1e14
		VAL = VAL - (math.log10(math.abs(enum[3]))*1e13)
	elseif mode == 3 then
		local VOFFSET = 0
		VOFFSET = VOFFSET + (enum[2]*1e14) + 1e14
		VOFFSET = VOFFSET - (math.log10(math.abs(enum[3]))*1e13)
		VOFFSET = (1e18 - VOFFSET)
		VAL = VAL + VOFFSET
	elseif mode == 2 then
		local VOFFSET = 0
		VOFFSET = VOFFSET + 1e18
		VOFFSET = VOFFSET - ((math.log10(enum[2] + (math.log10(math.abs(enum[3])) / 10))) * 3.2440674117208e+15)
		VOFFSET = (1e18 - VOFFSET)
		VAL = VAL + VOFFSET
	elseif mode == 1 then
		local VOFFSET = 0
		VOFFSET = VOFFSET + (enum[2]*1e14)
		VOFFSET = VOFFSET + (math.log10(enum[3])*1e13)
		VOFFSET = (1e18 - VOFFSET)
		VAL = VAL + VOFFSET
	elseif mode == 0 then
		local VOFFSET = ((math.log10(enum[2] + (math.log10(enum[3]) / 10))) * 3.2440674117208e+15)		
		VOFFSET = (1e18 - VOFFSET)
		VAL = VAL + VOFFSET	
	end
	return VAL
end

function ree.lbdecode(enum)	
	if enum == 2e18 then
		return {-1, 0, 1}
	elseif enum == 3e18 then
		return {-1, 10000, -1}
	elseif enum == 1e18 then
		return {-1, 0, -1}
	elseif enum == 6e18 then
		return {1, 0, 1}
	elseif enum == 7e18 then
		return {1, 0, 1}
	elseif enum == 5e18 then
		return {1, 10000, -1}	
	end
	local mode = math.floor(enum/1e18)
	if mode == 4 then
		return {0,0,0}
	end
	if mode == 0 then
		local v = enum
		v = 1e18-v
		v = v/3.2440674117208e+15
		v = 10^v
		local layers = math.floor(v)
		local numbaa = 10^(math.fmod(v, 1)*10)
		return {-1, layers, numbaa}
	elseif mode == 8 then
		local v = enum-8e18
		v = v/3.2440674117208e+15
		v = 10^v
		local layers = math.floor(v)
		local numbaa = 10^(math.fmod(v, 1)*10)
		return {1, layers, numbaa}
	elseif mode == 1 then
		local v = enum-1e18
		v = 1e18-v		
		local layers = math.floor(v / 1E14)
		local numbaa = 10^(math.fmod(v, 1e14)/1e13)
		return {-1, layers, numbaa}
	elseif mode == 7 then
		local v = enum-7e18		
		local layers = math.floor(v / 1E14)
		local numbaa = 10^(math.fmod(v, 1e14)/1e13)
		return {1, layers, numbaa}	
	elseif mode == 2 then
		local v = enum-2e18		
		v = v/3.2440674117208e+15		
		v = 10^v
		local layers = math.floor(v)
		local e = 10^(math.fmod(v,1)*10)
		return {-1, layers, -e}
	elseif mode == 6 then
		local v = enum-6e18
		v = (1e18-v)
		v = v/3.2440674117208e+15		
		v = 10^v
		local layers = math.floor(v)
		local e = 10^(math.fmod(v,1)*10)
		return {1, layers, -e}
	elseif mode == 5 then
		local v = enum-5e18		
		--[[		
			VAL = VAL + (enum[2]*1e14) + 1e14
			VAL = VAL - (math.log10(math.abs(enum[3]))*1e13)
		]]
		-- v=(1e18-v)		
		local layers = math.floor((v) / 1E14)
		local e = 10^((1e14 - math.fmod(v, 1e14)) / 1e13)
		return {1, layers, -e}	
	elseif mode == 3 then
		local v = enum-3e18
		v = (1e18-v)
		--[[		
			VAL = VAL + (enum[2]*1e14) + 1e14
			VAL = VAL - (math.log10(math.abs(enum[3]))*1e13)
		]]
		-- v = (1e18-v)		
		local layers = math.floor((v) / 1E14)
		local e = 10^((1e14 - math.fmod(v, 1e14)) / 1e13)
		return {-1, layers, -e}	
	end
	return {1, -1, 1}
end

function ree.superpow(val)
	val = ree.floattobnum(val)
	local val1 = ree.fact(val)
	val1 = ree.pow10(val1)
	return ree.pow(val, val1)
end

function ree.megapow(val)
	val = ree.floattobnum(val)
	local val1 = ree.fact(val)
	val1 = ree.pow10(val1)
	return ree.superpow(ree.pow(ree.superpow(val), ree.superpow(val1)))
end

function ree.ultrapow(val)
	val = ree.floattobnum(val)
	local val1 = ree.fact(val)
	val1 = ree.megapow(ree.pow10(val1))
	val = ree.megapow(val)
	return ree.megapow(ree.superpow(ree.pow(ree.megapow(ree.superpow(val)), ree.megapow(ree.superpow(val1)))))
end

function ree.hyperpow(val)
	val = ree.ultrapow(ree.floattobnum(val))
	local val1 = ree.ultrapow(ree.fact(val))
	val1 = ree.ultrapow(ree.megapow(ree.pow10(val1)))
	val = ree.ultrapow(ree.megapow(val))
	val1 = ree.ultrapow(val1)
	val = ree.ultrapow(val)
	return ree.ultrapow(ree.megapow(ree.superpow(ree.pow(ree.ultrapow(ree.megapow(ree.superpow(val))), ree.ultrapow(ree.megapow(ree.superpow(val1)))))))
end

function ree.omegapow(val)
	val = ree.hyperpow(ree.ultrapow(ree.floattobnum(val)))
	local val1 = ree.hyperpow(ree.ultrapow(ree.megapow(ree.fact(val))))
	val1 = ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(ree.pow10(val1)))))
	val = ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val))))
	val1 = ree.hyperpow(ree.ultrapow(ree.megapow(val1)))
	val = ree.hyperpow(ree.ultrapow(ree.megapow(val)))
	return ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(ree.pow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val)))), ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val1)))))))))
end

function ree.finalpow(val)
	val = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(ree.floattobnum(val))))))
	local val1 = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(ree.fact(val))))))
	val1 = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(ree.pow10(val1))))))
	val = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val)))))
	val1 = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val1)))))
	val = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val)))))
	val1 = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(ree.pow10(val1))))))
	val = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val)))))
	val1 = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val1)))))
	val = ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val)))))
	return ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(ree.pow(ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val))))), ree.omegapow(ree.hyperpow(ree.ultrapow(ree.megapow(ree.superpow(val1)))))))))))
end

function ree.mod(x,y) -- abs(y*math.floor(x/y) - x)	
	x = ree.floattobnum(x)	
	y = ree.floattobnum(y)	
	if bnumtofloat(x) < 1e308 and bnumtofloat(y) < 1e308 then		
		return convert(math.fmod(bnumtofloat(x), bnumtofloat(y)))		
	end	
	local first = abs(sub(mul(y, floor(div(x, y))),x))	
	return first	
end

function ree.cos(x)	
	x = ree.floattobnum(x)	
	if x[3] < 0 then		
		return {1, 0, 1}		
	end	
	if x[2] == 0 then
		return ree.floattobnum(math.cos(x[1],x[3]))
	end	
	return {1,0,1}	
end

function bench(fct, numbaas)
	local FUNCTION = fct
	for m = 1,890 do
    	local X,Y = pcall(function()
	 		local RES2 = ree.lbdecode(m*1.001238578479478467356e16)
	   		--RES[1], RES[2], RES[3] = tostring(RES[1], RES[2], RES[3])
	  		print(m*1.001238578479478467356e16 .. " -> " .. table.concat(RES2, ", ")) 
		end)
    	if Y then
	   		-- print("{".. table.concat(BENCHES[i][1], ", ") .. "} x {".. table.concat(BENCHES[i][2], ", ") .."} = FAIL")
	   	end
	end
end

function ree.correct(val)
	if val == nil then return ZERO end
	if val ~= val then return NAN end
	if type(val) ~= 'table' then
		return ree.toOmega(val)
	end
	if type(val[2]) ~= "table" and #val == 2 then
		val = {math.sign(val[1]), {val[2] + math.log10(math.abs(val[1])),1}}
	end
	if type(val[2]) ~= "table" then
		val = {1,val}
	end
	if #val[2] == 0 then
		return ZERO
	end
	if (val[1] == 1 or val[1] == -1) and #val[2] == 1 and val[2][1] == 0 or  #val[2] == 2 and val[2][1] == 0  and val[2][2] == 0 then
		return {val[1],{0}}
	end
	-- {sign, {}}
	local qq = copytab(val)
	local sign = qq[1]
	local array = qq[2]
	array = array or {0}
	sign = sign or 1
	local len = #array
	-- Handle bullshit correctly
	for i=len,1,-1 do
		if array[i] == 0 then
			table.remove(array)
			len -= 1
		else
			break
		end
	end
	if array[1] > maxInt then
		array[1] = math.log10(array[1])
		if len > 1 then
			array[2] += 1
		else
			table.insert(array, 1)
			len += 1
		end
	end
	-- handle 1,0,0,0,x
	if len > 2 then
		if array[2] < 3 then
			for i=1,array[2] do
				if array[i] >= math.log10(maxInt) then
					break
				elseif array[2] == 0 then
					break
				end
				array[i] = 10^array[i]
				array[2] -= 1
			end 
		end
		if array[2] == 0 then
			if array[1] == 1 then
				for i=2,len do
					if array[i] == 0 then
						continue
					elseif array[i] > 1 then
						break
					elseif array[i] == 1 and i == len then
						return {sign, {10}}
					end
				end 
			end
			local LastZero = 2
			local OneEncountered = false
			for i=3,#array do
				if array[i] == 0 then
					LastZero = i
				elseif array[i] == 0 and OneEncountered then
					continue
				elseif array[i] == 1 and OneEncountered  then
					break
				elseif array[i] == 1  then
					OneEncountered = true
				else
					break
				end
			end
			if LastZero == len then
				return {sign, {array[1]}}
			else
				local Mode = 1
				if array[1] == 1 then Mode = OneEncountered and 1 or 2 array[1] = 10 end
				array[LastZero] = array[1] - 2
				array[1] = 1e10
				for i=2,LastZero - 1 do
					array[i] = 8
				end
				array[LastZero + 1] -= Mode
				for i=#array,2,-1 do
					if array[i] == 0 then
						array[i] = nil
					else
						break
					end
				end
				-- Loop through LastZero
				--return {sign, array}
			end
		end
	end
	len = #array
	for i=len,1,-1 do
		if array[i] == 0 then
			table.remove(array)
			len -= 1
		else
			break
		end
	end
	if len > 1 then
		if array[1] < math.log10(maxInt) and array[2] > 0  then
			array[2] -= 1
			array[1] = 10^array[1]
			array[2] = (array[2] == 0) and nil or array[2] 
		end
		if array[1] < math.log10(maxInt) and array[2] > 0  then
			array[2] -= 1
			array[1] = 10^array[1]
			array[2] = (array[2] == 0) and nil or array[2] 
		end
	end
	for i=2,len do
		if array[i]>maxInt then
			array[1] = array[i]
			array[i+1] = (array[i+1] or 0)+1
			array[i]+=1
			for j=2,i do
				array[j] = 0
			end
			if array[1] > maxInt then
				array[1] = math.log10(array[1])
				array[2]+=1
			end
		end
	end
	-- Convert trailing zeros
	-- Remove trailing zeros
	-- loop until
	if qq[1] == 0 then
		return ZERO
	end
	for i=1,#array do
		local cur = array[i]
		if cur == NAN then
			warn('correct() returning NAN')
			return qq
		end
		if cur==INF then
			return qq
		end
		if cur % 1 ~= 0 and i~= 1 then
			array[i] = math.floor(cur)
		end
	end
	if not #array then qq[2] = {0} end
	return qq
end

function ree.fromNumber(val)
	if type(val) ~= 'number' then
		error('NAN input at fromNumber()')
	end
	if val == 0 then
		return ZERO
	end
	return ree.correct({math.sign(val), {math.abs(val)}})
end

function ree.fromString(str)
	if str == "[0]" then
		return ZERO
	end
	if (string.find(str, 'e') or string.find(str, 'E')) and not string.find(str,"%[") then
		local subs = string.split(str, 'e')
		if #subs == 2 then
			-- its scientific yk
			local n = false
			if subs[1]:find("-") then
				subs[1] = math.abs(subs[1])
				n = true
			end
			local first = subs[2]+math.log10(subs[1])
			if n then 
				first = -first
			end
			local second = 1
			local sign = math.sign(first)
			first = math.abs(first)
			return ree.correct({sign, {first, second}})
		else
			-- its a e chain!
			local second = #subs-1
			local first = subs[#subs]
			local sign = 1
			if subs[1] == '-' then
				sign = -1
			end
			return ree.correct({sign, {tonumber(first), second}})
		end
	end
	if string.find(str, ',') or string.find(str,"%[") then
		str = game.HttpService:JSONDecode(str)
		str = {math.sign(str[1] or 1), str}
		str[2][1] = math.abs(str[2][1] or 0)
		return ree.correct(str)
	else
		return ree.fromNumber(tonumber(str))
	end
end

function ree.toOmega(val)
	if type(val) == 'table' then
		-- Assuming its Omega type..
		-- For converting other Bnums please use assigned function.
		if #val < 2 then
			val = {1, val}
		end
		return val
	end
	if type(val) == 'number' then
		-- convert number to omega
		return ree.fromNumber(val)
	end
	if type(val) == 'string' then
		-- convert str to omega
		return ree.fromString(val)
	end
end

function ree.Omegacmp(val, val2) -- 0 = eq, -1 = le, 1 = me 
	val = ree.correct(val)
	val2 = ree.correct(val2)
	local V1Nan = val ~= val
	if V1Nan and val2 ~= val2 then return 0
	elseif V1Nan or val2 ~= val2 then return 1
	end
	if val[1] == INF and val2[1] ~= INF then
		return val[1]
	end
	if val[1] ~= INF and val2[1] == INF then
		return -val2[1]
	end
	if #val[2]==1 and val[2][1]==0 and #val2[2]==1 and val2[2][1]==0 then
		return 0
	end
	if val[1] ~= val2[1] then
		return val[1]
	end
	local a = val[1]
	local z
	if #val[2] > #val2[2] then z=1 
	elseif #val[2] < #val2[2] then z=-1
	else
		for i=#val[2],1,-1 do
			if val[2][i] > val2[2][i] then
				z = 1
				break
			elseif val[2][i] < val2[2][i] then
				z = -1
				break
			end
		end
		z= z or 0
	end
	return z*a
end

function ree.OmegaMe(val, val2)
	val,val2 = ree.correct(val),ree.correct(val2)
	return ree.Omegacmp(val, val2) == 1 
end

function ree.OmegaAbs(val)
	val = ree.correct(val)
	return {1, val[2]}
end 

function ree.OmegatoEternity(Omega)
	Omega = ree.toOmega(Omega)
	if ree.OmegaMe(ree.OmegaAbs(Omega),{1,{305,1,1}}) then
		return {Omega[1],1e309,1e309}
	end
	if #Omega[2] == 1 then
		return {Omega[1],0,Omega[2][1]}
	end
	if #Omega[2] == 2 then
		return {Omega[1],Omega[2][2],Omega[2][1]}
	end
	return {Omega[1],Omega[2][1]*10^Omega[2][1],Omega[2][3]}
end

function commmas(Value)
	if Value < 1e3 then 
		return math.floor(Value*100)/100
	end
	local Number
	local Formatted = math.floor(Value * 100) / 100
	if Value < 10^13 then
		while (Number ~= 0) do
			Formatted, Number = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		end 
		return Formatted
	elseif Value < 10^26 then
		local Formatted2 = math.floor(Value / 10^12)
		Formatted = math.fmod(Value, 10^12)
		while Number ~= 0 do  
			Formatted2, Number = string.gsub(Formatted2, "^(-?%d+)(%d%d%d)", '%1,%2')
		end 
		Number = nil
		while Number ~= 0 do   
			Formatted, Number = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		end 
		local TpFormatted = math.fmod(Value, 10^12)
		local String = Formatted2 .. ","
		if TpFormatted == 0 then
			String ..= "000,000,000,000"
		elseif TpFormatted < 10 then
			String ..= "000,000,000,00"
		elseif TpFormatted < 100 then
			String ..= "000,000,000,0"
		elseif TpFormatted < 1000 then
			String ..= "000,000,000,"
		elseif TpFormatted < 10000 then
			String ..= "000,000,00"
		elseif TpFormatted < 100000 then
			String ..= "000,000,0"
		elseif TpFormatted < 1000000 then
			String ..= "000,000,"
		elseif TpFormatted < 10000000 then
			String ..= "000,00"
		elseif TpFormatted < 100000000 then
			String ..= "000,0"
		elseif TpFormatted < 1000000000 then
			String ..= "000,"
		elseif TpFormatted < 10000000000 then
			String ..= "00"
		elseif TpFormatted < 100000000000 then
			String ..= "0"
		end
		if TpFormatted > 0 then
			String ..= Formatted
		end
		return String
	else
		return "9,999,999,999,999,999,999,999,999,999+"
	end
end

-- Making it easier for SamirDevs to use this lol.

function ree.onen(onum)
	return ree.OmegatoEternity(onum)
end

function ree.bnflt(enum)
	return ree.bnumtofloat(enum)
end

function ree.fltbn(flt)
	return ree.floattobnum(flt)
end

function ree.bnstr(enum)
	return ree.bnumtostr(enum)
end

function ree.strbn(str)
	return ree.strtobnum(str)
end

function ree.enflt(enum)
	return ree.bnumtofloat(enum)
end

function ree.flten(flt)
	return ree.floattobnum(flt)
end

function ree.enstr(enum)
	return ree.bnumtostr(enum)
end

function ree.stren(str)
	return ree.strtobnum(str)
end

function ree.equal(enum1,enum2)
	return ree.eq(enum1,enum2)
end

function ree.moreequal(enum1,enum2)
	return ree.meeq(enum1,enum2)
end

function ree.lessequal(enum1,enum2)
	return ree.leeq(enum1,enum2)
end

function ree.more(enum1,enum2)
	return ree.me(enum1,enum2)
end

function ree.less(enum1,enum2)
	return ree.le(enum1,enum2)
end

function ree.abbreviate(enum)
	if ree.le(enum,{0,0})then
		return "0"
	elseif ree.le(enum,1e6) then
		return commmas(ree.enflt(enum))
	elseif ree.le(enum,{1,breakpointsuffixe}) then
		return ree.globalshort(enum,"Suffix")
	elseif ree.le(enum,{1,1e14}) then
		return ree.globalshort(enum,"Short Scientific")
	else
		return ree.globalshort(enum,"Short E Notation")
	end
end

return ree