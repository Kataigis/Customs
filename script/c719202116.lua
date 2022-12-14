--Satellite Styvermaz Dvorak
--Kataigis
local s,id=GetID()
function s.initial_effect(c)
	--Link summon method
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Banish recycle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.bntg)
	e1:SetOperation(s.bnop)
	c:RegisterEffect(e1)
	--Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spac)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
	--Attack magnet
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tglimit)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_series={0x917}
function s.matfilter(c,lc,stype,tp)
	return c:IsSetCard(0x917,lc,stype,tp) and not c:IsType(TYPE_LINK,lc,stype,tp)
end

function s.tgfilter(c)
	return c:IsSetCard(0x917) and c:IsFaceup()
end
function s.bntg(e,tp,eg,ep,ev,re,r,rp,chk)
	--local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil)
	e:SetCategory(CATEGORY_TOGRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
	--local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil) then
		local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if #tg>0 then
			Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)
		end
	end
end
function s.rescon(tuner,scard)
	return	function(sg,e,tp,mg)
				sg:AddCard(tuner)
				local res=Duel.GetLocationCountFromEx(tp,tp,sg,scard)>0 
					and sg:CheckWithSumEqual(Card.GetLevel,scard:GetLevel(),#sg,#sg)
				sg:RemoveCard(tuner)
				return res
			end
end
function s.spfilter1(c,e,tp,zone)
	local lv=c:GetLevel()
	return c:IsSetCard(0x917) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false,POS_FACEUP,tp,zone)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp,c)
end
function s.spfilter2(c,tp,sc)
	local rg=Duel.GetMatchingGroup(s.spfilter3,tp,LOCATION_MZONE+LOCATION_GRAVE,0,c)
	return c:IsType(TYPE_TUNER) and c:IsSetCard(0x917) and c:IsAbleToRemove()
		and aux.SelectUnselectGroup(rg,e,tp,nil,1,s.rescon(c,sc),0)
end
function s.spfilter3(c)
	return c:HasLevel() and c:IsAttribute(ATTRIBUTE_WIND) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		return #pg<=0 and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spac(e,tp,eg,ep,ev,re,r,rp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if #pg>0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=g1:GetFirst()
	if sc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp,sc)
		local tuner=g2:GetFirst()
		local rg=Duel.GetMatchingGroup(s.spfilter3,tp,LOCATION_MZONE+LOCATION_GRAVE,0,tuner)
		local sg=aux.SelectUnselectGroup(rg,e,tp,1,1,s.rescon(tuner,sc),1,tp,HINTMSG_REMOVE,s.rescon(tuner,sc))
		sg:AddCard(tuner)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		Duel.SpecialSummonStep(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP,zone)
		sc:CompleteProcedure()
	end
	Duel.SpecialSummonComplete()
end
function s.stormfilter(c)
	return c:IsFaceup() and c:IsCode(719202113)
end
function s.tgcon(e,c)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end
