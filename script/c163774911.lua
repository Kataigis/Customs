--Relaised Overhaul
--Kataigis
local s,id=GetID()
function s.initial_effect(c)
	local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x749),matfilter=aux.FALSE,
		extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,stage2=s.stage2,extratg=s.extratarget}
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
end
s.listed_series={0x749}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.NecroValleyFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		--Cannot attack directly this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3207)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
