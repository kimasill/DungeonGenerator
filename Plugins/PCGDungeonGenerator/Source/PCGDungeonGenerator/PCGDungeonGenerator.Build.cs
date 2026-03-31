using UnrealBuildTool;

public class PCGDungeonGenerator : ModuleRules
{
	public PCGDungeonGenerator(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[]
		{
			"Core",
			"CoreUObject",
			"Engine",
			"PCG"
		});
	}
}
