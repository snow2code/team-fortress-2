#define DEFAULT_DAMAGE 24.5 // 24
#define DEFAULT_FORCE 100.0
#define DEFAULT_RADIUS 150.0

ConVar g_cvarExplosiveArrows;

void Arrows_Start()
{
	if (FindConVar("sm_explosivearrows"))
	{
		g_cvarExplosiveArrows = FindConVar("sm_explosivearrows");
	} else {
		g_cvarExplosiveArrows = CreateConVar("sm_explosivearrows", "1", "Enable or disable Explosive Arrows", FCVAR_NOTIFY);
	}
}

public bool IsExplosiveArrowsEnabled()
{
    if (g_cvarExplosiveArrows != null)
    {
        return g_cvarExplosiveArrows.BoolValue;
    }

    return false;
}

// Called when ANY entity is created
public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntity(entity))
		return;

	if (IsValidArrowClass(classname))
	{
		// Once the arrow is spawned, hook touch
		SDKHook(entity, SDKHook_SpawnPost, OnArrowSpawned);
	}
}

public void OnArrowSpawned(int entity)
{
	SDKHook(entity, SDKHook_StartTouchPost, ArrowTouch);
}

public void ArrowTouch(int entity, int other)
{
	if (IsExplosiveArrowsEnabled())
	{
		if (!IsValidEntity(entity))
			return;

		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

		int explosion = CreateEntityByName("env_explosion");
		if (explosion <= MaxClients || !IsValidEntity(explosion))
			return;

		DispatchKeyValueFloat(explosion, "iMagnitude", DEFAULT_DAMAGE);
		DispatchKeyValueFloat(explosion, "DamageForce", DEFAULT_FORCE);
		DispatchKeyValueFloat(explosion, "iRadiusOverride", DEFAULT_RADIUS);

		DispatchSpawn(explosion);
		ActivateEntity(explosion);

		SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", owner);

		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

		TeleportEntity(explosion, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(explosion, "Explode");
		AcceptEntityInput(explosion, "Kill");
	}
}

bool IsValidArrowClass(const char[] classname)
{
	return StrEqual(classname, "tf_projectile_arrow") || StrEqual(classname, "tf_projectile_healing_bolt");
}