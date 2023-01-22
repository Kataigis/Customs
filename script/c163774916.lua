--Relaised Sentinel
--Kataigis
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon procedure
	c:EnableReviveLimit()
	Fusion.AddProcFunRep(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x749),2,true)
	--bounce
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.bntg)
	e1:SetOperation(s.bnop)
	c:RegisterEffect(e1)
	--recover
	
end
s.listed_series={0x749}
function s.bnfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x749) and c:IsAbleToHand()
end
function s.oppfilter(c,p,eg)
	return c:IsSummonPlayer(p) and eg:IsContains(c)
end
function s.bntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(s.bnfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		and Duel.IsExistingTarget(s.oppfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp,s.bnfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,s.oppfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
