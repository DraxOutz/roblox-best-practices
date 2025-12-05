--!strict
--!optimize 2

type TaskResult<T> = {
	success: boolean,
	data: T?,
	error: string?
}

local function async<T>(callback: () -> T): () -> TaskResult<T>
	return function()
		local thread = coroutine.create(callback)
		local ok, result = coroutine.resume(thread)

		if not ok then
			return {
				success = false,
				data = nil,
				error = tostring(result)
			}
		end

		return {
			success = true,
			data = result,
			error = nil
		}
	end
end

local Economy = {}
Economy.__index = Economy

type EconomyObj = {
	Balance: number,
	Shadow: NumberValue,

	deposit: (self: EconomyObj, amount: number) -> (),
	withdraw: (self: EconomyObj, amount: number) -> boolean,
	_commitShadow: (self: EconomyObj) -> (),
}

function Economy.new(plr: Player): EconomyObj
	local shadow = Instance.new("NumberValue")
	shadow.Name = "BalanceShadow"
	shadow.Value = 0
	shadow.Parent = plr

	local self: EconomyObj = setmetatable({
		Balance = 0,
		Shadow = shadow,
	}, Economy)

	return self
end

function Economy:_commitShadow()
	self.Shadow.Value = self.Balance
end

function Economy:deposit(amount: number)
	self.Balance += amount

	coroutine.wrap(function()
		task.wait(0.05)
		self:_commitShadow()
	end)()
end

function Economy:withdraw(amount: number)
	if amount > self.Balance then
		return false
	end
	
	self.Balance -= amount

	local run = async(function()
		task.wait(0.08)
		self:_commitShadow()
		return true
	end)

	run()
	return true
end

local Players = game:GetService("Players")
local PlayerEconomies: { [Player]: EconomyObj } = {}

Players.PlayerAdded:Connect(function(plr)
	local eco = Economy.new(plr)
	PlayerEconomies[plr] = eco

	eco:deposit(100)
	eco:withdraw(25)
end)

Players.PlayerRemoving:Connect(function(plr)
	PlayerEconomies[plr] = nil
end)
