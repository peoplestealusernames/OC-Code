file,_ = io.open("Temp","w")
Tab = component.droneInterface
file:write(serialization.serialize(Tab,1000))
file:close()

{"entityAttack",
 "dig",
 "harvest",
 "place",
 "blockRightClick",
 "entityRightClick",
 "pickupItem",
 "dropItem",
 "inventoryExport",
 "inventoryImport",
 "liquidExport",
 "liquidImport",
 "entityExport",
 "entityImport",
 "goto",
 "teleport",
 "emitRedstone",
 "rename",
 "suicide",
 "crafting",
 "standby",
 "logistics",
 "editSign",
 "conditionRedstone",
 "conditionLight",
 "conditionItemInventory",
 "conditionBlock",
 "conditionLiquidInventory",
 "conditionPressure",
 "droneConditionItem",
 "droneConditionLiquid",
 "droneConditionEntity",
 "droneConditionPressure",
 "conditionRF",
 "droneConditionRF",
 "rfExport",
 "rfImport",
 "computerCraft"}
 
 {abortAction=function,
 addArea=function,
 addBlacklistItemFilter=function,
 addBlacklistLiquidFilter=function,
 addBlacklistText=function,
 addWhitelistItemFilter=function,
 addWhitelistLiquidFilter=function,
 addWhitelistText=function,
 address="1a0e74e0-4aff-4c25-b7b5-04c7cbb3e765",
 clearArea=function,
 clearBlacklistItemFilter=function,
 clearBlacklistLiquidFilter=function,
 clearBlacklistText=function,
 clearWhitelistItemFilter=function,
 clearWhitelistLiquidFilter=function,
 clearWhitelistText=function,
 evaluateCondition=function,
 exitPiece=function,
 forgetTarget=function,
 getAction=function,
 getAllActions=function,
 getAreaTypes=function,
 getDroneName=function,
 getDronePosition=function,
 getDronePressure=function,
 getOwnerID=function,
 getOwnerName=function,
 getUpgrades=function,
 getVariable=function,
 hideArea=function,
 isActionDone=function,
 isConnectedToDrone=function,
 removeArea=function,
 setAction=function,
 setBlockOrder=function,
 setCount=function,
 setCraftingGrid=function,
 setDropStraight=function,
 setEmittingRedstone=function,
 setIsAndFunction=function,
 setMaxActions=function,
 setOperator=function,
 setPlaceFluidBlocks=function,
 setRenameString=function,
 setRequiresTool=function,
 setSide=function,
 setSides=function,
 setSignText=function,
 setSneaking=function,
 setUseCount=function,
 setUseMaxActions=function,
 setVariable=function,
 showArea=function,
 slot=-1,
 type="droneInterface"}