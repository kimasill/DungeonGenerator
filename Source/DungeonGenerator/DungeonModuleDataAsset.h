#pragma once

#include "Engine/DataAsset.h"
#include "DungeonModuleDataAsset.generated.h"

USTRUCT(BlueprintType)
struct FDungeonModuleInfo
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Dungeon")
    TSoftObjectPtr<UStaticMesh> Mesh;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Dungeon")
    FName SocketName;
};

UCLASS(BlueprintType)
class DUNGEONGENERATOR_API UDungeonModuleDataAsset : public UPrimaryDataAsset
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Dungeon")
    TArray<FDungeonModuleInfo> Modules;
};
