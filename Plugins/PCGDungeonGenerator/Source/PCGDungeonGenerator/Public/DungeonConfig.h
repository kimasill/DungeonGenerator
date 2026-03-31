#pragma once

#include "CoreMinimal.h"
#include "Engine/DataAsset.h"
#include "DungeonConfig.generated.h"

UENUM(BlueprintType)
enum class EDungeonObjectPlacement : uint8
{
	Floor,
	Wall,
	Ceiling,
	Corner,
	Top,
	Side
};

USTRUCT(BlueprintType)
struct FDungeonObjectEntry
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	TSoftObjectPtr<UStaticMesh> Mesh;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	EDungeonObjectPlacement Placement = EDungeonObjectPlacement::Floor;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, meta = (ClampMin = "0.0", ClampMax = "1.0"))
	float SpawnWeight = 1.0f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	int32 MaxDepth = 0;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	TArray<TSoftObjectPtr<UStaticMesh>> ChildObjects;
};

USTRUCT(BlueprintType)
struct FDungeonFloorConfig
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadOnly, meta = (ClampMin = "2"))
	int32 GridSizeX = 5;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, meta = (ClampMin = "2"))
	int32 GridSizeY = 5;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, meta = (ClampMin = "100.0"))
	float CellSize = 1000.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	TArray<FDungeonObjectEntry> ObjectEntries;
};

UCLASS(BlueprintType)
class PCGDUNGEONGENERATOR_API UDungeonConfig : public UDataAsset
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Seed")
	int32 Seed = 0;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Generation")
	int32 MaxObjectDepth = 3;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Generation", meta = (ClampMin = "0.0", ClampMax = "1.0"))
	float RoomDensity = 0.6f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Floors")
	TArray<FDungeonFloorConfig> Floors;
};
