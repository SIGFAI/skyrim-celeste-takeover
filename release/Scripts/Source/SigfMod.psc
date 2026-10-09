Scriptname SigfMod extends Quest
{Celeste Takeover: snow on Riverwood, a train of giant strawberries behind the player, Madeline's dash, Badeline's shadow.}

ActorBase Property SigfMadeline Auto
ActorBase Property SigfBadeline Auto
Potion Property SigfStrawberry Auto
Potion Property SigfHeart Auto
Spell Property VoiceUnrelentingForce3 Auto
EffectShader Property SigfDashFX Auto
EffectShader Property SigfShadowFX Auto
Weather Property SkyrimOvercastSnow Auto
Explosion Property SigfDashPuff Auto
Explosion Property SigfHitBurst Auto
Explosion Property crExplosionFrost01 Auto
Faction Property PlayerFaction Auto
Faction Property BanditFaction Auto
Weapon Property IronSword Auto
Weapon Property SteelSword Auto

ObjectReference[] chain
float[] hx
float[] hy
float[] hz
bool[] kf
int head = 0
int ticks = 0
int links = 6
int Property Berries = 0 Auto

Event OnInit()
	if IsRunning()
		RegisterForSingleUpdate(4.0)
	endif
EndEvent

Event OnUpdate()
	if !chain
		SigfLib.Say("Chapter 1: Forsaken Riverwood")
		StartChain()
	endif
	TickChain()
	ticks += 1
	if ticks == 90
		StartSnow()
	endif
	if ticks % 280 == 0
		RainBerries(4)
	endif
	RegisterForSingleUpdate(0.25)
EndEvent

Function StartChain()
	chain = new ObjectReference[6]
	kf = new bool[6]
	hx = new float[64]
	hy = new float[64]
	hz = new float[64]
	Actor p = Game.GetPlayer()
	int i = 0
	while i < 64
		hx[i] = p.GetPositionX()
		hy[i] = p.GetPositionY()
		hz[i] = p.GetPositionZ()
		i += 1
	endwhile
	i = 0
	while i < links
		ObjectReference b = p.PlaceAtMe(SigfStrawberry)
		b.SetScale(0.55 - i * 0.04)
		chain[i] = b
		i += 1
	endwhile
	Debug.Trace("SIGF_SPAWN strawberry_train")
EndFunction

Function TickChain()
	Actor p = Game.GetPlayer()
	hx[head] = p.GetPositionX()
	hy[head] = p.GetPositionY()
	hz[head] = p.GetPositionZ()
	int i = 0
	while i < links
		ObjectReference b = chain[i]
		if b && b.Is3DLoaded()
			if !kf[i]
				b.SetMotionType(4, false)
				kf[i] = true
			endif
			int k = head - (i + 1) * 3
			while k < 0
				k += 64
			endwhile
			float bob = Math.Sin((head * 25 + i * 60) as float) * 25.0
			float t = (head * 9 + i * 60) as float
			float tx = p.GetPositionX() + 240.0 * Math.Sin(t)
			float ty = p.GetPositionY() + 240.0 * Math.Cos(t)
			b.TranslateTo(tx, ty, p.GetPositionZ() + 150.0 + bob, 0.0, 0.0, t, 500.0, 90.0)
		endif
		i += 1
	endwhile
	head += 1
	if head >= 64
		head = 0
	endif
EndFunction

; Madeline's dash: a fast straight slide with a blue streak.
Function Dash(Actor a, float dist)
	float ang = a.GetAngleZ()
	float x0 = a.GetPositionX()
	float y0 = a.GetPositionY()
	float z0 = a.GetPositionZ()
	float sgn = 1.0
	if dist < 0.0
		sgn = -1.0
	endif
	SigfDashFX.Play(a, 1.2)
	a.PlaceAtMe(SigfDashPuff)
	a.TranslateTo(x0 + dist * Math.Sin(ang), y0 + dist * Math.Cos(ang), z0, a.GetAngleX(), a.GetAngleY(), ang, 2200.0, 0.0)
	int k = 1
	while k <= 5
		Utility.Wait(0.07)
		float f = k / 6.0
		ObjectReference m = a.PlaceAtMe(SigfDashPuff)
		k += 1
	endwhile
EndFunction

Function Report()
	Actor p = Game.GetPlayer()
	Debug.Trace("SIGF_POS me " + p.GetPositionX() + " " + p.GetPositionY() + " " + p.GetPositionZ())
	int i = 0
	while i < links
		ObjectReference b = chain[i]
		if b
			Debug.Trace("SIGF_POS chain" + i + " " + b.Is3DLoaded() + " " + b.GetPositionX() + " " + b.GetPositionY() + " " + b.GetPositionZ() + " scale " + b.GetScale() + " cell " + b.GetParentCell())
		else
			Debug.Trace("SIGF_POS chain" + i + " none")
		endif
		i += 1
	endwhile
