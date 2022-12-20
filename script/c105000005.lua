--Metaphys Displacement
--Kataigis
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.bncost)
	e1:SetTarget(s.bntg)
	e1:SetOperation(s.bnop)
	c:RegisterEffect(e1)
end
s.listed_series={0x105}

function s.bnfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToRemoveAsCost()
end
function s.bncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bnfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) end
	local maxtc=Duel.GetTargetCount(nil,tp,0,LOCATION_MZONE,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.bnfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,1,maxtc,nil)
	local cg=Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(cg)
end
function s.bntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
	
	local tg=Duel.GetTargetCards(e)
	if Duel.Remove(tg,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
		local c=e:GetHandler()
		for rc in tg:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(rc)
			e1:SetCountLimit(1)
			e1:SetOperation(s.retop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
