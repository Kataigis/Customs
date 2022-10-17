--Styvermaz Stormfront
--Kataigis
local s,id=GetID()
function s.initial_effect(c)
	--Activation and banish from deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Atk boost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x917))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.drco)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
s.listed_series={0x917}
function s.filter(c)
	return c:IsSetCard(0x917) and c:IsMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.acfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
	--summon count limit
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limittg)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e3,tp)
	--counter
	local et=Effect.CreateEffect(e:GetHandler())
	et:SetType(EFFECT_TYPE_FIELD)
	et:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	et:SetRange(LOCATION_SZONE)
	et:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	et:SetTargetRange(1,0)
	et:SetValue(s.countval)
	Duel.RegisterEffect(et,tp)
end
function s.acfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x917) and c:IsAbleToRemove()
end
function s.atkfil(c)
	return c:IsFaceup() and c:IsSetCard(0x917)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfil,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*100
end
function s.drcofilter(c)
	return c:IsSetCard(0x917) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
function s.drco(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.drcofilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,0x917) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.drcofilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local h=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND,0,1,1,nil,0x917)
	Duel.Remove(h,POS_FACEUP,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp,chk)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Draw(tp,1,REASON_EFFECT)
end
function s.limittg(e,c,tp)
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	return t1+t2+t3>=4
end
function s.countval(e,re,tp)
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	if t1+t2+t3>=4 then return 0 else return 4-t1-t2-t3 end
end