EndFunction

; ---------- set pieces ----------

; Giant strawberries fall from the sky around (and ahead of) the player and bounce.
Function RainBerries(int n)
	Actor p = Game.GetPlayer()
	float ang = p.GetAngleZ()
	int i = 0
	while i < n
		float fwd = Utility.RandomFloat(250.0, 900.0)
		float side = Utility.RandomFloat(-500.0, 500.0)
		ObjectReference m = p.PlaceAtMe(SigfStrawberry)
		m.MoveTo(p, fwd * Math.Sin(ang) + side * Math.Cos(ang), fwd * Math.Cos(ang) - side * Math.Sin(ang), Utility.RandomFloat(650.0, 900.0))
		m.SetScale(Utility.RandomFloat(1.4, 2.4))
		m.SetAngle(0.0, 0.0, Utility.RandomFloat(0.0, 360.0))
		Utility.Wait(Utility.RandomFloat(0.15, 0.45))
		i += 1
	endwhile
	Debug.Trace("SIGF_SPAWN berry_rain")
EndFunction

; Strawberries pop out of a spot (Badeline's defeat).
Function Burst(ObjectReference at, int n)
	at.PlaceAtMe(crExplosionFrost01)
	int i = 0
	while i < n
		ObjectReference b = at.PlaceAtMe(SigfStrawberry)
		b.MoveTo(at, Utility.RandomFloat(-60.0, 60.0), Utility.RandomFloat(-60.0, 60.0), 120.0)
		b.SetScale(Utility.RandomFloat(0.8, 1.4))
		b.ApplyHavokImpulse(Utility.RandomFloat(-1.0, 1.0), Utility.RandomFloat(-1.0, 1.0), 1.0, Utility.RandomFloat(60.0, 160.0))
		i += 1
	endwhile
EndFunction

Actor Function SpawnMadeline(float dist, float side)
	Actor a = SigfLib.Spawn(SigfMadeline, "madeline", dist, side)
	a.AddToFaction(PlayerFaction)
	a.RemoveAllItems()
	a.AddItem(IronSword, 1, true)
	a.EquipItem(IronSword, false, true)
	a.SetActorValue("Health", 350.0)
	return a
EndFunction

Actor Function SpawnBadeline(float dist, float side)
	Actor a = SigfLib.Spawn(SigfBadeline, "badeline", dist, side)
	a.RemoveAllItems()
	a.AddItem(SteelSword, 1, true)
	a.EquipItem(SteelSword, false, true)
	a.SetActorValue("Health", 450.0)
	SigfShadowFX.Play(a, -1.0)
	return a
EndFunction

; One Madeline dashes at Badeline and lands a hit with a frost burst.
Function DashAttack(Actor m, Actor b)
	if m.IsDead() || b.IsDead()
		return
	endif
	SigfLib.FaceTo(m, b)
	float d = m.GetDistance(b)
	if d > 140.0
		Dash(m, d - 90.0)
		Utility.Wait(d / 2400.0 + 0.1)
	endif
	SigfDashFX.Play(b, 0.6)
	b.PlaceAtMe(SigfHitBurst)
	b.DamageActorValue("Health", 55.0)
	if !b.IsDead() && !m.IsDead()
		b.PushActorAway(m, 0.4)
		m.StartCombat(b)
	endif
EndFunction

Function StartSnow()
	SkyrimOvercastSnow.ForceActive(true)
EndFunction

; Badeline's gift: a spinning Crystal Heart rises, then flies into the player.
Function HeartReward(ObjectReference at)
	ObjectReference h = at.PlaceAtMe(SigfHeart)
	h.MoveTo(at, 0.0, 0.0, 40.0)
	h.SetScale(1.4)
	int n = 0
	while !h.Is3DLoaded() && n < 30
		Utility.Wait(0.1)
		n += 1
	endwhile
	h.SetMotionType(4, false)
	h.TranslateTo(h.GetPositionX(), h.GetPositionY(), h.GetPositionZ() + 170.0, 0.0, 0.0, 0.0, 90.0, 0.0)
	Utility.Wait(2.0)
	float ang = 0.0
	n = 0
	while n < 40
		ang += 24.0
		h.SetAngle(0.0, 0.0, ang)
		Utility.Wait(0.07)
		n += 1
	endwhile
	Actor p = Game.GetPlayer()
	h.TranslateTo(p.GetPositionX(), p.GetPositionY(), p.GetPositionZ() + 90.0, 0.0, 0.0, ang, 520.0, 0.0)
	Utility.Wait(0.9)
	p.PlaceAtMe(SigfHitBurst)
	SigfDashFX.Play(p, 2.0)
	h.Disable()
	h.Delete()
EndFunction

; Fus Ro Dah at whatever lies ahead.
Function Shout()
	VoiceUnrelentingForce3.Cast(Game.GetPlayer())
EndFunction
