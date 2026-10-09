Scriptname SigfDemo extends Quest
{The demo.}

SigfMod Property Celeste Auto

Event OnInit()
	if IsRunning()
		RegisterForSingleUpdate(0.5)
	endif
EndEvent

Event OnUpdate()
	Debug.Trace("SIGF_DEMO start")
	Actor p = Game.GetPlayer()
	p.SetAngle(0.0, 0.0, 70.0)
	Celeste.StartSnow()
	SigfLib.Say("Chapter 1: Forsaken Riverwood")
	Utility.Wait(1.0)
	; moment 2: the player dashes, the strawberry train snakes after
	Celeste.Dash(p, 380.0)
	Utility.Wait(1.8)
	Celeste.Dash(p, -380.0)
	Utility.Wait(1.8)
	; moment 3: strawberry rain
	SigfLib.Say("Strawberries are falling!")
	Celeste.RainBerries(12)
	Utility.Wait(1.5)
	SigfLib.Say("FUS RO DAH! Berries everywhere!")
	Celeste.Shout()
	Utility.Wait(2.5)
	; moment 4: Madelines vs Badeline
	Actor bad = Celeste.SpawnBadeline(800.0, 300.0)
	SigfLib.Say("Badeline appears!")
	Actor m1 = Celeste.SpawnMadeline(350.0, 150.0)
	Actor m2 = Celeste.SpawnMadeline(300.0, 400.0)
	Actor m3 = Celeste.SpawnMadeline(250.0, 250.0)
	SigfLib.Fight(m1, bad)
	SigfLib.Fight(m2, bad)
	SigfLib.Fight(m3, bad)
	bad.StartCombat(m3)
	Utility.Wait(1.5)
	int round = 0
	while round < 8 && !bad.IsDead()
		Celeste.DashAttack(m1, bad)
		Utility.Wait(0.6)
		Celeste.DashAttack(m2, bad)
		Utility.Wait(0.6)
		Celeste.DashAttack(m3, bad)
		Utility.Wait(1.2)
		round += 1
	endwhile
	if !bad.IsDead()
		bad.Kill(m1)
	endif
	Utility.Wait(0.5)
	; moment 5: defeat
	SigfLib.Say("Badeline is defeated! Strawberries!")
	Celeste.Burst(bad, 8)
	Celeste.HeartReward(bad)
	SigfLib.Say("Crystal Heart collected!")
	Utility.Wait(1.5)
	Utility.Wait(5.0)
	Debug.Trace("SIGF_DEMO end")
EndEvent
