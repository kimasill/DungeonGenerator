# DungeonGenerator (UE5 PCG Dungeon Generator Plugin)

<p align="center">
  <a href="https://github.com/kimasill/DungeonGenerator"><img alt="GitHub Repo" src="https://img.shields.io/badge/GitHub-DungeonGenerator-181717?style=for-the-badge&logo=github&logoColor=white" /></a>
  <img alt="Unreal Engine" src="https://img.shields.io/badge/Unreal%20Engine-5.6+-0E1128?style=for-the-badge&logo=unrealengine&logoColor=white" />
  <img alt="PCG" src="https://img.shields.io/badge/PCG-Plugin-2EA44F?style=for-the-badge" />
</p>

> UE5 **PCG/PCGEx** 기반의 절차적 던전 생성 플러그인입니다.  
> 다층 구조 던전 생성과, 데이터 에셋 기반의 오브젝트 배치/가중치/재귀 생성(Depth)을 통해 “컨텐츠 확장 비용이 낮은 생성 파이프라인”을 만드는 것을 목표로 했습니다.

## Links

- **Portfolio (PDF/웹)**: `https://kimasill.github.io/`
- **Plugin Repo**: `https://github.com/kimasill/DungeonGenerator`

## Features (요약)

- **구조 생성**: 다층(Levels), 층간 간격(Level Spacing), 외곽/내벽, 문/창/통로, 기둥/코너, 계단 모드(직선/ㄴ/ㄷ/Z 등)
- **오브젝트 배치**: Placement Mode(Floor/Wall/Corner/Window…), Facing Mode, Clearance, Region 제한(Room/Corridor/Any)
- **가중치 기반 랜덤성**: Weight/Empty + Seed 기반 재현 가능한 생성
- **Depth 기반 재귀 생성**: Container/Children 방식으로 부모→자식 오브젝트를 재귀적으로 생성
- **샘플 맵**: 예제 맵/프리셋 포함(레포 내 Content 참고)

## Architecture (개념)

1) 던전 그리드/구조를 생성  
2) 구조 포인트를 기반으로 오브젝트 후보 포인트를 생성  
3) 가중치/빈도/제약조건(Clearance/Region)을 적용해 배치  
4) Depth 만큼 반복하며 부모-자식 오브젝트를 재귀 생성

## Getting Started

1. 플러그인을 프로젝트의 `Plugins/` 폴더에 배치합니다.
2. UE 에디터에서 `Edit → Plugins`에서 플러그인을 활성화합니다.
3. 필요 시 `PCG`, `PCGEx` 플러그인도 함께 Enable 합니다.
4. 샘플 맵/액터를 열어 데이터 에셋 파라미터를 조정하며 결과를 확인합니다.

> 실제 사용법/설정(파라미터 설명)은 추후 `docs/`로 분리해 더 상세히 보강할 예정입니다.

